# 🧪 Testing Guide - SOUL App

**Last Updated**: October 18, 2025  
**Version**: 1.0.0  
**Branch**: `soul_fresh`

---

## ✅ **Pre-Testing Checklist**

Before testing, ensure all components are ready:

- ✅ Authentication system implemented
- ✅ Navigation/routing integrated
- ✅ Profile & Settings screens created
- ✅ Error handling framework in place
- ✅ INTERNET permission added to AndroidManifest
- ✅ All code committed to GitHub

---

## 🚀 **Step 1: Build the APK**

### **Option A: Release Build (Recommended for Testing)**

```bash
cd D:\OneDrive\Desktop\Mood\soul_fresh

# Install dependencies
flutter pub get

# Generate code (for Retrofit and JSON serialization)
flutter pub run build_runner build --delete-conflicting-outputs

# Build release APK
flutter build apk --release

# APK location:
# D:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk
```

**Expected Output:**
```
✓ Built build\app\outputs\flutter-apk\app-release.apk (48.5MB)
```

### **Option B: Debug Build (For Development)**

```bash
flutter build apk --debug

# APK location:
# build\app\outputs\flutter-apk\app-debug.apk
```

---

## 🖥️ **Step 2: Start the Backend**

### **Terminal 1: Backend Server**

```bash
cd D:\OneDrive\Desktop\Mood\backend

# Activate virtual environment (if using one)
# venv\Scripts\activate

# Start FastAPI server
python -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
```

**Expected Output:**
```
INFO:     Uvicorn running on http://0.0.0.0:8001 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

### **Verify Backend is Running:**

```bash
# In another terminal or browser
curl http://localhost:8001/healthz

# Or open in browser:
# http://localhost:8001/docs
```

**Expected Response:**
```json
{
  "status": "healthy",
  "db": true,
  "timestamp": "2025-10-18T..."
}
```

---

## 📱 **Step 3: Install APK on Device/Emulator**

### **Option A: Android Emulator**

1. **Start Emulator:**
   ```bash
   # List available emulators
   flutter emulators
   
   # Launch emulator
   flutter emulators --launch <emulator_id>
   ```

2. **Install APK:**
   ```bash
   adb install -r build\app\outputs\flutter-apk\app-release.apk
   ```

3. **Or use drag-and-drop** to install APK on emulator

### **Option B: Physical Device**

1. **Enable USB Debugging** on your Android device
2. **Connect device** via USB
3. **Install APK:**
   ```bash
   adb devices  # Verify device is connected
   adb install -r build\app\outputs\flutter-apk\app-release.apk
   ```

---

## 🧪 **Step 4: Test Authentication Flow**

### **Test Case 1: New User Signup**

1. **Open App** → Should show Login screen
2. **Tap "Sign Up"** → Navigate to Signup screen
3. **Fill form:**
   - Email: `test@example.com`
   - Password: `Test1234!`
   - Confirm Password: `Test1234!`
4. **Accept Terms** → Check the checkbox
5. **Tap "Sign Up"** → Should show loading overlay
6. **OTP Screen** → Should navigate to OTP verification
7. **Enter OTP:** `123456` (check backend logs for actual OTP)
8. **Tap "Verify"** → Should navigate to Home screen

**Expected Behavior:**
- ✅ Form validation works (email format, password strength)
- ✅ Loading overlay appears during API calls
- ✅ Navigation to OTP screen on successful signup
- ✅ Token stored securely after verification
- ✅ Navigate to Home screen

### **Test Case 2: Existing User Login**

1. **Open App** → Login screen
2. **Fill form:**
   - Email: `test@example.com`
   - Password: `Test1234!`
3. **Tap "Log In"** → Should show loading
4. **Success** → Navigate to Home screen

**Expected Behavior:**
- ✅ Credentials validated
- ✅ Token retrieved and stored
- ✅ Navigate to Home screen

### **Test Case 3: Token Persistence**

1. **Login successfully**
2. **Close app completely** (swipe away from recent apps)
3. **Reopen app**

**Expected Behavior:**
- ✅ Should stay logged in (token persists)
- ✅ Directly show Home screen (no login required)

---

## 👤 **Step 5: Test Profile & Settings**

### **Test Case 4: Profile Screen**

1. **Navigate to Profile** (from home or settings)
2. **Verify displayed:**
   - ✅ User avatar with email initial
   - ✅ Email address
   - ✅ Member since year
   - ✅ Stats cards (Mood, Journal, Meditation, Streak)
3. **Tap "Edit Profile"** → Should show "Coming soon" snackbar
4. **Tap "View Analytics"** → Should navigate to analytics (if implemented)
5. **Tap "Settings"** → Navigate to Settings screen

### **Test Case 5: Logout**

1. **From Profile screen**
2. **Tap "Logout"** → Confirmation dialog appears
3. **Tap "Cancel"** → Dialog closes, stay on profile
4. **Tap "Logout" again** → Tap "Logout" in dialog
5. **Verify:**
   - ✅ Token cleared from secure storage
   - ✅ Navigate to Login screen
   - ✅ Cannot go back to profile (auth guard works)

### **Test Case 6: Settings Screen**

1. **Navigate to Settings**
2. **Toggle Dark Mode** → Should show "Coming soon" snackbar (UI only)
3. **Toggle Notifications** → Switch should work
4. **Tap "Notification Time"** → Show "Coming soon" snackbar
5. **Tap "Privacy Settings"** → Navigate to Privacy Settings
6. **Tap "Clear Cache"** → Confirmation dialog → Clear successful
7. **Tap "About SOUL"** → About dialog with version info
8. **Tap "Delete Account"** → Confirmation dialog → "Coming soon"

### **Test Case 7: Privacy Settings**

1. **Navigate to Privacy Settings**
2. **Toggle switches:**
   - ✅ Share Analytics
   - ✅ Personalized Content
   - ✅ Cloud Sync
3. **Tap "Export My Data"** → Confirmation → "Coming soon"
4. **Tap "Delete All Data"** → Warning dialog → "Coming soon"
5. **Tap "Read Privacy Policy"** → "Coming soon" snackbar

---

## ⚠️ **Step 6: Test Error Handling**

### **Test Case 8: Network Errors**

1. **Turn off WiFi/Mobile data**
2. **Try to login** → Should show network error
3. **Error widget** should display with retry button
4. **Turn on network**
5. **Tap "Retry"** → Should work

### **Test Case 9: Invalid Credentials**

1. **Login with wrong password**
2. **Error message** should display
3. **Error card** shows with details

### **Test Case 10: Form Validation**

**Email validation:**
- ❌ `test` → "Please enter a valid email"
- ❌ `test@` → "Please enter a valid email"
- ✅ `test@example.com` → Valid

**Password validation:**
- ❌ `123` → "Password must be at least 8 characters"
- ❌ `password` → "Must contain uppercase, lowercase, and number"
- ✅ `Test1234!` → Valid

**OTP validation:**
- ❌ `123` → "OTP must be 6 digits"
- ❌ `abcdef` → "OTP must be numeric"
- ✅ `123456` → Valid

---

## 📊 **Step 7: Monitor Backend Logs**

### **What to Watch:**

**Terminal with backend running:**

```bash
# Successful signup
INFO: POST /api/auth/signup 200 OK
INFO: Email: test@example.com, User created

# OTP sent
INFO: POST /api/auth/request-otp 200 OK
INFO: OTP sent to test@example.com: 123456

# OTP verification
INFO: POST /api/auth/verify-otp 200 OK
INFO: User verified, token issued

# Login
INFO: POST /api/auth/login 200 OK
INFO: Login successful for test@example.com

# Logout
INFO: POST /api/auth/logout 200 OK
```

**Check Database:**

```bash
cd backend
python

# In Python shell:
from app.models.user import User
from app.config import engine
from sqlalchemy.orm import Session

with Session(engine) as session:
    users = session.query(User).all()
    for user in users:
        print(f"Email: {user.email}, Verified: {user.is_verified}")
```

---

## ✅ **Step 8: Verify Success Criteria**

### **Authentication (Must Pass All)**
- [ ] User can signup with email/password
- [ ] OTP is sent and can be verified
- [ ] User can login with credentials
- [ ] Token is stored securely
- [ ] Token persists after app restart
- [ ] User stays logged in on app reopen
- [ ] Logout clears token and navigates to login
- [ ] Auth guard prevents access without token

### **Navigation (Must Pass All)**
- [ ] Router handles all routes correctly
- [ ] Auth guards protect routes
- [ ] 404 page shows for unknown routes
- [ ] Navigation between screens works
- [ ] Back button works correctly
- [ ] Deep links work (if implemented)

### **Profile & Settings (Must Pass All)**
- [ ] Profile screen displays user data
- [ ] Stats cards show (even if 0)
- [ ] Logout confirmation works
- [ ] Settings toggles work
- [ ] Privacy settings accessible
- [ ] All navigation flows work

### **Error Handling (Must Pass All)**
- [ ] Network errors handled gracefully
- [ ] Form validation works on all inputs
- [ ] Error widgets display correctly
- [ ] Retry mechanism works
- [ ] Loading states shown during operations

### **UI/UX (Must Pass All)**
- [ ] Material 3 design consistent
- [ ] Theme (light) applied correctly
- [ ] Text styles uniform
- [ ] Colors from palette used
- [ ] Animations smooth
- [ ] No visual glitches

---

## 🐛 **Common Issues & Solutions**

### **Issue 1: "Connection refused" or DNS error**
**Solution:**
- ✅ Check INTERNET permission in AndroidManifest
- ✅ Verify backend is running on port 8001
- ✅ Use `10.0.2.2:8001` for emulator (not `localhost`)
- ✅ Use actual IP for physical device

### **Issue 2: "Token not found" after login**
**Solution:**
- ✅ Check SecureStorageService is saving token
- ✅ Verify AuthService.login() saves to storage
- ✅ Check flutter_secure_storage package installed

### **Issue 3: APK build fails**
**Solution:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter build apk --release
```

### **Issue 4: Routing doesn't work**
**Solution:**
- ✅ Verify AppRouter is provided in main.dart
- ✅ Check `onGenerateRoute` is set in MaterialApp
- ✅ Ensure Routes constants match route names

### **Issue 5: Profile screen shows loading forever**
**Solution:**
- ✅ Check token is saved after login
- ✅ Verify SecureStorageService methods work
- ✅ Check getUserEmail() and getUserId() return values

---

## 📝 **Test Report Template**

After testing, document results:

```markdown
## Test Report - SOUL App

**Date**: October 18, 2025
**Tester**: [Your Name]
**Device**: [Emulator/Physical Device]
**Android Version**: [e.g., Android 13]

### Authentication
- [ ] Signup: ✅ Pass / ❌ Fail - [Notes]
- [ ] Login: ✅ Pass / ❌ Fail - [Notes]
- [ ] OTP: ✅ Pass / ❌ Fail - [Notes]
- [ ] Logout: ✅ Pass / ❌ Fail - [Notes]
- [ ] Token Persistence: ✅ Pass / ❌ Fail - [Notes]

### Profile & Settings
- [ ] Profile Display: ✅ Pass / ❌ Fail - [Notes]
- [ ] Settings Navigation: ✅ Pass / ❌ Fail - [Notes]
- [ ] Privacy Settings: ✅ Pass / ❌ Fail - [Notes]

### Error Handling
- [ ] Network Errors: ✅ Pass / ❌ Fail - [Notes]
- [ ] Form Validation: ✅ Pass / ❌ Fail - [Notes]

### Performance
- App launch time: [X] seconds
- Login time: [X] seconds
- Navigation smoothness: ✅ Smooth / ❌ Laggy
- Memory usage: [X] MB

### Bugs Found
1. [Description] - Severity: High/Medium/Low
2. [Description] - Severity: High/Medium/Low

### Overall Status
✅ Ready for Production / ⚠️ Minor Issues / ❌ Major Issues
```

---

## 🎯 **Next Steps After Testing**

### **If All Tests Pass ✅**
1. Create release notes
2. Update version number
3. Build signed APK for distribution
4. Deploy to Play Store (internal testing)
5. Start analytics dashboard implementation

### **If Tests Fail ❌**
1. Document all failures
2. Create GitHub issues for bugs
3. Fix critical issues first
4. Re-test after fixes
5. Iterate until all pass

---

## 📚 **Additional Resources**

- **Backend API Docs**: http://localhost:8001/docs
- **Implementation Guide**: `IMPLEMENTATION_PROGRESS.md`
- **Quick Start**: `QUICK_START.md`
- **Priority Roadmap**: `PRIORITY_ROADMAP.md`
- **Frontend Analysis**: `FRONTEND_ANALYSIS.md`

---

## 🚀 **Ready to Test!**

1. **Build APK** (Step 1)
2. **Start Backend** (Step 2)
3. **Install APK** (Step 3)
4. **Test Authentication** (Step 4)
5. **Test Profile/Settings** (Step 5)
6. **Test Error Handling** (Step 6)
7. **Monitor Logs** (Step 7)
8. **Verify Success** (Step 8)

**Good luck with testing!** 🎉

---

**Questions or issues?** Check the troubleshooting section or create a GitHub issue.
