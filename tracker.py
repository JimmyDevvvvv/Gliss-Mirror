import json
import os
from datetime import datetime
from typing import List, Dict, Any

# Path to scan history file
HISTORY_FILE = "scan_history.json"


# ------------------------------
# 📦 SAVE SCAN
# ------------------------------
def save_scan(result: Dict[str, Any]) -> None:
    """
    Save a single scan result to the history file.
    Compatible with both Streamlit and FastAPI usage.
    """
    try:
        # ✅ Normalize key names - handle both 'score' and 'damage_score'
        score = result.get("damage_score") or result.get("score") or 0
        
        record = {
            "timestamp": datetime.utcnow().isoformat(),
            "damage_score": float(score),
            "level": result.get("level", "Unknown"),
            "detected_texture": result.get("detected_texture", "Unknown"),
            "recommended_product": result.get("recommended_product", "N/A"),
            "primary_concern": result.get("primary_concern", "N/A"),
            "care_level": result.get("care_level", "N/A"),
        }

        history = load_history()
        history.append(record)

        with open(HISTORY_FILE, "w") as f:
            json.dump(history, f, indent=4)

        print(f"✅ Saved scan at {record['timestamp']} (Score: {record['damage_score']})")

    except Exception as e:
        print(f"⚠️ Failed to save scan: {e}")
        import traceback
        traceback.print_exc()


# ------------------------------
# 📖 LOAD HISTORY
# ------------------------------
def load_history() -> List[Dict[str, Any]]:
    """Load all scan history records."""
    try:
        if os.path.exists(HISTORY_FILE):
            with open(HISTORY_FILE, "r") as f:
                data = json.load(f)
                # Ensure it's a list
                if isinstance(data, list):
                    return data
                print("⚠️ History file is not a list - resetting")
                return []
        return []
    except json.JSONDecodeError:
        print("⚠️ History file corrupted – resetting.")
        return []
    except Exception as e:
        print(f"⚠️ Failed to load history: {e}")
        return []


# ------------------------------
# 📊 STATS CALCULATION
# ------------------------------
def get_stats() -> Dict[str, Any]:
    """Return average, best, worst, and trend info."""
    history = load_history()
    if not history:
        return {
            "avg": 0,
            "best": 0,
            "worst": 0,
            "trend": "No Data",
            "total_scans": 0,
        }

    scores = [scan["damage_score"] for scan in history if scan.get("damage_score") is not None]

    if not scores:
        return {
            "avg": 0,
            "best": 0,
            "worst": 0,
            "trend": "No Data",
            "total_scans": 0,
        }

    avg = round(sum(scores) / len(scores), 1)
    best = min(scores)
    worst = max(scores)
    trend = "⬆️ Improving" if len(scores) > 1 and scores[-1] < scores[0] else "⬇️ Declining"

    return {
        "avg": avg,
        "best": best,
        "worst": worst,
        "trend": trend,
        "total_scans": len(scores),
    }


# ------------------------------
# 🔍 COMPARISON
# ------------------------------
def get_comparison() -> Dict[str, Any]:
    """Compare first and latest scans."""
    history = load_history()
    if len(history) < 2:
        return {"first": None, "latest": None, "delta": 0}

    sorted_history = sorted(history, key=lambda x: x["timestamp"])
    first = sorted_history[0]
    latest = sorted_history[-1]
    delta = round(first["damage_score"] - latest["damage_score"], 2)  # ✅ Fixed: first - latest

    return {
        "first": first,
        "latest": latest,
        "delta": delta,
        "trend": "Improved 🟢" if delta > 0 else "Worsened 🔴" if delta < 0 else "Stable ⚪"
    }


# ------------------------------
# 🧠 INSIGHT GENERATION (used by /insights)
# ------------------------------
def get_insight_summary() -> Dict[str, Any]:
    """
    Generate a high-level summary for the /insights endpoint.
    """
    history = load_history()
    if not history:
        return {
            "message": "No scans available yet.",
            "average_score": 0,
            "best_score": 0,
            "worst_score": 0,
            "trend": "No Data",
            "total_scans": 0,
            "delta": 0,
            "insight": "Start analyzing your hair to see insights! 💫"
        }

    stats = get_stats()
    comparison = get_comparison()

    if comparison["first"] and comparison["latest"]:
        delta = comparison["delta"]
        trend = comparison["trend"]
    else:
        delta, trend = 0, "No Change"

    # Generate insight message
    if delta > 1:
        insight_msg = f"Great progress! Your hair improved by {abs(delta):.1f} points 💚"
    elif delta > 0:
        insight_msg = f"Nice! Your hair is slightly better ({abs(delta):.1f} points improvement) 💫"
    elif delta < -1:
        insight_msg = f"Your hair needs attention - worsened by {abs(delta):.1f} points ⚠️"
    elif delta < 0:
        insight_msg = f"Minor decline of {abs(delta):.1f} points - consider adjusting your routine 💡"
    else:
        insight_msg = "Your hair condition is stable. Keep up your routine! 💪"

    return {
        "average_score": stats["avg"],
        "best_score": stats["best"],
        "worst_score": stats["worst"],
        "trend": trend,
        "total_scans": stats["total_scans"],
        "delta": delta,
        "insight": insight_msg,
    }