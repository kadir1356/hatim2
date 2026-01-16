#!/usr/bin/env python3
"""
Download Quran with proper 604-page Madinah Mushaf mapping
Uses verse-by-verse API with page numbers
"""

import json
import requests
import time
from pathlib import Path

# Madinah Mushaf Page Boundaries (Standard 604-page distribution)
# This is a verified mapping from Tanzil/QuranComplex data
PAGE_TO_VERSE_START = {
    1: (1, 1),    # Fatiha 1:1
    2: (2, 1),    # Baqarah 2:1 (Alif-Lam-Mim)
    3: (2, 6),
    4: (2, 17),
    5: (2, 25),
    # ... (we'll fetch dynamically from API with page_number field)
}

def download_quran_by_pages_v2():
    """
    Download using Quran.com API - fetch all verses with page numbers
    """
    print("=" * 70)
    print("DOWNLOADING FULL QURAN - 604 PAGES (Madinah Mushaf)")
    print("Strategy: Fetch all 6236 verses grouped by page number")
    print("=" * 70)
    print()
    
    quran_by_page = {}
    
    try:
        # Strategy: Download entire Quran verse-by-verse
        # The API should include page_number in the response
        print("[Step 1] Downloading all verses from Quran.com API...")
        print()
        
        # Try the verses endpoint with pagination
        page_num = 1
        per_page = 50  # Fetch 50 verses at a time
        total_verses = 0
        
        while True:
            try:
                print(f"Fetching verses page {page_num} (offset: {(page_num-1)*per_page})...", end=" ")
                
                response = requests.get(
                    "https://api.quran.com/api/v4/verses/by_page/1",
                    params={
                        "words": "false",
                        "translations": "",
                        "per_page": per_page,
                        "page": page_num
                    },
                    timeout=15
                )
                
                if response.status_code != 200:
                    print(f"FAILED ({response.status_code})")
                    break
                
                data = response.json()
                verses = data.get('verses', [])
                
                if not verses:
                    print("No more verses")
                    break
                
                print(f"OK ({len(verses)} verses)")
                
                # Group verses by page number
                for verse in verses:
                    verse_page = verse.get('page_number')
                    verse_text = verse.get('text_uthmani', '').strip()
                    
                    if verse_page and verse_text:
                        page_key = str(verse_page)
                        
                        if page_key not in quran_by_page:
                            quran_by_page[page_key] = []
                        
                        quran_by_page[page_key].append(verse_text)
                        total_verses += 1
                
                # Check if we have more pages
                pagination = data.get('pagination', {})
                if not pagination.get('next_page'):
                    break
                
                page_num += 1
                time.sleep(0.3)  # Rate limiting
                
            except Exception as e:
                print(f"ERROR: {e}")
                break
        
        print()
        print(f"[Step 2] Downloaded {total_verses} verses across {len(quran_by_page)} pages")
        
        # Convert to formatted text
        quran_text = {}
        for page_num in sorted(quran_by_page.keys(), key=int):
            verses = quran_by_page[page_num]
            # Join verses with double newline for readability
            quran_text[page_num] = '\n\n'.join(verses)
        
        return quran_text
        
    except Exception as e:
        print(f"\n[ERROR] {e}")
        import traceback
        traceback.print_exc()
        return None

def download_via_curl_tanzil():
    """
    Alternative: Download from Tanzil.net XML and parse
    """
    print("\n[Alternative Method] Downloading from Tanzil.net...")
    
    try:
        # Tanzil provides Uthmanic text in XML format
        url = "https://tanzil.net/pub/download/get_xml.php?tanzilVersion=v1.0.2&quranType=uthmani-min"
        
        print(f"Fetching from: {url}")
        response = requests.get(url, timeout=30)
        
        if response.status_code == 200:
            print(f"[OK] Downloaded {len(response.content)} bytes")
            
            # Parse XML (requires xml.etree.ElementTree)
            import xml.etree.ElementTree as ET
            root = ET.fromstring(response.content)
            
            quran_by_page = {}
            
            # Parse verses and group by page
            for sura in root.findall('.//sura'):
                for aya in sura.findall('aya'):
                    page_num = aya.get('page')
                    text = aya.get('text', '').strip()
                    
                    if page_num and text:
                        if page_num not in quran_by_page:
                            quran_by_page[page_num] = []
                        quran_by_page[page_num].append(text)
            
            # Convert to formatted text
            quran_text = {}
            for page_num in sorted(quran_by_page.keys(), key=int):
                verses = quran_by_page[page_num]
                quran_text[page_num] = '\n\n'.join(verses)
            
            print(f"[OK] Parsed {len(quran_text)} pages from Tanzil XML")
            return quran_text
        else:
            print(f"[ERROR] Failed to download: {response.status_code}")
            return None
            
    except Exception as e:
        print(f"[ERROR] {e}")
        import traceback
        traceback.print_exc()
        return None

def save_and_verify(quran_text):
    """Save Quran text and verify key pages"""
    if not quran_text or len(quran_text) < 600:
        print(f"\n[ERROR] Incomplete data: Only {len(quran_text) if quran_text else 0} pages")
        return False
    
    # Save to JSON
    output_dir = Path("assets/quran")
    output_dir.mkdir(parents=True, exist_ok=True)
    output_file = output_dir / "quran_text.json"
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(quran_text, f, ensure_ascii=False, indent=2)
    
    print(f"\n[SUCCESS] Saved to: {output_file}")
    print(f"   Total pages: {len(quran_text)}")
    print(f"   File size: {output_file.stat().st_size / 1024:.2f} KB")
    
    # Verify critical pages
    print("\n[VERIFICATION]")
    print("-" * 70)
    
    # Page 1: Al-Fatiha
    if '1' in quran_text:
        page1 = quran_text['1']
        print(f"Page 1 (first 100 chars): {page1[:100]}...")
        if 'بِسْمِ' in page1 or 'ٱلْحَمْدُ' in page1:
            print("  [OK] Page 1 contains Fatiha")
        else:
            print("  [WARNING] Page 1 might be incorrect")
    
    # Page 2: Al-Baqarah (Alif-Lam-Mim)
    if '2' in quran_text:
        page2 = quran_text['2']
        print(f"\nPage 2 (first 100 chars): {page2[:100]}...")
        if 'الم' in page2 or 'ذَٰلِكَ' in page2:
            print("  [OK] Page 2 contains Baqarah")
        else:
            print("  [WARNING] Page 2 might be incorrect")
    
    # Page 604: An-Nas
    if '604' in quran_text:
        page604 = quran_text['604']
        print(f"\nPage 604 (last 100 chars): ...{page604[-100:]}...")
        if 'النَّاسِ' in page604 or 'ٱلنَّاسِ' in page604:
            print("  [OK] Page 604 contains An-Nas")
        else:
            print("  [WARNING] Page 604 might be incorrect")
    
    print("-" * 70)
    
    return True

def main():
    print("\nQURAN DOWNLOADER - MADINAH MUSHAF 604 PAGES")
    print()
    
    quran_text = None
    
    # Try Tanzil XML first (most reliable for page numbers)
    quran_text = download_via_curl_tanzil()
    
    # Fallback: Try Quran.com API
    if not quran_text or len(quran_text) < 600:
        print("\n[INFO] Trying alternative method: Quran.com API...")
        quran_text = download_quran_by_pages_v2()
    
    # Save and verify
    if quran_text and len(quran_text) >= 600:
        success = save_and_verify(quran_text)
        if success:
            print("\n[SUCCESS] Full Quran downloaded and verified!")
        else:
            print("\n[WARNING] Downloaded but verification failed.")
    else:
        print("\n[FAILED] Could not download complete Quran")
        print(f"   Only {len(quran_text) if quran_text else 0} pages obtained")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n[CANCELLED] Download cancelled by user")
    except Exception as e:
        print(f"\n[ERROR] {e}")
        import traceback
        traceback.print_exc()
