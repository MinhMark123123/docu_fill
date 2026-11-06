"""Tells exports the user really checked from those exported as proposed.

The mapper learns from exported values on the assumption that the user confirmed
them. An export made without looking at the values only repeats the mapper's own
mistakes, and teaching those back makes the next case worse.
"""

# Share of the proposed values the user changed or cleared, below which an export
# counts as not reviewed. In the first 8 real exports this was 1.7% for the one
# exported unchecked, and 11% or more for all the others.
MIN_TOUCHED = 0.03
MIN_PREDICTED = 20  # with fewer proposals the share says nothing


def touched_share(predicted: dict[str, str], values: dict[str, str]) -> float:
    if not predicted:
        return 1.0
    changed = sum(
        1 for key, value in predicted.items()
        if (values.get(key) or "").split() != (value or "").split()
    )
    return changed / len(predicted)


# The user's "use for learning" choice in the app's export history, stored in
# caseStudyStatus: "good" always learns, "failed" never, anything else is decided
# from the share of values touched.
INCLUDE, EXCLUDE = "good", "failed"


def was_reviewed(predicted: dict[str, str], values: dict[str, str], choice: str = "none") -> bool:
    if choice == INCLUDE:
        return True
    if choice == EXCLUDE:
        return False
    return len(predicted) < MIN_PREDICTED or touched_share(predicted, values) >= MIN_TOUCHED


def is_reviewed(history: dict) -> bool:
    """For a record of export_histories.json."""
    predicted: dict[str, str] = {}
    for source in history.get("sources", []):
        predicted.update(source.get("predictedValues") or {})
    values = {
        k: e.get("value") or ""
        for group in ("fieldValues", "singleLineValues")
        for k, e in history.get(group, {}).items()
    }
    return was_reviewed(predicted, values, history.get("caseStudyStatus") or "none")
