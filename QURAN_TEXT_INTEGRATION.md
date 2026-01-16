# Arabic Quran Text Integration Guide

## Current Implementation

The app is now set up to load Arabic Quran text from a JSON file. The `QuranContentService` will:

1. **First**: Try to load from `assets/quran/quran_text.json`
2. **Fallback**: Use placeholder text if JSON file is missing or invalid

## JSON File Format

You can use either of these formats:

### Format 1: Direct page mapping
```json
{
  "1": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\nالْحَمْدُ لِلَّهِ...",
  "2": "الم\nذَٰلِكَ الْكِتَابُ لَا رَيْبَ...",
  ...
  "604": "..."
}
```

### Format 2: Nested structure
```json
{
  "pages": {
    "1": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\nالْحَمْدُ لِلَّهِ...",
    "2": "الم\nذَٰلِكَ الْكِتَابُ لَا رَيْبَ...",
    ...
    "604": "..."
  }
}
```

## How to Add Quran Text

### Option 1: Manual JSON Creation
1. Get Quran text from a reliable source (e.g., Tanzil, Quran.com API)
2. Format it as JSON with page numbers as keys
3. Save as `assets/quran/quran_text.json`
4. Run `flutter pub get` to ensure assets are registered

### Option 2: Use a Quran API/Service
You can modify `QuranContentService` to fetch from an API:

```dart
Future<void> loadFromAPI() async {
  // Fetch from API and cache locally
  // Then save to JSON for offline use
}
```

### Option 3: Use a Quran Database
- SQLite database with Quran text
- Convert to JSON format
- Place in assets folder

## Important Notes

1. **File Size**: A complete Quran text JSON file will be ~2-3 MB
2. **Encoding**: Ensure UTF-8 encoding for proper Arabic text display
3. **Formatting**: Use `\n` for line breaks, preserve Arabic diacritics
4. **Verification**: Always verify text accuracy from trusted sources

## Testing

After adding the JSON file:

1. Run `flutter pub get`
2. Restart the app
3. Navigate to Reading screen
4. The Arabic text should load automatically

## Current Status

- ✅ Service is ready to load from JSON
- ✅ Placeholder text shows if JSON is missing
- ✅ Supports both JSON formats
- ✅ Proper error handling
- ✅ Arabic font support (Amiri via Google Fonts)

## Next Steps

1. Obtain verified Quran text in Arabic
2. Format as JSON (604 pages)
3. Place in `assets/quran/quran_text.json`
4. Test loading and display

## Resources

- **Tanzil Project**: https://tanzil.net/ (Reliable Quran text source)
- **Quran.com API**: https://quran.com/api (Alternative source)
- **Arabic Fonts**: Amiri font is already configured via Google Fonts
