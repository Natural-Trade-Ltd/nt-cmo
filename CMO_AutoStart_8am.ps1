# ============================================================
#  CMO - Inicio automatico a las 8:00 am (lunes a viernes)
#  Cada usuario lo corre UNA vez en su PC.
#  Como correrlo:  clic derecho -> "Ejecutar con PowerShell"
#     (o abrir PowerShell y pegar:  powershell -ExecutionPolicy Bypass -File .\CMO_AutoStart_8am.ps1 )
#  No requiere admin: registra una tarea del usuario actual.
# ============================================================

$Url  = "https://natural-trade-ltd.github.io/nt-cmo/"
$Name = "CMO Inicio 8am"

# --- localizar Microsoft Edge ---
$edgeCandidates = @(
  "$Env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
  "${Env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
)
$Edge = $edgeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $Edge) {
  Write-Host "No encontre Microsoft Edge. Se abrira con el navegador predeterminado." -ForegroundColor Yellow
  $Action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c start `"`" `"$Url`""
} else {
  # --app = ventana tipo aplicacion (como la PWA instalada)
  $Action = New-ScheduledTaskAction -Execute $Edge -Argument "--app=$Url"
}

# --- disparador: cada dia laboral a las 8:00; si la PC estaba apagada, corre al encender ---
$Trigger  = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -At 8:00am
$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries

# --- reemplaza la tarea si ya existia ---
Unregister-ScheduledTask -TaskName $Name -Confirm:$false -ErrorAction SilentlyContinue

Register-ScheduledTask -TaskName $Name -Action $Action -Trigger $Trigger -Settings $Settings `
  -Description "Abre el CMO cada dia laboral a las 8:00 am y registra el inicio de jornada automaticamente." | Out-Null

Write-Host ""
Write-Host "Listo. El CMO se abrira solo de lunes a viernes a las 8:00 am." -ForegroundColor Green
Write-Host "(Si la PC estaba apagada a esa hora, se abre en cuanto la enciendas.)" -ForegroundColor Green
Write-Host ""
Write-Host "Para quitarlo mas adelante:  Unregister-ScheduledTask -TaskName '$Name' -Confirm:`$false" -ForegroundColor DarkGray
