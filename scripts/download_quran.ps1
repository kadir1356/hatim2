# PowerShell script to download Uthmanic Arabic Quran text
# Uses Quran.com API (Tanzil Uthmanic script)

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Quran Text Downloader - Uthmanic Script" -ForegroundColor Cyan
Write-Host "Source: Tanzil Project (via Quran.com API)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Ensure assets/quran directory exists
$quranDir = "assets\quran"
if (-not (Test-Path $quranDir)) {
    New-Item -ItemType Directory -Path $quranDir -Force | Out-Null
    Write-Host "Created directory: $quranDir" -ForegroundColor Green
}

$quranText = @{}
$totalPages = 604
$downloaded = 0

Write-Host "Downloading Quran text (this may take a few minutes)..." -ForegroundColor Yellow
Write-Host ""

for ($pageNum = 1; $pageNum -le $totalPages; $pageNum++) {
    try {
        $uri = "https://api.quran.com/api/v4/verses/by_page/$pageNum?language=ar&words=true"
        $response = Invoke-RestMethod -Uri $uri -Method Get -TimeoutSec 10 -ErrorAction Stop
        
        if ($response.verses -and $response.verses.Count -gt 0) {
            $pageVerses = @()
            
            foreach ($verse in $response.verses) {
                if ($verse.words) {
                    $verseText = ($verse.words | Where-Object { $_.text_uthmani } | ForEach-Object { $_.text_uthmani }) -join ' '
                    if ($verseText) {
                        $pageVerses += $verseText
                    }
                }
            }
            
            if ($pageVerses.Count -gt 0) {
                $quranText[$pageNum.ToString()] = $pageVerses -join "`n"
                $downloaded++
            }
        }
        
        if ($pageNum % 50 -eq 0) {
            Write-Host "Downloaded $pageNum/$totalPages pages..." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error downloading page $pageNum : $_" -ForegroundColor Red
        continue
    }
}

if ($quranText.Count -eq 0) {
    Write-Host "`nFailed to download from API. Creating template..." -ForegroundColor Yellow
    $quranText["1"] = "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ`n`nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ`nالرَّحْمَٰنِ الرَّحِيمِ`nمَالِكِ يَوْمِ الدِّينِ`nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ`nاهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ`nصِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ"
}

# Convert to JSON
$jsonContent = $quranText | ConvertTo-Json -Depth 10

# Save to file
$outputFile = "$quranDir\quran_text.json"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($outputFile, $jsonContent, $utf8NoBom)

$fileSize = (Get-Item $outputFile).Length / 1KB

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Download Complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "File: $outputFile" -ForegroundColor White
Write-Host "Total pages: $($quranText.Count)" -ForegroundColor White
Write-Host "File size: $([math]::Round($fileSize, 2)) KB" -ForegroundColor White

if ($quranText.Count -ge 600) {
    Write-Host "`n✅ Success! Quran text downloaded successfully." -ForegroundColor Green
} else {
    Write-Host "`n⚠️  Warning: Only $($quranText.Count) pages downloaded. Expected 604 pages." -ForegroundColor Yellow
}
