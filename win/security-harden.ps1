#Requires -Version 5.1
# ============================================================================
# security-harden.ps1 - Endurecimiento de la cuenta de TRABAJO (Fase 4)
#
# SIN parametros  -> modo AUDITORIA (informa, no cambia nada)
# -Apply          -> aplica los cambios (requiere administrador)
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File .\win\security-harden.ps1
#   powershell -ExecutionPolicy Bypass -File .\win\security-harden.ps1 -Apply
# ============================================================================

[CmdletBinding()]
param(
    [switch]$Apply,
    [string[]]$ProtectedFolders = @()
)

$ErrorActionPreference = 'Continue'

. (Join-Path $PSScriptRoot 'config.ps1')

function Write-Step($m)  { Write-Host "==> $m" -ForegroundColor Cyan }
function Write-Ok($m)    { Write-Host "  [OK] $m" -ForegroundColor Green }
function Write-Warn($m)  { Write-Host "  [!!] $m" -ForegroundColor Yellow }

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).
    IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

Write-Step ("Modo: " + $(if ($Apply) { 'APLICAR CAMBIOS' } else { 'AUDITORIA (no modifica)' }))
if ($Apply -and -not $isAdmin) {
    Write-Warn "Se requiere administrador para aplicar cambios. Se continua en modo auditoria."
    $Apply = $false
}

# ---------------------------------------------------------------------------
# 1) Control de acceso a carpetas (anti-ransomware)
# ---------------------------------------------------------------------------
Write-Step "Control de acceso a carpetas (Windows Defender)"
try {
    $mp = Get-MpPreference
    Write-Ok "Estado actual: EnableControlledFolderAccess = $($mp.EnableControlledFolderAccess)"
    Write-Ok "Carpetas protegidas: $($mp.ControlledFolderAccessProtectedFolders -join ', ')"
    Write-Ok "Apps permitidas:     $($mp.ControlledFolderAccessAllowedApplications -join ', ')"
} catch {
    Write-Warn "No se pudo leer Get-MpPreference: $($_.Exception.Message)"
}

if ($Apply) {
    # Carpetas a proteger: Documents de trabajo + raiz de perfiles de navegador
    $targets = @("$HOME_USER\Documents", $PROFILE_ROOT) + $ProtectedFolders | Select-Object -Unique
    foreach ($p in $targets) {
        if (Test-Path $p) {
            try {
                Add-MpPreference -ControlledFolderAccessProtectedFolders $p
                Write-Ok "Carpeta protegida anadida: $p"
            } catch { Write-Warn "No se anadio '$p': $($_.Exception.Message)" }
        } else { Write-Warn "Carpeta no existe, se omite: $p" }
    }
    # Apps permitidas listadas (solo si la ruta existe realmente)
    foreach ($app in @($APPS.Editor.Exe, $APPS.Gamer.Exe)) {
        if ($app -and (Test-Path $app)) {
            try {
                Add-MpPreference -ControlledFolderAccessAllowedApplications $app
                Write-Ok "App permitida: $app"
            } catch { Write-Warn "No se anadio app permitida '$app': $($_.Exception.Message)" }
        }
    }
    try {
        Set-MpPreference -EnableControlledFolderAccess Enabled
        Write-Ok "Control de acceso a carpetas ACTIVADO"
    } catch { Write-Warn "Fallo al activar el control: $($_.Exception.Message)" }
}

# ---------------------------------------------------------------------------
# 2) SmartScreen / proteccion basada en reputacion
# ---------------------------------------------------------------------------
Write-Step "SmartScreen (proteccion basada en reputacion)"
$smart = Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost' `
    -Name 'EnableSmartScreen' -ErrorAction SilentlyContinue
if ($null -ne $smart) { Write-Ok "EnableSmartScreen = $($smart.EnableSmartScreen) (1 = activo)" }
else { Write-Warn "Clave EnableSmartScreen ausente (por defecto queda activo)." }
if ($Apply) {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost' `
        -Name 'EnableSmartScreen' -Value 1 -Type DWord
    Write-Ok "SmartScreen fijado a 1 (activo)"
}

# ---------------------------------------------------------------------------
# 3) Firewall de Windows
# ---------------------------------------------------------------------------
Write-Step "Firewall de Windows"
Get-NetFirewallProfile | ForEach-Object {
    $s = if ($_.Enabled) { 'Activado' } else { 'DESACTIVADO' }
    Write-Ok "$($_.Name): $s"
}
if ($Apply) {
    try {
        Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled True
        Write-Ok "Firewall activado en todos los perfiles"
    } catch { Write-Warn "Fallo al activar firewall: $($_.Exception.Message)" }
}

Write-Step "Fin de hardening. Ejecuta en\win\env-check.ps1 para auditar el resultado."