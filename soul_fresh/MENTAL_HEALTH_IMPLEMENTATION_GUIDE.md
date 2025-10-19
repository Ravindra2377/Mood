# Mental Health Features Implementation - Complete Guide

## 📋 Project Overview

This document outlines the comprehensive implementation of 6 mental health goal tracking features for the Mood wellness app. The implementation includes backend services, API endpoints, database models, and Flutter UI components.

## 🎯 Feature Categories

### 1. **Managing Stress** 😰

#### Backend Components
- **Models**: `StressLog`, `StressExercise`, `StressJournalEntry`
- **Key Endpoints**:
  - `POST /api/v1/mental-health/stress/log` - Log stress level (1-10)
  - `POST /api/v1/mental-health/stress/exercise` - Log completed exercise
  - `POST /api/v1/mental-health/stress/journal` - Create journal entry
  - `GET /api/v1/mental-health/stress/trends` - Get stress analysis

#### Database Schema
```sql
-- StressLog: Track daily stress levels
CREATE TABLE stress_logs (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  level INT (1-10),
  triggers JSONB (list of stress triggers),
  notes TEXT,
  timestamp DATETIME,
  created_at DATETIME
);

-- StressExercise: Track completed relief exercises
CREATE TABLE stress_exercises (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  exercise_type VARCHAR (breathing, muscle_relaxation, etc),
  exercise_name VARCHAR,
  duration_seconds INT,
  effectiveness_rating INT (1-5),
  notes TEXT,
  completed_at DATETIME,
  created_at DATETIME
);

-- StressJournalEntry: Dedicated journal for stress reflection
CREATE TABLE stress_journal_entries (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  title VARCHAR,
  content TEXT,
  stress_level_before INT (1-10),
  stress_level_after INT (1-10),
  triggers JSONB,
  coping_strategies_used JSONB,
  created_at DATETIME,
  updated_at DATETIME
);
```

#### Analytics
- Weekly/monthly stress level trends
- Most common stress triggers
- Most effective relief exercises
- Correlation with other factors

#### Frontend Features (Flutter)
- **Stress Tracker Widget**: Daily stress level input (1-10 scale)
- **Breathing Exercises**: Guided 4-7-8, box breathing
- **Stress Journal**: Prompts and entry management
- **Relief Tools Library**: Collection of techniques

---

### 2. **Improving Mood** 😊

#### Backend Components
- **Models**: `MoodActivity`, `MoodCorrelation`, `GratitudeEntry`
- **Key Endpoints**:
  - `POST /api/v1/mental-health/mood/activity` - Log mood activity
  - `POST /api/v1/mental-health/mood/gratitude` - Create gratitude entry
  - `GET /api/v1/mental-health/mood/insights` - Get mood analysis

#### Database Schema
```sql
-- MoodActivity: Track mood-boosting activities
CREATE TABLE mood_activities (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  activity_type VARCHAR (music, exercise, socializing, etc),
  activity_name VARCHAR,
  mood_before INT (1-10),
  mood_after INT (1-10),
  duration_minutes INT,
  effectiveness_rating INT (1-5),
  notes TEXT,
  completed_at DATETIME,
  created_at DATETIME
);

-- MoodCorrelation: Store mood-factor correlations
CREATE TABLE mood_correlations (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  factor_type VARCHAR (activity, sleep, weather, etc),
  factor_value VARCHAR,
  correlation_score FLOAT (-1.0 to 1.0),
  data_points INT,
  last_updated DATETIME
);

-- GratitudeEntry: Gratitude journal
CREATE TABLE gratitude_entries (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  content TEXT,
  mood_before INT (1-10),
  mood_after INT (1-10),
  category VARCHAR (health, relationships, work, etc),
  created_at DATETIME
);
```

#### Analytics
- Average mood over time
- Mood trends (improving/declining/stable)
- Most effective activities
- Correlations between mood and other factors
- Personalized recommendations

#### Frontend Features (Flutter)
- **Mood Calendar**: Visual mood tracking
- **Activity Logger**: Quick activity logging
- **Gratitude Journal**: Daily gratitude prompts
- **Mood Insights Dashboard**: Trends and recommendations
- **Activity Feed**: Suggested activities based on mood

---

### 3. **Better Sleep** 😴

#### Backend Components
- **Models**: `SleepLog`, `SleepFactor`, `SleepMeditation`
- **Key Endpoints**:
  - `POST /api/v1/mental-health/sleep/log` - Log sleep session
  - `POST /api/v1/mental-health/sleep/factors` - Log sleep factors
  - `GET /api/v1/mental-health/sleep/trends` - Get sleep analysis

#### Database Schema
```sql
-- SleepLog: Track sleep duration and quality
CREATE TABLE sleep_logs (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  bedtime DATETIME,
  wake_time DATETIME,
  duration_hours FLOAT,
  quality_rating INT (1-5 stars),
  notes TEXT,
  created_at DATETIME
);

-- SleepFactor: Track factors affecting sleep
CREATE TABLE sleep_factors (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  date DATETIME,
  caffeine_intake FLOAT (mg),
  alcohol_intake FLOAT (standard drinks),
  exercise_minutes INT,
  screen_time_minutes INT,
  stress_level INT (1-10),
  notes TEXT,
  created_at DATETIME
);

-- SleepMeditation: Track sleep meditation sessions
CREATE TABLE sleep_meditations (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  meditation_id VARCHAR,
  title VARCHAR,
  duration_seconds INT,
  fell_asleep BOOLEAN,
  quality_rating INT (1-5),
  completed_at DATETIME,
  created_at DATETIME
);
```

#### Analytics
- Sleep duration trends
- Sleep quality patterns
- Sleep debt calculation
- Factor correlation analysis
- Sleep hygiene score

#### Frontend Features (Flutter)
- **Sleep Tracker**: Bedtime and wake time logging
- **Sleep Quality Rating**: 1-5 star system
- **Sleep Hygiene Tips**: Personalized recommendations
- **Sleep Meditations**: Guided sleep audio
- **Sleep Analytics**: Duration, quality, patterns
- **Sleep Debt Calculator**: Hours owed vs. optimal

---

### 4. **Mindfulness Practice** 🧘

#### Backend Components
- **Models**: `MeditationSession`, `MindfulnessAchievement`, `MeditationContent`
- **Key Endpoints**:
  - `POST /api/v1/mental-health/mindfulness/session` - Log meditation
  - `GET /api/v1/mental-health/mindfulness/stats` - Get statistics
  - `GET /api/v1/mental-health/mindfulness/achievements` - Get achievements
  - `GET /api/v1/mental-health/mindfulness/library` - Get meditation library

#### Database Schema
```sql
-- MeditationSession: Track meditation practice
CREATE TABLE meditation_sessions (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  meditation_type VARCHAR (guided, body_scan, breathing, etc),
  meditation_id VARCHAR,
  title VARCHAR,
  duration_seconds INT,
  mood_before INT (1-10),
  mood_after INT (1-10),
  focus_level INT (1-5),
  notes TEXT,
  completed_at DATETIME,
  created_at DATETIME
);

-- MindfulnessAchievement: Track achievements
CREATE TABLE mindfulness_achievements (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  achievement_type VARCHAR (streak_7, streak_30, total_hours_100, etc),
  achievement_name VARCHAR,
  description TEXT,
  unlocked_at DATETIME
);

-- MeditationContent: Library of meditation content
CREATE TABLE meditation_content (
  id INT PRIMARY KEY,
  title VARCHAR,
  description TEXT,
  meditation_type VARCHAR,
  duration_seconds INT,
  category VARCHAR (sleep, stress, focus, anxiety, etc),
  audio_url VARCHAR,
  thumbnail_url VARCHAR,
  instructor_name VARCHAR,
  difficulty_level VARCHAR (beginner, intermediate, advanced),
  language VARCHAR (default: en),
  created_at DATETIME,
  is_active BOOLEAN
);
```

#### Gamification
- **Streak Tracking**: Current and longest streaks
- **Achievements**: 
  - First week (7 sessions)
  - Meditation master (30 sessions)
  - Total hours milestones
- **Leaderboards**: Optional anonymous leaderboards

#### Frontend Features (Flutter)
- **Meditation Library**: Filterable by type, duration, difficulty
- **Session Logger**: Track completed sessions
- **Streak Counter**: Visual streak display
- **Achievement Badges**: Unlocked achievements
- **Progress Dashboard**: Total minutes, sessions, trends
- **Mood Before/After**: Track meditation impact

---

### 5. **Coping with Anxiety** 😰

#### Backend Components
- **Models**: `AnxietyLog`, `AnxietyCopingTechnique`, `SafetyPlan`, `CrisisAlert`
- **Key Endpoints**:
  - `POST /api/v1/mental-health/anxiety/log` - Log anxiety episode
  - `POST /api/v1/mental-health/anxiety/coping` - Log coping technique
  - `PUT /api/v1/mental-health/anxiety/safety-plan` - Update safety plan
  - `GET /api/v1/mental-health/anxiety/crisis-alerts` - Get crisis alerts

#### Database Schema
```sql
-- AnxietyLog: Track anxiety episodes
CREATE TABLE anxiety_logs (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  level INT (1-10),
  triggers JSONB (list of triggers),
  symptoms JSONB (racing_heart, sweating, etc),
  duration_minutes INT,
  intensity VARCHAR (mild, moderate, severe),
  is_panic_attack BOOLEAN,
  notes TEXT,
  created_at DATETIME
);

-- AnxietyCopingTechnique: Track coping technique effectiveness
CREATE TABLE anxiety_coping_techniques (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  technique_name VARCHAR,
  technique_type VARCHAR (physical, mental, behavioral),
  description TEXT,
  duration_minutes INT,
  effectiveness_rating INT (1-5),
  anxiety_level_before INT (1-10),
  anxiety_level_after INT (1-10),
  used_at DATETIME,
  created_at DATETIME
);

-- SafetyPlan: User's crisis safety plan
CREATE TABLE safety_plans (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY (UNIQUE),
  warning_signs JSONB,
  internal_coping JSONB,
  people_to_contact JSONB (friends/family),
  professional_contacts JSONB (therapist/doctor),
  crisis_hotlines JSONB (emergency numbers),
  ways_to_make_environment_safer JSONB,
  plan_content TEXT,
  updated_at DATETIME,
  created_at DATETIME
);

-- CrisisAlert: Track crisis alerts
CREATE TABLE crisis_alerts (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  alert_level VARCHAR (low, medium, high, critical),
  trigger_reason VARCHAR,
  description TEXT,
  intervention_provided VARCHAR,
  is_resolved BOOLEAN,
  resolved_at DATETIME,
  triggered_at DATETIME,
  created_at DATETIME
);
```

#### Crisis Management
- **ML Detection**: Automatic crisis detection
- **Escalation Protocols**: Appropriate response levels
- **Safety Planning**: User-created safety plans
- **Emergency Integration**: Crisis hotline info

#### Frontend Features (Flutter)
- **Anxiety Tracker**: Episode logging with intensity
- **Symptom Checklist**: Physical symptoms tracking
- **Trigger Identification**: Pattern recognition
- **Panic SOS Button**: Quick access to calming exercises
- **Coping Techniques Library**: Evidence-based techniques
- **Grounding Exercises**: 5-4-3-2-1, breathing, etc.
- **Safety Plan Manager**: Create and manage safety plans
- **Crisis Support**: Emergency contacts and hotlines

---

### 6. **General Wellness** 🌟

#### Backend Components
- **Models**: `WellnessScore`, `LifestyleLog`, `WellnessGoal`, `DailyCheckin`, `UserGoalSelection`
- **Key Endpoints**:
  - `POST /api/v1/mental-health/wellness/checkin` - Daily check-in
  - `POST /api/v1/mental-health/wellness/lifestyle` - Log activity
  - `POST /api/v1/mental-health/wellness/goal` - Create goal
  - `GET /api/v1/mental-health/wellness/score` - Get wellness score
  - `GET /api/v1/mental-health/goals/selected` - Get selected goals

#### Database Schema
```sql
-- WellnessScore: Overall wellness calculation
CREATE TABLE wellness_scores (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  date DATETIME,
  overall_score FLOAT (0-100),
  stress_score FLOAT,
  mood_score FLOAT,
  sleep_score FLOAT,
  anxiety_score FLOAT,
  exercise_score FLOAT,
  social_score FLOAT,
  nutrition_score FLOAT,
  component_scores JSONB,
  created_at DATETIME
);

-- LifestyleLog: Track lifestyle activities
CREATE TABLE lifestyle_logs (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  activity_type VARCHAR (exercise, nutrition, social, screen_time),
  activity_name VARCHAR,
  value FLOAT,
  unit VARCHAR (minutes, calories, servings, etc),
  intensity VARCHAR (low, moderate, high),
  notes TEXT,
  logged_at DATETIME,
  created_at DATETIME
);

-- WellnessGoal: User's wellness goals
CREATE TABLE wellness_goals (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  goal_type VARCHAR,
  goal_name VARCHAR,
  target_value FLOAT,
  current_value FLOAT,
  unit VARCHAR,
  timeframe VARCHAR (daily, weekly, monthly),
  deadline DATETIME,
  progress_percentage FLOAT,
  is_active BOOLEAN,
  is_completed BOOLEAN,
  created_at DATETIME,
  updated_at DATETIME
);

-- DailyCheckin: Daily wellness snapshot
CREATE TABLE daily_checkins (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY,
  date DATETIME,
  mood INT (1-10),
  energy INT (1-10),
  stress INT (1-10),
  sleep_quality INT (1-5),
  overall_wellness INT (1-10),
  notes TEXT,
  created_at DATETIME
);

-- UserGoalSelection: Track selected wellness goals
CREATE TABLE user_goal_selections (
  id INT PRIMARY KEY,
  user_id INT FOREIGN KEY (UNIQUE),
  goal_categories JSONB (selected categories),
  customization_preferences JSONB,
  created_at DATETIME,
  updated_at DATETIME
);
```

#### Scoring Algorithm
```
Overall Wellness Score = Average(Component Scores)

Component Scores:
- Stress Score = 100 - (Average Stress Level × 10)
- Anxiety Score = 100 - (Average Anxiety Level × 10)
- Mood Score = Average Mood Level × 10
- Sleep Score = (Average Sleep Quality × 20) + 50
- Exercise Score = (Exercise Minutes / 150 × 100) capped at 100
- Social Score = (Social Interactions × 10) capped at 100
- Nutrition Score = (Healthy Meals / Total Meals × 100)
```

#### Analytics
- Multi-factor correlation analysis
- Lifestyle impact on wellness
- Goal progress tracking
- Predictive insights
- Personalized recommendations

#### Frontend Features (Flutter)
- **Daily Check-in**: Quick mood/energy/stress/sleep snapshot
- **Wellness Dashboard**: Holistic health overview
- **Life Balance Wheel**: Visual representation
- **Lifestyle Tracker**: Exercise, nutrition, social
- **Goal Manager**: Create, track, complete goals
- **Wellness Score**: Calculated and displayed
- **Comprehensive Insights**: Recommendations and analysis
- **Health Integrations**: Apple Health, Google Fit (future)

---

## 🔌 API Integration Details

### Authentication
All endpoints require JWT authentication via `Authorization: Bearer <token>` header.

### Request Examples

#### Log Stress
```bash
POST /api/v1/mental-health/stress/log
{
  "level": 7,
  "triggers": ["work deadline", "family issue"],
  "notes": "Feeling overwhelmed"
}
```

#### Log Mood Activity
```bash
POST /api/v1/mental-health/mood/activity
{
  "activity_type": "exercise",
  "activity_name": "30 min jog",
  "mood_before": 5,
  "mood_after": 8,
  "duration_minutes": 30,
  "effectiveness_rating": 4
}
```

#### Get Wellness Score
```bash
GET /api/v1/mental-health/wellness/score
```

Response:
```json
{
  "overall_score": 72.5,
  "stress_score": 65,
  "mood_score": 75,
  "sleep_score": 80,
  "anxiety_score": 70,
  "exercise_score": 60,
  "social_score": 50,
  "nutrition_score": 55
}
```

---

## 📱 Flutter Implementation

### Project Structure
```
lib/
├── screens/
│   ├── wellness_goal_selection_screen.dart    # Goal selection UI
│   ├── stress_management/
│   │   ├── stress_tracker_screen.dart
│   │   ├── stress_journal_screen.dart
│   │   └── breathing_exercises_screen.dart
│   ├── mood_tracking/
│   │   ├── mood_dashboard_screen.dart
│   │   ├── mood_activity_logger_screen.dart
│   │   └── gratitude_journal_screen.dart
│   ├── sleep_tracking/
│   │   ├── sleep_tracker_screen.dart
│   │   └── sleep_analytics_screen.dart
│   ├── mindfulness/
│   │   ├── meditation_library_screen.dart
│   │   ├── meditation_session_screen.dart
│   │   └── achievements_screen.dart
│   ├── anxiety_management/
│   │   ├── anxiety_tracker_screen.dart
│   │   ├── safety_plan_screen.dart
│   │   └── coping_techniques_screen.dart
│   └── wellness/
│       ├── wellness_dashboard_screen.dart
│       ├── daily_checkin_screen.dart
│       └── goals_screen.dart
├── providers/
│   ├── stress_provider.dart
│   ├── mood_provider.dart
│   ├── sleep_provider.dart
│   ├── mindfulness_provider.dart
│   ├── anxiety_provider.dart
│   └── wellness_provider.dart
├── services/
│   └── mental_health_api_service.dart
└── widgets/
    ├── goal_card.dart
    ├── progress_indicator.dart
    ├── stress_level_slider.dart
    └── wellness_score_display.dart
```

### Key Riverpod Providers

```dart
// Stress providers
final stressLogsProvider = FutureProvider((ref) => /* */);
final stressExercisesProvider = StateProvider<List>((ref) => []);
final stressAnalyticsProvider = FutureProvider((ref) => /* */);

// Mood providers
final moodActivitiesProvider = FutureProvider((ref) => /* */);
final moodInsightsProvider = FutureProvider((ref) => /* */);
final gratitudeEntriesProvider = StateProvider<List>((ref) => []);

// Sleep providers
final sleepLogsProvider = FutureProvider((ref) => /* */);
final sleepTrendsProvider = FutureProvider((ref) => /* */);
final sleepFactorsProvider = StateProvider<Map>((ref) => {});

// Mindfulness providers
final meditationSessionsProvider = FutureProvider((ref) => /* */);
final mindfulnessStatsProvider = FutureProvider((ref) => /* */);
final achievementsProvider = FutureProvider((ref) => /* */);
final meditationLibraryProvider = FutureProvider((ref) => /* */);

// Anxiety providers
final anxietyLogsProvider = FutureProvider((ref) => /* */);
final copingTechniquesProvider = FutureProvider((ref) => /* */);
final safetyPlanProvider = FutureProvider((ref) => /* */);

// Wellness providers
final wellnessScoreProvider = FutureProvider((ref) => /* */);
final dailyCheckinsProvider = StateProvider<Map>((ref) => {});
final wellnessGoalsProvider = FutureProvider((ref) => /* */);
final selectedGoalsProvider = StateProvider<Set>((ref) => {});
```

---

## 🗄️ Database Migration

Create migration file: `alembic/versions/mental_health_tracking_001.py`

```python
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

def upgrade():
    # Create all mental health tracking tables
    op.create_table('stress_logs', ...)
    op.create_table('stress_exercises', ...)
    op.create_table('stress_journal_entries', ...)
    # ... create remaining tables
    
def downgrade():
    # Drop all tables
    op.drop_table('stress_logs')
    op.drop_table('stress_exercises')
    # ... drop remaining tables
```

Run migration:
```bash
alembic upgrade head
```

---

## 🚀 Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)
- [x] Database schema creation
- [x] API endpoint implementation
- [x] Service layer development
- [ ] Frontend goal selection UI
- [ ] Basic API integration

### Phase 2: Core Features (Weeks 3-4)
- [ ] Stress management UI
- [ ] Mood tracking dashboard
- [ ] Sleep tracking screens
- [ ] Meditation library integration
- [ ] Anxiety tracking UI

### Phase 3: Analytics & Insights (Weeks 5-6)
- [ ] Analytics engine
- [ ] Correlation analysis
- [ ] Personalized recommendations
- [ ] Crisis detection system
- [ ] Achievement system

### Phase 4: Polish & Integration (Weeks 7-8)
- [ ] UI/UX refinement
- [ ] Performance optimization
- [ ] Health app integrations
- [ ] Testing and QA
- [ ] Production deployment

---

## 📊 Analytics Engine

### Algorithms

**Trend Calculation**
```python
def calculate_trend(values: List[int]) -> str:
    first_half = mean(values[:len(values)//2])
    second_half = mean(values[len(values)//2:])
    diff_percent = ((second_half - first_half) / first_half) * 100
    
    if diff_percent > 10:
        return "increasing"
    elif diff_percent < -10:
        return "decreasing"
    else:
        return "stable"
```

**Correlation Calculation**
```python
def calculate_correlation(factor_values: List, mood_values: List) -> float:
    improvements = [mood_values[i] - mood_values[i-1] 
                   for i in range(1, len(mood_values))]
    return mean(improvements) / 10.0  # Normalize to -1 to 1
```

---

## 🔐 Privacy & Security

- **Data Encryption**: All health data encrypted at rest
- **HIPAA Compliance**: Health data handling complies with HIPAA
- **User Consent**: Explicit consent for data collection
- **Audit Logging**: All sensitive operations logged
- **Data Retention**: User-controlled data retention policies
- **Export Capability**: Users can export their data

---

## 📝 Next Steps

1. **Create database migrations** using Alembic
2. **Register routes** in FastAPI main.py
3. **Build Flutter UI screens** for each category
4. **Implement Riverpod providers** for state management
5. **Create API client service** in Flutter
6. **Add error handling** and validation
7. **Implement caching** and offline support
8. **Write unit and integration tests**
9. **Performance optimization**
10. **Production deployment**

---

## 📞 Support & Maintenance

For questions or issues:
1. Check existing documentation
2. Review code comments
3. Test with Postman/Thunder Client
4. Check logs for errors
5. Create GitHub issue if needed

---

**Last Updated**: October 19, 2025
**Version**: 1.0
**Status**: Implementation in progress
