from fastapi import APIRouter, Depends, HTTPException, Header
from typing import List, Optional
from datetime import datetime, timezone
from app.models.user import User
from app.services import security
from app.services.analytics import record_event
from pydantic import BaseModel

router = APIRouter()

# Models for meditation sessions
class AudioTrack(BaseModel):
    id: str
    name: str
    icon: str
    duration_minutes: int
    description: Optional[str] = None
    file_path: str

class MeditationSession(BaseModel):
    id: str
    user_id: int
    duration_minutes: int
    ambient_sound: str
    start_time: datetime
    end_time: Optional[datetime] = None
    focus_rating: Optional[int] = None  # 1-5 rating
    notes: Optional[str] = None

# Available audio tracks
AUDIO_TRACKS = [
    AudioTrack(
        id="ocean",
        name="Ocean breeze",
        icon="🌊",
        duration_minutes=5,
        description="Soothing ocean wave sounds",
        file_path="assets/audio/ocean_breeze.mp3"
    ),
    AudioTrack(
        id="rain",
        name="Rain sounds",
        icon="🌧️",
        duration_minutes=5,
        description="Relaxing rainfall ambience",
        file_path="assets/audio/rain_sounds.mp3"
    ),
    AudioTrack(
        id="forest",
        name="Forest birds",
        icon="🌲",
        duration_minutes=5,
        description="Nature sounds with birds chirping",
        file_path="assets/audio/forest_birds.mp3"
    ),
    AudioTrack(
        id="white_noise",
        name="White noise",
        icon="🎵",
        duration_minutes=5,
        description="Classic white noise for deep focus",
        file_path="assets/audio/white_noise.mp3"
    ),
    AudioTrack(
        id="piano",
        name="Calm piano",
        icon="🎹",
        duration_minutes=5,
        description="Gentle piano melodies",
        file_path="assets/audio/calm_piano.mp3"
    ),
    AudioTrack(
        id="meditation",
        name="Meditation bells",
        icon="🔔",
        duration_minutes=5,
        description="Mindfulness bell sounds",
        file_path="assets/audio/meditation_bells.mp3"
    ),
    AudioTrack(
        id="nature",
        name="Nature symphony",
        icon="🦅",
        duration_minutes=10,
        description="Mixed nature soundscape",
        file_path="assets/audio/nature_symphony.mp3"
    ),
    AudioTrack(
        id="stream",
        name="Flowing stream",
        icon="💧",
        duration_minutes=10,
        description="Peaceful stream water sounds",
        file_path="assets/audio/flowing_stream.mp3"
    ),
]

def get_current_user(authorization: Optional[str] = Header(None)) -> User:
    if not authorization:
        raise HTTPException(status_code=401, detail='Missing authorization header')
    try:
        scheme, token = authorization.split()
    except Exception:
        raise HTTPException(status_code=401, detail='Invalid authorization header')
    payload = security.decode_access_token(token)
    if not payload or 'sub' not in payload:
        raise HTTPException(status_code=401, detail='Invalid token')
    user_id = int(payload['sub'])
    from app.main import SessionLocal
    db = SessionLocal()
    try:
        user = db.query(User).get(user_id)
        if not user:
            raise HTTPException(status_code=401, detail='User not found')
        return user
    finally:
        db.close()

@router.get('/meditation/audio-tracks', response_model=List[AudioTrack])
def get_audio_tracks(user: User = Depends(get_current_user)):
    """
    Get all available ambient sound/audio tracks for meditation
    """
    return AUDIO_TRACKS

@router.get('/meditation/audio-tracks/{track_id}', response_model=AudioTrack)
def get_audio_track(track_id: str, user: User = Depends(get_current_user)):
    """
    Get a specific audio track details
    """
    track = next((t for t in AUDIO_TRACKS if t.id == track_id), None)
    if not track:
        raise HTTPException(status_code=404, detail='Audio track not found')
    return track

@router.post('/meditation/session')
def start_meditation_session(
    duration_minutes: int,
    ambient_sound: str,
    user: User = Depends(get_current_user)
):
    """
    Record meditation session start
    """
    # Validate audio track exists
    if not any(t.id == ambient_sound for t in AUDIO_TRACKS):
        raise HTTPException(status_code=400, detail='Invalid ambient sound')
    
    # Record analytics event
    record_event(user.id, 'meditation_session_started', {
        'duration_minutes': duration_minutes,
        'ambient_sound': ambient_sound,
        'timestamp': datetime.now(timezone.utc).isoformat()
    })
    
    return {
        'message': 'Meditation session started',
        'user_id': user.id,
        'duration_minutes': duration_minutes,
        'ambient_sound': ambient_sound,
        'start_time': datetime.now(timezone.utc)
    }

@router.post('/meditation/session/complete')
def complete_meditation_session(
    duration_minutes: int,
    ambient_sound: str,
    focus_rating: Optional[int] = None,
    notes: Optional[str] = None,
    user: User = Depends(get_current_user)
):
    """
    Record meditation session completion with feedback
    """
    # Validate focus rating
    if focus_rating is not None and not (1 <= focus_rating <= 5):
        raise HTTPException(status_code=400, detail='Focus rating must be between 1 and 5')
    
    # Record analytics event
    record_event(user.id, 'meditation_session_completed', {
        'duration_minutes': duration_minutes,
        'ambient_sound': ambient_sound,
        'focus_rating': focus_rating,
        'has_notes': bool(notes),
        'timestamp': datetime.now(timezone.utc).isoformat()
    })
    
    return {
        'message': 'Meditation session completed',
        'user_id': user.id,
        'duration_minutes': duration_minutes,
        'ambient_sound': ambient_sound,
        'focus_rating': focus_rating,
        'completed_at': datetime.now(timezone.utc)
    }

@router.get('/meditation/stats')
def get_meditation_stats(user: User = Depends(get_current_user)):
    """
    Get user's meditation statistics
    """
    from app.main import SessionLocal
    from sqlalchemy import func
    
    db = SessionLocal()
    try:
        # Get meditation sessions from analytics (if stored)
        # This is a placeholder - actual implementation depends on your analytics storage
        
        return {
            'total_sessions': 0,
            'this_week': 0,
            'total_minutes': 0,
            'average_focus_rating': 0,
            'favorite_sound': None,
            'streak_days': 0
        }
    finally:
        db.close()
