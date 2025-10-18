from fastapi import FastAPI, UploadFile, File, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, FileResponse
from pydantic import BaseModel
from PIL import Image
import io
from datetime import datetime
import pyttsx3
import os
import re

# Import your modules
from analyzer import analyze_hair_balanced
import tracker
from models import ScanResult, SaveResponse
from maya_chat import maya_chat, get_matching_product

# Initialize FastAPI app
app = FastAPI(title="Gliss Mirror API", version="1.1")

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==================== EMOJI CLEANING FUNCTION ====================

def clean_maya_response(text: str) -> str:
    """Remove ALL emojis, special characters, and markdown formatting."""
    emoji_pattern = re.compile(
        "["
        "\U0001F600-\U0001F64F"  # emoticons
        "\U0001F300-\U0001F5FF"  # symbols & pictographs
        "\U0001F680-\U0001F6FF"  # transport & map
        "\U0001F1E0-\U0001F1FF"  # flags
        "\U00002702-\U000027B0"  # dingbats
        "\U000024C2-\U0001F251"  # enclosed
        "\U0001F900-\U0001F9FF"  # supplemental
        "\U0001FA70-\U0001FAFF"  # extended
        "]+",
        flags=re.UNICODE
    )
    text = emoji_pattern.sub('', text)
    text = text.replace('**', '').replace('*', '').replace('_', '').replace('`', '')
    text = text.replace('•', '-').replace('◦', '-').replace('▪', '-')
    text = text.replace('→', '->').replace('←', '<-')
    text = re.sub(r'\s+', ' ', text).strip()
    return text


# ==================== MODELS ====================

class MayaChatRequest(BaseModel):
    question: str
    hair_type: str = "Medium"
    damage_score: float = 5.0
    concern: str = "Dryness"


class TTSRequest(BaseModel):
    text: str


# ==================== HEALTH CHECK ====================

@app.get("/")
def home():
    """Root endpoint - Health check"""
    return {
        "status": "running",
        "message": "Gliss Mirror API is live",
        "version": "1.1",
        "timestamp": datetime.utcnow()
    }


# ==================== HAIR ANALYSIS ====================

@app.post("/analyze", response_model=ScanResult)
async def analyze_image(file: UploadFile = File(...)):
    """Analyze a hair image and return damage assessment + product recommendation."""
    image_data = await file.read()
    image = Image.open(io.BytesIO(image_data))
    result = analyze_hair_balanced(image)
    return result


# ==================== SCAN TRACKING ====================

@app.post("/save_scan", response_model=SaveResponse)
async def save_scan(request: Request):
    """Save a scan result to progress history."""
    try:
        body = await request.json()
        print(f"📥 Received save_scan request: {body}")
        
        damage_score = body.get('damage_score') or body.get('score') or 0
        
        normalized_data = {
            'damage_score': float(damage_score),
            'level': body.get('level', 'Unknown'),
            'detected_texture': body.get('detected_texture', 'Unknown'),
            'recommended_product': body.get('recommended_product', 'N/A'),
            'primary_concern': body.get('primary_concern', 'N/A'),
            'care_level': body.get('care_level', 'N/A'),
        }
        
        print(f"💾 Saving normalized data: {normalized_data}")
        tracker.save_scan(normalized_data)
        
        return SaveResponse(
            status="success",
            message=f"Scan saved successfully (Score: {damage_score})"
        )
        
    except Exception as e:
        print(f"❌ Error in save_scan: {e}")
        import traceback
        traceback.print_exc()
        
        return JSONResponse(
            status_code=500,
            content={
                "status": "error",
                "message": f"Failed to save scan: {str(e)}"
            }
        )


@app.get("/history")
def get_history():
    """Retrieve all saved scans from history."""
    return tracker.load_history()


@app.get("/stats")
def get_stats():
    """Return overall statistics from scan history."""
    return tracker.get_stats()


@app.get("/comparison")
def get_comparison():
    """Compare first vs latest scans to show progress."""
    return tracker.get_comparison()


# ==================== INSIGHTS & ANALYTICS ====================

@app.get("/insights")
def get_insights():
    """Analyze progress history and return AI-style improvement insights."""
    history = tracker.load_history()
    
    if not history:
        return {"message": "No scans available yet."}

    scores = [h["damage_score"] for h in history if "damage_score" in h]
    products = [h["recommended_product"] for h in history if "recommended_product" in h]
    textures = [h["detected_texture"] for h in history if "detected_texture" in h]

    if not scores:
        return {"message": "No valid scan data available."}

    avg_score = sum(scores) / len(scores)
    first_score, last_score = scores[0], scores[-1]
    delta = round(first_score - last_score, 2)
    trend = "Improving" if last_score < first_score else "Worsening" if last_score > first_score else "Stable"

    best_product = max(set(products), key=products.count) if products else "N/A"
    common_texture = max(set(textures), key=textures.count) if textures else "N/A"

    if delta > 0:
        improvement_msg = f"Great progress! Your average score improved by {abs(delta)} points"
    elif delta < -0.5:
        improvement_msg = "Your hair needs more attention. Consider adjusting your routine"
    else:
        improvement_msg = "Your hair condition is stable. Keep up your routine"

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


# ==================== MAYA CHAT AI ====================

@app.get("/maya_greet")
def maya_greet_user():
    """Maya's personalized greeting based on user's latest scan."""
    try:
        history = tracker.load_history()
        
        if not history:
            greeting = "Hi there! I'm Maya, your personal AI hair stylist. I'm here 24/7 to help you achieve your best hair ever! Let's start with your first hair analysis - just tap the camera icon to begin your journey!"
            return {
                "maya_response": clean_maya_response(greeting),
                "has_scan": False,
                "first_time": True
            }
        
        # Get latest scan
        latest = history[-1]
        score = latest.get("damage_score", 5.0)
        level = latest.get("level", "Unknown")
        product = latest.get("recommended_product", "Unknown")
        concern = latest.get("primary_concern", "hair health")
        
        # Calculate trend
        delta = 0
        if len(history) > 1:
            first_score = history[0].get("damage_score", score)
            delta = first_score - score
            
            if delta > 1:
                trend_msg = f"Amazing news! Your hair has improved by {abs(delta):.1f} points since you started! "
            elif delta > 0:
                trend_msg = f"Great progress! Your hair is {abs(delta):.1f} points better! Keep it up! "
            elif delta < -1:
                trend_msg = f"I noticed your hair needs some attention - it's {abs(delta):.1f} points lower than before. Don't worry, we'll fix this together! "
            else:
                trend_msg = "Your hair condition is stable. "
        else:
            trend_msg = "This is your first scan! Let's work together to improve your hair health. "
        
        # Generate contextual greeting
        if score < 3.5:
            greeting = f"Hey gorgeous! {trend_msg}Your hair is looking healthy with a score of {score:.1f}/10! Your {product} routine is working wonders. Keep up the fantastic work!"
        elif score < 6.5:
            greeting = f"Hello! {trend_msg}Your hair scored {score:.1f}/10 - there's room for improvement! Your main concern is {concern}. I recommend using {product} consistently. Want some personalized tips?"
        else:
            greeting = f"Hi there! {trend_msg}Your hair needs some extra love (score: {score:.1f}/10). Don't worry - I'm here to help! Focus on {concern} with {product}. Let's get your hair back to its best together!"
        
        return {
            "maya_response": clean_maya_response(greeting),
            "has_scan": True,
            "latest_score": score,
            "level": level,
            "trend": delta,
            "total_scans": len(history)
        }
        
    except Exception as e:
        print(f"❌ Maya greet error: {e}")
        import traceback
        traceback.print_exc()
        return {
            "maya_response": clean_maya_response("Hi! I'm Maya, ready to help you with your hair!"),
            "has_scan": False
        }


@app.get("/maya_analyze_scan")
def maya_analyze_latest_scan():
    """Maya provides detailed analysis and actionable advice on the latest scan."""
    try:
        history = tracker.load_history()
        
        if not history:
            return {
                "maya_response": clean_maya_response("You haven't scanned your hair yet! Let's do that first so I can give you personalized advice!"),
                "has_scan": False
            }
        
        latest = history[-1]
        score = latest.get("damage_score", 5.0)
        level = latest.get("level", "Unknown")
        texture = latest.get("detected_texture", "Unknown")
        product = latest.get("recommended_product", "Unknown")
        concern = latest.get("primary_concern", "hair health")
        care_level = latest.get("care_level", "Medium")
        
        # Build comprehensive analysis
        analysis_parts = []
        
        # 1. Score assessment
        if score < 3.5:
            analysis_parts.append(f"Your hair is in excellent condition with a {score:.1f}/10 score! You're doing everything right!")
        elif score < 6.5:
            analysis_parts.append(f"Your hair scored {score:.1f}/10, which means there's definite room for improvement. But don't worry - we can fix this!")
        else:
            analysis_parts.append(f"Your hair needs serious attention with a {score:.1f}/10 score. Let's work on a recovery plan together!")
        
        # 2. Texture and concern
        analysis_parts.append(f"\nI detected {texture.lower()} texture with {concern.lower()} as your primary concern.")
        
        # 3. Product recommendation with usage
        analysis_parts.append(f"\nI recommend Gliss {product} for {care_level.lower()} care:")
        
        if "Ultimate Repair" in product:
            analysis_parts.append("- Use 2-3 times per week")
            analysis_parts.append("- Leave on for 3-5 minutes")
            analysis_parts.append("- Focus on damaged ends")
        elif "Oil Nutritive" in product:
            analysis_parts.append("- Use daily for best results")
            analysis_parts.append("- Massage into scalp")
            analysis_parts.append("- Great for overnight treatment")
        elif "Aqua Revive" in product:
            analysis_parts.append("- Perfect for daily use")
            analysis_parts.append("- Light formula, won't weigh down")
            analysis_parts.append("- Focus on mid-lengths to ends")
        else:
            analysis_parts.append("- Follow package instructions")
            analysis_parts.append("- Use consistently for best results")
        
        # 4. Actionable tips
        analysis_parts.append(f"\nQuick Action Plan:")
        if concern.lower() == "dryness":
            analysis_parts.append("- Deep condition weekly")
            analysis_parts.append("- Avoid hot water when washing")
            analysis_parts.append("- Use a microfiber towel")
        elif concern.lower() == "breakage":
            analysis_parts.append("- Minimize heat styling")
            analysis_parts.append("- Sleep on silk pillowcase")
            analysis_parts.append("- Get regular trims")
        else:
            analysis_parts.append("- Be gentle when brushing")
            analysis_parts.append("- Protect from sun damage")
            analysis_parts.append("- Stay hydrated!")
        
        # 5. Progress tracking
        if len(history) > 1:
            first_score = history[0].get("damage_score", score)
            delta = first_score - score
            
            if delta > 0:
                analysis_parts.append(f"\nProgress Update: You've improved {abs(delta):.1f} points since starting! Keep going!")
            elif delta < 0:
                analysis_parts.append(f"\nProgress Update: Your score dropped {abs(delta):.1f} points. Let's refocus on your routine!")
            else:
                analysis_parts.append(f"\nProgress Update: Stable at {score:.1f}/10. Ready to push for even better?")
        
        # 6. Encouraging close
        analysis_parts.append("\n\nRemember: Healthy hair is a journey, not a destination. I'm here with you every step of the way!")
        
        response_text = "\n".join(analysis_parts)
        
        return {
            "maya_response": clean_maya_response(response_text),
            "has_scan": True,
            "score": score,
            "actionable_items": len([p for p in analysis_parts if p.startswith("-")])
        }
        
    except Exception as e:
        print(f"❌ Maya analyze error: {e}")
        import traceback
        traceback.print_exc()
        return {
            "maya_response": clean_maya_response("I'm having trouble analyzing right now, but I'm here to help! Try asking me a specific question!"),
            "has_scan": True
        }


@app.get("/maya_progress")
def maya_progress_report():
    """Maya gives a progress report comparing all scans."""
    try:
        history = tracker.load_history()
        
        if len(history) < 2:
            return {
                "maya_response": clean_maya_response("You need at least 2 scans for me to track your progress! Keep scanning regularly so I can show you how far you've come!"),
                "has_scans": False
            }
        
        # Calculate statistics
        scores = [h.get("damage_score", 0) for h in history]
        first_score = scores[0]
        latest_score = scores[-1]
        avg_score = sum(scores) / len(scores)
        best_score = min(scores)
        worst_score = max(scores)
        delta = first_score - latest_score
        
        # Build progress report
        report_parts = []
        
        report_parts.append(f"Your Hair Health Journey ({len(history)} scans)")
        report_parts.append(f"\n----------------------------")
        
        # Overall trend
        if delta > 1.5:
            report_parts.append(f"\nAMAZING PROGRESS! You've improved {abs(delta):.1f} points!")
            report_parts.append("Your dedication is really paying off! Keep up the fantastic work!")
        elif delta > 0.5:
            report_parts.append(f"\nGreat job! You're {abs(delta):.1f} points better than when you started!")
            report_parts.append("You're on the right track! Stay consistent!")
        elif delta > -0.5:
            report_parts.append(f"\nSteady progress! Your hair is stable.")
            report_parts.append("Let's push for improvement with some adjustments!")
        else:
            report_parts.append(f"\nYour hair needs attention - down {abs(delta):.1f} points.")
            report_parts.append("Don't worry! Let's get back on track together!")
        
        # Statistics
        report_parts.append(f"\n\nYour Stats:")
        report_parts.append(f"- First scan: {first_score:.1f}/10")
        report_parts.append(f"- Latest scan: {latest_score:.1f}/10")
        report_parts.append(f"- Average: {avg_score:.1f}/10")
        report_parts.append(f"- Best ever: {best_score:.1f}/10")
        report_parts.append(f"- Worst: {worst_score:.1f}/10")
        
        # Recommendations based on trend
        report_parts.append(f"\n\nMaya's Recommendations:")
        if delta > 0:
            report_parts.append("- Keep using your current products!")
            report_parts.append("- Maintain your routine consistency")
            report_parts.append("- Consider adding a weekly hair mask")
        else:
            report_parts.append("- Review your current routine")
            report_parts.append("- Be more consistent with treatments")
            report_parts.append("- Avoid heat styling when possible")
        
        report_parts.append("\n\nNext Goal: Let's aim for a score under 3.0 for optimal health!")
        
        response_text = "\n".join(report_parts)
        
        return {
            "maya_response": clean_maya_response(response_text),
            "delta": delta,
            "trend": "improving" if delta > 0 else "stable" if abs(delta) < 0.5 else "declining",
            "total_scans": len(history)
        }
        
    except Exception as e:
        print(f"❌ Maya progress error: {e}")
        import traceback
        traceback.print_exc()
        return {
            "maya_response": clean_maya_response("I'm having trouble loading your progress right now, but I know you're doing great!"),
            "has_scans": True
        }


@app.get("/maya_chat")
def chat_with_maya_get(
    q: str,
    hair_type: str = "Medium",
    damage_score: float = 5.0,
    concern: str = "Dryness"
):
    """Enhanced Maya chat with context awareness"""
    try:
        q_lower = q.lower()
        
        # Route to specialized endpoints
        if any(word in q_lower for word in ["progress", "improvement", "how am i doing", "journey"]):
            return maya_progress_report()
        
        if any(word in q_lower for word in ["analyze", "latest scan", "my hair", "current"]):
            return maya_analyze_latest_scan()
        
        # Get product info
        product_info = get_matching_product(
            hair_type=hair_type,
            concern=concern,
            damage_score=damage_score
        )
        
        # Get Maya's response with enhanced context
        reply = maya_chat(
            q=q,
            hair_type=hair_type,
            damage_score=damage_score,
            concern=concern,
            tts=False
        )
        
        reply = clean_maya_response(reply)
        
        # Make response more agent-like
        if damage_score > 6.5:
            reply = f"{reply}\n\nRemember, I'm here to help you every step of the way! Your hair will thank you!"
        elif damage_score < 3.5:
            reply = f"{reply}\n\nYou're doing amazing! Keep up the great work!"
        
        response_data = {
            "maya_response": reply,
            "context": {
                "hair_type": hair_type,
                "damage_score": damage_score,
                "concern": concern
            }
        }
        
        if product_info:
            response_data["matched_product"] = {
                "name": f"Gliss {product_info['product_name']} {product_info['product_type']}",
                "ingredients": product_info['ingredients'],
                "benefit": product_info['benefit'],
                "care_level": product_info['care_level']
            }
        
        return response_data
        
    except Exception as e:
        print(f"❌ Maya chat error: {e}")
        import traceback
        traceback.print_exc()
        return {
            "maya_response": clean_maya_response("I'm having a little trouble right now, but I'm still here for you! Try asking me again!"),
            "context": {
                "hair_type": hair_type,
                "damage_score": damage_score,
                "concern": concern
            }
        }


# ==================== TEXT-TO-SPEECH ====================

@app.options("/tts")
async def options_tts():
    """Handle CORS preflight requests for TTS endpoint"""
    return JSONResponse(content={"status": "ok"})


@app.post("/tts")
async def text_to_speech(request: TTSRequest):
    """Convert text to speech using pyttsx3 and return audio file."""
    text = request.text or "Hello from Maya!"
    filename = f"maya_voice_{datetime.now().timestamp()}.mp3"
    
    try:
        engine = pyttsx3.init()
        voices = engine.getProperty('voices')
        if len(voices) > 1:
            engine.setProperty('voice', voices[1].id)
        engine.setProperty('rate', 150)
        engine.save_to_file(text, filename)
        engine.runAndWait()
        
        response = FileResponse(
            filename,
            media_type="audio/mpeg",
            filename="maya_voice.mp3"
        )
        return response
        
    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                "status": "error",
                "message": f"TTS generation failed: {str(e)}"
            }
        )


# ==================== ERROR HANDLERS ====================

@app.exception_handler(404)
async def not_found_handler(request: Request, exc):
    """Custom 404 handler"""
    return JSONResponse(
        status_code=404,
        content={
            "status": "error",
            "message": "Endpoint not found",
            "path": str(request.url)
        }
    )


@app.exception_handler(500)
async def internal_error_handler(request: Request, exc):
    """Custom 500 handler"""
    return JSONResponse(
        status_code=500,
        content={
            "status": "error",
            "message": "Internal server error",
            "detail": str(exc)
        }
    )


# ==================== STARTUP/SHUTDOWN EVENTS ====================

@app.on_event("startup")
async def startup_event():
    """Tasks to run on application startup"""
    print("🚀 Gliss Mirror API started successfully")
    print("📍 API Documentation: http://localhost:8000/docs")
    print("📍 Alternative docs: http://localhost:8000/redoc")


@app.on_event("shutdown")
async def shutdown_event():
    """Tasks to run on application shutdown"""
    print("👋 Gliss Mirror API shutting down...")
    
    for file in os.listdir("."):
        if file.startswith("maya_voice_") and file.endswith(".mp3"):
            try:
                os.remove(file)
                print(f"🗑️  Cleaned up: {file}")
            except Exception as e:
                print(f"⚠️  Could not delete {file}: {e}")


# ==================== MAIN ====================

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "server:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )