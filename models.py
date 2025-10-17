# models.py
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class ScanResult(BaseModel):
    """Schema for analyzed scan results."""
    score: float = Field(..., ge=0, le=10, description="Hair damage score between 0 and 10")
    level: str
    confidence: int = Field(..., ge=0, le=100)
    edge_density: float
    texture_score: float
    brightness: float
    saturation_std: float
    highlight_ratio: float
    color_std: float
    message: str
    detected_texture: str
    recommended_product: str
    key_ingredients: Optional[str]
    benefit: Optional[str]
    hair_type: str
    primary_concern: str
    care_level: str


class SaveResponse(BaseModel):
    """Schema for save confirmation response."""
    status: str
    message: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)
