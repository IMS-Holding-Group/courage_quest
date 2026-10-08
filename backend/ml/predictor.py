# Load sklearn RandomForest ensemble and predict 5 category labels from 3 sessions of 8 answers (mapped to English in report_routes)
import os

import joblib
import numpy as np

_ML_ROOT = os.path.dirname(os.path.abspath(__file__))
_models = None
_scaler = None


def _load():
    global _models, _scaler
    if _models is None:
        mp = os.path.join(_ML_ROOT, "model", "progress_model.pkl")
        sp = os.path.join(_ML_ROOT, "model", "scaler.pkl")
        _models = joblib.load(mp)
        _scaler = joblib.load(sp)


def predict_progress(sessions):
    # sessions: 3 lists, each length 8, ordered oldest to newest chronologically

    _load()
    feats = []
    for session in sessions:
        feats.extend(session)
    X = np.asarray(feats, dtype=float).reshape(1, -1)
    Xs = _scaler.transform(X)
    label_map = {
        "overall_label": "bravery_progress",
        "emotional_label": "emotional_wellbeing",
        "growth_label": "growth_mindset",
        "fears_label": "facing_fears",
        "coping_label": "coping_skills",
    }
    results = {}
    for model_key, result_key in label_map.items():
        results[result_key] = str(_models[model_key].predict(Xs)[0])
    return results
