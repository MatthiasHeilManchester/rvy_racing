import sh
import requests
from pathlib import Path
from config import Config
from typing import Optional
from datetime import datetime
from requests import Session, Response
__session: Optional[requests.Session] = None
"""
Common things
"""


def get_authenticated_session() -> Session:
    """
    Logs into rouvy and returns an authenticated session we can use for requests
    :return: An authenticated Session
    """
    # Reuse the session we have or create a new one
    global __session
    if __session is not None:
        return __session
    session = Session()
    payload = {'email': Config.rouvy.email,
               'password': Config.rouvy.password}
    try:
        response: Response = session.post("https://riders.rouvy.com/login", payload)
    except requests.exceptions.ConnectionError:
        print("[X] Connection error, no internet?")
        exit(1)
    if response.status_code == 200:
        # print("[*] Login Success")
        # Force our session to GMT / UTC
        session.cookies.set("CH-time-zone", "Greenwich", domain="riders.rouvy.com")
        __session = session  # let's keep the same sessions going...
        return session
    else:
        print(f"[X] Login Fail :( error: {response.status_code}")
        exit(1)


def json_date_to_datetime(json_date: str) -> datetime:
    """
    Converts a JSON date string to a datetime object.
    :param json_date: JSON date string.
    :return: datetime object.
    """
    dt: datetime = datetime.strptime(json_date, '%Y-%m-%dT%H:%M:%S.%fZ')
    return dt


def backup_series() -> int:
    """
    Backup series with tar lzma (about 3 times smaller than gz)
    zero exception handling, they will bubble up
    :return: The tar return code
    """
    ts: str = datetime.now().strftime('%Y-%m-%d_%H%M%S')
    backup_path = Path(Config.series.data_path, 'Backup')
    backup_path.mkdir(exist_ok=True)
    series_folder: str = Config.series.series_path.name
    backup_name: str = Path(backup_path, f'{series_folder}_{ts}.tar.gz').as_posix()
    series_path: str = Config.series.series_path.as_posix()
    result = sh.tar(('cvfz', backup_name, series_path), _return_cmd=True)
    return result.exit_code


if __name__ == '__main__':
    pass
