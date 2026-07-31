# Script PowerShell para subir cambios del launcher a GitHub
# Uso: Doble clic o .\GUARDAR CAMBIOS.ps1

param(
    [string]$mensaje = ""
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   GUARDAR CAMBIOS EN GITHUB - PokeRetro Launcher" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

try {
    Write-Host "[1/4] Verificando cambios..." -ForegroundColor Yellow
    git status
    
    Write-Host ""
    Write-Host "[2/4] Agregando archivos..." -ForegroundColor Yellow
    git add -A
    
    Write-Host ""
    Write-Host "[3/4] Creando commit..." -ForegroundColor Yellow
    
    if ($mensaje -eq "") {
        $mensaje = Read-Host "Describe los cambios realizados"
        if ($mensaje -eq "") {
            $mensaje = "Actualizacion del launcher"
        }
    }
    
    git commit -m $mensaje
    
    Write-Host ""
    Write-Host "[4/4] Subiendo a GitHub..." -ForegroundColor Yellow
    git push origin main
    
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host "   CAMBIOS GUARDADOS EN GITHUB!" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
catch {
    Write-Host ""
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Presiona cualquier tecla para continuar..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}