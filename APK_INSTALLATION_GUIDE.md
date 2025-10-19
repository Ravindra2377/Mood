# 📱 APK Installation & Testing Guide

## Quick Facts

- **APK File**: `app-release.apk`
- **Size**: 50.3 MB
- **Location**: `d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk`
- **Status**: ✅ Ready to install
- **Build Type**: Release (optimized)

---

## Installation Methods

### Method 1: ADB Command Line (Fastest)

**Step 1: Connect Device**
```powershell
# Enable USB debugging on your Android phone:
# Settings → Developer Options → USB Debugging (toggle ON)

# Verify connection
adb devices
# Should show: <device-id> device
```

**Step 2: Install APK**
```powershell
# Install the APK
adb install -r "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk"

# Success output:
# Success
```

**Step 3: Launch App**
```powershell
# Launch the app
adb shell am start -n com.example.soul/.MainActivity
```

---

### Method 2: Direct File Transfer

**For USB Mass Storage**:
1. Connect Android device to PC via USB
2. Enable "File Transfer" mode on device
3. Copy `app-release.apk` to device storage
4. Open device file manager
5. Tap APK file
6. Tap "Install" when prompted
7. Grant permissions

**For No Connection**:
1. Email APK file to yourself
2. Open email on phone
3. Tap attachment to download
4. Open file manager
5. Find APK and tap to install

---

### Method 3: Android Studio

1. **Connect Device**: Plug in Android phone
2. **In Android Studio**:
   - Bottom menu → Device File Explorer
   - Navigate to `/data/local/tmp/`
3. **Right-click** → "Put file"
4. **Select APK**: `app-release.apk`
5. **Install on device**:
   - Open file manager on phone
   - Navigate to `/data/local/tmp/`
   - Tap APK to install

---

## Pre-Installation Checklist

- [ ] Android device running Android 5.0 or higher
- [ ] USB debugging enabled on device
- [ ] Device recognized by `adb devices`
- [ ] At least 50 MB free storage
- [ ] USB cable that supports data transfer

---

## Testing Checklist

After installation, test these features:

### Launch & Navigation
- [ ] App icon appears on home screen
- [ ] App launches without crashing
- [ ] Bottom navigation shows 6 tabs
- [ ] Tab switching works smoothly

### Stress Management Screen
- [ ] Stress level slider works
- [ ] Can log stress entry
- [ ] Analytics tab shows data
- [ ] Exercises tab displays exercise cards

### Mood Tracking Screen
- [ ] Can select mood emoji (6 levels)
- [ ] Activity grid shows 6 options
- [ ] Calendar view displays month
- [ ] Insights show trends

### Sleep Tracking Screen
- [ ] Time picker opens when tapped
- [ ] Can set bedtime and wake time
- [ ] Quality rating (1-5 stars) works
- [ ] Tips display correctly

### Mindfulness Screen
- [ ] Meditation library shows categories
- [ ] Sessions tab shows history
- [ ] Stats display streaks
- [ ] Achievement badges visible

### Anxiety Management Screen
- [ ] Intensity slider works (1-10)
- [ ] Coping strategies display
- [ ] Safety plan visible
- [ ] SOS button appears

### Wellness Dashboard Screen
- [ ] Daily check-in sliders work
- [ ] Wellness metrics display
- [ ] Goal progress shows
- [ ] Scores calculate correctly

### Data Persistence
- [ ] Log data on one screen
- [ ] Switch to another screen
- [ ] Return to first screen
- [ ] Data still visible ✅

### UI/UX Quality
- [ ] Colors display correctly
- [ ] Text is readable
- [ ] Buttons are responsive
- [ ] Spacing/layout looks good
- [ ] No artifacts or glitches

---

## Uninstallation

### Via ADB
```powershell
adb uninstall com.example.soul
```

### Via Device
- Settings → Apps → SOUL → Uninstall → OK

---

## Troubleshooting

### "Device Not Found"
```powershell
# Solution 1: Restart adb
adb kill-server
adb start-server
adb devices

# Solution 2: Check USB drivers
# Download Android USB drivers from Google
# Install and restart device

# Solution 3: Reconnect
# Unplug USB → wait 5 seconds → reconnect
```

### "Installation Failed"
```powershell
# Solution 1: Clear existing installation
adb uninstall com.example.soul
adb install -r <apk-path>

# Solution 2: Check device storage
adb shell df /data
# Need at least 50 MB free

# Solution 3: Use no-streaming flag
adb install -r --no-streaming <apk-path>
```

### "App Crashes on Launch"
```powershell
# View crash logs
adb logcat -c
adb logcat | grep -i crash

# Check for specific errors
adb logcat | grep SOUL
```

### "Blank Screen After Install"
```powershell
# Clear app cache
adb shell pm clear com.example.soul

# Reinstall
adb install -r <apk-path>
```

### "Permission Denied During Install"
```powershell
# May need admin rights
# Run PowerShell as Administrator
# Then run install command again
```

---

## Performance Testing

### What to Monitor

**Startup Time**
- App should launch in ~2-3 seconds
- No splash screen freezing
- Smooth rendering

**Memory Usage**
- Check via: Settings → About Phone → Memory
- Should use 50-100 MB normally
- No continuous increase = good

**Battery Impact**
- Run for 10 minutes
- Check battery usage: Settings → Battery → Battery Usage
- Should show normal consumption

**Heat**
- Device should not overheat
- Back of phone should be warm, not hot

---

## Logging & Debugging

### View Logs
```powershell
# Real-time logs
adb logcat

# Only app logs
adb logcat | findstr "SOUL"

# Save logs to file
adb logcat > app_logs.txt

# Clear logs
adb logcat -c
```

### Take Screenshots
```powershell
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png
```

### Record Video
```powershell
# Record 30 seconds
adb shell screenrecord --time-limit 30 /sdcard/video.mp4
adb pull /sdcard/video.mp4
```

---

## Features to Test Carefully

### High Priority
1. **Tab Navigation**: Switch between all 6 screens
2. **Data Input**: Try logging data on each screen
3. **Data Persistence**: Verify data survives navigation
4. **UI Rendering**: Check for glitches or artifacts

### Medium Priority
1. **Sliders**: Test smooth movement
2. **Time Pickers**: Test date/time selection
3. **Emoji Selector**: Test mood selection
4. **Calculations**: Verify wellness scores

### Nice to Have
1. **Animations**: Check smoothness
2. **Color Accuracy**: Verify theme colors
3. **Text**: Check readability

---

## Report Template

If you find issues:

```markdown
## Issue Report

**Device**: [Phone model]
**Android Version**: [e.g., Android 12]
**App Version**: 1.0.0

### Issue Description
[What happened?]

### Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [etc]

### Expected Behavior
[What should happen?]

### Actual Behavior
[What actually happened?]

### Screenshots
[Attach if possible]

### Logs
[Run: adb logcat > logs.txt and attach]
```

---

## Success Indicators ✅

If you see these, the build is working correctly:

- ✅ App installs without errors
- ✅ App launches and displays screens
- ✅ All 6 tabs visible and functional
- ✅ Can input data without crashing
- ✅ UI is responsive
- ✅ No major glitches

---

## Next Steps

### If Testing Goes Well
1. ✅ Document any minor issues
2. ✅ Test on multiple devices
3. ✅ Prepare for beta testing
4. ✅ Ready for Google Play submission

### If Issues Found
1. ⚠️ Collect detailed logs
2. ⚠️ Reproduce issues
3. ⚠️ Check code for bugs
4. ⚠️ Rebuild with fixes
5. ⚠️ Retest APK

---

## Support

**For APK Issues**: See this file  
**For Build Issues**: See `APK_BUILD_COMPLETE.md`  
**For Code Issues**: See `FRONTEND_INTEGRATION_GUIDE.md`  
**For General Help**: See `QUICK_START_CHECKLIST.md`  

---

**APK Ready**: October 19, 2025  
**Status**: ✅ READY FOR TESTING  

Enjoy testing! 🎉
