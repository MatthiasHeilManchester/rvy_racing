import os
from dotenv import dotenv_values
from dataclasses import dataclass
from typing import List
from datetime import date
from pathlib import Path
from enums import IsoDow
from pytz import timezone as pytz_timezone
"""
All things configuration
(Complicated simple)
"""

# Load up our config
config = {
    **dotenv_values(".env"),         # The common stuff
    **dotenv_values(".sec.env"),     # Private keys
    **dotenv_values(".series.env"),  # Race series TODO: Maybe get .series.env file name from an environment variable
    **os.environ,  # Override loaded values with environment variables
}


#################################################
# ------------------ Constants ------------------
# Things that are used in different places
# but don't change (if they change) make them
# a config setting in .env
class Constants:
    REQUEST_RATE_LIMIT: float = 2.1     # Delay in seconds between requests to Rouvy
    REQUEST_RETRY_LIMIT: int = 3        # How many times will we retry
    REQUEST_RETRY_DELAY: float = 5.0    # Delay between retries (will expand with the retry count eg DELAY * RETRY)
#################################################


def int_list_from_str(s: str) -> List[int]:
    """
    Takes a string that is (**assumed** to be a comma seperated list of ints), and returns a list of integers.
    :param s: A comma seperated list of ints as a string
    :return: A typed list of ints
    """
    # TODO: Maybe add some exception handling (int parsing) to throw a slightly more nice exception
    s = s.strip()
    if s == '':
        return []
    l: List[int] = list()
    for i in s.split(','):
        l.append(int(i.strip()))
    return l


def str_list_from_str(s: str) -> List[str]:
    """
    Takes a string that is (**assumed** to be a comma seperated list of strings), and returns a list of strings.
    :param s: A comma seperated list of strings as a string
    :return: A typed list of strings
    """
    s = s.strip()
    if s == '':
        return []
    l: List[str] = list()
    for x in s.split(','):
        l.append(x.strip())
    return l


@dataclass
class RvySeries:
    include_dnr:            bool
    summer:                 bool
    length:                 int
    points:                 List[int]
    start_date:             date
    race_days:              List[IsoDow]
    name:                   str
    official_race_offsets:  List[int]
    official_race_timezone: pytz_timezone
    official_authors:       List[str]
    route_lap_list:         List[str]
    data_path:              Path
    series_path:            Path
    gen_html_path:          Path

    def __parse(self):
        self.start_date = date.fromisoformat(config.get('RVYSERIES_START_DATE'))
        self.race_days = list(map(lambda _x: IsoDow(_x), sorted(int_list_from_str(config.get('RVYSERIES_RACE_DAYS')))))
        self.summer = bool(int(config.get('RVYSERIES_SUMMER', 1)))
        self.include_dnr = bool(int(config.get('RVYSERIES_INCLUDE_DNR', 1)))
        self.name = config.get('RVYSERIES_NAME')
        self.official_authors = str_list_from_str(config.get('RVYSERIES_OFFICIAL_AUTHORS'))
        self.route_lap_list = str_list_from_str(config.get('RVYSERIES_ROUTES'))
        self.official_race_offsets = int_list_from_str(config.get('RVYSERIES_OFFICIAL_RACES'))
        self.official_race_timezone = pytz_timezone(config.get('RVYSERIES_OFFICIAL_RACES_TIMEZONE'))
        # TODO: self.route_lap_list - Add some validation that all (provided) @### values are ints
        if len(self.route_lap_list) == 0:  # Inject a token TBA race if we do not have any
            self.route_lap_list = ['TBA',]
        self.length = len(self.route_lap_list)

    def route(self, race_number: int) -> str:
        return (str(self.route_lap_list[race_number]) + '@1').split('@')[0]

    def lap_count(self, race_number: int) -> int:
        # YOLO: int parsing
        return int((str(self.route_lap_list[race_number]) + '@1').split('@')[1])

    def __paths(self):
        data_path: str = config["DATA_DIR"]
        series_path: str = config["RVYSERIES_DATA_DIR"]
        html_path: str = config['RVYSERIES_HTML_DIR']
        self.data_path = Path('..', data_path)
        self.series_path = Path(self.data_path, series_path)
        self.gen_html_path = Path('..', html_path, 'generated')
        # check / make paths as required
        if not Path.exists(self.data_path):
            Path.mkdir(self.data_path)
        if not Path.exists(self.series_path):
            Path.mkdir(self.series_path)
        if not Path.exists(self.gen_html_path):
            Path.mkdir(self.gen_html_path)

    def __init__(self):
        self.__parse()
        self.__paths()

        p_list = int_list_from_str(config.get('RVYSERIES_POINTS', ''))
        if len(p_list) > 0:
            self.points = p_list
        else:
            self.points = ([40, 30, 25] + list(range(20, -1, -1)))


@dataclass
class Rouvy:
    email:     str = config.get('ROUVY_EMAIL')
    password:  str = config.get('ROUVY_PASSWORD')


@dataclass
class RaceFinder:
    search_back_days:    int = int(config.get('SEARCH_BACK_DAYS', 0)) * -1
    search_froward_days: int = int(config.get('SEARCH_FROWARD_DAYS', 0))
    allow_plus_n_hours:  int = int(config.get('ALLOW_PLUS_N_HOURS', 0))


@dataclass
class Config:
    __instance = None
    rouvy: Rouvy = Rouvy()
    race_finder: RaceFinder = RaceFinder()
    series: RvySeries = RvySeries()

    def __new__(cls):
        if cls.__instance is None:
            # load_dotenv()
            cls.__instance = super(Config, cls).__new__(cls)
        return cls.__instance


if __name__ == '__main__':
    pass
