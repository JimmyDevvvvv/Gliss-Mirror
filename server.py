from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from analyzer import analyze_hair_balanced
import tracker
from PIL import Image
import io

app = FastAPI(title="Gliss Mirror API", version="1.0")

# --- Allow frontend apps to connect (Flutter, React, etc.) ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # change to your frontend URL in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def home():
    return {"status": "running", "message": "Gliss Mirror API is live"}

@app.post("/analyze")
async def analyze_image(file: UploadFile = File(...)):
    image_data = await file.read()
    image = Image.open(io.BytesIO(image_data))
    result = analyze_hair_balanced(image)
    return result

@app.post("/save_scan")
async def save_scan(result: dict):
    tracker.save_scan(result)
    return {"status": "success", "message": "Scan saved to progress history"}

@app.get("/history")
def history():
    return tracker.load_history()

@app.get("/stats")
def stats():
    return tracker.get_stats()

@app.get("/comparison")
def comparison():
    return tracker.get_comparison()
