# Download Quran Text - Quick Guide

## 📁 Scripts Location

The scripts are located in: **`scripts/`** folder

If you can't see it in your IDE:
1. Refresh your project/IDE
2. Check if `.gitignore` is hiding it
3. Navigate to: `C:\Users\murat\hatim\scripts\`

## 🚀 Quick Start (Choose One)

### Option 1: PowerShell (Windows - Easiest)
```powershell
cd C:\Users\murat\hatim
.\scripts\download_quran.ps1
```

### Option 2: Python (Cross-platform)
```bash
cd C:\Users\murat\hatim
python scripts/download_quran.py
```

### Option 3: Auto-runner
```powershell
cd C:\Users\murat\hatim
.\scripts\run_download.ps1
```

## 📋 Available Scripts

1. **`scripts/download_quran.ps1`** - PowerShell script (Windows)
2. **`scripts/download_quran.py`** - Python script (All platforms)
3. **`scripts/download_quran_dart.dart`** - Dart script (Flutter)
4. **`scripts/run_download.ps1`** - Auto-selector script

## ✅ What Happens

1. Downloads 604 pages from Quran.com API
2. Formats as: `{"1": "Arabic text", "2": "Arabic text", ...}`
3. Saves to: `assets/quran/quran_text.json`
4. Takes 5-10 minutes

## 📍 Verify Scripts Exist

Run this in PowerShell:
```powershell
Get-ChildItem C:\Users\murat\hatim\scripts
```

You should see:
- download_quran.ps1
- download_quran.py
- download_quran_dart.dart
- run_download.ps1
- README.md

## 🎯 Direct Path

Full path to scripts:
```
C:\Users\murat\hatim\scripts\
```

## 💡 If Scripts Still Not Visible

1. **Check file explorer**: Navigate to the folder manually
2. **Refresh IDE**: Close and reopen your IDE
3. **Check .gitignore**: Scripts might be ignored
4. **Run from terminal**: Use the commands above directly
