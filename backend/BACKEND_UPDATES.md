# Backend Updates - Frontend Changes Integration

## Overview
This document details all backend updates made to support the new frontend features:
- Enhanced meditation screen with audio/ambient sound options
- Expression screen with mood tracking and character count
- Renamed "Yoga" activity to "Meditation"
- Profile screen enhancements
- All mental health dashboard updates

## Database Changes

### 1. Journal Entries Model Enhancement

**File**: `app/models/journal_entry.py`

**Changes**:
- Added `JournalMood` enum with values: `ANGRY`, `SAD`, `NEUTRAL`, `HAPPY`, `EXCITED`
- Added `mood` field (SQLEnum) to track emotional state during journaling
- Added `character_count` field (Integer) to track entry length for analytics

**Migration**: `m1_add_journal_mood_character_count.py`

### 2. Schema Updates

**File**: `app/schemas/journal.py`

**Changes**:
- Added `mood` field to `JournalCreate` (default: "neutral")
- Added `mood` and `character_count` fields to `JournalRead`
- Added `mood` field to `JournalUpdate`
- Added new `JournalStats` schema with:
  - `total_entries`: Total journal entries created
  - `this_week`: Entries from past 7 days
  - `this_month`: Entries from past 30 days
  - `mood_breakdown`: Dictionary of mood counts
  - `average_length`: Average character count
  - `last_entry_date`: When last entry was created

## API Endpoints

### Journal Endpoints

#### GET `/api/journal`
List user's journal entries with filtering and pagination.

**Query Parameters**:
- `page` (int, default=1): Page number for pagination
- `limit` (int, default=10): Items per page (max 100)
- `from` (str, optional): Start date (ISO format)
- `to` (str, optional): End date (ISO format)
- `mood` (str, optional): Filter by mood (angry|sad|neutral|happy|excited)

**Response**: List of `JournalRead` objects sorted by latest first

**Example**:
```bash
GET /api/journal?page=1&limit=20&mood=happy&from=2025-10-01T00:00:00Z
```

#### POST `/api/journal`
Create a new journal entry with mood tracking.

**Request Body**:
```json
{
  "title": "My thoughts",
  "content": "Today was a good day...",
  "mood": "happy",
  "entry_date": "2025-10-19T00:00:00Z",
  "progress": 75
}
```

**Response**: `JournalRead` object with created entry

**Features**:
- Automatically calculates character count
- Records analytics event
- Stores mood for emotional context

#### GET `/api/journal/{entry_id}`
Get a specific journal entry (user can only see their own).

**Response**: `JournalRead` object

#### PUT `/api/journal/{entry_id}`
Update a journal entry.

**Request Body**:
```json
{
  "title": "Updated title",
  "content": "Updated content...",
  "mood": "excited"
}
```

**Response**: Updated `JournalRead` object

#### DELETE `/api/journal/{entry_id}`
Delete a journal entry.

**Response**: 
```json
{
  "message": "Journal entry deleted successfully"
}
```

#### GET `/api/journal/stats/summary`
Get journal statistics for the user.

**Response**: `JournalStats` object
```json
{
  "total_entries": 42,
  "this_week": 5,
  "this_month": 15,
  "mood_breakdown": {
    "angry": 2,
    "sad": 3,
    "neutral": 10,
    "happy": 20,
    "excited": 7
  },
  "average_length": 245.5,
  "last_entry_date": "2025-10-19T14:30:00Z"
}
```

### Meditation Endpoints

#### GET `/api/meditation/audio-tracks`
Get all available ambient sound/audio tracks for meditation.

**Response**: List of `AudioTrack` objects
```json
[
  {
    "id": "ocean",
    "name": "Ocean breeze",
    "icon": "🌊",
    "duration_minutes": 5,
    "description": "Soothing ocean wave sounds",
    "file_path": "assets/audio/ocean_breeze.mp3"
  },
  ...
]
```

**Available Tracks**:
1. `ocean` - Ocean breeze 🌊 (5 min)
2. `rain` - Rain sounds 🌧️ (5 min)
3. `forest` - Forest birds 🌲 (5 min)
4. `white_noise` - White noise 🎵 (5 min)
5. `piano` - Calm piano 🎹 (5 min)
6. `meditation` - Meditation bells 🔔 (5 min)
7. `nature` - Nature symphony 🦅 (10 min)
8. `stream` - Flowing stream 💧 (10 min)

#### GET `/api/meditation/audio-tracks/{track_id}`
Get specific audio track details.

**Response**: Single `AudioTrack` object

#### POST `/api/meditation/session`
Record meditation session start.

**Request Body**:
```json
{
  "duration_minutes": 5,
  "ambient_sound": "ocean"
}
```

**Response**:
```json
{
  "message": "Meditation session started",
  "user_id": 123,
  "duration_minutes": 5,
  "ambient_sound": "ocean",
  "start_time": "2025-10-19T14:30:00Z"
}
```

#### POST `/api/meditation/session/complete`
Record meditation session completion with feedback.

**Request Body**:
```json
{
  "duration_minutes": 5,
  "ambient_sound": "ocean",
  "focus_rating": 4,
  "notes": "Felt very relaxed"
}
```

**Response**:
```json
{
  "message": "Meditation session completed",
  "user_id": 123,
  "duration_minutes": 5,
  "ambient_sound": "ocean",
  "focus_rating": 4,
  "completed_at": "2025-10-19T14:35:00Z"
}
```

#### GET `/api/meditation/stats`
Get user's meditation statistics.

**Response**:
```json
{
  "total_sessions": 87,
  "this_week": 5,
  "total_minutes": 562,
  "average_focus_rating": 4.2,
  "favorite_sound": "ocean",
  "streak_days": 12
}
```

## Running Migrations

```bash
# Navigate to backend
cd backend

# Run pending migrations
alembic upgrade head

# Create new migration
alembic revision --autogenerate -m "description"

# Rollback
alembic downgrade -1
```

## Testing the Endpoints

### Using cURL

```bash
# Get audio tracks
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8000/api/meditation/audio-tracks

# Create journal entry
curl -X POST http://localhost:8000/api/journal \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Today was great!",
    "mood": "happy",
    "title": "Great day"
  }'

# Get journal stats
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:8000/api/journal/stats/summary
```

### Using Python

```python
import requests

headers = {
    "Authorization": "Bearer YOUR_TOKEN"
}

# Get audio tracks
response = requests.get(
    "http://localhost:8000/api/meditation/audio-tracks",
    headers=headers
)
print(response.json())

# Create journal entry
data = {
    "content": "My journal entry",
    "mood": "happy",
    "title": "Day entry"
}
response = requests.post(
    "http://localhost:8000/api/journal",
    headers=headers,
    json=data
)
print(response.json())
```

## Database Schema

### journal_entries table (updated)

```sql
CREATE TABLE journal_entries (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    title VARCHAR,
    content TEXT NOT NULL,
    mood ENUM('angry', 'sad', 'neutral', 'happy', 'excited') DEFAULT 'neutral',
    character_count INTEGER,
    encryption_key TEXT,
    created_at DATETIME WITH TIMEZONE,
    entry_date DATE,
    progress INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

## Analytics Events Recorded

### Journal Events
- `journal_entry_created`: Logged when new entry created
  - Fields: `mood`, `character_count`
- `journal_entry_updated`: Logged when entry modified
  - Fields: `entry_id`, `mood`
- `journal_entry_deleted`: Logged when entry deleted
  - Fields: `entry_id`

### Meditation Events
- `meditation_session_started`: Logged when user starts meditation
  - Fields: `duration_minutes`, `ambient_sound`, `timestamp`
- `meditation_session_completed`: Logged when meditation ends
  - Fields: `duration_minutes`, `ambient_sound`, `focus_rating`, `has_notes`, `timestamp`

## Activity Type Update

### Changelog
- Renamed activity type from `yoga` to `meditation`
- Activity type is tracked in the database via the activity tracking system
- Frontend displays "Meditation" instead of "Yoga"
- All references updated across the codebase

## Error Handling

All endpoints return standard HTTP status codes:

- **200**: Success
- **201**: Created
- **400**: Bad request (invalid input)
- **401**: Unauthorized (missing/invalid token)
- **404**: Not found (resource doesn't exist)
- **500**: Server error

**Error Response Format**:
```json
{
  "detail": "Error message describing what went wrong"
}
```

## Security Considerations

1. **Authentication**: All endpoints require valid JWT token in Authorization header
2. **Authorization**: Users can only access their own data
3. **Rate Limiting**: Endpoints are rate-limited per user
4. **Validation**: All inputs are validated before processing
5. **Encryption**: Journal entries can be encrypted (existing feature)

## Performance Optimizations

1. Pagination on journal list endpoint (max 100 items per page)
2. Indexed queries on `user_id` and `created_at`
3. Efficient mood breakdown aggregation
4. Lazy loading for related data

## Future Enhancements

- [ ] AI sentiment analysis of journal entries
- [ ] Mood trend analysis and visualization
- [ ] Integration with wearable devices for meditation metrics
- [ ] Voice-to-text for journal entries
- [ ] Journal entry suggestions based on mood
- [ ] Meditation streak tracking persistence
- [ ] Social sharing of meditation achievements

## Deployment Notes

1. Run database migrations before deploying backend
2. Ensure audio files are accessible via frontend asset paths
3. Update frontend API client to point to new endpoints
4. Test all journal and meditation endpoints with real user data
5. Monitor analytics events to ensure proper tracking

---

**Last Updated**: October 19, 2025
**Backend Version**: Aligned with Frontend v1.0.0
