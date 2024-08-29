from pprint import pp
from config import Config
from datetime import datetime, timedelta
from collector_json import get_event_info
from common import json_date_to_datetime, nice_request
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
        url = (f"https://riders.rouvy.com/events?status={status.value}&"
               f"from={date_from}&to={date_to}&eventType={event_type.value}&organizer={organizer.value}&"
               f"index={index}&offset={offset}&_data=routes/_main.events._index")
        result = nice_request(url=url)
        j: dict = result.json()
        if 'events' not in j:
            # This will not be the best way to handel this but until we get more info IDK hot to recover from the issue
            # the rate limiting sleep may help
            print(f'{"X"*40}\n{"X"*40}\nSomething unexpected happened:\n{pp(vars(result))}\n{"X"*40}\n{"X"*40}')
            exit(1)
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
            event_info: dict = get_event_info(event['id'])
            smart_trainers_only = event_info.get("smartTrainersOnly", None)
            if smart_trainers_only is not None:
                if smart_trainers_only is False:
                    print('[X] Rejected: Smart Trainer status = False')
                    continue  # We only do smart trainers
            else:
                print('[?] Unknown Smart Trainer status')
            print(f'[-] Searching {str(status.value).capitalize()}', end='')
            events.append(event_info)
    print('')
    return sorted(events, key=lambda d: d['startDateTime'])


if __name__ == '__main__':
    pass
