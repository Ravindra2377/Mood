# 🎯 AI Chat Integration - File Reference Guide

## Backend Files Created/Modified

### Models (`backend/app/models/`)
- **chat_session.py** ✨ NEW
  - `ChatSession` - conversation metadata
  - `ChatMessage` - individual messages  
  - `ModerationLog` - crisis event logging
  - `UserContextCache` - personalization caching
  - All models indexed for performance

### Schemas (`backend/app/schemas/`)
- **chat.py** 📝 EXTENDED
  - Kept legacy `MessageIn`, `MessageOut`, `ConversationRead` (backward compatible)
  - Added `ChatRequest`, `ChatResponse` for streaming
  - Added `ChatMessageRead`, `ChatSessionRead` for serialization
  - Added `CrisisResponseSchema` for emergency responses
  - Added `UserContextRead` for personalization

### Services (`backend/app/services/`)
- **crisis_detection.py** ✨ NEW
  - `CrisisDetector` class with keyword lists
  - Three severity levels (CRITICAL, HIGH, MEDIUM)
  - Returns crisis resources (988, Crisis Text, 911)
  
- **ai_service.py** ✨ NEW
  - `AIService` class for OpenAI integration
  - Async streaming support
  - System prompt builder with safety rules
  - Content moderation via OpenAI API

### Controllers (`backend/app/controllers/`)
- **chat.py** 📝 EXTENDED
  - Kept legacy endpoints: `/chat/message`, `/chat/conversations`
  - Added 4 new endpoints:
    - `POST /chat/interactive` - main chat with streaming
    - `GET /chat/sessions` - list sessions
    - `GET /chat/sessions/{id}/messages` - load history
    - `DELETE /chat/sessions/{id}` - delete session
  - All new endpoints rate-limited (10/min per user)

### Model Registry (`backend/app/models/__init__.py`)
- 📝 UPDATED - Added `chat_session` import for table creation

---

## Flutter Files Created/Modified

### Models (`lib/models/`)
- **chat_models.dart** ✨ NEW
  - `MessageRole` enum (user, assistant, system)
  - `ChatMessage` with streaming support
  - `ChatSession` with session metadata
  - `CrisisResponse` for emergency handling
  - All models have JSON serialization

### Services (`lib/services/`)
- **chat_api_service.dart** ✨ NEW
  - `ChatApiService` for API communication
  - SSE stream parsing in `sendMessage()`
  - `getSessions()` - load session list
  - `getSessionMessages()` - load conversation history
  - `deleteSession()` - delete a session
  - Integrated Riverpod provider `chatApiServiceProvider`

### State Management (`lib/state/`)
- **feature_flags.dart** ✨ NEW
  - `FeatureFlags` provider for remote config
  - `enableAiChat` flag for gradual rollout
  - Also: `enableNewSelfHelp`, `enableBetaFeatures`, `enableAnalytics`
  - JSON serialization for persistence

### Controllers (`lib/features/self_help/controllers/`)
- **chat_controller.dart** ✨ NEW
  - `ChatController` extends `StateNotifier<ChatState>`
  - `sendMessage()` - stream tokens with accumulation
  - `loadHistory()` - load session messages
  - `newSession()` - create new chat
  - `deleteSession()` - remove session
  - Bonus providers: `chatSessionsProvider`, `sessionMessagesProvider`

### UI Screens (`lib/features/self_help/screens/`)
- **self_help_chat_screen.dart** ✨ NEW
  - Main chat interface
  - Welcome screen with quick starters
  - Auto-scroll with manual button
  - Menu for new chat, history, clear
  - Info dialog with disclaimers
  - Crisis dialog handling

### UI Widgets (`lib/features/self_help/widgets/`)
- **chat_bubble.dart** ✨ NEW
  - User/AI message styling with gradients
  - Timestamps on each message
  - Streaming indicator animation
  - Selectable text for copying

- **typing_indicator.dart** ✨ NEW
  - Smooth animated dots (3-dot animation)
  - Staggered timing
  - Shows AI is thinking

- **crisis_dialog.dart** ✨ NEW
  - Emergency response modal
  - Quick-tap crisis hotlines (988, 741741, 911)
  - Immediate action checklist
  - Legal disclaimers
  - Auto-calling via url_launcher

### Navigation & Configuration
- **lib/screens/self_help_screen.dart** 📝 MODIFIED
  - Added feature flag check in `_buildAiChatCard()`
  - Updated button to navigate to `SelfHelpChatScreen`
  - AI chat card hidden when `enableAiChat = false`

---

## Database Schema

### chat_sessions table
```sql
id                    VARCHAR PRIMARY KEY
user_id               INTEGER (FK users.id)
started_at            TIMESTAMP DEFAULT NOW()
ended_at              TIMESTAMP NULL
is_active             BOOLEAN DEFAULT TRUE
session_mood          VARCHAR(50)
session_intensity     INTEGER (1-10)
session_triggers      TEXT[] (array of keywords)
total_messages        INTEGER DEFAULT 0
is_crisis_escalated   BOOLEAN DEFAULT FALSE
created_at            TIMESTAMP DEFAULT NOW()
updated_at            TIMESTAMP DEFAULT NOW()

INDEXES:
- idx_chat_sessions_user_id ON (user_id)
- idx_chat_sessions_active ON (is_active)
```

### chat_messages table
```sql
id                      VARCHAR PRIMARY KEY
session_id              VARCHAR (FK chat_sessions.id)
role                    VARCHAR(20) CHECK (role IN ('user', 'assistant', 'system'))
content                 TEXT
tokens_used             INTEGER NULL
model_used              VARCHAR(50)
streaming_completed     BOOLEAN DEFAULT FALSE
flagged_by_moderation   BOOLEAN DEFAULT FALSE
contains_crisis_keywords BOOLEAN DEFAULT FALSE
response_time_ms        INTEGER NULL
created_at              TIMESTAMP DEFAULT NOW()

INDEXES:
- idx_chat_messages_session_id ON (session_id)
- idx_chat_messages_created_at ON (created_at)
```

### moderation_logs table
```sql
id                  VARCHAR PRIMARY KEY
message_id          VARCHAR (FK chat_messages.id)
user_id             INTEGER (FK users.id)
flagged_content     TEXT
moderation_reason   VARCHAR(255)
severity_level      VARCHAR(20) (low, medium, high, critical)
human_reviewed      BOOLEAN DEFAULT FALSE
reviewer_notes      TEXT NULL
created_at          TIMESTAMP DEFAULT NOW()

INDEXES:
- idx_moderation_logs_severity ON (severity_level)
```

### user_context_cache table
```sql
user_id             INTEGER PRIMARY KEY (FK users.id)
latest_mood_entry   JSON NULL
recent_activities   JSON NULL
active_pathways     JSON NULL
assessment_scores   JSON NULL
cached_at           TIMESTAMP DEFAULT NOW()
expires_at          TIMESTAMP NULL
```

---

## API Endpoints

### Legacy (Kept for backward compatibility)
- `POST /api/chat/message` - Post message to conversation
- `GET /api/chat/conversations` - List conversations
- `GET /api/chat/conversations/{id}` - Get conversation details

### New AI Chat System
- **`POST /api/chat/interactive`** - Stream chat response (SSE)
  - Request: `{ message, session_id?, include_context? }`
  - Response: SSE stream with tokens
  - Rate limit: 10 msg/min per user
  - Crisis: Returns full crisis response as JSON

- **`GET /api/chat/sessions`** - List user's sessions
  - Query params: `limit` (default 10)
  - Response: `List[SessionHistoryRead]`

- **`GET /api/chat/sessions/{session_id}/messages`** - Get session messages
  - Response: `List[ChatMessageRead]` (chronological)

- **`DELETE /api/chat/sessions/{session_id}`** - Delete session
  - Response: 204 No Content

---

## Environment Variables Required

### Backend
```env
# OpenAI
OPENAI_API_KEY=sk-xxxxx
OPENAI_MODEL=gpt-4-turbo-preview

# Database
DATABASE_URL=postgresql://user:pass@localhost/mood

# Redis (for rate limiting)
REDIS_URL=redis://localhost:6379

# Feature flags
AI_CHAT_ENABLED=true
RATE_LIMIT_CHAT=10  # messages per minute
```

### Flutter
```env
# In lib/core/config.dart
const String apiBaseUrl = 'https://api.yourdomain.com';
```

---

## Dependencies to Add

### Flutter (pubspec.yaml)
```yaml
dependencies:
  uuid: ^4.0.0           # Generate message IDs
  url_launcher: ^6.1.0   # Call 988, SMS to crisis text
  http: ^1.1.0           # SSE streaming
  intl: ^0.18.0          # Date formatting in bubbles
```

### Backend (requirements.txt)
```
openai>=1.0.0           # GPT-4 API
fastapi>=0.100.0        # Already have
slowapi>=0.1.0          # Rate limiting (check if present)
sqlalchemy>=2.0.0       # Already have
```

---

## Testing Scenarios

### Test Crisis Detection
```dart
// In Flutter, type these messages:
"I want to kill myself"        // → CrisisDialog appears
"I can't go on"                // → CrisisDialog appears
"feeling hopeless"             // → CrisisDialog appears
"I'm just sad"                 // → Normal response
```

### Test Streaming
- Messages should appear token-by-token, not all at once
- Average response time should be 2-5 seconds
- Typing indicator should animate while streaming

### Test Session Persistence
- Start a conversation
- Go back to home screen
- Return to chat
- Previous messages should still be visible

### Test Rate Limiting
- Send 10 messages in quick succession
- 11th message should fail with 429 Too Many Requests

---

## Deployment Checklist

- [ ] Set `OPENAI_API_KEY` in production
- [ ] Set `DATABASE_URL` to production PostgreSQL
- [ ] Set `REDIS_URL` for rate limiting
- [ ] Run `alembic upgrade head` to create tables
- [ ] Test with real OpenAI API (not mock)
- [ ] Set up Sentry for error tracking
- [ ] Enable CORS restrictions to production domain
- [ ] Monitor crisis detection logs
- [ ] Set up admin moderation dashboard
- [ ] Enable feature flag for beta group (5%)
- [ ] Collect feedback and iterate
- [ ] Expand feature flag to 100% of users

---

## Monitoring & Analytics

Track these metrics after launch:

```
Response Time:
- P50: < 2 seconds
- P95: < 5 seconds
- P99: < 10 seconds

Error Rate:
- Target: < 0.1%
- Watch for: API timeouts, malformed requests

Crisis Detection:
- False positives: < 5%
- False negatives: < 1%
- Escalation time: < 100ms

User Engagement:
- % of users who try chat
- Avg messages per session
- Session duration (minutes)
- Repeat user rate (%)
```

---

## Key Files Summary

| File | Purpose | Status |
|------|---------|--------|
| `backend/app/models/chat_session.py` | Database models | ✅ NEW |
| `backend/app/schemas/chat.py` | Request/response schemas | ✅ EXTENDED |
| `backend/app/services/crisis_detection.py` | Crisis keyword detection | ✅ NEW |
| `backend/app/services/ai_service.py` | OpenAI integration | ✅ NEW |
| `backend/app/controllers/chat.py` | Chat API endpoints | ✅ EXTENDED |
| `lib/models/chat_models.dart` | Dart models | ✅ NEW |
| `lib/services/chat_api_service.dart` | API client | ✅ NEW |
| `lib/state/feature_flags.dart` | Feature toggle | ✅ NEW |
| `lib/features/self_help/controllers/chat_controller.dart` | State management | ✅ NEW |
| `lib/features/self_help/screens/self_help_chat_screen.dart` | Main chat UI | ✅ NEW |
| `lib/features/self_help/widgets/chat_bubble.dart` | Message display | ✅ NEW |
| `lib/features/self_help/widgets/typing_indicator.dart` | Loading animation | ✅ NEW |
| `lib/features/self_help/widgets/crisis_dialog.dart` | Emergency resources | ✅ NEW |
| `lib/screens/self_help_screen.dart` | Navigation integration | ✅ MODIFIED |

---

## Success Criteria

✅ **Backend**
- All endpoints respond with correct status codes
- SSE streaming delivers tokens in real-time
- Crisis detection triggers on keywords
- Rate limiting blocks requests after limit
- Session data persists in database

✅ **Frontend**
- Chat screen displays without errors
- Messages stream token-by-token
- Crisis dialog appears with correct resources
- Feature flag toggles visibility
- Navigation works smoothly

✅ **Integration**
- User token automatically injected in requests
- Responses parsed correctly from SSE
- Error messages displayed to user
- Session history loads on refresh

---

**Ready for production beta testing!** 🚀
