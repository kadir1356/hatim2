#!/usr/bin/env python3
"""
Script to download high-quality Uthmanic Arabic Quran text
Uses Tanzil project (tanzil.net) as the source - verified and reliable
"""

import json
import requests
import os
from pathlib import Path

# Tanzil API endpoint for Uthmanic script
TANZIL_API_BASE = "https://api.quran.com/api/v4/quran/verses/uthmani"
# Alternative: Direct Tanzil text files
TANZIL_TEXT_BASE = "https://tanzil.net/trans/?transID=ar.uthmani&type=txt"

def get_quran_from_tanzil_api():
    """
    Download Quran from Tanzil API (Quran.com API with Tanzil data)
    Returns dict with page numbers as keys
    """
    print("Downloading Quran text from Tanzil (via Quran.com API)...")
    
    # Page to verse mapping (approximate - 604 pages total)
    # Each page has approximately 15-20 verses
    quran_text = {}
    
    try:
        # Get all verses (6236 verses total)
        response = requests.get("https://api.quran.com/api/v4/quran/verses/uthmani", timeout=30)
        if response.status_code == 200:
            data = response.json()
            verses = data.get('verses', [])
            
            # Group verses by page
            current_page = 1
            page_text = []
            
            for verse in verses:
                verse_number = verse.get('verse_number')
                page_number = verse.get('page_number', current_page)
                text = verse.get('text_uthmani', '')
                
                if page_number != current_page:
                    # Save previous page
                    quran_text[str(current_page)] = '\n'.join(page_text)
                    page_text = []
                    current_page = page_number
                
                page_text.append(text)
            
            # Save last page
            if page_text:
                quran_text[str(current_page)] = '\n'.join(page_text)
            
            print(f"Downloaded {len(quran_text)} pages")
            return quran_text
            
    except Exception as e:
        print(f"Error with API method: {e}")
        return None

def get_quran_from_tanzil_direct():
    """
    Alternative method: Download from Tanzil directly
    This uses the Tanzil project's direct text files
    """
    print("Trying alternative download method...")
    
    quran_text = {}
    
    try:
        # Tanzil provides verse-by-verse text
        # We need to group by pages
        # Page mapping: Each surah has specific page ranges
        
        # For now, we'll use a more reliable method
        # Download from a pre-formatted source or use verse-to-page mapping
        
        # This is a fallback - you may need to adjust based on actual Tanzil format
        print("Direct download method requires page mapping...")
        return None
        
    except Exception as e:
        print(f"Error with direct method: {e}")
        return None

def get_quran_from_quran_com():
    """
    Download from Quran.com API (uses Tanzil Uthmanic script)
    More reliable and structured
    """
    print("Downloading from Quran.com API (Tanzil Uthmanic)...")
    
    quran_text = {}
    
    try:
        # Get all chapters (114 surahs)
        chapters_response = requests.get("https://api.quran.com/api/v4/chapters", timeout=30)
        if chapters_response.status_code != 200:
            print("Failed to get chapters")
            return None
        
        chapters = chapters_response.json().get('chapters', [])
        
        # Page mapping - approximate mapping
        # In reality, we need verse-to-page mapping
        # Let's use a different approach: get verses grouped by page
        
        # Alternative: Use verses endpoint with page parameter
        for page_num in range(1, 605):  # 604 pages
            try:
                # Get verses for this page
                verses_response = requests.get(
                    f"https://api.quran.com/api/v4/verses/by_page/{page_num}",
                    params={"language": "ar", "words": "true"},
                    timeout=10
                )
                
                if verses_response.status_code == 200:
                    data = verses_response.json()
                    verses = data.get('verses', [])
                    
                    if verses:
                        # Combine all verse texts for this page
                        page_verses = []
                        for verse in verses:
                            # Try to get text_uthmani first (this is the REAL Arabic Quran text)
                            if 'text_uthmani' in verse and verse['text_uthmani']:
                                verse_text = verse['text_uthmani'].strip()
                                if verse_text:
                                    page_verses.append(verse_text)
                            # Fallback: Get Uthmanic text from words array
                            elif 'words' in verse and verse['words']:
                                words_text = []
                                for word in verse['words']:
                                    if isinstance(word, dict):
                                        # Use text_uthmani field from words
                                        word_text = word.get('text_uthmani', '')
                                        if word_text and word.get('char_type_name') != 'end':
                                            words_text.append(word_text)
                                if words_text:
                                    verse_text = ' '.join(words_text)
                                    if verse_text.strip():
                                        page_verses.append(verse_text.strip())
                        
                        if page_verses:
                            quran_text[str(page_num)] = '\n'.join(page_verses)
                        
                        if page_num % 50 == 0:
                            print(f"Downloaded {page_num}/604 pages...")
                
            except Exception as e:
                print(f"Error downloading page {page_num}: {e}")
                continue
        
        print(f"Downloaded {len(quran_text)} pages")
        return quran_text
        
    except Exception as e:
        print(f"Error with Quran.com API: {e}")
        return None

def create_quran_json():
    """
    Main function to download and create Quran JSON file
    """
    print("=" * 60)
    print("Quran Text Downloader - Uthmanic Script")
    print("Source: Tanzil Project (via Quran.com API)")
    print("=" * 60)
    
    # Try different methods
    quran_text = None
    
    # Method 1: Quran.com API (most reliable)
    quran_text = get_quran_from_quran_com()
    
    # Method 2: Fallback to API method
    if not quran_text:
        quran_text = get_quran_from_tanzil_api()
    
    if not quran_text:
        print("\n[ERROR] Failed to download Quran text from online sources")
        print("Creating template file instead...")
        # Create a template with first page as example
        quran_text = {
            "1": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\n\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ\nالرَّحْمَٰنِ الرَّحِيمِ\nمَالِكِ يَوْمِ الدِّينِ\nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\nاهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ\nصِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ",
        }
        print("[WARNING] Template created. Please add remaining pages manually or use a different source.")
    
    # Ensure assets/quran directory exists
    output_dir = Path("assets/quran")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Save to JSON file
    output_file = output_dir / "quran_text.json"
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(quran_text, f, ensure_ascii=False, indent=2)
    
    print(f"\n[SUCCESS] Quran text saved to: {output_file}")
    print(f"   Total pages: {len(quran_text)}")
    print(f"   File size: {output_file.stat().st_size / 1024:.2f} KB")
    
    # Verify format
    if len(quran_text) >= 600:
        print("\n[SUCCESS] Success! Quran text downloaded successfully.")
    else:
        print(f"\n[WARNING] Warning: Only {len(quran_text)} pages downloaded. Expected 604 pages.")
        print("   You may need to run the script again or use an alternative source.")

if __name__ == "__main__":
    try:
        create_quran_json()
    except KeyboardInterrupt:
        print("\n\nDownload cancelled by user.")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
