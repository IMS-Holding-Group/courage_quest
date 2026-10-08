# Session row helpers
import json


def row_to_session_dict(row):
    if row is None:
        return None
    d = dict(row)
    try:
        d["answers"] = json.loads(d["answers"])
    except (json.JSONDecodeError, KeyError):
        d["answers"] = []
    return d
