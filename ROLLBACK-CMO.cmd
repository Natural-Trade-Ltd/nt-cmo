@echo off
title ROLLBACK CMO  a  version estable (v28)
cd /d "%~dp0"
echo.
echo   Revirtiendo el CMO a la version estable v28 (stable-cmo-v28)...
echo.
git fetch origin
git pull --rebase origin main
git checkout stable-cmo-v28 -- index.html sw.js
git commit -m "ROLLBACK CMO a version estable stable-cmo-v28" || echo   (ya estaba en la version estable, sin cambios)
git push origin main
echo.
echo   Listo. El CMO volvio a la version estable. Recarga la app (F5).
echo.
pause
