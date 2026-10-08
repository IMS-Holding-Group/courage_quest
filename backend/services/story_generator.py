# Story text generation on the server using local templates (no external AI API)
import random

PAGE_DELIMITER = "[NEW_PAGE]"
NAMES_MALE = ["Yusuf", "Leo", "Omar", "Ethan", "Ziad", "Noah", "Faris", "Sam"]
NAMES_FEMALE = ["Noor", "Raya", "Lina", "Sara", "Dana", "Hana", "Rana", "Jude"]
SETTINGS = ["school", "home", "the playground", "the corner store", "the park", "the library", "the beach"]
MENTORS = ["Mom", "Dad", "a teacher", "Grandma", "a friend", "Grandpa", "an aunt"]
PAGE_IMAGE_KEYS = ["panda.png", "panda2.png", "Archie_with_wand.png", "Archie_with_bow.png", "Archie_with_crown.png"]

_LEGACY_ANXIETY = {"خفيف": "light", "معتدل": "moderate", "عالٍ": "high", "Mild": "light", "Moderate": "moderate", "High": "high"}
_LEGACY_BEHAVIOR = {
    "غسيل اليدين / التنظيف": "hand washing / cleaning",
    "تكرار العبارات": "repeating phrases",
    "طلب التطمين المتكرر": "asking for reassurance often",
    "تجنب الأماكن/الأشخاص": "avoiding places or people",
    "فحص الأشياء بشكل متكرر": "checking things over and over",
    "ترتيب الأشياء": "arranging things until they feel 'just right'",
}


def generate_story(user_data):
    gender = random.choice(["male", "female"])
    names = NAMES_MALE if gender == "male" else NAMES_FEMALE
    char_name = random.choice(names)
    setting = random.choice(SETTINGS)
    mentor = random.choice(MENTORS)
    behaviors = user_data.get("compulsive_behaviors") or []
    behaviors_str = _format_behaviors(behaviors)
    ocd = str(user_data.get("ocd_type", ""))
    story_text = _local_multi_page_story(
        char_name, setting, mentor, user_data, behaviors_str, ocd
    )
    pages = [p.strip() for p in story_text.split(PAGE_DELIMITER) if p.strip()]
    if len(pages) < 2:
        pages = _fallback_pages(char_name, setting, mentor)
    story_pages = []
    images = []
    for i, page_text in enumerate(pages):
        key = PAGE_IMAGE_KEYS[i % len(PAGE_IMAGE_KEYS)]
        story_pages.append({"text": page_text, "image": key})
        images.append(key)
    return {
        "story_pages": story_pages,
        "character_name": char_name,
        "setting": setting,
        "mentor": mentor,
        "images": images,
    }


def _anxiety_tone(user_data):
    raw = user_data.get("anxiety_level", "Moderate")
    return _LEGACY_ANXIETY.get(str(raw).strip(), str(raw).strip().lower() or "moderate")


def _format_behaviors(behaviors):
    if not behaviors:
        return "none noted"
    parts = []
    for b in behaviors:
        s = str(b).strip()
        parts.append(_LEGACY_BEHAVIOR.get(s, s))
    return ", ".join(parts)


def _local_multi_page_story(char_name, setting, mentor, user_data, behaviors_str, ocd):
    age = str(user_data.get("age", 8))
    tone = _anxiety_tone(user_data)
    p1 = (
        "At "
        + setting
        + ", "
        + char_name
        + " woke up, "
        + age
        + " years old and ready to explore. Each morning they practiced a small calm breath with "
        + mentor
        + ".\n"
        "One day a thought looped in their mind—something like what they knew about OCD: "
        + ocd
        + ". Some things felt extra tricky, like: "
        + behaviors_str
        + ". They told themselves gently: “I’m not alone in this, and I can learn one small step at a time.”"
    )
    p2 = (
        mentor
        + " sat with "
        + char_name
        + " and explained a “tiny step”: moving toward a feeling a little without getting stuck in a tiring loop.\n"
        "They made a short plan: notice the thought without fighting a battle in their head, then go back to play or reading."
        + " That’s a bit like gradual exposure—staying safe while still choosing courage."
    )
    p3 = (
        "A tough moment arrived: worry crept up, especially since the day’s mood felt "
        + tone
        + " in the story. But "
        + char_name
        + " slowed their breathing and remembered feelings can pass like clouds.\n"
        + mentor
        + " aimed for ‘try’ instead of ‘perfect’—a big difference in a kid-sized world."
    )
    p4 = (
        "The hero practiced something new: they stayed in a tricky spot a few seconds longer than usual "
        "without asking for reassurance over and over, then shifted to something they enjoyed to break the loop.\n"
        "Something shifted a little for the better—worry didn’t vanish, but worry stopped being the only thing ending the day."
    )
    p5 = (
        "That evening "
        + char_name
        + " looked back with "
        + mentor
        + ": what felt brave today? Which step might you try tomorrow?\n"
        "They smiled together—because courage here doesn’t mean zero fear; it means walking anyway with fear at your side."
    )
    return PAGE_DELIMITER.join([p1, p2, p3, p4, p5])


def _fallback_pages(char_name, setting, mentor):
    return [
        "On a bright morning, "
        + char_name
        + " got ready for a new day at "
        + setting
        + ". Their heart tapped with a spark of bravery.",
        "A fuzzy worry appeared, but "
        + mentor
        + " stepped in softly: together we’ll take one steady little step.",
        char_name + " remembered they could breathe slowly, and feelings drift like clouds.",
        "In the end, "
        + char_name
        + " smiled with pride—they learned bravery grows bit by bit every day.",
    ]
