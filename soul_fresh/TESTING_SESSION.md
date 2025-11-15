# 🧪 Testing Session - October 18, 2025

## ✅ Pre-Test Setup Completed

### Build Status
- ✅ **APK Built Successfully**: `app-release.apk` (49.9MB)
- ✅ **Location**: `D:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk`
- ✅ **Build Time**: 195.8 seconds

### Backend Status
- ✅ **Server Running**: http://0.0.0.0:8001
- ✅ **Health Check**: Endpoint available at `/healthz`
- ⚠️ **Warning**: Pydantic V2 config warning (non-critical)

### Device Status
- ✅ **Emulator Available**: Medium_Phone_API_36.1 (Android API 36)
- 🔄 **Status**: Launching emulator...

---

## 📋 Test Checklist

### Test Case 1: Backend Verification
```powershell
# Test backend health
curl http://localhost:8001/healthz

# Expected: {"status": "healthy", "db": true}
```

**Status**: ⏳ Pending

---

### Test Case 2: Install APK on Emulator
```powershell
# Wait for emulator to fully boot
adb wait-for-device

# Install APK
adb install -r build\app\outputs\flutter-apk\app-release.apk

# Expected: Success message
```

**Status**: ⏳ Pending (waiting for emulator)

---

### Test Case 3: App Launch
- Open the app on emulator
- **Expected**: Login screen appears
- **Check**: Material 3 theme applied, Poppins font visible

**Status**: ⏳ Pending

---

### Test Case 4: User Signup Flow
**Steps**:
1. Tap "Sign Up" button
2. Fill in test credentials:
   - Email: `test@example.com`
   - Password: `Test1234!`
   - Confirm Password: `Test1234!`
3. Accept Terms checkbox
4. Tap "Sign Up"

**Expected**:
- ✅ Form validation works
- ✅ Loading overlay appears
- ✅ Navigate to OTP screen

**Actual**: ⏳ Pending

---

### Test Case 5: OTP Verification
**Steps**:
1. Check backend logs for OTP code
2. Enter OTP (usually `123456` in dev)
3. Tap "Verify"

**Expected**:
- ✅ OTP verified successfully
- ✅ Token saved to secure storage
- ✅ Navigate to Home screen

**Actual**: ⏳ Pending

---

### Test Case 6: Login Flow (Existing User)
**Steps**:
1. Logout (if logged in)
2. Enter credentials:
   - Email: `test@example.com`
   - Password: `Test1234!`
3. Tap "Log In"

**Expected**:
- ✅ Successfully logged in
- ✅ Token saved
- ✅ Navigate to Home screen

**Actual**: ⏳ Pending

---

### Test Case 7: Profile Screen
**Steps**:
1. Navigate to Profile (from settings or menu)
2. Check displayed information

**Expected**:
- ✅ User email shown
- ✅ Avatar with initial displayed
- ✅ Stats cards visible (mood, journal, meditation, streak)
- ✅ "Member since" year shown

**Actual**: ⏳ Pending

---

### Test Case 8: Settings Navigation
**Steps**:
1. Open Settings
2. Check all sections

**Expected**:
- ✅ Appearance section (dark mode toggle UI)
- ✅ Notifications section
- ✅ Privacy Settings link
- ✅ About SOUL dialog

**Actual**: ⏳ Pending

---

### Test Case 9: Privacy Settings
**Steps**:
1. Navigate to Privacy Settings
2. Toggle switches

**Expected**:
- ✅ Share Analytics toggle works
- ✅ Personalized Content toggle works
- ✅ Cloud Sync toggle works
- ✅ Export/Delete data options visible

**Actual**: ⏳ Pending

---

### Test Case 10: Logout Flow
**Steps**:
1. Go to Profile
2. Tap "Logout"
3. Confirm in dialog

**Expected**:
- ✅ Confirmation dialog appears
- ✅ Token cleared from storage
- ✅ Navigate to Login screen
- ✅ Cannot navigate back to protected screens

**Actual**: ⏳ Pending

---

### Test Case 11: Token Persistence
**Steps**:
1. Login successfully
2. Close app completely (swipe from recents)
3. Reopen app

**Expected**:
- ✅ Still logged in
- ✅ Token persists
- ✅ Home screen shown directly

**Actual**: ⏳ Pending

---

### Test Case 12: Error Handling - Network Errors
**Steps**:
1. Turn off WiFi/mobile data
2. Try to login

**Expected**:
- ✅ Network error message appears
- ✅ Error widget displayed
- ✅ Retry button visible

**Actual**: ⏳ Pending

---

### Test Case 13: Error Handling - Invalid Credentials
**Steps**:
1. Enter wrong password
2. Tap Login

**Expected**:
- ✅ Error message: "Invalid credentials"
- ✅ Error card/snackbar shown
- ✅ Form stays on screen

**Actual**: ⏳ Pending

---

### Test Case 14: Form Validation
**Test Email**:
- ❌ `test` → "Please enter a valid email"
- ❌ `test@` → "Please enter a valid email"
- ✅ `test@example.com` → Valid

**Test Password**:
- ❌ `123` → "Password must be at least 8 characters"
- ❌ `password` → "Must contain uppercase, lowercase, and number"
- ✅ `Test1234!` → Valid

**Test OTP**:
- ❌ `123` → "OTP must be 6 digits"
- ❌ `abcdef` → "OTP must be numeric"
- ✅ `123456` → Valid

**Actual**: ⏳ Pending

---

## 🐛 Issues Found

### Critical Issues
_None yet_

### Medium Priority Issues
_None yet_

### Low Priority Issues
_None yet_

---

## 📊 Backend API Calls to Monitor

Watch the backend terminal for these calls:

```
POST /auth/signup         # User registration
POST /auth/request-otp    # OTP request
POST /auth/verify-otp     # OTP verification
POST /auth/token          # Login (OAuth2)
POST /auth/logout         # Logout
GET /users/me             # Get current user (if implemented)
```

---

## 🎯 Next Steps

1. ⏳ **Wait for emulator to boot** (1-2 minutes)
2. ⏳ **Install APK** on emulator
3. ⏳ **Run Test Cases 1-14** in sequence
4. ⏳ **Document all findings** in this file
5. ⏳ **Create GitHub issues** for any bugs found
6. ⏳ **Update TODO list** with testing results

---

## 📝 Notes

- Backend started with Pydantic V2 warning (non-critical)
- APK size: 49.9MB (reasonable for release build)
- Build time: ~3 minutes (normal for first build)
- Using Android API 36.1 emulator

---

**Testing Started**: October 18, 2025  
**Tester**: GitHub Copilot Assistant  
**Build**: app-release.apk (49.9MB)  
**Backend**: FastAPI on port 8001
