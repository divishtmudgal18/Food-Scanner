import json
import os
import logging
from typing import Dict, Any
from assessment_engine import evaluate_food

logger = logging.getLogger()
logger.setLevel(logging.INFO)

PROFILES_TABLE = os.environ.get("PROFILES_TABLE", "FoodScannerProfiles")
SCANS_TABLE = os.environ.get("SCANS_TABLE", "FoodScannerHistory")

def build_response(status_code: int, body: Any) -> Dict[str, Any]:
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type,Authorization",
            "Access-Control-Allow-Methods": "GET,POST,PUT,DELETE,OPTIONS"
        },
        "body": json.dumps(body)
    }

def get_user_id(event: Dict[str, Any]) -> str:
    # Try extracting Cognito JWT sub claim
    try:
        claims = event.get("requestContext", {}).get("authorizer", {}).get("jwt", {}).get("claims", {})
        if "sub" in claims:
            return claims["sub"]
    except Exception:
        pass
    # Fallback to custom header or demo user
    headers = event.get("headers", {}) or {}
    return headers.get("x-user-id", "demo_user_1")

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    logger.info("Incoming event: %s", json.dumps(event))

    http_method = event.get("requestContext", {}).get("http", {}).get("method") or event.get("httpMethod", "GET")
    raw_path = event.get("rawPath") or event.get("path", "/")

    if http_method == "OPTIONS":
        return build_response(200, {"message": "CORS preflight OK"})

    user_id = get_user_id(event)

    try:
        # Route 1: Assessment Engine (POST /assess)
        if raw_path == "/assess" and http_method == "POST":
            body = json.loads(event.get("body", "{}"))
            profile = body.get("profile", {})
            nutrition = body.get("nutrition", {})
            ingredients = body.get("ingredients", "")
            allergens = body.get("allergens", "")

            assessment = evaluate_food(
                profile=profile,
                nutrition=nutrition,
                ingredients_text=ingredients,
                allergen_text=allergens
            )
            return build_response(200, assessment)

        # Route 2: Profile (GET /profile & PUT /profile)
        elif raw_path == "/profile":
            if http_method == "GET":
                # In actual AWS, call DynamoDB get_item. Here we provide response structure:
                return build_response(200, {
                    "userId": user_id,
                    "name": "Demo Student",
                    "email": "demo@cloudproject.edu",
                    "dietaryPreferences": ["Vegetarian"],
                    "allergiesAndIntolerances": ["Peanuts"],
                    "goals": ["Reduce Added Sugar", "Monitor Sodium / Salt"],
                    "optionalRestrictions": ["No Palm Oil"]
                })
            elif http_method == "PUT":
                body = json.loads(event.get("body", "{}"))
                body["userId"] = user_id
                return build_response(200, {"message": "Profile updated successfully", "profile": body})

        # Route 3: Scans History (GET /scans & POST /scans)
        elif raw_path == "/scans":
            if http_method == "GET":
                return build_response(200, {"scans": []})
            elif http_method == "POST":
                scan_data = json.loads(event.get("body", "{}"))
                scan_data["userId"] = user_id
                return build_response(201, {"message": "Scan recorded", "scanId": scan_data.get("scanId")})

        # Route 4: Delete Scan (DELETE /scans/{scanId})
        elif raw_path.startswith("/scans/") and http_method == "DELETE":
            scan_id = raw_path.split("/")[-1]
            return build_response(200, {"message": f"Scan {scan_id} deleted successfully"})

        return build_response(404, {"error": "Not Found", "path": raw_path})

    except Exception as e:
        logger.error("Error processing request: %s", str(e), exc_info=True)
        return build_response(500, {"error": "Internal Server Error", "detail": str(e)})
