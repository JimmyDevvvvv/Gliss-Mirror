import cv2
import numpy as np
from PIL import Image
import pandas as pd
import os
from functools import lru_cache
from typing import Dict, Optional

# --------------------------------------------------------------------
# CONFIG
# --------------------------------------------------------------------
DATASET_PATH = "Hackathon_dataset.xlsx"


# --------------------------------------------------------------------
# DATA LOADING
# --------------------------------------------------------------------
@lru_cache(maxsize=1)
def load_dataset() -> Optional[pd.DataFrame]:
    """
    Load the Gliss product dataset once and cache it in memory.
    """
    if not os.path.exists(DATASET_PATH):
        print(f"⚠️ Dataset not found at {DATASET_PATH}")
        return None

    try:
        df = pd.read_excel(DATASET_PATH)
        df.columns = df.columns.str.strip()
        print(f"✓ Loaded {len(df)} Gliss products from dataset")
        return df
    except Exception as e:
        print(f"⚠️ Could not load dataset: {e}")
        return None


# --------------------------------------------------------------------
# MAIN ANALYSIS FUNCTION
# --------------------------------------------------------------------
def analyze_hair_balanced(image: Image.Image) -> Dict:
    """
    Perform advanced hair damage analysis and recommend Gliss products.
    Framework-agnostic: no Streamlit dependencies.
    """
    img = np.array(image.convert("RGB"))
    gray = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
    hsv = cv2.cvtColor(img, cv2.COLOR_RGB2HSV)

    # --- Normalize lighting ---
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    norm_gray = clahe.apply(gray)

    # --- Core features ---
    sobelx = cv2.Sobel(norm_gray, cv2.CV_64F, 1, 0, ksize=3)
    sobely = cv2.Sobel(norm_gray, cv2.CV_64F, 0, 1, ksize=3)
    edge_magnitude = np.sqrt(sobelx**2 + sobely**2)
    texture_score = np.var(edge_magnitude) / 15000
    edge_density = np.mean(edge_magnitude > 50) * 100

    brightness = np.mean(norm_gray) / 255.0
    saturation_std = np.std(hsv[:, :, 1]) / 128.0
    highlight_ratio = np.mean(norm_gray > 200)
    color_diff = np.std(hsv[:, :, 2]) / 128.0

    # --- Calculate raw score ---
    raw_score = (
        0.3 * texture_score +
        0.2 * (1 - brightness) +
        0.15 * saturation_std +
        0.1 * color_diff -
        0.25 * highlight_ratio
    ) * 10
    score = np.clip(raw_score, 0, 10)

    # --- Adaptive normalization ---
    if brightness < 0.4:
        score *= 0.9
    elif brightness > 0.75:
        score *= 1.1
    score = np.clip(score, 0, 10)

    # --- Determine texture ---
    if edge_density > 15:
        detected_texture = "Coarse"
    elif edge_density < 8:
        detected_texture = "Fine"
    else:
        detected_texture = "Medium"

    # --- Classification ---
    if score < 3.5:
        level, care_level = "Healthy", "Gentle"
        hair_type, primary_concern = "Normal & Fine", "Moisture"
        msg = "Smooth surface and consistent tone — minimal damage detected."
    elif score < 6.5:
        level, care_level = "Moderate Damage", "Medium"
        hair_type, primary_concern = "Dry, Damaged", "Nourishment"
        msg = "Some uneven shine and slight dryness detected — mild repair suggested."
    else:
        level, care_level = "Severe Damage", "Deep Care"
        hair_type, primary_concern = "Heavily Damaged & Dry", "Breakage"
        msg = "High texture variation and dull tone — deep treatment recommended."

    # --- Product Matching ---
    df = load_dataset()
    confidence = 90
    recommended_product, key_ingredients, benefit = None, None, None

    if df is not None:
        try:
            care_level_map = {"Gentle": 1, "Medium": 2, "Deep Care": 3}
            target_code = care_level_map.get(care_level, 2)

            matched = df[df['Care Level Code'] == target_code]
            texture_matched = matched[matched['Hair Texture'] == detected_texture]
            if texture_matched.empty:
                texture_matched = matched

            shampoo = texture_matched[texture_matched['Product Type'] == 'Shampoo']
            if not shampoo.empty:
                row = shampoo.iloc[0]
                recommended_product = row['Product']
                key_ingredients = row['Key Ingredients']
                benefit = row['Benefit from Ingredient']
                confidence = 95
        except Exception as e:
            print(f"⚠️ Product matching error: {e}")

    # --- Default fallback ---
    if recommended_product is None:
        if score < 3:
            recommended_product = "Aqua Revive"
            key_ingredients = "Marine Algae, Hyaluron Complex"
            benefit = "Seals Moisture"
        elif score < 7:
            recommended_product = "Oil Nutritive"
            key_ingredients = "Marula Oil, Omega 9"
            benefit = "Controls Water Loss"
        else:
            recommended_product = "Ultimate Repair"
            key_ingredients = "Black Pearl, Liquid Keratin"
            benefit = "Repairing Damage"

    return {
        "damage_score": round(float(score), 1),  # ✅ Flutter-friendly key name
        "level": level,
        "confidence": confidence,
        "edge_density": round(float(edge_density), 2),
        "texture_score": round(float(texture_score), 3),
        "brightness": round(float(brightness), 3),
        "saturation_std": round(float(saturation_std), 3),
        "highlight_ratio": round(float(highlight_ratio), 3),
        "color_std": round(float(color_diff), 3),
        "message": msg,
        "detected_texture": detected_texture,
        "recommended_product": recommended_product,
        "key_ingredients": key_ingredients,
        "benefit": benefit,
        "hair_type": hair_type,
        "primary_concern": primary_concern,
        "care_level": care_level
    }


# --------------------------------------------------------------------
# PRODUCT DETAILS FUNCTIONS
# --------------------------------------------------------------------
def get_product_details(product_name: str) -> Optional[Dict]:
    """Return shampoo/conditioner details for a product name."""
    df = load_dataset()
    if df is None or not product_name:
        return None

    products = df[df['Product'] == product_name]
    if products.empty:
        return None

    return {
        "shampoo": products[products['Product Type'] == 'Shampoo'].to_dict('records'),
        "conditioner": products[products['Product Type'] == 'Conditioner'].to_dict('records')
    }


def get_all_products() -> Optional[pd.DataFrame]:
    """Return the complete Gliss product dataset."""
    return load_dataset()
