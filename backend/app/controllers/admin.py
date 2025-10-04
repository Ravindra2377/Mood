from fastapi import APIRouter, Depends, Response
from app.dependencies import require_role
from pathlib import Path

router = APIRouter()


@router.get('/analytics')
def serve_admin_analytics(_=Depends(require_role('admin'))):
    p = Path(__file__).parent.parent.parent / 'components' / 'admin_analytics.html'
    if not p.exists():
        return Response('Not found', status_code=404)
    return Response(p.read_bytes(), media_type='text/html')
