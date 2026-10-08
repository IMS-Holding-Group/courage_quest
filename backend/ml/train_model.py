# Train RandomForest multi-label ensemble; save dict of 5 estimators + StandardScaler
import os

import joblib
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

ML_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_PATH = os.path.join(ML_DIR, "dataset", "courage_quest_dataset.csv")
MODEL_DIR = os.path.join(ML_DIR, "model")

FEATURE_COLS = [
    "q1_s1",
    "q2_s1",
    "q3_s1",
    "q4_s1",
    "q5_s1",
    "q6_s1",
    "q7_s1",
    "q8_s1",
    "q1_s2",
    "q2_s2",
    "q3_s2",
    "q4_s2",
    "q5_s2",
    "q6_s2",
    "q7_s2",
    "q8_s2",
    "q1_s3",
    "q2_s3",
    "q3_s3",
    "q4_s3",
    "q5_s3",
    "q6_s3",
    "q7_s3",
    "q8_s3",
]

LABEL_COLS = ["overall_label", "emotional_label", "growth_label", "fears_label", "coping_label"]

MIN_ACC = 0.80


def main():
    df = pd.read_csv(DATA_PATH)
    X = df[FEATURE_COLS].values

    ys = [df[col].values for col in LABEL_COLS]
    splits = train_test_split(X, *ys, test_size=0.2, random_state=42, stratify=ys[0])
    X_train = splits[0]
    X_test = splits[1]
    label_splits = list(zip(splits[2::2], splits[3::2]))

    scaler = StandardScaler()
    X_train_s = scaler.fit_transform(X_train)
    X_test_s = scaler.transform(X_test)

    os.makedirs(MODEL_DIR, exist_ok=True)
    models = {}
    for i, col in enumerate(LABEL_COLS):
        y_train, y_test = label_splits[i]
        clf = RandomForestClassifier(
            n_estimators=200,
            max_depth=12,
            random_state=42,
            class_weight="balanced_subsample",
        )
        clf.fit(X_train_s, y_train)
        y_pred = clf.predict(X_test_s)
        acc = accuracy_score(y_test, y_pred)
        print("\n--- %s ---" % col)
        print("Accuracy: %.2f%%" % (acc * 100.0))
        print(classification_report(y_test, y_pred, zero_division=0))
        if acc < MIN_ACC:
            raise SystemExit(
                "%s accuracy %.4f below %.2f; regenerate dataset or tune params." % (col, acc, MIN_ACC)
            )
        models[col] = clf

    joblib.dump(models, os.path.join(MODEL_DIR, "progress_model.pkl"))
    joblib.dump(scaler, os.path.join(MODEL_DIR, "scaler.pkl"))
    print("\nSaved model/", "progress_model.pkl", "and scaler.pkl under", MODEL_DIR)


if __name__ == "__main__":
    main()
