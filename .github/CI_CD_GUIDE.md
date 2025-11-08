# 🚀 CI/CD Pipeline Guide

## Overview

This repository uses **GitHub Actions** to automatically test, analyze, and build the SOUL app on every push and pull request. This ensures code quality and catches bugs before they reach production.

## 🔄 Workflow Jobs

### 1. 🧪 Flutter Analysis & Testing
**Runs on**: Every push and PR  
**Purpose**: Validates code quality and runs comprehensive test suite

**What it does:**
- ✅ Runs `flutter analyze` (lint checks)
- ✅ Executes all 60+ tests across 5 test suites
- ✅ Generates code coverage report
- ✅ Uploads coverage to Codecov

**Test Suites Executed:**
1. **Auth System Tests** (6 tests) - JWT, OTP, refresh tokens
2. **Navigation & UI Tests** (20 tests) - 5-tab navigation, themes
3. **Journal System Tests** (15 tests) - CRUD, sentiment analysis
4. **AI Companion Tests** (12 tests) - Chat, streaming, **crisis detection**
5. **AI Analyst Tests** (12 tests) - Insights, charts, aggregations

### 2. 🐍 Backend Testing
**Runs on**: Every push and PR  
**Purpose**: Validates Python FastAPI backend

**What it does:**
- ✅ Runs pytest with coverage
- ✅ Tests API endpoints
- ✅ Validates database operations
- ✅ Checks AI service integration

### 3. 🔒 Security Audit
**Runs on**: Every push and PR  
**Purpose**: Scans for security vulnerabilities

**What it does:**
- ✅ Runs `safety` check on Python dependencies
- ✅ Checks Flutter pub dependencies
- ✅ Flags known CVEs

### 4. 🤖 Build Android APK
**Runs on**: Push to `main` branch only  
**Purpose**: Creates release-ready APK

**What it does:**
- ✅ Builds production APK
- ✅ Uploads artifact (available for 30 days)
- ✅ Only runs after tests pass

### 5. 🚨 Critical Safety Validation
**Runs on**: Every push and PR  
**Purpose**: **Double-checks crisis detection works**

**What it does:**
- ✅ Runs ONLY the safety/crisis tests
- ✅ Verifies keywords: `suicide`, `kill myself`, `harm myself`, etc.
- ✅ **Blocks merge if safety tests fail**

---

## 📊 Code Coverage

Coverage reports are automatically uploaded to **Codecov** after each run.

### Setup Codecov (One-time):

1. Go to [codecov.io](https://codecov.io/)
2. Sign in with GitHub
3. Add your repository
4. Copy the upload token
5. Add to GitHub Secrets:
   - Go to **Settings** → **Secrets and variables** → **Actions**
   - Create secret: `CODECOV_TOKEN` = your token

### Viewing Coverage:

- Badge: Add to README: `[![codecov](https://codecov.io/gh/Ravindra2377/Mood/branch/main/graph/badge.svg)](https://codecov.io/gh/Ravindra2377/Mood)`
- Dashboard: Visit `https://codecov.io/gh/Ravindra2377/Mood`

---

## 🚨 Critical Safety Checks

The pipeline includes **mandatory safety validation** to prevent shipping code that could harm users.

### What is checked:

```dart
// Crisis keywords that MUST trigger safety response:
- "suicide"
- "kill myself"  
- "end my life"
- "want to die"
- "harm myself"
```

### Safety test must verify:

1. ✅ Keywords are detected
2. ✅ AI response includes helpline: **988** or **1-800-273-8255**
3. ✅ Response includes "You are not alone"
4. ✅ Gemini API is NOT called (safety response is immediate)

**If this test fails, the entire build fails.** This is non-negotiable for a mental health app.

---

## 🏗️ Build Artifacts

### Android APK (main branch only)

After a successful push to `main`:

1. Go to **Actions** tab
2. Click the latest workflow run
3. Scroll to **Artifacts**
4. Download `soul-app-release.apk`

**Retention**: 30 days

---

## 📋 Status Badges

Add these to your README to show build status:

```markdown
![Flutter CI](https://github.com/Ravindra2377/Mood/actions/workflows/flutter-ci-cd.yml/badge.svg)
[![codecov](https://codecov.io/gh/Ravindra2377/Mood/branch/main/graph/badge.svg)](https://codecov.io/gh/Ravindra2377/Mood)
```

---

## 🛠️ Local Testing (Before Push)

Run the same checks locally:

```bash
# Flutter
cd soul_fresh
flutter analyze
flutter test --coverage
flutter build apk --release

# Backend
cd backend
pytest --cov=app --cov-report=term
```

---

## ⚙️ Configuration

### Branches Monitored:
- `main` (production)
- `soul_fresh` (development)
- `develop` (staging)

### Workflow Triggers:
- **push**: Auto-runs on commit
- **pull_request**: Runs on PR creation
- **workflow_dispatch**: Manual trigger from Actions tab

### Timeouts:
- Flutter tests: 30 minutes
- Backend tests: 20 minutes
- APK build: 30 minutes

---

## 🚦 Merge Protection Rules (Recommended)

Set up branch protection on `main`:

1. Go to **Settings** → **Branches** → **Add rule**
2. Branch name pattern: `main`
3. Enable:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - Select required checks:
     - `flutter-test`
     - `critical-safety-check`
4. Save

This ensures:
- No direct pushes to main
- All tests must pass
- Safety checks must pass

---

## 🐛 Troubleshooting

### "flutter analyze" fails
- Check for lint errors: `flutter analyze`
- Fix warnings before pushing

### "flutter test" fails
- Run locally: `flutter test`
- Check test output for specific failures

### "Build APK" fails
- Ensure all dependencies are in `pubspec.yaml`
- Check Java/Flutter versions match workflow

### Coverage not uploading
- Verify `CODECOV_TOKEN` secret is set
- Check Codecov integration is enabled for your repo

---

## 📚 Next Steps

With CI/CD in place, you're now ready for:

1. **🔔 Push Notifications** - Implement FCM for daily reminders
2. **🚀 App Store Deployment** - Prepare for Google Play & Apple App Store
3. **📈 Monitoring** - Set up Sentry for crash reporting
4. **🔄 CD** - Auto-deploy backend to Railway/Render

---

## 📞 Support

For issues with the CI/CD pipeline:
- Check workflow logs in **Actions** tab
- Review [GitHub Actions docs](https://docs.github.com/en/actions)
- Ensure all secrets are properly configured

---

**Last Updated**: November 8, 2025  
**Pipeline Version**: 1.0  
**Flutter**: 3.24.0  
**Python**: 3.11
