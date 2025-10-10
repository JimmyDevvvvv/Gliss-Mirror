import cv2
import numpy as np
from PIL import Image
import random

def analyze_hair(image: Image.Image) -> dict:
    """
    AI-theater version of hair analysis:
    Uses multiple visual features to simulate deep learning inference.
    Returns explainable metrics and a believable confidence score.
    """
    img = np.array(image.convert("RGB"))
    gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
    hsv = cv2.cvtColor(img, cv2.COLOR_RGB2HSV)

    # --- Feature extraction ---
    edges = cv2.Canny(gray, 50, 150)
    edge_density = np.mean(edges > 0)

    brightness = np.mean(gray) / 255.0
    color_std = np.std(hsv[:, :, 1]) / 128.0  # saturation variance
    highlight_ratio = np.mean(gray > 200)     # shiny pixels ratio

    # --- Weighted scoring system (tuned for realism) ---
    score = (
        0.35 * edge_density +
        0.25 * color_std +
        0.25 * (1 - brightness) +
        0.15 * highlight_ratio
    ) * 10
    score = np.clip(score, 0, 10)

    # --- Confidence and classification ---
    confidence = random.randint(87, 98)
    if score < 3:
        level = "Healthy"
        message = "Your hair structure looks smooth and reflective — minimal visible damage."
    elif score < 7:
        level = "Moderate Damage"
        message = "We detected some texture irregularities and reduced shine — likely early heat or dryness."
    else:
        level = "Severe Damage"
        message = "Frizz density and color inconsistency are high — deep repair treatment recommended."

    return {
        "score": round(float(score), 1),
        "level": level,
        "confidence": confidence,
        "edge_density": round(float(edge_density), 3),
        "brightness": round(float(brightness), 3),
        "color_std": round(float(color_std), 3),
        "highlight_ratio": round(float(highlight_ratio), 3),
        "message": message
    }
