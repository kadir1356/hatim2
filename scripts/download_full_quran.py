#!/usr/bin/env python3
"""
Download complete Quran (604 pages) using Quran.com API
Strategy: Fetch all verses with their page numbers and group by page
"""

import json
import requests
import time
from pathlib import Path

def download_full_quran_with_pages():
    """
    Download all 6236 verses with page numbers from Quran.com API
    """
    print("=" * 60)
    print("Downloading FULL Quran - 604 Pages")
    print("Source: Quran.com API (Uthmanic Text)")
    print("=" * 60)
    print()
    
    # Quran has 6236 verses total
    # We'll fetch them in chunks by chapter (surah)
    
    quran_by_page = {}
    
    try:
        # Get all chapters info first
        print("Fetching chapter information...")
        chapters_response = requests.get(
            "https://api.quran.com/api/v4/chapters",
            timeout=10
        )
        
        if chapters_response.status_code != 200:
            print(f"[ERROR] Failed to fetch chapters: {chapters_response.status_code}")
            return None
        
        chapters = chapters_response.json().get('chapters', [])
        print(f"[OK] Found {len(chapters)} chapters (surahs)")
        print()
        
        # Now fetch all verses chapter by chapter
        total_verses = 0
        
        for chapter in chapters:
            chapter_id = chapter['id']
            chapter_name = chapter['name_simple']
            verses_count = chapter['verses_count']
            
            print(f"Chapter {chapter_id}: {chapter_name} ({verses_count} verses)...", end=" ")
            
            try:
                # Fetch all verses for this chapter
                verses_response = requests.get(
                    f"https://api.quran.com/api/v4/quran/verses/uthmani",
                    params={
                        "chapter_number": chapter_id
                    },
                    timeout=15
                )
                
                if verses_response.status_code == 200:
                    data = verses_response.json()
                    verses = data.get('verses', [])
                    
                    for verse in verses:
                        page_num = verse.get('page_number')
                        text = verse.get('text_uthmani', '').strip()
                        
                        if page_num and text:
                            page_key = str(page_num)
                            
                            if page_key not in quran_by_page:
                                quran_by_page[page_key] = []
                            
                            quran_by_page[page_key].append(text)
                            total_verses += 1
                    
                    print(f"OK ({len(verses)} verses)")
                else:
                    print(f"FAILED ({verses_response.status_code})")
                
                # Small delay to avoid rate limiting
                time.sleep(0.2)
                
            except Exception as e:
                print(f"[ERROR] {e}")
                continue
        
        print()
        print(f"Total verses collected: {total_verses}")
        print(f"Total pages: {len(quran_by_page)}")
        
        # Convert lists to newline-separated strings
        quran_text = {}
        for page_num in sorted(quran_by_page.keys(), key=int):
            verses = quran_by_page[page_num]
            quran_text[page_num] = '\n'.join(verses)
        
        return quran_text
        
    except Exception as e:
        print(f"\n[ERROR] {e}")
        import traceback
        traceback.print_exc()
        return None

def save_quran_json(quran_text):
    """Save Quran text to JSON file"""
    if not quran_text:
        print("\n[ERROR] No data to save")
        return False
    
    # Ensure directory exists
    output_dir = Path("assets/quran")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Save to JSON
    output_file = output_dir / "quran_text.json"
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(quran_text, f, ensure_ascii=False, indent=2)
    
    print(f"\n[SUCCESS] Saved to: {output_file}")
    print(f"   Total pages: {len(quran_text)}")
    print(f"   File size: {output_file.stat().st_size / 1024:.2f} KB")
    
    # Verify first 3 pages
    print("\nVerification:")
    for page_num in ['1', '2', '3']:
        if page_num in quran_text:
            text = quran_text[page_num]
            preview = text[:80] if len(text) > 80 else text
            print(f"   Page {page_num}: {preview}...")
    
    return True

def main():
    print("\nStarting download...")
    print()
    
    quran_text = download_full_quran_with_pages()
    
    if quran_text and len(quran_text) >= 600:
        print("\n" + "=" * 60)
        print("[SUCCESS] Full Quran downloaded!")
        print("=" * 60)
        
        save_quran_json(quran_text)
    else:
        print("\n" + "=" * 60)
        print("[FAILED] Incomplete download")
        print("=" * 60)
        if quran_text:
            print(f"   Only {len(quran_text)} pages downloaded")
            print(f"   Expected 604 pages")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n[CANCELLED] Download cancelled by user")
    except Exception as e:
        print(f"\n[ERROR] {e}")
        import traceback
        traceback.print_exc()
