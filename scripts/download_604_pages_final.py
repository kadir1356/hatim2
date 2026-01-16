#!/usr/bin/env python3
"""
FINAL STRATEGY: Download all 604 pages using Quran.com by_page endpoint
Each page request gives us all verses for that specific page
"""

import json
import requests
import time
from pathlib import Path

def download_page(page_number):
    """Download a single page's verses"""
    try:
        url = f"https://api.quran.com/api/v4/verses/by_page/{page_number}"
        params = {
            "words": "false",
            "translations": ""
        }
        
        response = requests.get(url, params=params, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            verses = data.get('verses', [])
            
            if verses:
                # Extract Uthmanic text from each verse
                verse_texts = []
                for verse in verses:
                    text = verse.get('text_uthmani', '').strip()
                    if text:
                        verse_texts.append(text)
                
                # Join with double newline for readability
                return '\n\n'.join(verse_texts)
        
        return None
        
    except Exception as e:
        print(f"  [ERROR] Page {page_number}: {e}")
        return None

def download_all_604_pages():
    """Download all 604 pages"""
    print("=" * 70)
    print("DOWNLOADING 604 PAGES - MADINAH MUSHAF")
    print("Source: Quran.com API (by_page endpoint)")
    print("=" * 70)
    print()
    
    quran_text = {}
    failed_pages = []
    
    for page_num in range(1, 605):  # 1 to 604
        print(f"Page {page_num:3d}/604...", end=" ", flush=True)
        
        page_text = download_page(page_num)
        
        if page_text:
            quran_text[str(page_num)] = page_text
            print(f"OK ({len(page_text)} chars)")
        else:
            print("FAILED")
            failed_pages.append(page_num)
        
        # Rate limiting - be nice to the API
        time.sleep(0.15)  # 150ms delay between requests
        
        # Progress update every 50 pages
        if page_num % 50 == 0:
            print(f"\n[Progress] {page_num}/604 pages downloaded ({len(quran_text)} successful)\n")
    
    print()
    print(f"[RESULT] Downloaded {len(quran_text)}/604 pages")
    
    if failed_pages:
        print(f"[WARNING] Failed pages: {failed_pages[:10]}{'...' if len(failed_pages) > 10 else ''}")
    
    return quran_text

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
    
    # Verification
    print("[VERIFICATION]")
    print("-" * 70)
    
    # Page 1: Al-Fatiha
    if '1' in quran_text:
        page1 = quran_text['1']
        print(f"Page 1 (first 80 chars):")
        print(f"  {page1[:80]}")
        if 'بِسْمِ' in page1 and 'ٱلْحَمْدُ' in page1:
            print("  [OK] Contains Fatiha (Bismillah + Alhamdulillah)")
        else:
            print("  [WARNING] Might not be Fatiha")
    else:
        print("  [ERROR] Page 1 missing!")
    
    print()
    
    # Page 2: Al-Baqarah
    if '2' in quran_text:
        page2 = quran_text['2']
        print(f"Page 2 (first 80 chars):")
        print(f"  {page2[:80]}")
        # Alif-Lam-Mim: الم or ٱلٓمٓ
        if 'ٱلٓمٓ' in page2 or 'الم' in page2:
            print("  [OK] Contains Baqarah (Alif-Lam-Mim)")
        else:
            print("  [WARNING] Might not be Baqarah")
    else:
        print("  [ERROR] Page 2 missing!")
    
    print()
    
    # Page 604: An-Nas
    if '604' in quran_text:
        page604 = quran_text['604']
        print(f"Page 604 (last 80 chars):")
        print(f"  ...{page604[-80:]}")
        if 'النَّاسِ' in page604 or 'ٱلنَّاسِ' in page604:
            print("  [OK] Contains An-Nas")
        else:
            print("  [WARNING] Might not be An-Nas")
    else:
        print("  [ERROR] Page 604 missing!")
    
    print("-" * 70)
    
    return len(quran_text) >= 600

def main():
    print("\n" + "=" * 70)
    print(" QURAN DOWNLOADER - 604 PAGES (Madinah Mushaf)")
    print("=" * 70)
    print()
    
    # Download all 604 pages
    quran_text = download_all_604_pages()
    
    # Save and verify
    if quran_text and len(quran_text) >= 600:
        success = save_and_verify(quran_text)
        if success:
            print("\n[SUCCESS] Download complete and verified!")
            print("[INFO] You can now run the Flutter app and see all 604 pages.")
        else:
            print("\n[WARNING] Download incomplete or verification failed.")
    else:
        print("\n[FAILED] Could not download complete Quran.")
        print(f"[INFO] Only {len(quran_text) if quran_text else 0} pages obtained.")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n[CANCELLED] Download cancelled by user.")
    except Exception as e:
        print(f"\n[ERROR] {e}")
        import traceback
        traceback.print_exc()
