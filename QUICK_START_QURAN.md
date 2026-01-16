# Quick Start: Download Quran Text

## 🚀 Fastest Method (PowerShell - Windows)

```powershell
.\scripts\download_quran.ps1
```

Or use the runner script:
```powershell
.\scripts\run_download.ps1
```

## 🐍 Python Method (Cross-platform)

1. Install requests:
```bash
pip install requests
```

2. Run script:
```bash
python scripts/download_quran.py
```

## ⚡ What Happens

1. Script downloads all 604 pages from Quran.com API (Tanzil Uthmanic script)
2. Formats as JSON: `{"1": "Arabic text", "2": "Arabic text", ...}`
3. Saves to `assets/quran/quran_text.json`
4. Takes 5-10 minutes (604 API calls)

## ✅ After Download

The file will be at: `assets/quran/quran_text.json`

Your app will automatically load it when you:
1. Run `flutter pub get`
2. Restart the app
3. Navigate to Reading screen

## 📝 Format

The JSON file follows this format:
```json
{
  "1": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\nالْحَمْدُ لِلَّهِ...",
  "2": "الم\nذَٰلِكَ الْكِتَابُ...",
  ...
  "604": "..."
}
```

## 🔍 Verification

After download, check:
- File exists: `assets/quran/quran_text.json`
- File size: ~2-3 MB
- Page count: 604 pages
- Format: Valid JSON with Arabic text

## ⚠️ Troubleshooting

**If download fails:**
1. Check internet connection
2. Try Python script instead
3. Check API status: https://api.quran.com/api/v4/chapters
4. Script will create a template file if download fails

**If file is incomplete:**
- Re-run the script
- It will continue from where it left off (some pages may be missing)
