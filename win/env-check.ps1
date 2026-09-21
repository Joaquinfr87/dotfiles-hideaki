#Requires -Version 5.1
# ============================================================================
# env-check.ps1 - Auditoria del entorno gestionado (Fase 4)
# Verifica que la maquina cumpla la politica del repo: perfiles aislados,
# espanso junction, AHK en startup, Defender y BitLocker.
# Ideal tras un despliegue o como diagnostico.
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File .\win\env-check.ps1
# ============================================================================

$ErrorActionPreference = 'Continue'

. (Join-Path $PSScriptRoot 'config.ps1')

function Write-Ok($m)   { Write-Host "  [OK] $m" -ForegroundColor Green }
function Write-Fail($m) { Write-Host "  [!!] $m" -ForegroundColor Yellow }

Write-Host "==> Sistema" -ForegroundColor Cyan
$os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
if ($os) { Write-Ok "$($os.Caption) (Build $($os.BuildNumber))" }
Write-Ok "Cuenta actual: $env:USERNAME"
if ($env:USERNAME -ne 'Trabajo') { Write-Fail "Se espera ejecutar en la cuenta Trabajo (actual: $env:USERNAME)" }

Write-Host "==> Perfiles de navegador aislados" -ForegroundColor Cyan
foreach ($prof in $PROFILES) {
    if (Test-Path $prof.DataDir) { Write-Ok "Perfil $($prof.Name): $($prof.DataDir)" }
    else { Write-Fail "Falta perfil $($prof.Name): $($prof.DataDir)" }
}

Write-Host "==> Espanso" -ForegroundColor Cyan
if (Test-Path $ESPANSO_DIR) {
    $item = Get-Item $ESPANSO_DIR -Force
    if ($item.LinkType) { Write-Ok "espanso junction hacia: $($item.Target)" }
    else { Write-Fail "espanso NO es un junction (no apunta al repo)" }
    $matchCount = (Get-ChildItem "$ESPANSO_DIR\match" -Recurse -Filter '*.yml' -ErrorAction SilentlyContinue).Count
    Write-Ok "match files cargables: $matchCount"
} else { Write-Fail "No existe $ESPANSO_DIR" }

Write-Host "==> AutoHotkey en inicio" -ForegroundColor Cyan
$hits = Get-ChildItem $AHK_DIR -Filter '*.ahk' -ErrorAction SilentlyContinue
if ($hits) { $hits | ForEach-Object { Write-Ok "En startup: $($_.Name)" } }
else { Write-Fail "Ningun .ahk en Startup (Fase 5 lo dejara instalado)" }

Write-Host "==> Control de acceso a carpetas (Defender)" -ForegroundColor Cyan
try {
    $mp = Get-MpPreference
    Write-Ok "EnableControlledFolderAccess = $($mp.EnableControlledFolderAccess)"
} catch { Write-Fail "No se pudo leer Defender" }

Write-Host "==> BitLocker" -ForegroundColor Cyan
try {
    Get-BitlockerVolume -MountPoint $env:SystemDrive | ForEach-Object {
        Write-Ok ("{0}: proteccion {1}" -f $_.MountPoint, $_.ProtectionStatus)
    }
} catch { Write-Fail "No se pudo leer BitLocker (requiere administrador?)" }

Write-Host "==> Fin de auditoria. Revisa cualquier [!!]."