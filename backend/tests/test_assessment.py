import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../handlers')))

from assessment_engine import evaluate_food

def test_peanut_allergy():
    profile = {
        "allergiesAndIntolerances": ["Peanuts"],
        "goals": [],
        "dietaryPreferences": []
    }
    result = evaluate_food(
        profile=profile,
        nutrition={"sugar": 3.0},
        ingredients_text="Roasted peanuts, salt, oil."
    )
    assert result["category"] == "avoid"
    assert any("Allergen Alert" in r["title"] for r in result["reasons"])

def test_high_sugar():
    profile = {
        "allergiesAndIntolerances": [],
        "goals": ["Reduce Added Sugar"],
        "dietaryPreferences": []
    }
    result = evaluate_food(
        profile=profile,
        nutrition={"sugar": 18.0},
        ingredients_text="Flour, sugar, cocoa."
    )
    assert result["category"] == "considerLimiting"
    assert any("High Sugar" in r["title"] for r in result["reasons"])

def test_suitable_food():
    profile = {
        "allergiesAndIntolerances": [],
        "goals": ["Reduce Added Sugar", "Increase Protein"],
        "dietaryPreferences": ["Vegetarian"]
    }
    result = evaluate_food(
        profile=profile,
        nutrition={"sugar": 2.0, "protein": 12.0, "sodium": 80.0},
        ingredients_text="Oats, soy protein, chia seeds."
    )
    assert result["category"] == "suitable"
    assert len(result["positiveHighlights"]) > 0

if __name__ == "__main__":
    test_peanut_allergy()
    test_high_sugar()
    test_suitable_food()
    print("All Python backend assessment tests passed successfully!")
