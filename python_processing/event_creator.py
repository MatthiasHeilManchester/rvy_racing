import requests
from typing import Optional
from datetime import datetime
import common

# TODO: Rework this
# def __gen_official_race_schedule():
#     # TODO: Change to use RVYSERIES_OFFICIAL_RACES_TIMEZONE
#     # Official race schedule, offset hours from 00:00 UTC
#     o_str = config.get('RVYSERIES_OFFICIAL_RACES')
#     o_tz = config.get('RVYSERIES_OFFICIAL_RACE_TIMEZONE')
#     race_offsets: List[int] = list()
#     for x in o_str.split(','):
#         race_offsets.append(int(x.strip()))
#
#     race_number: int = 1
#     official_races: List[OfficialRace] = list()
#     for offset in race_offsets:
#         official_races.append(OfficialRace(race_number,
#                                            f'Official race {race_number} : {offset % 24:02}:00:00 (GMT)',
#                                            timedelta(hours=offset)))
#         race_number += 1
#     self.official_races = official_races

# Does not belong in here
# def generate_events(race_number: int) -> list:
#     series = json.load(open(Path(Config.series.series_path, 'races.json')))
#     race = series[race_number-1]
#     event_file = Path(race['path'], 'events.json')
#     print(json.dumps(race, ensure_ascii=False))
#     event_list: list = []
#     i: int = 0
#     for r in Config.series.official_races:
#         i += 1
#         event = {
#             'number': i,
#             'datetime': (datetime.combine(date.fromisoformat(race['date']), time(0), timezone.utc)
#                          + r.time_offset).isoformat(),
#             'name': r.name
#         }
#         event_list.append(event)
#     return event_list

def create_race(route_id: int, race_date: datetime, race_name: str, session: Optional[requests.Session] = None) -> bool:
    # you should pass in a session if you are going to do more than 1 call
    if session is None:
        session = common.get_authenticated_session()
    """
    Rough guess on what it will accept
    routeId: number
    title: string
    lapsCount: number().gte(1).nullish()
    disableDrafting: boolean().optional()
    smartTrainersOnly: boolean().optional()
    isMultilap: boolean().optional()
    type: enum(["RACE", "GROUP_RIDE"])
    dateTimeLocal: coerce.date() eg '2024-07-07T11:12'
    dateTimeOffset: number() in minutes, just use 0 for utc
    accessibility: enum(["PUBLIC", "PRIVATE"])
    """

    payload = {
        'routeId': route_id,
        'title': race_name,
        'type': 'RACE',
        'dateTimeLocal': race_date.strftime('%Y-%m%dT%H:%M'),
        'dateTimeOffset': 0,
        'smartTrainersOnly': 'on',
        'accessibility': 'PUBLIC'
    }

    pg = session.post('https://riders.rouvy.com/events/setup', payload)
    if pg.status_code == 200:
        print("[*] Race create success")
        # TODO: see if the race_id or anything useful is returned
        return True
    else:
        print(f"[X] Race create Fail :( error: {pg.status_code}")
        return False


if __name__ == '__main__':
    print('call this from another script')
    # Let's not create a load of test races...
    # create_race(route_id=95369, race_date=datetime.now()+timedelta(hours=2), race_name='race')
