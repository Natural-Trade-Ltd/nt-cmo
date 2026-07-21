# CMO_Setup.ps1  -  Instalador del CMO (Natural Trade / Global Forest)
# Crea el icono, programa el inicio automatico 8am L-V y abre la app en MODO APP (ventana propia).
$ErrorActionPreference = 'Stop'
$Url  = 'https://natural-trade-ltd.github.io/nt-cmo/'
$Name = 'CMO Inicio 8am'

# --- elegir navegador: preferir Chrome (default); si no esta, usar Edge (siempre presente en Windows) ---
$chromePaths = @("$Env:ProgramFiles\Google\Chrome\Application\chrome.exe","${Env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe","$Env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe")
$edgePaths   = @("$Env:ProgramFiles\Microsoft\Edge\Application\msedge.exe","${Env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe")
$browser = ($chromePaths + $edgePaths) | Where-Object { Test-Path $_ } | Select-Object -First 1

# --- acceso directo en Escritorio y menu Inicio (abre en modo app) ---
$w = New-Object -ComObject WScript.Shell
foreach($dir in @([Environment]::GetFolderPath('Desktop'), (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'))){
  try{
    $lnk = $w.CreateShortcut((Join-Path $dir 'CMO.lnk'))
    if($browser){ $lnk.TargetPath=$browser; $lnk.Arguments="--app=$Url"; $lnk.IconLocation="$browser,0" } else { $lnk.TargetPath=$Url }
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

$eng = if($browser){ Split-Path $browser -Leaf } else { 'navegador predeterminado' }
Write-Host ''
Write-Host " Listo! El CMO quedo instalado como app en esta PC (motor: $eng):" -ForegroundColor Green
Write-Host '   - Icono "CMO" en tu Escritorio y en el menu Inicio (abre en ventana propia, sin pestanas).'
Write-Host '   - Se abrira solo de lunes a viernes a las 8:00 am.'
Write-Host ''
Write-Host ' Abriendo el CMO para que inicies sesion con Google...' -ForegroundColor Green
if($browser){ Start-Process $browser -ArgumentList "--app=$Url" } else { Start-Process $Url }
Start-Sleep -Seconds 2
