# Quran Download Scripts

This folder contains scripts to download high-quality Uthmanic Arabic Quran text.

## Available Scripts

### 1. `download_quran.ps1` (PowerShell - Windows)
**Recommended for Windows users**

```powershell
.\scripts\download_quran.ps1
```

### 2. `download_quran.py` (Python - Cross-platform)
**Works on Windows, Mac, and Linux**

**Requirements:**
```bash
pip install requests
```

**Usage:**
```bash
python scripts/download_quran.py
```

### 3. `download_quran_dart.dart` (Dart)
**For Flutter developers**

**Requirements:** Add `http` to `pubspec.yaml` dev_dependencies

**Usage:**
```bash
dart run scripts/download_quran_dart.dart
```

### 4. `run_download.ps1` (Auto-selector)
**Automatically tries Python, then PowerShell**

```powershell
.\scripts\run_download.ps1
```

## What They Do

All scripts:
1. Download 604 pages of Uthmanic Arabic Quran text from Quran.com API
2. Format as JSON: `{"1": "Arabic text", "2": "Arabic text", ...}`
3. Save to `assets/quran/quran_text.json`
4. Take 5-10 minutes to complete

## Output

The scripts create/update: `assets/quran/quran_text.json`

Format:
```json
{
  "1": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\nالْحَمْدُ لِلَّهِ...",
  "2": "الم\nذَٰلِكَ الْكِتَابُ...",
  ...
  "604": "..."
}
```

## Quick Start

**Windows (PowerShell):**
```powershell
cd C:\Users\murat\hatim
.\scripts\download_quran.ps1
```

**Python:**
```bash
python scripts/download_quran.py
```

## Notes

- Requires internet connection
- Downloads from verified Tanzil Uthmanic script
- Includes error handling and progress indicators
- Creates template file if download fails
