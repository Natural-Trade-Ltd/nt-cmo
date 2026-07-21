@echo off
title Instalar CMO - Natural Trade / Global Forest
echo.
echo   Instalando el CMO en esta computadora...
echo.
echo   (Si Windows muestra un aviso azul "Windows protegio tu PC",
echo    haz clic en "Mas informacion" y luego en "Ejecutar de todas formas".)
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "try{ irm 'https://natural-trade-ltd.github.io/nt-cmo/CMO_Setup.ps1' | iex } catch { Write-Host ('Error: ' + $_.Exception.Message) -ForegroundColor Red }"
echo.
pause
