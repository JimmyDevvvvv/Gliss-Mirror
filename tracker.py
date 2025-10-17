import streamlit as st
from PIL import Image
from analyzer import analyze_hair_balanced as analyze_hair, get_product_details
import tracker  # 🆕 Import progress tracker
import time
import pandas as pd
import json
import datetime
import os
from typing import List, Dict

# ------------------------------
# PAGE CONFIG & STYLING
# ------------------------------
st.set_page_config(page_title="Gliss Mirror", page_icon="💇‍♀️", layout="centered")

st.markdown(
    """
    <style>
    .title {text-align:center; font-size:2em; font-weight:700; color:#d91c5c;}
    .score {font-size:1.5em; font-weight:600;}
    .product-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 20px;
        border-radius: 15px;
        color: white;
        margin: 10px 0;
    }
    </style>
    """,
    unsafe_allow_html=True
)

st.markdown('<p class="title">💇‍♀️ Gliss Mirror</p>', unsafe_allow_html=True)
st.caption("AI-Powered Hair Damage Assessment with Smart Product Matching")

# ------------------------------
# SIDEBAR NAVIGATION
# ------------------------------
tab = st.sidebar.radio("🧭 Navigation", ["New Scan", "Progress History"])

# ------------------------------
# TAB 1: NEW SCAN
# ------------------------------
if tab == "New Scan":
    uploaded_file = st.file_uploader("📸 Upload or capture your hair image", type=["jpg", "jpeg", "png"])

    if uploaded_file:
        image = Image.open(uploaded_file)
        st.image(image, caption="Your Hair Sample", use_container_width=True)

        with st.spinner("✨ Analyzing hair texture and matching with Gliss products..."):
            time.sleep(2.5)
            result = analyze_hair(image)

        # Display Score
        st.success(f"Damage Score: **{result['score']}/10** — {result['level']} (Confidence: {result['confidence']}%)")
        st.progress(int((result['score'] / 10) * 100))

        # Hair Profile
        col1, col2, col3 = st.columns(3)
        with col1:
            st.metric("Care Level", result['care_level'])
        with col2:
            st.metric("Hair Texture", result['detected_texture'])
        with col3:
            st.metric("Primary Concern", result['primary_concern'])

        # Detailed Insights
        st.markdown("### 🔍 Detailed AI Insights:")
        st.write(f"• Frizz Intensity: `{result['edge_density']}`")
        st.write(f"• Shine Index: `{result['brightness']}`")
        st.write(f"• Color Variance: `{result['color_std']}`")
        st.write(f"• Highlight Ratio: `{result['highlight_ratio']}`")

        st.markdown("---")
        st.markdown(f"**🧠 Gliss AI Insight:** {result['message']}")

        # Product Recommendation
        st.markdown("---")
        st.markdown("### 🧴 Recommended Gliss Product Line")

        st.markdown(
            f"""
            <div class='product-card'>
                <h3>✨ {result['recommended_product']}</h3>
                <p><strong>Key Ingredients:</strong> {result['key_ingredients']}</p>
                <p><strong>Benefit:</strong> {result['benefit']}</p>
                <p><strong>Detected Hair Type:</strong> {result['hair_type']}</p>
            </div>
            """,
            unsafe_allow_html=True,
        )

        # Full product details
        product_details = get_product_details(result['recommended_product'])

        if product_details:
            st.markdown("#### 📦 Complete Care Routine:")

            if product_details["shampoo"]:
                shampoo = product_details["shampoo"][0]
                st.markdown(
                    f"""
                    **Shampoo - {shampoo['Size']}**
                    - Goal: {shampoo['Goal']}
                    - Fragrance: {shampoo['Fragrance']}
                    """
                )

            if product_details["conditioner"]:
                conditioner = product_details["conditioner"][0]
                st.markdown(
                    f"""
                    **Conditioner - {conditioner['Size']}**
                    - Goal: {conditioner['Goal']}
                    - Fragrance: {conditioner['Fragrance']}
                    """
                )

        # Nutrient Profile
        with st.expander("🔬 View Mineral & Nutrient Profile"):
            if product_details and product_details["shampoo"]:
                prod = product_details["shampoo"][0]
                minerals = [
                    name
                    for key, name in [
                        ("Mineral : Calcium", "Calcium"),
                        ("Mineral : Magnsium", "Magnesium"),
                        ("Mineral : Zinc", "Zinc"),
                        ("Mineral : Antioxidant", "Antioxidants"),
                        ("Mineral : Omgea 6 & 9", "Omega 6 & 9"),
                        ("Mineral : Amino Acid", "Amino Acids"),
                        ("Mineral : Vitamns", "Vitamins"),
                    ]
                    if prod.get(key) == "yes"
                ]
                if minerals:
                    st.write("**Contains:** " + ", ".join(minerals))
                else:
                    st.write("Specialized formula with targeted active ingredients")

        # ------------------------------
        # 🆕 SAVE TO PROGRESS TRACKER BUTTON
        # ------------------------------
        if st.button("💾 Save to Progress Tracker"):
            tracker.save_scan(result)
            st.success("✅ Scan saved to history!")

        st.markdown(
            """
            <div style='text-align:center;margin-top:20px;color:gray;font-size:0.9em;'>
            *Prototype powered by Gliss product database. Recommendations based on AI analysis + expert formulation data.*
            </div>
            """,
            unsafe_allow_html=True,
        )

# ------------------------------
# TAB 2: PROGRESS HISTORY
# ------------------------------
else:
    st.markdown("## 📊 Your Progress History")

    history = tracker.load_history()

    if not history:
        st.info("No scans saved yet. Perform your first analysis to start tracking progress!")
    else:
        # Convert to DataFrame
        df = pd.DataFrame(history)
        df["timestamp"] = pd.to_datetime(df["timestamp"])
        df = df.sort_values("timestamp")

        stats = tracker.get_stats()
        comparison = tracker.get_comparison()

        # Stats Overview
        col1, col2, col3, col4 = st.columns(4)
        with col1:
            st.metric("Average", f"{stats['avg']}/10")
        with col2:
            st.metric("Best", f"{stats['best']}/10")
        with col3:
            st.metric("Worst", f"{stats['worst']}/10")
        with col4:
            st.metric("Trend", stats["trend"])

        # Line Chart
        st.markdown("### 📈 Damage Score Over Time")
        st.line_chart(df, x="timestamp", y="damage_score")

        # Comparison
        st.markdown("### 🔍 Comparison View")
        if comparison["first"] and comparison["latest"]:
            first = comparison["first"]
            latest = comparison["latest"]
            delta = comparison["delta"]

            col1, col2 = st.columns(2)
            with col1:
                st.markdown("#### 🕒 First Scan")
                st.write(f"Score: {first['damage_score']}")
                st.write(f"Level: {first['level']}")
                st.write(f"Texture: {first['detected_texture']}")
                st.write(f"Product: {first['recommended_product']}")

            with col2:
                st.markdown("#### 🕒 Latest Scan")
                st.write(f"Score: {latest['damage_score']}")
                st.write(f"Level: {latest['level']}")
                st.write(f"Texture: {latest['detected_texture']}")
                st.write(f"Product: {latest['recommended_product']}")

            # Trend Result
            if delta < -1:
                st.success(f"🏆 Improved by {abs(delta)} points! Great progress! 🎉")
                st.balloons()
            elif delta > 1:
                st.warning(f"⚠️ Worsened by {abs(delta)} points — consider a deeper care routine.")
            else:
                st.info("No significant change detected yet.")

        # Raw data expander
        with st.expander("📋 View Raw Scan History"):
            st.dataframe(df)

# ------------------------------
# TRACKER FUNCTIONS
# ------------------------------
HISTORY_FILE = "scan_history.json"

def save_scan(result: Dict) -> None:
    """Save a scan result to the history file."""
    try:
        # Add timestamp
        scan_record = {
            "timestamp": datetime.datetime.now().isoformat(),
            "damage_score": result["score"],
            "level": result["level"],
            "detected_texture": result["detected_texture"],
            "recommended_product": result["recommended_product"]
        }
        
        # Load existing history
        history = load_history()
        history.append(scan_record)
        
        # Save updated history
        with open(HISTORY_FILE, "w") as f:
            json.dump(history, f, indent=2)
            
    except Exception as e:
        raise Exception(f"Failed to save scan: {e}")

def load_history() -> List[Dict]:
    """Load scan history from file."""
    try:
        if os.path.exists(HISTORY_FILE):
            with open(HISTORY_FILE, "r") as f:
                return json.load(f)
        return []
    except Exception as e:
        raise Exception(f"Failed to load history: {e}")

def get_stats() -> Dict:
    """Calculate statistics from scan history."""
    history = load_history()
    if not history:
        return {
            "avg": 0,
            "best": 0,
            "worst": 0,
            "trend": "No data"
        }
    
    scores = [scan["damage_score"] for scan in history]
    return {
        "avg": round(sum(scores) / len(scores), 1),
        "best": min(scores),
        "worst": max(scores),
        "trend": "⬆️ Improving" if len(scores) > 1 and scores[-1] < scores[0] else "⬇️ Declining"
    }

def get_comparison() -> Dict:
    """Compare first and latest scans."""
    history = load_history()
    if len(history) < 2:
        return {"first": None, "latest": None, "delta": 0}
    
    sorted_history = sorted(history, key=lambda x: x["timestamp"])
    first = sorted_history[0]
    latest = sorted_history[-1]
    
    return {
        "first": first,
        "latest": latest,
        "delta": latest["damage_score"] - first["damage_score"]
    }
