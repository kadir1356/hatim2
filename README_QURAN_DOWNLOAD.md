# Quran Text Download Scripts

This directory contains scripts to download high-quality Uthmanic Arabic Quran text from verified sources.

## Available Scripts

### 1. Python Script (Recommended)
**File**: `scripts/download_quran.py`

**Requirements**:
```bash
pip install requests
```

**Usage**:
```bash
python scripts/download_quran.py
```

### 2. PowerShell Script (Windows)
**File**: `scripts/download_quran.ps1`

**Usage**:
```powershell
.\scripts\download_quran.ps1
```

### 3. Dart Script
**File**: `scripts/download_quran_dart.dart`

**Requirements**: Add `http` package to `pubspec.yaml`:
```yaml
dev_dependencies:
  http: ^1.1.0
```

**Usage**:
```bash
dart run scripts/download_quran_dart.dart
```

## Output Format

The script generates `assets/quran/quran_text.json` with the format:
```json
{
  "1": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\nالْحَمْدُ لِلَّهِ...",
  "2": "الم\nذَٰلِكَ الْكِتَابُ...",
  ...
  "604": "..."
}
```

## Source

- **API**: Quran.com API (https://api.quran.com)
- **Script**: Uthmanic (Tanzil project)
- **Verification**: Uses verified Tanzil Uthmanic script

## Notes

- The download may take 5-10 minutes (604 pages)
- Requires internet connection
- Scripts include error handling and progress indicators
- If download fails, a template file is created

## Manual Alternative

If scripts don't work, you can:
1. Visit https://tanzil.net/download/
2. Download Uthmanic text
3. Convert to JSON format with page numbers
4. Save as `assets/quran/quran_text.json`
