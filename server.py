# server.py
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from analyzer import analyze_hair_balanced
import tracker
from models import ScanResult, SaveResponse
from PIL import Image
import io
from datetime import datetime

app = FastAPI(title="Gliss Mirror API", version="1.1")

# --- Allow Flutter / Web access ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def home():
    return {"status": "running", "message": "Gliss Mirror API is live", "timestamp": datetime.utcnow()}


@app.post("/analyze", response_model=ScanResult)
async def analyze_image(file: UploadFile = File(...)):
    """
    Analyze a hair image and return damage assessment + product recommendation.
    """
    image_data = await file.read()
    image = Image.open(io.BytesIO(image_data))
    result = analyze_hair_balanced(image)
    return result


@app.post("/save_scan", response_model=SaveResponse)
async def save_scan(result: ScanResult):
    """
    Save a scan result to progress history.
    """
    tracker.save_scan(result.dict())
    return SaveResponse(status="success", message="Scan saved to history")


@app.get("/history")
def get_history():
    """Retrieve all saved scans."""
    return tracker.load_history()


@app.get("/stats")
def get_stats():
    """Return overall statistics."""
    return tracker.get_stats()


@app.get("/comparison")
def get_comparison():
    """Compare first vs latest scans."""
    return tracker.get_comparison()


@app.get("/insights")
def get_insights():
    """
    Analyze progress history and return AI-style improvement insights.
    """
    history = tracker.load_history()
    if not history:
        return {"message": "No scans available yet."}

    scores = [h["damage_score"] for h in history if "damage_score" in h]
    products = [h["recommended_product"] for h in history if "recommended_product" in h]
    textures = [h["detected_texture"] for h in history if "detected_texture" in h]

    avg_score = sum(scores) / len(scores)
    first_score, last_score = scores[0], scores[-1]
    delta = round(first_score - last_score, 2)
    trend = "Improving 🟢" if last_score < first_score else "Worsening 🔴"

    best_product = max(set(products), key=products.count) if products else "N/A"
    common_texture = max(set(textures), key=textures.count) if textures else "N/A"

    improvement_msg = (
        f"Great progress! Your average score improved by {abs(delta)} points 👏"
        if delta > 0 else
        "No significant improvement yet. Stay consistent 💪"
    )

    return {
        "average_score": round(avg_score, 2),
        "first_score": first_score,
        "latest_score": last_score,
        "change": delta,
        "trend": trend,
        "most_used_product": best_product,
        "most_common_texture": common_texture,
        "insight": improvement_msg,
        "total_scans": len(history)
    }

from maya_chat import maya_chat, get_matching_product
from pydantic import BaseModel

class MayaChatRequest(BaseModel):
    question: str
    hair_type: str = "Medium"
    damage_score: float = 5.0
    concern: str = "Dryness"


@app.get("/maya_chat")
def chat_with_maya(
    q: str,
    hair_type: str = "Medium",
    damage_score: float = 5.0,
    concern: str = "Dryness"
):
    """
    Chat with Maya AI stylist - GET endpoint.
    Returns clean text without emojis or special formatting.
    Also returns the matched product for reference.
    
    Example: /maya_chat?q=Should I use conditioner daily?&hair_type=Curly&damage_score=8&concern=Dryness
    """
    # Get the matched product info
    product_info = get_matching_product(
        hair_type=hair_type,
        concern=concern,
        damage_score=damage_score
    )
    
    # Get Maya's response
    reply = maya_chat(
        q=q,
        hair_type=hair_type,
        damage_score=damage_score,
        concern=concern,
        tts=False
    )
    
    # Build response
    response_data = {
        "maya_response": reply
    }
    
    # Add product info if available
    if product_info:
        response_data["matched_product"] = {
            "name": f"Gliss {product_info['product_name']} {product_info['product_type']}",
            "ingredients": product_info['ingredients'],
            "benefit": product_info['benefit'],
            "care_level": product_info['care_level']
        }
    
    return response_data


@app.post("/maya_chat")
def chat_with_maya_post(request: MayaChatRequest):
    """
    Chat with Maya AI stylist - POST endpoint.
    Alternative POST version if you prefer sending JSON body.
    """
    # Get the matched product info
    product_info = get_matching_product(
        hair_type=request.hair_type,
        concern=request.concern,
        damage_score=request.damage_score
    )
    
    # Get Maya's response
    reply = maya_chat(
        q=request.question,
        hair_type=request.hair_type,
        damage_score=request.damage_score,
        concern=request.concern,
        tts=False
    )
    
    # Build response
    response_data = {
        "maya_response": reply
    }
    
    # Add product info if available
    if product_info:
        response_data["matched_product"] = {
            "name": f"Gliss {product_info['product_name']} {product_info['product_type']}",
            "ingredients": product_info['ingredients'],
            "benefit": product_info['benefit'],
            "care_level": product_info['care_level']
        }
    
    return response_data