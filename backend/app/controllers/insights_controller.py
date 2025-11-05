from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.dependencies import get_current_user
from app.models.user import User
from app.schemas.insights import InsightsResponse
from app.services.insights_service import get_user_insights

router = APIRouter()


@router.get("/insights", response_model=InsightsResponse)
async def get_insights_data(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> InsightsResponse:
    """Return aggregated sentiment and keyword insights for the current user."""

    return await get_user_insights(current_user.id, db)
