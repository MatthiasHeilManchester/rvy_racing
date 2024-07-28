## Requirements / Setup
Python 3.8+
(Has only been tested against 3.8)

A virtual environment is recommended
https://packaging.python.org/en/latest/guides/installing-using-pip-and-virtual-environments/

#### python requirements
Just use `pip install -r ./requirements.txt` or manually...
```bash
pip install Jinja2         # Templates
pip install requests       # https requests
pip install python-dotenv  # config
pip install pytz           # timezone handling
pip install beautifulsoup4 # If we need to do HTML parsing, legacy results etc
```

## Nomenclature

This is just to make code consistent / less confusing. I had used Race and Event
interchangeably during development and it got messy

| Term   | Meaning, in the context of this project's code               |
|--------|--------------------------------------------------------------|
| Event  | A singular race event                                        |
| Race   | A Race that is part of a series, a race can have many Events |
| Series | A collection of Races that form a Series aka Season          |

## TODO
Add some more doco
