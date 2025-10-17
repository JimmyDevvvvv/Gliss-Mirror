import streamlit as st
from PIL import Image
from analyzer import analyze_hair_balanced as analyze_hair, get_product_details
import time
 
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
    """, unsafe_allow_html=True
)

st.markdown('<p class="title">💇‍♀️ Gliss Mirror</p>', unsafe_allow_html=True)
st.caption("AI-Powered Hair Damage Assessment with Smart Product Matching")

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

    # Product Recommendation from Dataset
    st.markdown("---")
    st.markdown(f"### 🧴 Recommended Gliss Product Line")
    
    st.markdown(f"""
    <div class='product-card'>
        <h3>✨ {result['recommended_product']}</h3>
        <p><strong>Key Ingredients:</strong> {result['key_ingredients']}</p>
        <p><strong>Benefit:</strong> {result['benefit']}</p>
        <p><strong>Detected Hair Type:</strong> {result['hair_type']}</p>
    </div>
    """, unsafe_allow_html=True)

    # Get full product details
    product_details = get_product_details(result['recommended_product'])
    
    if product_details:
        st.markdown("#### 📦 Complete Care Routine:")
        
        # Shampoo
        if product_details['shampoo']:
            shampoo = product_details['shampoo'][0]
            st.markdown(f"""
            **Shampoo - {shampoo['Size']}**
            - Goal: {shampoo['Goal']}
            - Fragrance: {shampoo['Fragrance']}
            """)
        
        # Conditioner
        if product_details['conditioner']:
            conditioner = product_details['conditioner'][0]
            st.markdown(f"""
            **Conditioner - {conditioner['Size']}**
            - Goal: {conditioner['Goal']}
            - Fragrance: {conditioner['Fragrance']}
            """)

    # Additional Info
    with st.expander("🔬 View Mineral & Nutrient Profile"):
        if product_details and product_details['shampoo']:
            prod = product_details['shampoo'][0]
            minerals = []
            if prod.get('Mineral : Calcium') == 'yes':
                minerals.append("Calcium")
            if prod.get('Mineral : Magnsium') == 'yes':
                minerals.append("Magnesium")
            if prod.get('Mineral : Zinc') == 'yes':
                minerals.append("Zinc")
            if prod.get('Mineral : Antioxidant') == 'yes':
                minerals.append("Antioxidants")
            if prod.get('Mineral : Omgea 6 & 9') == 'yes':
                minerals.append("Omega 6 & 9")
            if prod.get('Mineral : Amino Acid') == 'yes':
                minerals.append("Amino Acids")
            if prod.get('Mineral : Vitamns') == 'yes':
                minerals.append("Vitamins")
            
            if minerals:
                st.write("**Contains:** " + ", ".join(minerals))
            else:
                st.write("Specialized formula with targeted active ingredients")

    st.markdown(
        """
        <div style='text-align:center;margin-top:20px;color:gray;font-size:0.9em;'>
        *Prototype powered by Gliss product database. Recommendations based on AI analysis + expert formulation data.*
        </div>
        """,
        unsafe_allow_html=True
    )