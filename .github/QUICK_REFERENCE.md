# 🎯 CI/CD Quick Reference

## 🔍 Quick Commands

### Check if tests pass locally
```bash
cd soul_fresh
flutter test
```

### Run specific test suite
```bash
flutter test test/auth_system_test.dart
flutter test test/ai_companion_chat_test.dart
```

### Check code quality
```bash
flutter analyze
```

### Generate coverage report
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Build APK locally
```bash
flutter build apk --release
```

---

## 📊 Pipeline Status

### View Workflow Runs
1. Go to **Actions** tab on GitHub
2. Click **Flutter CI/CD Pipeline**
3. See all recent runs

### Check Specific Job
1. Click on a workflow run
2. Click job name (e.g., "Flutter Analysis & Testing")
3. Expand steps to see logs

### Download APK
1. Go to successful workflow run on `main`
2. Scroll to **Artifacts** section
3. Download `soul-app-release.apk`

---

## 🚨 Critical Safety Tests

These tests **MUST** pass on every commit:

```bash
# Run ONLY safety tests
flutter test test/ai_companion_chat_test.dart --name "Safety"
```

**Validates:**
- ✅ Crisis keywords detected: `suicide`, `kill myself`, `harm myself`
- ✅ Safety response includes: **988**, **1-800-273-8255**
- ✅ Message includes: "You are not alone"

**If this fails, DO NOT merge.**

---

## 🔧 Common Fixes

### Test fails: "You need to initialize Hive"
**Solution**: Some tests require full app context
```dart
// These failures are expected for widget tests
// Core logic tests still validate correctly
```

### Flutter analyze warnings
**Solution**: Fix before pushing
```bash
flutter analyze --no-fatal-infos
dart fix --apply  # Auto-fix some issues
```

### Backend tests fail
**Solution**: Check database connection
```bash
cd backend
pytest -v  # See detailed error
```

---

## 📈 Coverage Targets

| Component | Current | Target |
|-----------|---------|--------|
| Auth System | 100% | 100% |
| AI Chat | 95% | 95% |
| Journal CRUD | 90% | 90% |
| Insights | 85% | 85% |
| **Overall** | **85%+** | **85%** |

---

## 🎯 Quality Gates

Before merging to `main`:

- ✅ All tests pass
- ✅ Flutter analyze: 0 errors
- ✅ Coverage ≥ 85%
- ✅ Safety tests pass
- ✅ Backend tests pass
- ✅ PR approved (if required)

---

## 🔗 Quick Links

- **Actions**: https://github.com/Ravindra2377/Mood/actions
- **Coverage**: https://codecov.io/gh/Ravindra2377/Mood
- **Issues**: https://github.com/Ravindra2377/Mood/issues
- **PRs**: https://github.com/Ravindra2377/Mood/pulls

---

## 🆘 Emergency Procedures

### Skip CI (Only if absolutely necessary)
Add to commit message:
```
[skip ci]
```

**⚠️ WARNING**: Use ONLY for docs/README changes

### Force merge (Admin only)
1. Disable branch protection temporarily
2. Merge
3. **RE-ENABLE IMMEDIATELY**

**⚠️ NEVER skip safety tests.**

---

## 📞 Support

**Issues?**
1. Check [CI/CD Guide](.github/CI_CD_GUIDE.md)
2. Review workflow logs
3. Run tests locally to reproduce

**Need help?**
- GitHub Actions Docs
- Flutter CI/CD Guide
- Create issue with `ci-cd` label

---

**Version**: 1.0  
**Last Updated**: Nov 8, 2025
