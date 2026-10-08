# User row helpers
import json


def row_to_user_dict(row):
    if row is None:
        return None
    d = dict(row)
    try:
        d["compulsive_behaviors"] = json.loads(d.get("compulsive_behaviors") or "[]")
    except json.JSONDecodeError:
        d["compulsive_behaviors"] = []
    try:
        d["unlocked_items"] = json.loads(d.get("unlocked_items") or "[]")
    except json.JSONDecodeError:
        d["unlocked_items"] = []
    return d
