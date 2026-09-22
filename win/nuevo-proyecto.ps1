#Requires -Version 5.1
# ============================================================================
# nuevo-proyecto.ps1 - Crea la estructura de carpetas de un proyecto de
# edicion (video + imagen) y, si hace falta, la base de cliente/informacion.
#
# Separacion de proposito:
#   Clientes\<cliente>\        -> informacion + entregables FINALES del cliente
#   Proyectos\<cliente>\<proyecto>\ -> trabajo en curso, desglosado por etapa
#
# Uso:
#   1. Doble clic en "nuevo-proyecto.ps1" y responder las preguntas, o
#   2. PowerShell:  .\win\nuevo-proyecto.ps1 -Cliente univalle -Proyecto "campaña-verano"
#   3. Registrar clic derecho (una vez, SIN admin, cuenta Trabajo):
#      .\win\nuevo-proyecto.ps1 -Register
#      Luego: clic derecho sobre el fondo de una carpeta -> Nuevo proyecto de edición
#   4. Quitar el registro: .\win\nuevo-proyecto.ps1 -Unregister
# ============================================================================

[CmdletBinding()]
param(
    [string]$Cliente,
    [string]$Proyecto,
    [switch]$Register,
    [switch]$Unregister
)

$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'config.ps1')

# --- Registro de menu contextual (nivel usuario HKCU, sin admin) ------------
if ($Register -or $Unregister) {
    # Menú contextual a nivel de usuario (HKCU): funciona sin admin.
    $regKey = 'Registry::HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\NuevoProyectoEdicion'
    if ($Unregister) {
        Remove-Item -Path $regKey -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Menu contextual eliminado." -ForegroundColor Green
        exit
    }
    $scriptFull = Join-Path $PSScriptRoot 'nuevo-proyecto.ps1'
    $cmd = 'powershell -NoProfile -ExecutionPolicy Bypass -File "{0}"' -f $scriptFull
    New-Item -Path $regKey -Force | Out-Null
    New-Item -Path "$regKey\command" -Force | Out-Null
    Set-ItemProperty -Path $regKey           -Name '(default)' -Value 'Nuevo proyecto de edición' -Type String
    Set-ItemProperty -Path $regKey           -Name 'Icon'      -Value 'shell32.dll,164' -Type String
    Set-ItemProperty -Path "$regKey\command" -Name '(default)' -Value $cmd -Type String
    Write-Host "Listo: clic derecho sobre el fondo de una carpeta -> Nuevo proyecto de edición." -ForegroundColor Green
    exit
}

# --- Preguntas interactivas (si no vienen por parametro) --------------------
if (-not $Cliente) {
    $Cliente = Read-Host "Nombre del cliente (ej. univalle)"
    if (-not $Cliente) { Write-Warning "Cliente vacio. Saliendo."; exit 1 }
}
if (-not $Proyecto) {
    $Proyecto = Read-Host "Nombre del proyecto (ej. campana-verano)"
    if (-not $Proyecto) { Write-Warning "Proyecto vacio. Saliendo."; exit 1 }
}

# --- Seguridad: nombre de carpeta valido ------------------------------------
$inv = [System.IO.Path]::GetInvalidFileNameChars() -join ''
if ($Cliente  -match "[$inv]" -or $Proyecto -match "[$inv]") {
    Write-Warning "Solo letras, numeros y guiones en los nombres. Saliendo."
    exit 1
}
if ($Cliente  -eq 'nul' -or $Proyecto -eq 'nul') {
    Write-Warning "Nombre reservado ('nul'). Saliendo."; exit 1
}

# --- Rutas base --------------------------------------------------------------
$baseClientes  = Join-Path $HOME_USER 'Documentos\Clientes'
$baseProyectos = Join-Path $HOME_USER 'Documentos\Proyectos'

$dirCliente  = Join-Path $baseClientes  $Cliente
$dirProyecto = Join-Path $baseProyectos $Cliente | Join-Path -ChildPath $Proyecto

# --- Estructura del cliente (solo se crea si aun no existe) -----------------
$clienteDirs = @(
    '01-informacion\marca'
    '01-informacion\documentos'
    '02-entregables\video'
    '02-entregables\imagen'
    '02-entregables\documentos'
    '03-admin'
)
foreach ($d in $clienteDirs) {
    $target = Join-Path $dirCliente $d
    if (-not (Test-Path $target)) {
        New-Item -ItemType Directory -Force -Path $target | Out-Null
        Write-Host "  [Cliente] $target" -ForegroundColor DarkCyan
    }
}

# --- Estructura del proyecto (si ya existe, se avisa y NO se pisa) ----------
$proyDirs = @(
    '00-planificacion\guion'
    '00-planificacion\storyboard'
    '01-origen\video'
    '01-origen\audio\musica'
    '01-origen\fotos'
    '01-origen\graficos'
    '02-trabajo\premiere'
    '02-trabajo\photoshop'
    '02-trabajo\canva'
    '02-trabajo\assets\logos'
    '02-trabajo\assets\tipografias'
    '02-trabajo\assets\overlays'
    '03-export\video'
    '03-export\imagen'
    '04-referencias\moodboard'
    '05-entrega\video'
)
foreach ($d in $proyDirs) {
    $target = Join-Path $dirProyecto $d
    if (-not (Test-Path $target)) {
        New-Item -ItemType Directory -Force -Path $target | Out-Null
        Write-Host "  [Proyecto] $target" -ForegroundColor Cyan
    }
}

# --- Nota del flujo ----------------------------------------------------------
Write-Host ""
Write-Host "Creado proyecto: $dirProyecto" -ForegroundColor Green
Write-Host "Entregables del cliente quedan en: $dirCliente\02-entregables" -ForegroundColor Green
Write-Host ""
Write-Host "Flujo: 01-origen -> 02-trabajo -> 03-export (revision) -> 05-entrega -> Clientes\02-entregables" -ForegroundColor DarkYellow