from enum import IntEnum, Enum
import enum
"""
A place to stor all the enums for the project
"""


@enum.unique
class IsoDow(IntEnum):
    MONDAY = 1
    TUESDAY = 2
    WEDNESDAY = 3
    THURSDAY = 4
    FRIDAY = 5
    SATURDAY = 6
    SUNDAY = 7
    ALL = 8

    def __format__(self, spec):
        return f'{self._name_.capitalize()}'


@enum.unique
class RouvyEventType(Enum):
    RACE = 'RACE'
    GROUP_RIDE = 'GROUP_RIDE'


@enum.unique
class RouvyEventOrganizer(Enum):
    ALL = 'all'
    OFFICIAL = 'official'
    UNOFFICIAL = 'unofficial'


@enum.unique
class RouvyEventStatus(Enum):
    FINISHED = 'FINISHED'
    UNFINISHED = 'UNFINISHED'
