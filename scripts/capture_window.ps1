# 이미 열려 있는 창(프로세스 이름 + 창 제목 일부)을 PNG로 캡처 (Windows 전용)
# 사용법: powershell -ExecutionPolicy Bypass -File capture_window.ps1 -Process Code -Title workstation -Out C:\path\shot.png
param([string]$Process, [string]$Title, [string]$Out)
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System; using System.Runtime.InteropServices;
public class W2 {
  [DllImport("dwmapi.dll")] public static extern int DwmGetWindowAttribute(IntPtr h, int a, out RECT r, int s);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
  public struct RECT { public int L, T, R, B; }
}
"@
$w = Get-Process $Process -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 -and $_.MainWindowTitle -like "*$Title*" } | Select-Object -First 1
if (-not $w) { throw "window not found" }
$h = $w.MainWindowHandle
[W2]::ShowWindow($h, 3) | Out-Null      # maximize
[W2]::SetForegroundWindow($h) | Out-Null
Start-Sleep 2
$r = New-Object W2+RECT
[W2]::DwmGetWindowAttribute($h, 9, [ref]$r, 16) | Out-Null
$bmp = New-Object System.Drawing.Bitmap ($r.R - $r.L), ($r.B - $r.T)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen($r.L, $r.T, 0, 0, $bmp.Size)
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
