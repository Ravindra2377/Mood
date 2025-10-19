# 📦 APK File Location & Quick Access

## ⚡ Direct Path to APK

```
d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk
```

## 📋 Quick Copy-Paste Commands

### PowerShell
```powershell
# Copy to clipboard
$apk = "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk"
Set-Clipboard $apk
Write-Host "APK path copied to clipboard"

# Or use directly in adb command
adb install -r "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk"
```

### CMD
```cmd
REM Install directly
adb install -r "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk"

REM Copy to specific location
copy "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk" "D:\APK_Builds\app-release.apk"
```

---

## 📂 File Location Breakdown

```
d:\OneDrive\Desktop\Mood\
└── soul_fresh\                                    ← Flutter project root
    └── build\                                     ← Build output directory
        └── app\
            └── outputs\
                ├── flutter-apk\
                │   └── app-release.apk            ← MAIN APK (50.3 MB)
                │
                └── apk\
                    └── release\
                        └── app-release.apk        ← Alternative location
```

---

## 🔍 How to Find It

### Option 1: File Explorer (GUI)
1. Open **File Explorer**
2. Navigate to: `This PC` → `Local Disk (D:)` → `OneDrive` → `Desktop` → `Mood`
3. Open: `soul_fresh` folder
4. Open: `build` folder
5. Open: `app` → `outputs` → `flutter-apk`
6. Find: `app-release.apk`

### Option 2: PowerShell Navigation
```powershell
# Navigate to APK
cd "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk"
ls -la

# Properties of APK
Get-Item app-release.apk | Format-List
```

### Option 3: Direct Search
```powershell
# Search for the APK
Get-ChildItem -Path "d:\OneDrive\Desktop\Mood" -Filter "app-release.apk" -Recurse

# Show full path and size
Get-ChildItem -Path "d:\OneDrive\Desktop\Mood" -Filter "app-release.apk" -Recurse | Format-Table FullName, @{Label="Size(MB)";Expression={$_.Length/1MB}}
```

---

## 📊 APK File Details

| Property | Value |
|----------|-------|
| **Filename** | `app-release.apk` |
| **Size** | 50.3 MB |
| **Type** | Android Package Archive |
| **Version** | 1.0.0 (Build 1) |
| **Min Android** | 5.0 (API 21) |
| **Target Android** | 14+ |
| **Architecture** | ARM64 + ARMv7 + x86 + x86_64 |
| **Signing** | Debug key (for testing) |

---

## 🚀 Install Commands (Copy & Paste Ready)

### Standard Installation
```powershell
adb install -r "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk"
```

### With Reinstall Force
```powershell
adb install -r -d "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk"
```

### No Streaming Mode
```powershell
adb install -r --no-streaming "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk"
```

### To Specific Device
```powershell
$apk = "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk"
adb devices # List devices first
adb -s <device_id> install -r $apk
```

---

## 💾 Backup APK to Other Locations

### Create Backup Directory
```powershell
New-Item -ItemType Directory -Path "D:\APK_Releases" -Force

# Copy APK
Copy-Item `
  "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk" `
  "D:\APK_Releases\soul-app-v1.0.0.apk"
```

### Share Ready Location
```powershell
# Copy to Desktop for easy access
Copy-Item `
  "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk" `
  "d:\OneDrive\Desktop\soul-app.apk"
```

---

## 🔗 Alternative Output Locations

The APK might also be found at:

### Primary Location (Recommended)
```
d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk
```

### Secondary Location
```
d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\apk\release\app-release.apk
```

### Check Both
```powershell
# Find all APK files in the build directory
Get-ChildItem -Path "d:\OneDrive\Desktop\Mood\soul_fresh\build" -Filter "*.apk" -Recurse | Select-Object FullName, @{Label="Size(MB)";Expression={$_.Length/1MB}}
```

---

## 📱 Install on Device

### Prerequisites
1. Android device connected via USB
2. USB debugging enabled
3. Device recognized by adb (`adb devices`)

### One-Command Installation
```powershell
# Copy and run this entire command:
adb install -r "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk"; Write-Host "Installation complete!"
```

### Verify Installation
```powershell
# Check if app is installed
adb shell pm list packages | findstr soul

# Launch the app
adb shell am start -n com.example.soul/.MainActivity
```

---

## 📤 Sharing the APK

### Email
1. Locate: `app-release.apk`
2. Right-click → "Send to" → "Compressed (zipped) folder"
3. Name: `soul-app.zip`
4. Attach to email

### File Sharing Service
```powershell
# Path to share:
"d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk"

# Services: Google Drive, OneDrive, Dropbox, etc.
```

### USB Transfer
1. Connect USB drive
2. Copy `app-release.apk` to USB root
3. Eject USB
4. Use on other computer

---

## 🔐 File Hash (for verification)

Get file hash to verify integrity:

```powershell
# SHA256 Hash
Get-FileHash -Path "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk" -Algorithm SHA256

# MD5 Hash (legacy)
Get-FileHash -Path "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk" -Algorithm MD5
```

Store the hash to verify file wasn't corrupted:
```
SHA256: [Your hash here]
Size: 50.3 MB
Date: 2025-10-19
```

---

## ✅ Checklist Before Testing

- [ ] Located `app-release.apk` file
- [ ] Verified file size (~50 MB)
- [ ] Device connected and recognized
- [ ] USB debugging enabled
- [ ] Enough storage on device (50+ MB)
- [ ] Ready to install

---

## 🆘 Can't Find the APK?

### Check Build Status
```powershell
cd "d:\OneDrive\Desktop\Mood\soul_fresh"

# Verify build directory exists
Test-Path build\app\outputs\flutter-apk\app-release.apk

# If false, rebuild
flutter build apk --release
```

### Search Everywhere
```powershell
# Comprehensive search
Get-ChildItem -Path "d:\OneDrive\Desktop\Mood" -Filter "*.apk" -Recurse -Force | Select-Object FullName, @{Label="Size(MB)";Expression={$_.Length/1MB}}
```

### Rebuild APK
```powershell
cd "d:\OneDrive\Desktop\Mood\soul_fresh"
flutter clean
flutter pub get
flutter build apk --release
```

---

## 🎯 Summary

| Task | Command |
|------|---------|
| Find APK | `d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk` |
| Install | `adb install -r "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk"` |
| Check Hash | `Get-FileHash -Path "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk"` |
| Backup | `Copy-Item ... -Destination "D:\APK_Releases\soul-app-v1.0.0.apk"` |
| Verify | `Test-Path "d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk"` |

---

**APK Ready**: ✅ 50.3 MB  
**Location**: `d:\OneDrive\Desktop\Mood\soul_fresh\build\app\outputs\flutter-apk\app-release.apk`  
**Status**: Ready for testing  

🚀 Ready to test the app!
