# 브라우저 접속 화면(주소창 포함)을 PNG로 캡처하는 보조 스크립트 (Windows 전용)
# 사용법: powershell -ExecutionPolicy Bypass -File capture_browser.ps1 -Url http://localhost:8080 -Out C:\path\shot.png [-Title Codyssey]
# - 개인 북마크/계정이 찍히지 않도록 매번 새(임시) Chrome 프로필로 띄운다.
param([string]$Url, [string]$Out, [string]$Title = "Codyssey")
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System; using System.Runtime.InteropServices;
public class W {
  [DllImport("dwmapi.dll")] public static extern int DwmGetWindowAttribute(IntPtr h, int a, out RECT r, int s);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr h, int x, int y, int w, int hh, bool r);
  public struct RECT { public int L, T, R, B; }
}
"@
$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$prof = Join-Path $env:TEMP ("codyssey-chrome-" + [guid]::NewGuid())
Start-Process $chrome -ArgumentList "--user-data-dir=$prof", "--no-first-run", "--no-default-browser-check", "--new-window", $Url | Out-Null
$h = [IntPtr]::Zero
for ($i = 0; $i -lt 20 -and $h -eq [IntPtr]::Zero; $i++) {
  Start-Sleep -Milliseconds 500
  $w = Get-Process chrome -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 -and $_.MainWindowTitle -like "*$Title*" } | Select-Object -First 1
  if ($w) { $h = $w.MainWindowHandle }
}
if ($h -eq [IntPtr]::Zero) { throw "browser window not found" }
[W]::MoveWindow($h, 40, 40, 1100, 650, $true) | Out-Null
[W]::SetForegroundWindow($h) | Out-Null
Start-Sleep 2
$r = New-Object W+RECT
[W]::DwmGetWindowAttribute($h, 9, [ref]$r, 16) | Out-Null   # DWMWA_EXTENDED_FRAME_BOUNDS
$bmp = New-Object System.Drawing.Bitmap ($r.R - $r.L), ($r.B - $r.T)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($r.L, $r.T, 0, 0, $bmp.Size)
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" | Where-Object { $_.CommandLine -like "*$prof*" } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep 1
Remove-Item -Recurse -Force $prof -ErrorAction SilentlyContinue
