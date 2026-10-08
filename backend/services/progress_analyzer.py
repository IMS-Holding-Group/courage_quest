# Progress scoring and category analysis

MAX_SCORES = {
    "emotional_wellbeing": 6,
    "growth_mindset": 5,
    "facing_fears": 6,
    "coping_skills": 4,
    "total": 21,
}


def calculate_distress_index(answers):
    total = sum(answers)
    distress_index = (total / 21.0) * 100.0
    return round(distress_index, 2)


def calculate_improvement(sessions):
    if len(sessions) < 2:
        return None
    latest = sessions[-1]["distress_index"]
    previous = sessions[-2]["distress_index"]
    improvement_rate = previous - latest
    if improvement_rate >= 8:
        status = "improving"
    elif improvement_rate <= -8:
        status = "worsening"
    else:
        status = "stable"
    return {"rate": improvement_rate, "status": status}


def analyze_categories(sessions):
    results = {}
    categories = {
        "emotional_wellbeing": [0, 1],
        "growth_mindset": [2, 3],
        "facing_fears": [4, 5],
        "coping_skills": [6, 7],
    }
    for category, indices in categories.items():
        category_scores = []
        for session in sessions:
            answers = session["answers"]
            score = sum(answers[i] for i in indices)
            category_scores.append(score)
        if len(category_scores) >= 2:
            change = category_scores[-2] - category_scores[-1]
            if change >= 1:
                status = "improving"
            elif change <= -1:
                status = "worsening"
            else:
                status = "stable"
        else:
            status = "insufficient data"
        results[category] = status
    return results
