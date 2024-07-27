from config import Config
from datetime import datetime, timedelta
from collector_json import get_event_info
from common import get_authenticated_session, json_date_to_datetime
from enums import RouvyEventType, RouvyEventOrganizer, RouvyEventStatus
"""
That magic that finds rvy events for rvy races
"""


def find_events(race_date: datetime, route_id: str, laps: int, finished: bool) -> list:
    """
    Get a list of events in datetime order that match the provided values
    :param race_date: UTC Day of the race
    :param route_id: The route id  for the race
    :param laps: The number of laps
    :param finished: Search finished or planned events
    :return: A list of events in datetime order
    """
    session = get_authenticated_session()
    # TODO: There is a bug where Rouvy forgot to include the restrictions eg "Smart Trainers Only"
    #       This messes up the website too, when they fix that we should include an additional check check for:
    # 	    "event": {"restrictions": ["smartTrainers"]}
    # 	    This may also require a deeper check specifically into the event, "restrictions" is not present via search
    #       It is via the event, but it is always an empty list regardless of any restrictions
    events: list = list()
    # search prams
    offset: int = 0  # pagination
    index: str = ""  # IDK what this if for
    date_from: str = (race_date + timedelta(days=Config.race_finder.search_back_days)).strftime("%Y-%m-%d")
    date_to:   str = (race_date + timedelta(days=Config.race_finder.search_froward_days)).strftime("%Y-%m-%d")
    event_type = RouvyEventType.RACE
    organizer = RouvyEventOrganizer.ALL
    status = RouvyEventStatus.UNFINISHED  # Sadly you can't search for all
    if finished:
        status = RouvyEventStatus.FINISHED
    print(f'[-] Searching {str(status.value).capitalize()}', end='')
    while True:
        print(f'.', end='')
        result = session.get(f"https://riders.rouvy.com/events?status={status.value}&"
                             f"from={date_from}&to={date_to}&eventType={event_type.value}&organizer={organizer.value}&"
                             f"index={index}&offset={offset}&_data=routes/_main.events._index")
        j: dict = result.json()
        result_count: int = len(j["events"])
        if result_count == 0:
            break  # Stop if we don't have any more results to search through
        offset += result_count
        for event in j["events"]:
            print(f'.', end='')
            event_start: datetime = json_date_to_datetime(event['startDateTime'])
            # Extra part day filtering
            extra_hours: int = Config.race_finder.allow_plus_n_hours
            if event_start < race_date or event_start > (race_date + timedelta(days=1, hours=extra_hours)):
                continue  # Skip events outside the allowed time window
            if event["event"]["type"] != 'RACE':
                continue  # Skip event that are not a RACE, the search fiter above should only get us races anyhow
            if event["event"]["route"]["id"] != route_id:
                continue  # Skip events that are not on the Route for the Race
            if event["event"]["laps"] != laps:
                continue  # Skip events that do not have the correct number of laps
            print(f'\n[-] Found: {event["event"]["title"]}')
            print(f'[-] Searching {str(status.value).capitalize()}', end='')
            event_info: dict = get_event_info(event['id'])
            # TODO: Remove this when Rouvy fix their shit
            if len(event_info['restrictions']) > 0:
                print(f'{"x" * 40}\n{"x" * 40}')
                print(f'Event restrictions found {event_info["restrictions"]}, Rouvy fixed something')
                print(f'{"x" * 40}\n{"x" * 40}')
            # TODO: When Rouvy fix their issue this should (a total guess) work
            # if 'smartTrainers' not in event_info['restrictions']:
            #     continue  # The event does not have the smart trainers restriction
            events.append(event_info)
    print('')
    return sorted(events, key=lambda d: d['startDateTime'])


if __name__ == '__main__':
    pass
