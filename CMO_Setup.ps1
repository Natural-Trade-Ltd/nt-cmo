# CMO_Setup.ps1  -  Instalador del CMO (Natural Trade / Global Forest)
# Instala el CMO "como app": acceso en Escritorio + menu Inicio que abre en MODO APP (ventana propia,
# sin pestanas ni barra) usando SIEMPRE Chrome (no depende del navegador predeterminado). Programa el
# inicio automatico L-V 8:00am. Si no hubiera Chrome, cae a Edge (siempre presente en Windows).
$ErrorActionPreference = 'Stop'
$Url  = 'https://natural-trade-ltd.github.io/nt-cmo/'
$Name = 'CMO Inicio 8am'

# --- localizar Chrome (rutas estandar + registro App Paths); si no, Edge ---
function Get-Browser {
  $chrome = @("$Env:ProgramFiles\Google\Chrome\Application\chrome.exe",
              "${Env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
              "$Env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe") |
            Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $chrome) {
    $reg = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe"
    if (Test-Path $reg) { $p = (Get-ItemProperty $reg).'(default)'; if ($p -and (Test-Path $p)) { $chrome = $p } }
  }
  if ($chrome) { return $chrome }
  $edge = @("$Env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
            "${Env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe") |
          Where-Object { Test-Path $_ } | Select-Object -First 1
  return $edge
}
$browser = Get-Browser
$eng = if ($browser) { Split-Path $browser -Leaf } else { 'navegador predeterminado' }

# --- icono "app-like" (cuadro redondeado verde con "CMO"); si falla, se usa el del navegador ---
$icon = if ($browser) { "$browser,0" } else { '' }
try {
  Add-Type -AssemblyName System.Drawing
  $icoDir = Join-Path $Env:LOCALAPPDATA 'NT-Apps'
  New-Item -ItemType Directory -Force -Path $icoDir | Out-Null
  $icoPath = Join-Path $icoDir 'CMO.ico'
  $sz = 128
  $bmp = New-Object System.Drawing.Bitmap $sz,$sz
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'
  $g.Clear([System.Drawing.Color]::Transparent)
  $pad = 8; $d = $sz - 2*$pad; $r = 26
  $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
  $gp.AddArc($pad,$pad,$r,$r,180,90); $gp.AddArc($pad+$d-$r,$pad,$r,$r,270,90)
  $gp.AddArc($pad+$d-$r,$pad+$d-$r,$r,$r,0,90); $gp.AddArc($pad,$pad+$d-$r,$r,$r,90,90); $gp.CloseFigure()
  $g.FillPath((New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#16352a'))),$gp)
  $font = New-Object System.Drawing.Font('Segoe UI',34,[System.Drawing.FontStyle]::Bold)
  $sf = New-Object System.Drawing.StringFormat; $sf.Alignment='Center'; $sf.LineAlignment='Center'
  $g.DrawString('CMO',$font,(New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#57b083'))),(New-Object System.Drawing.RectangleF 0,0,$sz,$sz),$sf)
  $g.Dispose()
  $hicon = $bmp.GetHicon(); $ic = [System.Drawing.Icon]::FromHandle($hicon)
  $fs = [System.IO.File]::Create($icoPath); $ic.Save($fs); $fs.Close(); $bmp.Dispose()
  $icon = "$icoPath,0"
} catch { }

# --- acceso directo en Escritorio y menu Inicio (abre en modo app) ---
$w = New-Object -ComObject WScript.Shell
foreach($dir in @([Environment]::GetFolderPath('Desktop'), (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'))){
  try{
    $lnk = $w.CreateShortcut((Join-Path $dir 'CMO.lnk'))
    if($browser){ $lnk.TargetPath=$browser; $lnk.Arguments="--app=$Url"; if($icon){ $lnk.IconLocation=$icon } }
    else { $lnk.TargetPath=$Url }
    $lnk.Description='Centro Maestro de Operaciones - NT/GF'
    $lnk.Save()
  }catch{}
}

# --- tarea programada: L-V 8:00 am (si la PC estaba apagada, corre al encender) ---
if($browser){ $action = New-ScheduledTaskAction -Execute $browser -Argument "--app=$Url" }
else        { $action = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument "/c start `"`" `"$Url`"" }
$trigger  = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -At 8:00am
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
try { Unregister-ScheduledTask -TaskName $Name -Confirm:$false -ErrorAction SilentlyContinue } catch {}
Register-ScheduledTask -TaskName $Name -Action $action -Trigger $trigger -Settings $settings `
  -Description 'Abre el CMO de lunes a viernes a las 8:00 am (modo app) y registra el inicio de jornada.' | Out-Null

Write-Host ''
Write-Host " Listo! El CMO quedo instalado como app en esta PC (motor: $eng):" -ForegroundColor Green
Write-Host '   - Icono "CMO" en tu Escritorio y en el menu Inicio (abre en ventana propia, sin pestanas).'
Write-Host '   - Se abrira solo de lunes a viernes a las 8:00 am.'
Write-Host ''
Write-Host ' Abriendo el CMO para que inicies sesion con Google...' -ForegroundColor Green
if($browser){ Start-Process $browser -ArgumentList "--app=$Url" } else { Start-Process $Url }
Start-Sleep -Seconds 2
