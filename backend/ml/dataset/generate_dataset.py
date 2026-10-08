# Synthetic dataset for Courage Quest progress labels (Arabic classes)
import csv
import os
import random

MAX_Q = [3, 3, 2, 3, 3, 3, 2, 2]

HIGH = [3, 3, 2, 3, 3, 3, 2, 2]
MID = [2, 2, 1, 2, 2, 2, 1, 1]
LOW = [0, 1, 0, 1, 1, 1, 0, 0]


def _clamp_session(sess):
    out = []
    for i, v in enumerate(sess):
        out.append(max(0, min(MAX_Q[i], int(round(v)))))
    return out


def _add_noise(sess, rnd, spread=1):
    return _clamp_session([v + rnd.randint(-spread, spread) for v in sess])


def calc_distress(answers):
    return sum(answers) / 21.0 * 100.0


def get_overall_label(s1_answers, s2_answers, s3_answers):
    d1 = calc_distress(s1_answers)
    d2 = calc_distress(s2_answers)
    d3 = calc_distress(s3_answers)
    change = ((d1 - d2) + (d2 - d3)) / 2.0
    if change >= 8:
        return "تحسن"
    if change <= -8:
        return "تدهور"
    return "مستقر"


def get_category_label(s1_scores, s2_scores, s3_scores, max_score):
    d1 = s1_scores / max_score * 100.0
    d2 = s2_scores / max_score * 100.0
    d3 = s3_scores / max_score * 100.0
    change = ((d1 - d2) + (d2 - d3)) / 2.0
    if change >= 8:
        return "تحسن"
    if change <= -8:
        return "تدهور"
    return "مستقر"


def _scores(session, indices):
    return sum(session[i] for i in indices)


EM = [0, 1]
GR = [2, 3]
FE = [4, 5]
CO = [6, 7]
MAX_EM, MAX_GR, MAX_FE, MAX_CO = 6, 5, 6, 4


def row_labels(s1, s2, s3):
    overall = get_overall_label(s1, s2, s3)
    emotional = get_category_label(_scores(s1, EM), _scores(s2, EM), _scores(s3, EM), MAX_EM)
    growth = get_category_label(_scores(s1, GR), _scores(s2, GR), _scores(s3, GR), MAX_GR)
    fears = get_category_label(_scores(s1, FE), _scores(s2, FE), _scores(s3, FE), MAX_FE)
    coping = get_category_label(_scores(s1, CO), _scores(s2, CO), _scores(s3, CO), MAX_CO)
    return overall, emotional, growth, fears, coping


def sample_improving(rnd):
    s1 = _add_noise(HIGH, rnd, 1)
    s2 = _add_noise(MID, rnd, 1)
    s3 = _add_noise(LOW, rnd, 1)
    if rnd.random() < 0.12:
        s2 = [(s1[i] + s3[i]) // 2 for i in range(8)]
        s2 = _clamp_session(_add_noise(s2, rnd, 1))
    return s1, s2, s3


def sample_stable(rnd):
    base = _add_noise(MID, rnd, 1)
    s1 = _clamp_session([v + rnd.randint(-1, 1) for v in base])
    s2 = _clamp_session([v + rnd.randint(-1, 1) for v in base])
    s3 = _clamp_session([v + rnd.randint(-1, 1) for v in base])
    return s1, s2, s3


def sample_deteriorating(rnd):
    s1 = _add_noise(LOW, rnd, 1)
    s2 = _add_noise(MID, rnd, 1)
    s3 = _add_noise(HIGH, rnd, 1)
    if rnd.random() < 0.12:
        s2 = [(s1[i] + s3[i]) // 2 for i in range(8)]
        s2 = _clamp_session(_add_noise(s2, rnd, 1))
    return s1, s2, s3


def main():
    rnd = random.Random(42)
    n_total = 5500
    n_imp = int(n_total * 0.40)
    n_stab = int(n_total * 0.35)
    n_det = n_total - n_imp - n_stab
    rows = []
    for _ in range(n_imp):
        s1, s2, s3 = sample_improving(rnd)
        lbls = row_labels(s1, s2, s3)
        rows.append((*s1, *s2, *s3, *lbls))
    for _ in range(n_stab):
        s1, s2, s3 = sample_stable(rnd)
        lbls = row_labels(s1, s2, s3)
        rows.append((*s1, *s2, *s3, *lbls))
    for _ in range(n_det):
        s1, s2, s3 = sample_deteriorating(rnd)
        lbls = row_labels(s1, s2, s3)
        rows.append((*s1, *s2, *s3, *lbls))

    rnd.shuffle(rows)
    out_dir = os.path.dirname(os.path.abspath(__file__))
    path = os.path.join(out_dir, "courage_quest_dataset.csv")
    header = (
        ["q%d_s%d" % (qi, si) for si in range(1, 4) for qi in range(1, 9)]
        + ["overall_label", "emotional_label", "growth_label", "fears_label", "coping_label"]
    )
    with open(path, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(header)
        for r in rows:
            w.writerow(r)
    print("wrote", path, "rows", len(rows))


if __name__ == "__main__":
    main()
