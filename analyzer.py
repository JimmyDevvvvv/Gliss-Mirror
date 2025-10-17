import cv2
import numpy as np
from PIL import Image
import pandas as pd
import os

# Load the dataset once at module level
DATASET_PATH = "Hackathon_dataset.xlsx"
dataset = None

def load_dataset():
    """Load the Gliss product dataset."""
    global dataset
    if dataset is None and os.path.exists(DATASET_PATH):
        try:
            dataset = pd.read_excel(DATASET_PATH)
            # Clean column names
            dataset.columns = dataset.columns.str.strip()
            print(f"✓ Loaded {len(dataset)} Gliss products from dataset")
        except Exception as e:
            print(f"Warning: Could not load dataset: {e}")
    return dataset

def analyze_hair_balanced(image: Image.Image) -> dict:
    """
    Enhanced hair analysis using Gliss product dataset.
    Combines computer vision with intelligent product matching.
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

    # --- Determine hair texture from image analysis ---
    if edge_density > 15:
        detected_texture = "Coarse"
    elif edge_density < 8:
        detected_texture = "Fine"
    else:
        detected_texture = "Medium"

    # --- Classification & Product Matching ---
    df = load_dataset()
    confidence = 92
    
    if score < 3.5:
        level = "Healthy"
        care_level = "Gentle"
        hair_type = "Normal & Fine"
        primary_concern = "Moisture"
        msg = "Smooth surface and consistent tone — minimal damage detected."
    elif score < 6.5:
        level = "Moderate Damage"
        care_level = "Medium"
        hair_type = "Dry, Damaged"
        primary_concern = "Nourishment"
        msg = "Some uneven shine and slight dryness detected — mild repair suggested."
    else:
        level = "Severe Damage"
        care_level = "Deep Care"
        hair_type = "Heavily Damaged & Dry"
        primary_concern = "Breakage"
        msg = "High texture variation and dull tone — deep treatment recommended."

    # --- Match with Gliss Product Dataset ---
    recommended_product = None
    product_line = None
    key_ingredients = None
    benefit = None
    
    if df is not None:
        try:
            # Filter products by care level
            care_level_code = {"Gentle": 1, "Medium": 2, "Deep Care": 3}
            target_code = care_level_code.get(care_level, 2)
            
            matched = df[df['Care Level Code'] == target_code]
            
            # Further filter by texture if possible
            texture_matched = matched[matched['Hair Texture'] == detected_texture]
            if len(texture_matched) == 0:
                texture_matched = matched
            
            # Get shampoo recommendation
            shampoo = texture_matched[texture_matched['Product Type'] == 'Shampoo']
            if len(shampoo) > 0:
                product_row = shampoo.iloc[0]
                recommended_product = product_row['Product']
                product_line = recommended_product
                key_ingredients = product_row['Key Ingredients']
                benefit = product_row['Benefit from Ingredient']
                
                # Update confidence based on dataset match
                confidence = 95
        except Exception as e:
            print(f"Product matching warning: {e}")

    # Default to rule-based if dataset matching fails
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
        "score": round(float(score), 1),
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

def get_product_details(product_name: str) -> dict:
    """Get full product line details from dataset."""
    df = load_dataset()
    if df is not None and product_name:
        products = df[df['Product'] == product_name]
        if len(products) > 0:
            return {
                "shampoo": products[products['Product Type'] == 'Shampoo'].to_dict('records'),
                "conditioner": products[products['Product Type'] == 'Conditioner'].to_dict('records')
            }
    return None

def get_all_products() -> pd.DataFrame:
    """Get the complete product dataset."""
    return load_dataset()