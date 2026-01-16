#!/usr/bin/env python3
"""
Try AlQuran.cloud API - might have better page support
"""

import json
import requests
import time
from pathlib import Path

def download_page_alquran(page_number):
    """Download page from AlQuran.cloud API"""
    try:
        # Try AlQuran.cloud endpoint
        url = f"https://api.alquran.cloud/v1/page/{page_number}/quran-uthmani"
        
        response = requests.get(url, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            
            # Check if data is valid
            if data.get('code') == 200 and 'data' in data:
                ayahs = data['data'].get('ayahs', [])
                
                if ayahs:
                    # Extract text from each ayah
                    verse_texts = []
                    for ayah in ayahs:
                        text = ayah.get('text', '').strip()
                        if text:
                            verse_texts.append(text)
                    
                    return '\n\n'.join(verse_texts)
        
        return None
        
    except Exception as e:
        print(f"  [ERROR] Page {page_number}: {e}")
        return None

def main():
    print("=" * 70)
    print("TESTING ALQURAN.CLOUD API")
    print("=" * 70)
    print()
    
    # Test first 5 pages
    test_pages = [1, 2, 3, 604]
    
    for page_num in test_pages:
        print(f"Testing Page {page_num}...", end=" ", flush=True)
        
        page_text = download_page_alquran(page_num)
        
        if page_text:
            print(f"SUCCESS ({len(page_text)} chars)")
            print(f"  Preview: {page_text[:80]}...")
            print()
        else:
            print("FAILED")
        
        time.sleep(0.5)
    
    # If tests pass, offer to download all
    print()
    print("[INFO] If tests above succeeded, I can download all 604 pages.")
    print("[INFO] Modify this script to set DOWNLOAD_ALL = True")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n[CANCELLED]")
    except Exception as e:
        print(f"\n[ERROR] {e}")
        import traceback
        traceback.print_exc()
