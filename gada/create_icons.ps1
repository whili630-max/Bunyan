# Create icons for Bunyan app
# This script creates simple text files that can be later converted to proper images

# Create Icon-192.png placeholder
$icon192Path = "C:\Projects\Bunyan\gada\web\icons\Icon-192.png"
$icon192Content = [byte[]]::new(1024)
# Fill with pattern (simple colored pixels)
for ($i = 0; $i -lt $icon192Content.Length; $i++) {
    $icon192Content[$i] = ($i % 256)
}
[System.IO.File]::WriteAllBytes($icon192Path, $icon192Content)
Write-Host "Created placeholder for Icon-192.png"

# Create Icon-512.png placeholder
$icon512Path = "C:\Projects\Bunyan\gada\web\icons\Icon-512.png"
$icon512Content = [byte[]]::new(2048)
# Fill with pattern (simple colored pixels)
for ($i = 0; $i -lt $icon512Content.Length; $i++) {
    $icon512Content[$i] = ($i % 256)
}
[System.IO.File]::WriteAllBytes($icon512Path, $icon512Content)
Write-Host "Created placeholder for Icon-512.png"

# Check that the files exist
Get-Item -Path "C:\Projects\Bunyan\gada\web\icons\Icon-192.png" | Select-Object Name, Length
Get-Item -Path "C:\Projects\Bunyan\gada\web\icons\Icon-512.png" | Select-Object Name, Length

Write-Host "Icons created successfully. You'll need to replace these with proper images later."
Write-Host "Please update 'index.html' to use these icons correctly."
