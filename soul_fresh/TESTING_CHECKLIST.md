# 📋 Testing Checklist - SOUL App
**Date**: October 18, 2025  
**Test Session**: End-to-End Authentication Flow

---

## ✅ **Pre-Test Setup**

- [x] Backend running on port 8001
- [ ] APK built successfully  
- [ ] Emulator/device connected
- [ ] APK installed on device

---

## 🧪 **Test Cases to Execute**

### **Test 1: New User Signup** 
- [ ] Open app → Shows login screen
- [ ] Tap "Sign Up" button
- [ ] Fill signup form:
  - Email: `testuser@example.com`
  - Password: `Test1234!`
  - Confirm Password: `Test1234!`
- [ ] Accept terms checkbox
- [ ] Tap "Sign Up" button
- [ ] **Expected**: Loading indicator shows
- [ ] **Expected**: Navigates to OTP screen
- [ ] **Expected**: Backend shows signup request in logs

### **Test 2: OTP Verification**
- [ ] On OTP screen
- [ ] Check backend logs for OTP code
- [ ] Enter OTP code (6 digits)
- [ ] Tap "Verify" button
- [ ] **Expected**: Loading indicator shows
- [ ] **Expected**: Navigates to Home screen
- [ ] **Expected**: Backend shows OTP verification success

### **Test 3: Logout**
- [ ] From Home screen
- [ ] Tap "Go to Profile" button
- [ ] On Profile screen, tap "Logout"
- [ ] **Expected**: Confirmation dialog appears
- [ ] Tap "Cancel" → Dialog closes
- [ ] Tap "Logout" again → Tap "Logout" in dialog
- [ ] **Expected**: Navigates to Login screen
- [ ] **Expected**: Token cleared from storage

### **Test 4: Existing User Login**
- [ ] On Login screen
- [ ] Fill login form:
  - Email: `testuser@example.com`
  - Password: `Test1234!`
- [ ] Tap "Log In" button
- [ ] **Expected**: Loading indicator shows
- [ ] **Expected**: Navigates to Home screen
- [ ] **Expected**: Backend shows login success

### **Test 5: Token Persistence**
- [ ] Login successfully (Test 4)
- [ ] Close app completely (swipe from recent apps)
- [ ] Reopen app
- [ ] **Expected**: Should remain logged in
- [ ] **Expected**: Shows Home screen (or last screen)

### **Test 6: Settings Navigation**
- [ ] From Profile screen
- [ ] Tap "Settings" button
- [ ] **Expected**: Navigates to Settings screen
- [ ] Toggle dark mode switch
- [ ] **Expected**: Shows "Coming soon" snackbar
- [ ] Tap "Privacy Settings"
- [ ] **Expected**: Navigates to Privacy Settings screen

### **Test 7: Privacy Controls**
- [ ] On Privacy Settings screen
- [ ] Toggle "Share Analytics" switch
- [ ] **Expected**: Switch changes state
- [ ] Tap "Export My Data"
- [ ] **Expected**: Shows dialog with export info
- [ ] Tap "Read Privacy Policy"
- [ ] **Expected**: Shows "Coming soon" snackbar

### **Test 8: Form Validation**
- [ ] On Signup screen
- [ ] Enter invalid email: `test@`
- [ ] **Expected**: Shows "Please enter a valid email"
- [ ] Enter weak password: `123`
- [ ] **Expected**: Shows "Password must be at least 8 characters"
- [ ] Enter valid data
- [ ] **Expected**: Form validates successfully

### **Test 9: Network Error Handling**
- [ ] Turn off WiFi/Mobile data
- [ ] Try to login
- [ ] **Expected**: Shows network error message
- [ ] Turn on network
- [ ] Try again
- [ ] **Expected**: Login succeeds

### **Test 10: Backend Integration**
- [ ] Monitor backend terminal during tests
- [ ] **Expected**: See requests for:
  - POST /auth/signup
  - POST /auth/request-otp (if OTP enabled)
  - POST /auth/verify-otp
  - POST /auth/token (login)
  - POST /auth/logout

---

## 📊 **Test Results**

### **Status**: Not Started

| Test Case | Status | Notes |
|-----------|--------|-------|
| 1. Signup | ⏳ Pending | |
| 2. OTP Verification | ⏳ Pending | |
| 3. Logout | ⏳ Pending | |
| 4. Login | ⏳ Pending | |
| 5. Token Persistence | ⏳ Pending | |
| 6. Settings Navigation | ⏳ Pending | |
| 7. Privacy Controls | ⏳ Pending | |
| 8. Form Validation | ⏳ Pending | |
| 9. Network Errors | ⏳ Pending | |
| 10. Backend Integration | ⏳ Pending | |

---

## 🐛 **Issues Found**

| Issue # | Description | Severity | Status |
|---------|-------------|----------|--------|
| - | - | - | - |

---

## 📝 **Notes**

### **Backend URL**: `http://10.0.2.2:8001` (emulator)
### **APK Location**: `build/app/outputs/flutter-apk/app-release.apk`

### **Next Steps After Testing**:
1. Fix any bugs found
2. Build analytics dashboard
3. Add notifications
4. Deploy to production

---

**Update this checklist as you test!** ✅
