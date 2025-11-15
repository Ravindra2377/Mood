# CI/CD Setup Guide for SOUL App

## 🎯 Overview

This guide will help you complete the CI/CD (Continuous Integration/Continuous Deployment) setup for your SOUL app. The pipeline will automatically:

1. **Test your code** on every push
2. **Run static analysis** to catch bugs
3. **Build signed release APK/AAB** files automatically

## ✅ What's Already Done

- ✅ GitHub Actions workflow file created (`.github/workflows/flutter-ci.yml`)
- ✅ Android build.gradle.kts configured for release signing
- ✅ .gitignore updated to exclude sensitive files

## 📋 Prerequisites Setup

### Step 1: Create Your Signing Key (One-Time Setup)

This is your app's master key. **Keep it safe and never commit it to Git.**

Open PowerShell and run:

```powershell
# Navigate to your project
cd D:\OneDrive\Desktop\Mood\soul_fresh\android\app

# Generate the keystore
keytool -genkey -v -keystore soul-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias soul-key
```

You'll be asked several questions:
- **Enter keystore password:** (Create a strong password and remember it!)
- **Re-enter password:** (Same password)
- **Enter key password:** (Can be same or different, remember it!)
- **Name, Organization, etc.:** (Fill in your details)

This creates `soul-release-key.jks` in the `soul_fresh/android/app/` folder.

### Step 2: Create key.properties File

Create a new file: `soul_fresh/android/key.properties`

Add this content (replace with YOUR actual values):

```properties
storePassword=YOUR_STORE_PASSWORD_HERE
keyPassword=YOUR_KEY_PASSWORD_HERE
keyAlias=soul-key
storeFile=soul-release-key.jks
```

⚠️ **IMPORTANT:** This file is already in `.gitignore` and will NOT be committed.

### Step 3: Test Local Build

Verify your signing setup works locally:

```powershell
cd D:\OneDrive\Desktop\Mood\soul_fresh

# Build a signed release APK
flutter build apk --release

# Or build an App Bundle (for Play Store)
flutter build appbundle --release
```

If successful, you'll find the built file at:
- **APK:** `soul_fresh/build/app/outputs/flutter-apk/app-release.apk`
- **AAB:** `soul_fresh/build/app/outputs/bundle/release/app-release.aab`

## 🔐 GitHub Secrets Setup

Now we need to securely upload your keys to GitHub.

### Step 1: Encode Your Keystore

In PowerShell, run:

```powershell
cd D:\OneDrive\Desktop\Mood\soul_fresh\android\app

# For PowerShell, use this command to encode to Base64
[Convert]::ToBase64String([IO.File]::ReadAllBytes("soul-release-key.jks")) | Set-Clipboard
```

This copies the encoded keystore to your clipboard.

### Step 2: Add GitHub Secrets

1. Go to: https://github.com/Ravindra2377/Mood
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add these 4 secrets:

| Secret Name | Value |
|------------|-------|
| `KEY_ALIAS` | `soul-key` (or whatever alias you used) |
| `KEY_PASSWORD` | Your key password from Step 1 |
| `STORE_PASSWORD` | Your keystore password from Step 1 |
| `KEYSTORE_BASE64` | Paste the long Base64 string from your clipboard |

## 🚀 Activate CI/CD

Now commit and push the changes:

```powershell
cd D:\OneDrive\Desktop\Mood

# Stage the new files
git add .github/
git add .gitignore
git add soul_fresh/android/app/build.gradle.kts

# Commit
git commit -m "ci: Add CI/CD pipeline with automated release builds

- Add GitHub Actions workflow for Flutter testing and analysis
- Configure Android release signing with secure keystore handling
- Set up automated APK/AAB build on successful tests
- Update gitignore to exclude sensitive signing files"

# Push to GitHub
git push origin soul_fresh
```

## 🎉 What Happens Next

1. **Immediately:** Go to https://github.com/Ravindra2377/Mood/actions
2. **You'll see:** Your "Flutter CI (Soul Fresh)" workflow running
3. **First job:** `build-and-test` runs `flutter analyze` and `flutter test`
4. **Second job:** `build-android-release` creates the signed APK/AAB (only on push, not pull requests)
5. **Download:** When complete, click the workflow run → Scroll to **Artifacts** → Download `release-appbundle`

## 📦 What Gets Built

The workflow builds an **Android App Bundle** (`.aab`) by default, which is:
- ✅ Required for Google Play Store
- ✅ Smaller download size for users
- ✅ Supports dynamic delivery

If you want an APK instead, edit `.github/workflows/flutter-ci.yml` and change:
```yaml
- name: Build Android App Bundle
  run: flutter build appbundle
```
to:
```yaml
- name: Build Android APK
  run: flutter build apk
```

And update the artifact path from:
```yaml
path: soul_fresh/build/app/outputs/bundle/release/app-release.aab
```
to:
```yaml
path: soul_fresh/build/app/outputs/flutter-apk/app-release.apk
```

## 🔒 Security Notes

✅ **Safe (these are in .gitignore):**
- `*.jks` files
- `key.properties`
- Your passwords

✅ **Safe (encrypted in GitHub):**
- GitHub Secrets are encrypted and never exposed in logs

❌ **Never commit:**
- Keystore files
- Passwords
- key.properties

## 🛠️ Troubleshooting

### "Keystore file not found"
Make sure `soul-release-key.jks` is in `soul_fresh/android/app/`

### "Wrong password"
Double-check your passwords in GitHub Secrets match what you entered in Step 1

### "Build fails in CI"
Check the Actions tab for detailed error logs. Common issues:
- Missing or incorrect GitHub Secrets
- Flutter dependencies not resolving
- Analysis errors in your code

### "flutter analyze fails"
Fix any Dart/Flutter warnings in your code first. The CI will not proceed if analysis fails.

## 🎯 Next Steps

After your CI/CD is running successfully:

1. **Add more tests** to increase code coverage
2. **Add Flutter test coverage reporting** to the workflow
3. **Set up automatic Play Store deployment** (advanced)
4. **Add iOS builds** to the workflow

## 📚 Additional Resources

- [Flutter CI/CD Documentation](https://docs.flutter.dev/deployment/cd)
- [GitHub Actions for Flutter](https://github.com/subosito/flutter-action)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)

---

**Congratulations!** 🎉 You now have a professional CI/CD pipeline that ensures code quality and automates your release builds!
