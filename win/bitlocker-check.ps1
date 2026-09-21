#Requires -Version 5.1
# ============================================================================
# bitlocker-check.ps1 - Auditoria de cifrado de discos (Fase 4)
# Reporta el estado de BitLocker por volumen y busca recovery keys sueltas
# dentro del repositorio (que NO deberian estar ahi).
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File .\win\bitlocker-check.ps1
# ============================================================================

$ErrorActionPreference = 'Continue'

Write-Host "==> Estado de BitLocker por volumen" -ForegroundColor Cyan
try {
    Get-BitlockerVolume | ForEach-Object {
        $pct = '{0:N0}%' -f $_.EncryptionPercentage
        $color = if ($_.ProtectionStatus -eq 'On') { 'Green' } else { 'Yellow' }
        $state = switch ($_.ProtectionStatus) {
            'On'  { 'PROTEGIDO' }
            'Off' { 'SIN PROTECCION' }
            default { $_.ProtectionStatus }
        }
        Write-Host ("  {0,-4} {1,-8} {2}" -f $_.MountPoint, $pct, $state) -ForegroundColor $color
    }
} catch { Write-Warn "No se pudo leer BitLocker: $($_.Exception.Message) (requiere administrador?)" }

Write-Host "==> Recovery keys dentro del repositorio (riesgo)" -ForegroundColor Cyan
Write-Host "  La recovery key DEBE estar en copia fisica/pendrive FUERA del equipo."
$repoRoot = Split-Path -Parent $PSScriptRoot
$found = Get-ChildItem -Path $repoRoot -Recurse -Force -Include '*.txt', '*.bev', '*.key', '*recovery*' -ErrorAction SilentlyContinue
if ($found) {
    Write-Host "  [!!] Posibles archivos de recovery DENTRO del repo:" -ForegroundColor Yellow
    $found | ForEach-Object { Write-Host "       $($_.FullName)" -ForegroundColor Yellow }
} else {
    Write-Host "  [OK] Sin archivos de recovery detectados en el repo." -ForegroundColor Green
}

Write-Host "==> Comprobacion manual" -ForegroundColor Cyan
Write-Host "  Copia la recovery key a un pendrive/USB aparte y borrala del equipo."