from ollama import Client
from analyzer import get_all_products
import pandas as pd
import re

client = Client()

def clean_text(text: str) -> str:
    """
    Remove ALL emojis, special characters, and markdown formatting.
    Returns clean, plain text only.
    """
    # Remove emojis (comprehensive Unicode ranges)
    emoji_pattern = re.compile(
        "["
        "\U0001F600-\U0001F64F"  # emoticons
        "\U0001F300-\U0001F5FF"  # symbols & pictographs
        "\U0001F680-\U0001F6FF"  # transport & map symbols
        "\U0001F1E0-\U0001F1FF"  # flags (iOS)
        "\U00002702-\U000027B0"  # dingbats
        "\U000024C2-\U0001F251"  # enclosed characters
        "\U0001F900-\U0001F9FF"  # supplemental symbols
        "\U0001FA70-\U0001FAFF"  # symbols and pictographs extended
        "]+",
        flags=re.UNICODE
    )
    text = emoji_pattern.sub('', text)
    
    # Remove markdown formatting
    text = text.replace('**', '').replace('*', '').replace('_', '').replace('`', '')
    
    # Remove special bullets and symbols
    text = text.replace('•', '-').replace('◦', '-').replace('▪', '-')
    text = text.replace('→', '->').replace('←', '<-')
    
    # Clean up extra whitespace
    text = re.sub(r'\s+', ' ', text).strip()
    
    return text


def get_matching_product(hair_type: str, concern: str, damage_score: float):
    """
    Smart product matching based on hair type, concern, and damage level.
    Returns best matching Gliss product from the dataset.
    """
    df = get_all_products()
    if df is None or df.empty:
        return None

    # Normalize inputs
    hair_type = hair_type.lower().strip()
    concern = concern.lower().strip()
    
    # Map damage score to care level (1-3 scale in dataset)
    if damage_score >= 7:
        care_level = "Deep Care"
    elif damage_score >= 4:
        care_level = "Medium"
    else:
        care_level = "Gentle"
    
    # Scoring system for best match
    df['match_score'] = 0
    
    # Score 1: Hair Type matching (flexible)
    hair_keywords = {
        'dry': ['dry', 'damaged', 'brittle'],
        'damaged': ['damaged', 'dry', 'heavily damaged', 'strawy'],
        'oily': ['greasy', 'oily'],
        'normal': ['normal', 'fine'],
        'fine': ['fine', 'normal', 'long hair'],
        'thick': ['coarse', 'thick'],
        'coarse': ['coarse', 'thick'],
        'colored': ['colored', 'bleached'],
        'curly': ['coarse', 'dry'],
        'straight': ['fine', 'normal']
    }
    
    for keyword in hair_keywords.get(hair_type, [hair_type]):
        df.loc[df['Hair Type'].str.contains(keyword, case=False, na=False), 'match_score'] += 3
    
    # Score 2: Primary Concern matching
    concern_keywords = {
        'dryness': ['dryness', 'dry', 'dehydration', 'moisture'],
        'damage': ['damage', 'damaged', 'breakage', 'repair'],
        'breakage': ['breakage', 'split ends', 'weakness'],
        'frizz': ['lack of smoothness', 'dullness'],
        'shine': ['dullness', 'lack of shine'],
        'split ends': ['split ends', 'breakage'],
        'greasiness': ['greasy roots', 'oily'],
        'volume': ['weighing down', 'lack of fluidity']
    }
    
    for keyword in concern_keywords.get(concern, [concern]):
        df.loc[df['Primary Concern'].str.contains(keyword, case=False, na=False), 'match_score'] += 5
        df.loc[df['Secondary Concern'].str.contains(keyword, case=False, na=False), 'match_score'] += 2
    
    # Score 3: Care Level matching
    df.loc[df['Care Level'] == care_level, 'match_score'] += 4
    
    # Score 4: Prefer conditioners over shampoos for advice
    df.loc[df['Product Type'] == 'Conditioner', 'match_score'] += 1
    
    # Get best match
    best_matches = df[df['match_score'] > 0].sort_values('match_score', ascending=False)
    
    if len(best_matches) == 0:
        # Fallback to care level only
        best_matches = df[df['Care Level'] == care_level]
    
    if len(best_matches) == 0:
        return None
    
    product = best_matches.iloc[0]
    return {
        "product_name": product["Product"],
        "product_type": product["Product Type"],
        "care_level": product["Care Level"],
        "ingredients": product["Key Ingredients"],
        "benefit": product["Benefit from Ingredient"],
        "texture": product["Hair Texture"],
        "need_state": product["Need State"],
        "match_score": product["match_score"]
    }


def maya_chat(q: str, hair_type: str, damage_score: float, concern: str, tts: bool = False):
    """Conversational AI stylist that references Gliss products by name."""

    product_info = get_matching_product(hair_type, concern, damage_score)
    
    if product_info:
        product_name = f"Gliss {product_info['product_name']} {product_info['product_type']}"
        product_context = f"""MATCHED PRODUCT FOR USER:
Product: {product_name}
Key Ingredients: {product_info['ingredients']}
Benefit: {product_info['benefit']}
Care Level: {product_info['care_level']}
Hair Texture: {product_info['texture']}
Purpose: {product_info['need_state']}

YOU MUST mention this specific product by its full name in your response."""
    else:
        product_name = "Gliss Aqua Revive Conditioner"
        product_context = f"""MATCHED PRODUCT FOR USER:
Product: {product_name}
Key Ingredients: Marine Algae, Hyaluron Complex
Benefit: Seals Moisture
Care Level: Gentle
Hair Texture: Fine
Purpose: Moisture

YOU MUST mention this specific product by its full name in your response."""

    system_prompt = f"""You are Maya, a professional hair stylist for Gliss by Henkel.

CRITICAL RULES - FOLLOW EXACTLY:
1. Write in PLAIN TEXT ONLY - absolutely NO emojis, NO special characters, NO symbols
2. Keep response to 3-4 sentences maximum
3. ALWAYS mention the exact Gliss product name provided below
4. Be warm, helpful, and natural like a professional stylist giving advice
5. End with one practical tip
6. NO bullet points, NO markdown, NO formatting - just clean sentences

USER PROFILE:
- Hair Type: {hair_type}
- Damage Level: {damage_score}/10
- Main Concern: {concern}

{product_context}

USER QUESTION: {q}

Remember: Plain text only. No emojis. No special characters. Professional and friendly tone."""

    response = client.chat(
        model="mistral",
        messages=[{"role": "user", "content": system_prompt}]
    )
    
    reply = response["message"]["content"]
    
    # Clean the response thoroughly
    reply = clean_text(reply)
    
    return reply