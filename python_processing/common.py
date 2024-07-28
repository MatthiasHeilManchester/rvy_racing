import requests
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


if __name__ == '__main__':
    pass
