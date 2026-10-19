"""
Assessment Engine - Python Serverless Implementation
Mirroring the explainable, evidence-based food evaluation rules.
"""

from typing import Dict, Any, List

def evaluate_food(profile: Dict[str, Any], nutrition: Dict[str, Any], ingredients_text: str = "", allergen_text: str = "") -> Dict[str, Any]:
    reasons: List[Dict[str, Any]] = []
    positive_highlights: List[str] = []
    uncertainty_notes: List[str] = []

    combined_text = f"{ingredients_text or ''} {allergen_text or ''}".lower()

    has_allergen_conflict = False
    has_dietary_conflict = False
    has_goal_conflict = False

    # 1. Allergen Check
    allergies = profile.get("allergiesAndIntolerances", [])
    if allergies:
        if not combined_text.strip():
            uncertainty_notes.append(
                "Ingredients and allergen statements were not detected. Verify physical label if you have severe allergies."
            )
        else:
            allergy_keywords_map = {
                "peanut": ["peanut", "peanuts", "arachis"],
                "dairy": ["milk", "dairy", "whey", "casein", "butter", "cheese", "cream", "lactose"],
                "milk": ["milk", "dairy", "whey", "casein", "butter", "cheese", "cream", "lactose"],
                "gluten": ["gluten", "wheat", "barley", "rye", "malt", "spelt"],
                "wheat": ["gluten", "wheat", "barley", "rye", "malt", "spelt"],
                "soy": ["soy", "soya", "soybean", "lecithin"],
                "egg": ["egg", "eggs", "albumin", "egg white", "egg yolk"],
                "tree nut": ["almond", "cashew", "walnut", "pistachio", "hazelnut", "pecan"],
                "fish": ["fish", "cod", "salmon", "tuna", "anchovy"],
                "shellfish": ["shellfish", "shrimp", "prawn", "crab", "lobster", "clam"],
            }
            for allergy in allergies:
                lower_a = allergy.lower()
                keywords = [lower_a]
                for key, kw_list in allergy_keywords_map.items():
                    if key in lower_a:
                        keywords = kw_list
                        break
                
                for kw in keywords:
                    if kw in combined_text:
                        has_allergen_conflict = True
                        reasons.append({
                            "title": f"Allergen Alert: {allergy}",
                            "detail": f'Packaging text contains "{kw}", matching your declared allergy to {allergy}.',
                            "matchedField": f"Allergen: {allergy}",
                            "isWarning": True,
                            "isPositive": False
                        })
                        break

    # 2. Dietary Preferences (Vegetarian / Vegan)
    prefs = profile.get("dietaryPreferences", [])
    if prefs and combined_text.strip():
        for pref in prefs:
            p_lower = pref.lower()
            if "vegetarian" in p_lower:
                non_veg = ["gelatin", "gelatine", "rennet", "carmine", "cochineal", "lard", "tallow", "chicken", "beef", "pork", "fish", "shellfish"]
                for item in non_veg:
                    if item in combined_text:
                        has_dietary_conflict = True
                        reasons.append({
                            "title": "Dietary Mismatch: Vegetarian",
                            "detail": f'Contains non-vegetarian ingredient "{item}".',
                            "matchedField": "Dietary Preference: Vegetarian",
                            "isWarning": True,
                            "isPositive": False
                        })
                        break
            elif "vegan" in p_lower:
                non_vegan = ["milk", "butter", "cheese", "whey", "casein", "egg", "eggs", "honey", "gelatin", "cream"]
                for item in non_vegan:
                    if item in combined_text:
                        has_dietary_conflict = True
                        reasons.append({
                            "title": "Dietary Mismatch: Vegan",
                            "detail": f'Contains animal-derived ingredient "{item}".',
                            "matchedField": "Dietary Preference: Vegan",
                            "isWarning": True,
                            "isPositive": False
                        })
                        break

    # 3. Health Goals
    goals = profile.get("goals", [])
    if not nutrition:
        uncertainty_notes.append("Nutrition facts table was unavailable; cannot verify goal thresholds.")
    else:
        for goal in goals:
            g_lower = goal.lower()
            if "sugar" in g_lower:
                sugar = nutrition.get("sugar")
                if sugar is not None:
                    if sugar > 10.0:
                        has_goal_conflict = True
                        reasons.append({
                            "title": "High Sugar Content",
                            "detail": f"Contains {sugar}g sugar per serving (exceeds recommended 10g threshold for sugar reduction).",
                            "matchedField": "Goal: Reduce Added Sugar",
                            "isWarning": True,
                            "isPositive": False
                        })
                    elif sugar <= 5.0:
                        positive_highlights.append(f"Low in sugar ({sugar}g/serving), supporting your sugar reduction goal.")
                else:
                    uncertainty_notes.append("Sugar value could not be read from label.")

            if "sodium" in g_lower or "salt" in g_lower:
                sodium = nutrition.get("sodium")
                if sodium is not None:
                    if sodium > 400.0:
                        has_goal_conflict = True
                        reasons.append({
                            "title": "High Sodium Content",
                            "detail": f"Contains {int(sodium)}mg sodium per serving (high for a single snack).",
                            "matchedField": "Goal: Monitor Sodium",
                            "isWarning": True,
                            "isPositive": False
                        })
                    elif sodium <= 140.0:
                        positive_highlights.append(f"Low sodium ({int(sodium)}mg/serving) supports sodium monitoring.")
                else:
                    uncertainty_notes.append("Sodium value could not be read from label.")

            if "protein" in g_lower:
                protein = nutrition.get("protein")
                if protein is not None and protein >= 8.0:
                    positive_highlights.append(f"High protein ({protein}g/serving) aligns with your protein intake target.")

    # Classification
    if has_allergen_conflict or has_dietary_conflict:
        category = "avoid"
        headline = "Not Recommended: Contains Declared Allergens or Dietary Mismatches"
    elif has_goal_conflict:
        category = "considerLimiting"
        headline = "Consider Limiting: Nutrient Values Exceed Your Stated Goals"
    elif not nutrition and not combined_text.strip():
        category = "incomplete"
        headline = "Insufficient Label Data to Form a Reliable Assessment"
    else:
        category = "suitable"
        headline = "Potentially Suitable: Aligns with Your Declared Goals & Preferences"

    return {
        "category": category,
        "headline": headline,
        "reasons": reasons,
        "positiveHighlights": positive_highlights,
        "uncertaintyNotes": uncertainty_notes,
        "disclaimer": "Informational wellness tool only. Always inspect physical packaging."
    }
