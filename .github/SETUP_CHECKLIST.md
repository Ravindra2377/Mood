# ✅ CI/CD Setup Checklist

Complete these steps to activate your GitHub Actions pipeline.

## 🎯 Prerequisites
- [ ] Repository is on GitHub
- [ ] You have admin access to the repository

---

## 📝 Setup Steps

### 1. Verify Workflow File
- [ ] File exists at `.github/workflows/flutter-ci-cd.yml`
- [ ] File is committed to your repository
- [ ] Push to GitHub:
  ```bash
  git add .github/
  git commit -m "Add CI/CD pipeline"
  git push origin soul_fresh
  ```

### 2. Enable GitHub Actions
- [ ] Go to repository **Settings** → **Actions** → **General**
- [ ] Under "Actions permissions", select:
  - ✅ **Allow all actions and reusable workflows**
- [ ] Click **Save**

### 3. Set Up Codecov (Optional but Recommended)

#### 3.1 Create Codecov Account
- [ ] Visit [codecov.io](https://codecov.io/)
- [ ] Click **Sign in with GitHub**
- [ ] Authorize Codecov

#### 3.2 Add Your Repository
- [ ] In Codecov dashboard, click **Add Repository**
- [ ] Find `Ravindra2377/Mood` and click **Set up**
- [ ] Copy the **Upload Token**

#### 3.3 Add Secret to GitHub
- [ ] Go to your GitHub repository
- [ ] Navigate to **Settings** → **Secrets and variables** → **Actions**
- [ ] Click **New repository secret**
- [ ] Name: `CODECOV_TOKEN`
- [ ] Value: Paste the token from Codecov
- [ ] Click **Add secret**

### 4. Test the Pipeline

#### 4.1 Manual Trigger
- [ ] Go to **Actions** tab in your GitHub repo
- [ ] Click **Flutter CI/CD Pipeline** workflow
- [ ] Click **Run workflow** button
- [ ] Select branch: `soul_fresh`
- [ ] Click **Run workflow**

#### 4.2 Verify Results
- [ ] Wait for workflow to complete (usually 5-10 minutes)
- [ ] Check all jobs have green checkmarks:
  - ✅ Flutter Analysis & Testing
  - ✅ Backend Testing
  - ✅ Security Audit
  - ✅ Critical Safety Check
  - ⚠️ Build Android APK (only runs on `main` branch)

### 5. Set Up Branch Protection (Highly Recommended)

#### 5.1 Protect Main Branch
- [ ] Go to **Settings** → **Branches**
- [ ] Click **Add branch protection rule**
- [ ] Branch name pattern: `main`
- [ ] Enable the following:
  - ✅ **Require a pull request before merging**
    - Require approvals: 0 (or 1 if you have collaborators)
  - ✅ **Require status checks to pass before merging**
    - ✅ Require branches to be up to date
    - Search and select:
      - `flutter-test`
      - `critical-safety-check`
      - `backend-test` (optional)
  - ✅ **Require conversation resolution before merging**
- [ ] Click **Create** or **Save changes**

#### 5.2 Protect Development Branch (Optional)
- [ ] Repeat above steps for `soul_fresh` branch
- [ ] Same settings but may skip approval requirement

### 6. Add Status Badges to README

- [ ] Open your main `README.md`
- [ ] Add these badges at the top:

```markdown
# SOUL - Mental Health Companion

![Flutter CI](https://github.com/Ravindra2377/Mood/actions/workflows/flutter-ci-cd.yml/badge.svg?branch=main)
[![codecov](https://codecov.io/gh/Ravindra2377/Mood/branch/main/graph/badge.svg)](https://codecov.io/gh/Ravindra2377/Mood)
![Tests](https://img.shields.io/badge/tests-60%2B-brightgreen)
![Coverage](https://img.shields.io/badge/coverage-85%25-green)
```

### 7. Verify Everything Works

#### 7.1 Make a Test Change
- [ ] Create a new branch: `git checkout -b test-ci`
- [ ] Make a small change (add a comment to a file)
- [ ] Commit and push:
  ```bash
  git add .
  git commit -m "Test CI/CD pipeline"
  git push origin test-ci
  ```

#### 7.2 Create Pull Request
- [ ] Go to GitHub and create a PR from `test-ci` to `soul_fresh`
- [ ] Verify that checks automatically run
- [ ] All checks should pass ✅
- [ ] Merge the PR (or close it if just testing)

---

## 🎉 Success Indicators

You'll know CI/CD is working when:

1. ✅ Actions tab shows workflow runs
2. ✅ Green checkmarks appear on commits
3. ✅ PRs show "All checks have passed"
4. ✅ Coverage reports appear on Codecov
5. ✅ APK artifacts are created on `main` branch pushes

---

## 🐛 Troubleshooting

### Workflow doesn't trigger
**Problem**: No workflow runs after push

**Solution**:
- Verify `.github/workflows/flutter-ci-cd.yml` exists
- Check Actions are enabled in Settings
- Ensure you pushed to a monitored branch (`main`, `soul_fresh`, `develop`)

### Tests fail in CI but pass locally
**Problem**: Tests pass on your machine but fail in CI

**Solution**:
- Run `flutter clean && flutter pub get` locally
- Check Flutter version matches (3.24.0)
- Review workflow logs for specific error
- May need to mock external dependencies

### Codecov upload fails
**Problem**: Coverage report not showing on Codecov

**Solution**:
- Verify `CODECOV_TOKEN` secret is set correctly
- Check token hasn't expired
- Ensure Codecov app is authorized for your repository

### APK build not triggering
**Problem**: APK build job doesn't run

**Solution**:
- APK only builds on pushes to `main` branch
- Ensure all other jobs passed first
- Check Java version compatibility

---

## 📞 Get Help

- **GitHub Actions Docs**: https://docs.github.com/en/actions
- **Flutter CI Best Practices**: https://docs.flutter.dev/deployment/cd
- **Codecov Docs**: https://docs.codecov.com/docs

---

## 🚀 Next Steps

Once CI/CD is set up:

1. **🔔 Implement Push Notifications**
   - Set up Firebase Cloud Messaging
   - Add notification scheduling to backend

2. **📱 Prepare for App Store**
   - Generate app icons
   - Create splash screen
   - Write store descriptions

3. **📊 Set Up Monitoring**
   - Add Sentry for crash reporting
   - Set up analytics (Mixpanel/Amplitude)

4. **🌐 Deploy Backend**
   - Set up production database
   - Configure environment variables
   - Deploy to Railway/Render

---

**Estimated Time**: 30-45 minutes  
**Difficulty**: Medium  
**Required**: GitHub account, repo admin access

---

Last Updated: November 8, 2025
