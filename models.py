from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class ScanResult(BaseModel):
    """Schema for analyzed scan results - flexible for both analyze and save endpoints."""
    damage_score: float = Field(..., ge=0, le=10, description="Hair damage score between 0 and 10")
    level: str
    detected_texture: str
    recommended_product: str
    primary_concern: str
    care_level: str
    
    # Optional fields that come from analyze but aren't required for save
    confidence: Optional[int] = Field(None, ge=0, le=100)
    edge_density: Optional[float] = None
    texture_score: Optional[float] = None
    brightness: Optional[float] = None
    saturation_std: Optional[float] = None
    highlight_ratio: Optional[float] = None
    color_std: Optional[float] = None
    message: Optional[str] = None
    key_ingredients: Optional[str] = None
    benefit: Optional[str] = None
    hair_type: Optional[str] = None

    class Config:
        # Allow extra fields without validation errors
        extra = "allow"


class SaveResponse(BaseModel):
    """Schema for save confirmation response."""
    status: str
    message: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)