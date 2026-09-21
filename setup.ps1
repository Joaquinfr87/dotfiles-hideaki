#Requires -Version 5.1
# ============================================================================
# setup.ps1 - Despliegue maestro del entorno (Fase 5)
#
# Analogia con GNU stow: enlaza los archivos del repositorio con sus
# ubicaciones reales de Windows mediante junctions/enlaces y deja la maquina
# lista para los scripts de contexto (AHK + Espanso).
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1
#       -> modo PLAN: crea junctions, accesos directos y auditoria.
#          No instala nada ni cambia Defender. Idempotente.
#
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1 -All
#       -> aprovisionamiento completo en maquina limpia (REQUIERE ADMIN):
#          instala Espanso y AutoHotkey, junction de espanso, accesos de
#          Brave por perfil, hardening de Defender y auditoria final.
#
# Esto es seguro de repetir: cada paso es idempotente (self-healing).
# ============================================================================

[CmdletBinding()]
param(
    [switch]$All,
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Continue'

# --- Cargar configuracion central (win\config.ps1) --------------------------
. (Join-Path $RepoRoot 'win\config.ps1')

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }
function Write-Ok($m)   { Write-Host "  [OK] $m" -ForegroundColor Green }
function Write-Warn($m) { Write-Host "  [!!] $m" -ForegroundColor Yellow }

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).
    IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Si -All y no admin, relanzar elevado con los mismos argumentos.
if ($All -and -not $isAdmin) {
    Write-Warn "Modo -All requiere administrador. Relanzando elevado..."
    $argsLine = "-ExecutionPolicy Bypass -File `"$PSCommandPath`" -All"
    $p = Start-Process powershell -Verb RunAs -ArgumentList $argsLine -Wait -PassThru
    if ($p) { exit $p.ExitCode } else { Write-Warn "Elevacion cancelada o fallida." }
}

Write-Host "=== dotfiles-ionel | setup.ps1" -ForegroundColor Magenta
Write-Host "Repo de origen : $RepoRoot"
Write-Host "Modo           : $(if ($All) { 'APROVISIONAMIENTO COMPLETO (-All)' } else { 'PLAN (links + accesos)' })"

# ---------------------------------------------------------------------------
# 0) Estructura de perfiles de navegador (crear si no existen)
# ---------------------------------------------------------------------------
Write-Step "Crear estructura de perfiles de navegador"
foreach ($prof in $PROFILES) {
    if (-not (Test-Path $prof.DataDir)) {
        New-Item -ItemType Directory -Force -Path $prof.DataDir | Out-Null
        Write-Ok "Creado perfil: $($prof.Name)"
    } else {
        Write-Ok "Ya existe perfil: $($prof.Name)"
    }
}

# ---------------------------------------------------------------------------
# 1) Junction de Espanso: %AppData%\espanso -> <repo>\espanso
# ---------------------------------------------------------------------------
Write-Step "Espanso: junction a $ESPANSO_DIR"
if (-not (Test-Path (Join-Path $RepoRoot 'espanso\match\base.yml'))) {
    Write-Warn "Falta <repo>\espanso\match\base.yml. Se omite el junction."
} elseif (Test-Path $ESPANSO_DIR) {
    $item = Get-Item $ESPANSO_DIR -Force
    if ($item.LinkType) {
        Write-Ok "Ya es un junction hacia: $($item.Target)"
    } else {
        $bak = "$ESPANSO_DIR.default.bak"
        Write-Warn "Existe como carpeta real -> se respalda a $bak y se crea el junction."
        Move-Item -Path $ESPANSO_DIR -Destination $bak -Force
        New-Item -ItemType Junction -Path $ESPANSO_DIR -Target (Join-Path $RepoRoot 'espanso') | Out-Null
        Write-Ok "Junction creado: $ESPANSO_DIR"
    }
} else {
    New-Item -ItemType Junction -Path $ESPANSO_DIR -Target (Join-Path $RepoRoot 'espanso') | Out-Null
    Write-Ok "Junction creado: $ESPANSO_DIR"
}

# ---------------------------------------------------------------------------
# 2) AutoHotkey: acceso en Startup apuntando a los scripts del repo
# ---------------------------------------------------------------------------
Write-Step "AutoHotkey: acceso de inicio"
$ahkScript = Join-Path $RepoRoot 'autohotkey\context-manager.ahk'
$ahkExePath = $null

if (Test-Path $ahkScript) {
    $cmd = Get-Command 'AutoHotkey.exe' -ErrorAction SilentlyContinue
    if ($cmd) { $ahkExePath = $cmd.Source }
    if (-not $ahkExePath) {
        foreach ($c in @(
            "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey.exe",
            "$env:ProgramFiles\AutoHotkey\AutoHotkey.exe")) {
            if (Test-Path $c) { $ahkExePath = $c; break }
        }
    }

    if ($ahkExePath) {
        $shell = New-Object -ComObject WScript.Shell
        $startup = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup'
        $lnkPath = Join-Path $startup 'context-manager.lnk'
        $lnk = $shell.CreateShortcut($lnkPath)
        $lnk.TargetPath = $ahkExePath
        $lnk.Arguments = '"{0}"' -f $ahkScript
        $lnk.WorkingDirectory = (Split-Path $ahkScript)
        $lnk.IconLocation = "$ahkExePath,0"
        $lnk.Save()
        Write-Ok "Acceso de inicio creado: $lnkPath"
    } else {
        Write-Warn "AutoHotkey v2 no encontrado. Con -All se instala; vuelve a ejecutar setup.ps1 tras instalar."
    }
} else {
    Write-Warn "No existe $ahkScript. Revisa autohotkey\; se omite el acceso de inicio."
}

# ---------------------------------------------------------------------------
# 3) Accesos directos de Brave por perfil (aislamiento)
# ---------------------------------------------------------------------------
Write-Step "Accesos directos de Brave por perfil"
if (-not (Test-Path $BROWSER_EXE)) {
    Write-Warn "No se encuentra Brave en $BROWSER_EXE. Revisa win\config.ps1."
} else {
    $shell = New-Object -ComObject WScript.Shell
    $desktop = [Environment]::GetFolderPath('Desktop')
    foreach ($prof in $PROFILES) {
        $lnkPath = Join-Path $desktop ("Brave | {0}.lnk" -f $prof.Name)
        $lnk = $shell.CreateShortcut($lnkPath)
        $lnk.TargetPath = $BROWSER_EXE
        $lnk.Arguments = ('--user-data-dir="{0}" --profile-directory="Default"' -f $prof.DataDir)
        $lnk.Description = 'Perfil aislado: ' + $prof.Name
        $lnk.Save()
        Write-Ok "Acceso listo: Brave | $($prof.Name)"
    }
}

# ---------------------------------------------------------------------------
# 4) Modo -All: instalacion de herramientas, hardening y cifrado
# ---------------------------------------------------------------------------
if ($All) {
    Write-Step "Instalacion de herramientas (winget)"
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --silent --accept-package-agreements --accept-source-agreements Espanso.Espanso
        winget install --silent --accept-package-agreements --accept-source-agreements AutoHotkey.AutoHotkey
        Write-Ok "Instalaciones solicitadas: Espanso y AutoHotkey."
    } else {
        Write-Warn "winget no disponible. Instala Espanso y AutoHotkey manualmente."
    }

    Write-Step "Hardening de Defender (Control de acceso a carpetas, SmartScreen, Firewall)"
    & (Join-Path $RepoRoot 'win\security-harden.ps1') -Apply

    Write-Step "Auditoria de BitLocker"
    & (Join-Path $RepoRoot 'win\bitlocker-check.ps1')
}

# ---------------------------------------------------------------------------
# 5) Auditoria final
# ---------------------------------------------------------------------------
Write-Step "Auditoria final del entorno"
& (Join-Path $RepoRoot 'win\env-check.ps1')

Write-Host "=== setup.ps1 finalizado." -ForegroundColor Magenta
Write-Host "Siguientes pasos manuales: registrar 2FA en cuentas criticas (docs\03-seguridad.md)."