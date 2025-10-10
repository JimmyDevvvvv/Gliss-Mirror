import streamlit as st
from PIL import Image
from analyzer import analyze_hair
import time

st.set_page_config(page_title="Gliss Mirror", page_icon="💇‍♀️", layout="centered")

st.markdown(
    """
    <style>
    .title {text-align:center; font-size:2em; font-weight:700; color:#d91c5c;}
    .score {font-size:1.5em; font-weight:600;}
    </style>
    """, unsafe_allow_html=True
)

st.markdown('<p class="title">💇‍♀️ Gliss Mirror</p>', unsafe_allow_html=True)
st.caption("AI-Powered Hair Damage Assessment (Hackathon Prototype)")

uploaded_file = st.file_uploader("📸 Upload or capture your hair image", type=["jpg", "jpeg", "png"])

if uploaded_file:
    image = Image.open(uploaded_file)
    st.image(image, caption="Your Hair Sample", use_container_width=True)

    with st.spinner("✨ Analyzing 200+ hair micro-textures..."):
        time.sleep(2.5)
        result = analyze_hair(image)

    st.success(f"Damage Score: **{result['score']}/10** — {result['level']} (Confidence: {result['confidence']}%)")
    st.progress(int((result['score'] / 10) * 100))

    st.markdown("### 🔍 Detailed AI Insights:")
    st.write(f"• Frizz Intensity: `{result['edge_density']}`")
    st.write(f"• Shine Index: `{result['brightness']}`")
    st.write(f"• Color Variance: `{result['color_std']}`")
    st.write(f"• Highlight Ratio: `{result['highlight_ratio']}`")

    st.markdown("---")
    st.markdown(f"**🧠 Gliss AI Insight:** {result['message']}")

    # Recommendations
    if result['score'] < 3:
        rec = "Gliss Oil Nutritive"
        desc = "Smooth, frizz-free formula for naturally healthy hair."
    elif result['score'] < 7:
        rec = "Gliss Total Repair"
        desc = "Keratin-rich repair for moderately damaged hair."
    else:
        rec = "Gliss Ultimate Repair"
        desc = "Intense rescue formula for over-processed and color-damaged hair."

    st.markdown("---")
    st.markdown(f"### 🧴 Recommended Routine: **{rec}**")
    st.caption(desc)

    st.markdown(
        """
        <div style='text-align:center;margin-top:20px;color:gray;font-size:0.9em;'>
        *Prototype simulation. Future versions will use on-device ML for live hair scanning.*
        </div>
        """,
        unsafe_allow_html=True
    )
