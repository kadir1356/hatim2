# Quick script to check download progress
$file = "assets\quran\quran_text.json"

if (Test-Path $file) {
    $jsonContent = Get-Content $file -Raw | ConvertFrom-Json
    $pageCount = ($jsonContent.PSObject.Properties | Measure-Object).Count
    $fileSize = (Get-Item $file).Length / 1KB
    
    Write-Host "`nDownload Progress:" -ForegroundColor Cyan
    Write-Host "  Pages downloaded: $pageCount / 604" -ForegroundColor $(if ($pageCount -ge 600) { "Green" } else { "Yellow" })
    Write-Host "  File size: $([math]::Round($fileSize, 2)) KB" -ForegroundColor White
    
    if ($pageCount -ge 604) {
        Write-Host "`n[SUCCESS] Download complete! All 604 pages downloaded." -ForegroundColor Green
        
        # Check if content has Arabic text
        $firstPage = $jsonContent."1"
        if ($firstPage -match "[\u0600-\u06FF]") {
            Write-Host "[SUCCESS] Arabic text detected in file!" -ForegroundColor Green
        } else {
            Write-Host "[WARNING] No Arabic text detected. May need to re-download." -ForegroundColor Yellow
        }
    } else {
        Write-Host "`n[INFO] Download in progress... ($pageCount/604 pages)" -ForegroundColor Yellow
        Write-Host "  Estimated time remaining: ~$([math]::Round((604 - $pageCount) * 0.5 / 60, 1)) minutes" -ForegroundColor Gray
    }
} else {
    Write-Host "[INFO] File not found yet. Download may be starting..." -ForegroundColor Yellow
}
