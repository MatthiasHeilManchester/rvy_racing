from time import sleep
from pathlib import Path
from config import Config
from csv import DictReader
from requests import Session, Response
from common import get_authenticated_session
"""
Here we collect json data from Rouvy, and return it for additional processing
"""


def get_challenges() -> list:
    """
    Collect current and planned challenges from Rouvy.
    :return: A list of challenges.
    """
    session: Session = get_authenticated_session()
    challenge_types: list = ['actual', 'planned']
    challenge_list: list = list()
    for challenge_type in challenge_types:
        result: Response = session.get(f"https://riders.rouvy.com/challenges/status/{challenge_type}"
                                       f"?_data=routes/_main.challenges.status.$status")
        if result.status_code == 200:
            pass
            # print("[*] Get challenges OK")
        else:
            print(f"[X] Error {result.status_code} getting challenges")
            exit(1)  # Let's just fail out
        c_data: dict = result.json()
        # Remove unneeded bloat
        c_data.pop('latestSpotlight', None)
        c_data.pop('pageMeta', None)
        c_data.pop('page', None)
        challenge_list += c_data['challenges']
    return challenge_list


def route_challenge_dict(challenges: list) -> dict:
    """
    Creates a dictionary keyed by route_id for current challenges.
    :param challenges: Challenges to convert into a dictionary.
    :return: A dictionary keyed by route_id for current challenges.
    """
    route_challenge: dict = dict()
    challenge: dict
    for challenge in challenges:
        segment: dict
        for segment in challenge['segments']:
            if segment['value'] is None:  # Rouvy have some grayness in the type of challenge
                route_challenge[str(segment['target'])] = challenge['challenge']
    return route_challenge


def get_event_info(event_id: str) -> dict:
    """
    Collect information about a specific event from Rouvy.
    :param event_id: The ID of the event.
    :return: Event information.
    """
    session: Session = get_authenticated_session()
    result: Response = session.get(f"https://riders.rouvy.com/events/{event_id}"
                                   f"?_data=routes/_main.events_.$id")
    if result.status_code == 200:
        pass
        # print("[*] Event exists")
    else:
        print(f"[X] Error {result.status_code} getting event information")
        exit(1)
    race_info: dict = result.json()
    # Remove unneeded bloat
    race_info.pop('pageMeta', None)
    race_info.get('event', dict()).pop('legacyRoute', None)  # Hope we never need this
    race_info.get('event', dict()).get('route', dict()).pop('geometry', None)
    race_info.get('event', dict()).get('route', dict()).pop('thumbnails', None)
    race_info.get('event', dict()).get('route', dict()).pop('videoPreview', None)
    return race_info['event']


def get_event_results(event_id: str) -> dict:
    """
    Collect results leaderboard for a specific event from Rouvy.
    :param event_id: The ID of the event.
    :return: A results leaderboard dictionary.
    """
    session: Session = get_authenticated_session()
    result: Response = session.get(f"https://riders.rouvy.com/events/{event_id}/leaderboard"
                                   f"?_data=routes/_main.events_.$id.leaderboard")
    if result.status_code == 200:
        pass
        # print("[*] Results found")
    else:
        print(f"[X] Error {result.status_code} getting results for event {event_id}")
        exit(1)
    return result.json()


def get_rouvy_user(username: str) -> dict:
    """
    Collect information about a specific user from Rouvy.
    :param username: Rouvy username.
    :return: User information.
    """
    session: Session = get_authenticated_session()
    result: Response = session.get(f"https://riders.rouvy.com/friends/search?query={username}"
                                   f"&_data=routes/_main.friends_.search")
    sleep(2.1)  # rate limit the requests to Rouvy
    if result.status_code == 200:
        pass
        # print("[*] User exists")
    else:
        print(f"[X] Error {result.status_code} getting user: {username}")
        exit(1)
    user: dict
    for user in result.json()['searchUser']:
        if str(user['username']) == username:
            return user
    return {'error': 'Rouvy user not found'}


def convert_user_data_to_json() -> dict:
    """
    Converts the legacy user_data.csv into dict / JSON format also collects and includes Rouvy user information.
    ** WARNING ** this is expensive requests wise, and should only be done when required.
    :return: User information as a dict.
    """
    user_data_dict: dict = dict()
    user_data_file: Path = Path(Config.series.data_path, 'user_data.csv')
    if not user_data_file.exists():
        print(f"[X] Expecting 'user_data.csv' to be in the base data directory: {str(Config.series.data_path)}")
        exit(1)
    with user_data_file.open('r', encoding='utf-8') as _f:
        # TODO: Maybe don't YOLO shit like this, anyhow YOLO.
        # YOLO: Totally presume for this csv that columns are always the same and in the same order.
        reader = DictReader(_f, fieldnames=["rvy_username", "rvy_rouvy_name", "rvy_fname", "rvy_sname",
                                            "rvy_strava_url", "rvy_yob", "rvy_gender", "rvy_allow", "extra"])
        next(reader)  # skip header
        user_row: dict
        print('[-] Collecting Rouvy user information', end='')
        for user_row in reader:
            print('.', end='')
            # Remove extra empty column
            user_row.pop('extra', None)
            # Replace data if not allowed, it just makes the logic easy later on
            # TODO: Consider populating with Rouvy data, this will be what the user has set as their public profile
            # TODO: YOB? Why not categories? Elite, Master, Super Master, 60+ or just 10y Age brackets 40-49, 50-59
            if user_row['rvy_allow'] != 'Allow':
                user_row['rvy_fname'] = '--'
                user_row['rvy_sname'] = '--'
                user_row['rvy_yob'] = '--'
                user_row['rvy_gender'] = '--'
            # Add in Rouvy user info if we can find it.
            # TODO: If we can not find the user, maybe retire this rvy user
            user_row['rouvy'] = get_rouvy_user(user_row['rvy_rouvy_name'])
            user_data_dict[user_row['rvy_rouvy_name']] = user_row
        print(' Done')
    return user_data_dict


def get_route_info(route_id: str) -> dict:
    """
    Collect information about a specific route from Rouvy.
    :param route_id: The ID of the route.
    :return: Route information.
    """
    session: Session = get_authenticated_session()
    result: Response = session.get(f'https://riders.rouvy.com/route/{route_id}'
                                   f'?_data=routes%2F_main.route.$id._index')
    if result.status_code == 200:
        pass
        # print("[*] Route exists")
    else:
        print(f"[X] Error {result.status_code} getting route information")
        exit(1)
    route_info: dict = result.json()
    # Remove unneeded bloat
    route_info.pop('legacyRoute', None)  # Hope we never need this
    # Let's keep geometry, you can do some cool things with it.
    # From simple altitude plots to 3d course plots
    # route_info.get('route', dict()).pop('geometry', None)
    route_info.get('route', dict()).pop('thumbnails', None)
    route_info.get('route', dict()).pop('videoPreview', None)
    route_info.get('route', dict()).pop('videoQualities', None)
    route_info.get('route', dict()).pop('splits', None)
    return route_info


if __name__ == '__main__':
    pass
