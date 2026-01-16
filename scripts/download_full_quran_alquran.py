#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
FINAL WORKING SOLUTION: Download all 604 pages from AlQuran.cloud API
This API actually works and returns proper Uthmanic text!
"""

import json
import requests
import time
import sys
import io
from pathlib import Path

# Fix Unicode output for Windows console
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def download_page(page_number):
    """Download a single page from AlQuran.cloud"""
    try:
        url = f"https://api.alquran.cloud/v1/page/{page_number}/quran-uthmani"
        
        response = requests.get(url, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            
            # Check if response is valid
            if data.get('code') == 200 and 'data' in data:
                ayahs = data['data'].get('ayahs', [])
                
                if ayahs:
                    # Extract Uthmanic text from each ayah
                    verse_texts = []
                    for ayah in ayahs:
                        text = ayah.get('text', '').strip()
                        if text:
                            verse_texts.append(text)
                    
                    # Join with double newline for readability
                    return '\n\n'.join(verse_texts)
        
        return None
        
    except Exception as e:
        return None

def download_all_604_pages():
    """Download all 604 pages"""
    print("=" * 70)
    print("DOWNLOADING 604 PAGES - AlQuran.cloud API")
    print("Source: api.alquran.cloud (Uthmani edition)")
    print("=" * 70)
    print()
    
    quran_text = {}
    failed_pages = []
    
    for page_num in range(1, 605):  # 1 to 604
        # Progress indicator without Arabic text to avoid encoding issues
        print(f"Page {page_num:3d}/604...", end=" ", flush=True)
        
        page_text = download_page(page_num)
        
        if page_text:
            quran_text[str(page_num)] = page_text
            print(f"OK ({len(page_text)} chars)")
        else:
            print("FAILED")
            failed_pages.append(page_num)
        
        # Rate limiting - be nice to the API
        time.sleep(0.2)  # 200ms delay
        
        # Progress update every 50 pages
        if page_num % 50 == 0:
            print(f"\n>>> Progress: {page_num}/604 pages ({len(quran_text)} successful)\n")
    
    print()
    print(f"[RESULT] Downloaded {len(quran_text)}/604 pages")
    
    if failed_pages:
        print(f"[WARNING] Failed pages: {failed_pages[:10]}{'...' if len(failed_pages) > 10 else ''}")
    
    return quran_text, failed_pages

def save_and_verify(quran_text):
    """Save and verify the downloaded Quran"""
    if not quran_text:
        print("\n[ERROR] No data to save")
        return False
    
    # Save to JSON
    output_dir = Path("assets/quran")
    output_dir.mkdir(parents=True, exist_ok=True)
    output_file = output_dir / "quran_text.json"
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(quran_text, f, ensure_ascii=False, indent=2)
    
    file_size_kb = output_file.stat().st_size / 1024
    
    print("\n" + "=" * 70)
    print("[SUCCESS] Quran saved successfully!")
    print("=" * 70)
    print(f"File: {output_file}")
    print(f"Pages: {len(quran_text)}/604")
    print(f"Size: {file_size_kb:.2f} KB")
    print()
    
    # Verification (without printing Arabic to avoid encoding issues)
    print("[VERIFICATION]")
    print("-" * 70)
    
    # Check key pages
    checks = []
    
    if '1' in quran_text:
        page1 = quran_text['1']
        has_bismillah = 'بِسْمِ' in page1 or 'بسم' in page1
        has_alhamdulillah = 'ٱلْحَمْدُ' in page1 or 'الحمد' in page1
        checks.append(("Page 1 (Fatiha)", has_bismillah and has_alhamdulillah, len(page1)))
    else:
        checks.append(("Page 1 (Fatiha)", False, 0))
    
    if '2' in quran_text:
        page2 = quran_text['2']
        has_alif_lam_mim = 'الم' in page2 or 'ٱلٓمٓ' in page2
        checks.append(("Page 2 (Baqarah)", has_alif_lam_mim, len(page2)))
    else:
        checks.append(("Page 2 (Baqarah)", False, 0))
    
    if '604' in quran_text:
        page604 = quran_text['604']
        has_nas = 'النَّاسِ' in page604 or 'الناس' in page604
        checks.append(("Page 604 (An-Nas)", has_nas, len(page604)))
    else:
        checks.append(("Page 604 (An-Nas)", False, 0))
    
    # Print verification results
    all_passed = True
    for page_name, passed, char_count in checks:
        status = "[OK]" if passed else "[FAILED]"
        print(f"{status} {page_name}: {char_count} chars")
        if not passed:
            all_passed = False
    
    print("-" * 70)
    
    return all_passed and len(quran_text) >= 600

def main():
    print("\n" + "=" * 70)
    print(" QURAN DOWNLOADER - 604 PAGES (Madinah Mushaf)")
    print(" Source: AlQuran.cloud API (Working!)")
    print("=" * 70)
    print()
    
    # Download all 604 pages
    quran_text, failed_pages = download_all_604_pages()
    
    # Save and verify
    if quran_text and len(quran_text) >= 600:
        success = save_and_verify(quran_text)
        
        if success:
            print("\n[SUCCESS] Download complete and verified!")
            print("[INFO] You can now restart Flutter app to see all 604 pages.")
            print()
            
            if failed_pages:
                print(f"[WARNING] {len(failed_pages)} pages failed. Retry those manually if needed.")
                print(f"Failed pages: {failed_pages}")
        else:
            print("\n[WARNING] Download incomplete or verification failed.")
            
            if failed_pages:
                print(f"\n[RETRY] You can retry {len(failed_pages)} failed pages:")
                print(failed_pages)
    else:
        print("\n[FAILED] Could not download complete Quran.")
        print(f"[INFO] Only {len(quran_text) if quran_text else 0}/604 pages obtained.")
        
        if failed_pages:
            print(f"[INFO] {len(failed_pages)} pages failed")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n[CANCELLED] Download cancelled by user.")
    except Exception as e:
        print(f"\n[ERROR] {e}")
        import traceback
        traceback.print_exc()
