@echo off
chcp 65001 >nul
echo.
echo ═══════════════════════════════════════════════════
echo    GUARDAR CAMBIOS EN GITHUB - PokeRetro Launcher
echo ═══════════════════════════════════════════════════
echo.

cd /d "%~dp0"

echo [1/4] Verificando cambios...
git status

echo.
echo [2/4] Agregando archivos...
git add -A

echo.
echo [3/4] Creando commit...
set /p mensaje="Describe los cambios realizados: "
if "%mensaje%"=="" set mensaje=Actualización del launcher

git commit -m "%mensaje%"

echo.
echo [4/4] Subiendo a GitHub...
git push origin main

echo.
echo ═══════════════════════════════════════════════════
echo    ¡CAMBIOS GUARDADOS EN GITHUB!
echo ═══════════════════════════════════════════════════
echo.
pause
