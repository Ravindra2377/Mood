# 🚀 Mental Health Features - Quick Reference Guide

## For Backend Developers

### Starting the API
```bash
cd backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8001
```

### Viewing API Docs
```
Open: http://localhost:8001/docs (Swagger UI)
      http://localhost:8001/redoc (ReDoc)
```

### Adding New Mental Health Feature

1. **Add Model** in `app/models/mental_health_tracking.py`:
```python
class MyNewModel(Base):
    __tablename__ = 'my_new_table'
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'))
    # ... fields
    user = relationship("User", back_populates="my_new_entries")
```

2. **Add Schema** in `app/schemas/mental_health_tracking.py`:
```python
class MyNewCreate(BaseModel):
    field1: str
    field2: int

class MyNewResponse(MyNewCreate):
    id: int
    user_id: int
```

3. **Add Service Method** in `app/services/mental_health_tracking.py`:
```python
@staticmethod
def create_my_new(db: Session, user_id: int, data: MyNewCreate):
    obj = MyNewModel(user_id=user_id, **data.dict())
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj
```

4. **Add Route** in `app/controllers/mental_health_tracking.py`:
```python
@router.post("/my-feature/endpoint", response_model=MyNewResponse)
def create_my_feature(
    data: MyNewCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return MyService.create_my_new(db, current_user.id, data)
```

---

## For Frontend Developers

### Adding Mental Health Screen

1. **Create Screen** (`lib/screens/feature_name_screen.dart`):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyFeatureScreen extends ConsumerStatefulWidget {
  const MyFeatureScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MyFeatureScreen> createState() => _MyFeatureScreenState();
}

class _MyFeatureScreenState extends ConsumerState<MyFeatureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Feature')),
      body: // ... UI
    );
  }
}
```

2. **Create Provider** (`lib/providers/feature_provider.dart`):
```dart
final featureProvider = FutureProvider<List>((ref) async {
  // Fetch from API
});

final featureCreateProvider = FutureProvider<Response>((ref) async {
  // Send to API
});
```

3. **Use in Widget**:
```dart
final data = ref.watch(featureProvider);
data.when(
  data: (items) => ListView(children: items.map((e) => ListTile(title: Text(e.name))).toList()),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

---

## API Quick Reference

### Authentication
```
Header: Authorization: Bearer <JWT_TOKEN>
```

### Stress Endpoints
```
POST   /api/v1/mental-health/stress/log
POST   /api/v1/mental-health/stress/exercise
POST   /api/v1/mental-health/stress/journal
GET    /api/v1/mental-health/stress/trends?days=30
```

### Mood Endpoints
```
POST   /api/v1/mental-health/mood/activity
POST   /api/v1/mental-health/mood/gratitude
GET    /api/v1/mental-health/mood/insights?days=30
```

### Sleep Endpoints
```
POST   /api/v1/mental-health/sleep/log
POST   /api/v1/mental-health/sleep/factors
GET    /api/v1/mental-health/sleep/trends?days=30
```

### Mindfulness Endpoints
```
POST   /api/v1/mental-health/mindfulness/session
GET    /api/v1/mental-health/mindfulness/stats
GET    /api/v1/mental-health/mindfulness/achievements
GET    /api/v1/mental-health/mindfulness/library
```

### Anxiety Endpoints
```
POST   /api/v1/mental-health/anxiety/log
POST   /api/v1/mental-health/anxiety/coping
PUT    /api/v1/mental-health/anxiety/safety-plan
GET    /api/v1/mental-health/anxiety/crisis-alerts
```

### Wellness Endpoints
```
POST   /api/v1/mental-health/wellness/checkin
POST   /api/v1/mental-health/wellness/lifestyle
POST   /api/v1/mental-health/wellness/goal
GET    /api/v1/mental-health/wellness/score
GET    /api/v1/mental-health/wellness/goals
POST   /api/v1/mental-health/goals/select
GET    /api/v1/mental-health/goals/selected
```

---

## Common Request Examples

### Log Stress
```json
POST /api/v1/mental-health/stress/log
{
  "level": 7,
  "triggers": ["work", "family"],
  "notes": "Had a difficult day"
}
```

### Log Mood Activity
```json
POST /api/v1/mental-health/mood/activity
{
  "activity_type": "exercise",
  "activity_name": "30 min run",
  "mood_before": 5,
  "mood_after": 8,
  "duration_minutes": 30,
  "effectiveness_rating": 4
}
```

### Log Sleep
```json
POST /api/v1/mental-health/sleep/log
{
  "bedtime": "2025-10-19T22:00:00Z",
  "wake_time": "2025-10-20T06:30:00Z",
  "quality_rating": 4,
  "notes": "Good sleep"
}
```

### Log Meditation
```json
POST /api/v1/mental-health/mindfulness/session
{
  "meditation_type": "guided",
  "meditation_id": "med_123",
  "title": "10 min calm",
  "duration_seconds": 600,
  "mood_before": 5,
  "mood_after": 7
}
```

### Log Anxiety
```json
POST /api/v1/mental-health/anxiety/log
{
  "level": 6,
  "triggers": ["presentation"],
  "symptoms": ["racing_heart", "sweating"],
  "duration_minutes": 15,
  "intensity": "moderate"
}
```

### Daily Wellness Checkin
```json
POST /api/v1/mental-health/wellness/checkin
{
  "date": "2025-10-19T12:00:00Z",
  "mood": 7,
  "energy": 6,
  "stress": 5,
  "sleep_quality": 4,
  "overall_wellness": 6
}
```

### Select Wellness Goals
```json
POST /api/v1/mental-health/goals/select
{
  "goal_categories": [
    "managing_stress",
    "improving_mood",
    "better_sleep"
  ],
  "customization_preferences": {
    "reminder_frequency": "daily",
    "preferred_time": "09:00"
  }
}
```

---

## Error Handling

### Common Errors
```
400 Bad Request - Invalid input (check schema)
401 Unauthorized - Missing/invalid token
403 Forbidden - User doesn't have permission
404 Not Found - Resource doesn't exist
500 Internal Server Error - Server error
```

### Example Error Response
```json
{
  "detail": "Field validation error: level must be between 1-10"
}
```

---

## Database Queries (SQL)

### Get User's Stress Logs
```sql
SELECT * FROM stress_logs 
WHERE user_id = ? AND timestamp >= NOW() - INTERVAL '30 days'
ORDER BY timestamp DESC;
```

### Get Average Mood This Week
```sql
SELECT AVG(mood_after) as avg_mood
FROM mood_activities
WHERE user_id = ? AND completed_at >= NOW() - INTERVAL '7 days';
```

### Get Meditation Streak
```sql
SELECT COUNT(DISTINCT DATE(completed_at)) as streak
FROM meditation_sessions
WHERE user_id = ?
  AND completed_at >= NOW() - INTERVAL '30 days'
ORDER BY completed_at DESC;
```

### Get Most Effective Exercises
```sql
SELECT exercise_name, AVG(effectiveness_rating) as avg_effectiveness, COUNT(*) as times_used
FROM stress_exercises
WHERE user_id = ? AND effectiveness_rating IS NOT NULL
GROUP BY exercise_name
ORDER BY avg_effectiveness DESC;
```

---

## Debugging Tips

### Check Backend Logs
```bash
# Terminal with running backend will show:
# GET /api/v1/mental-health/stress/log 200 OK
# POST /api/v1/mental-health/mood/activity 201 Created
```

### Use Postman Collection
```
1. Open Postman
2. Import: http://localhost:8001/docs
3. Select endpoint to test
4. Add Authorization header
5. Send request
```

### Common Issues

**401 Unauthorized**
- Check JWT token is valid
- Token might be expired
- Check Authorization header format

**400 Bad Request**
- Validate request schema against API docs
- Check field types and ranges
- Required fields might be missing

**500 Internal Server Error**
- Check backend console for error message
- Check database connection
- Check if migration was run

---

## Testing Endpoints with Curl

### Test Stress Logging
```bash
TOKEN="your_jwt_token"
curl -X POST http://localhost:8001/api/v1/mental-health/stress/log \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "level": 7,
    "triggers": ["work"],
    "notes": "Testing"
  }'
```

### Test Analytics
```bash
curl -X GET "http://localhost:8001/api/v1/mental-health/stress/trends?days=30" \
  -H "Authorization: Bearer $TOKEN"
```

### Test with jq (pretty print)
```bash
curl -X GET "http://localhost:8001/api/v1/mental-health/wellness/score" \
  -H "Authorization: Bearer $TOKEN" | jq '.'
```

---

## Performance Optimization

### Database Indexes
Already created for:
- user_id (all tables)
- timestamp/created_at (all tables)
- level fields (for sorting)

### Caching Strategy
- Trends: Cache for 1 hour
- Stats: Cache for 15 minutes
- Recommendations: Cache for 24 hours

### Query Optimization
- Use pagination for large datasets
- Filter by date range when possible
- Limit results to last 90 days for analytics

---

## Future Enhancements

### Planned APIs
- [ ] Export data (CSV, JSON)
- [ ] Share achievements
- [ ] Group challenges
- [ ] Therapist integration
- [ ] Health app sync

### Planned Features
- [ ] ML predictions
- [ ] Notifications
- [ ] Offline sync
- [ ] Social features
- [ ] Wearable integration

---

## Code Style Guidelines

### Python (Backend)
```python
# Follow PEP 8
# Use type hints
# Add docstrings
# Use meaningful variable names
```

### Dart (Frontend)
```dart
// Follow dart style guide
// Use const constructors
// Add documentation comments
// Use meaningful naming
```

---

## Resources

- **API Docs**: http://localhost:8001/docs (when running)
- **Implementation Guide**: `MENTAL_HEALTH_IMPLEMENTATION_GUIDE.md`
- **Delivery Package**: `MENTAL_HEALTH_DELIVERY_PACKAGE.md`
- **Implementation Summary**: `IMPLEMENTATION_SUMMARY.md`

---

## Quick Checklist for New Feature

- [ ] Model created in `models/mental_health_tracking.py`
- [ ] Schema created in `schemas/mental_health_tracking.py`
- [ ] Service method in `services/mental_health_tracking.py`
- [ ] Route in `controllers/mental_health_tracking.py`
- [ ] Route imported in `main.py`
- [ ] Tested with curl/Postman
- [ ] Documentation updated
- [ ] Database migration created
- [ ] Tests written (optional)

---

## Contact & Support

For questions, check:
1. Inline code comments
2. Documentation files
3. Swagger API docs
4. Existing implementations
5. GitHub issues

---

**Last Updated**: October 19, 2025
**Quick Reference v1.0**
