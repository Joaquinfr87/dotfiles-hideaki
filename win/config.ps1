# config.ps1 - Fuente única de verdad del repositorio (Fase 1)
# Todas las rutas y nombres centralizados. setup.ps1 y los scripts
# de AHK/espanso deberian derivar sus rutas de este archivo.

# --- Rutas del repositorio / SCRIPT_ROOT -------------------------------
# Al ejecutarse desde la raiz del repo, SCRIPT_ROOT apunta a la carpeta raiz.
$SCRIPT_ROOT = Split-Path -Parent $PSScriptRoot

# --- Rutas de destino en la maquina Windows -----------------------------
$HOME_USER   = $env:USERPROFILE
$APPDATA     = $env:APPDATA

# AutoHotkey: carpeta donde se dispara AHK al arrancar con Windows
$AHK_DIR     = "$APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
# Expanso: carpeta de config de Espanso
$ESPANSO_DIR = "$APPDATA\espanso"

# --- Perfiles aislados de navegador (Brave / Chromium) ------------------
# Cada cliente/usuario usa un --user-data-dir separado.
$BROWSER_EXE = "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe"
$PROFILE_ROOT = "$HOME_USER\BrowserProfiles"
$PROFILES = @(
    @{ Name = "personal";  DataDir = "$PROFILE_ROOT\personal" }
    @{ Name = "univalle";  DataDir = "$PROFILE_ROOT\univalle" }
    # @{ Name = "cliente";   DataDir = "$PROFILE_ROOT\cliente" }   # anadir por cliente
)

# --- Aplicaciones por contexto ------------------------------------------
$APPS = @{
    # Edicion de contenido (Adobe full suite + Photoshop)
    Editor = @{
        Exe      = "$env:ProgramFiles\Adobe\Adobe Premiere Pro 2025\Adobe Premiere Pro.exe"
        Assets   = "$HOME_USER\Documents\Clientes\univalle\assets"
    }
    Photoshop = @{
        Exe      = "$env:ProgramFiles\Adobe\Adobe Photoshop 2025\Photoshop.exe"
        Assets   = "$HOME_USER\Documents\Clientes\univalle\assets"
    }
    Gamer = @{
        Exe      = "$env:ProgramFiles\Steam\steam.exe"
    }
}

# --- Procesos a matar al cambiar de contexto ----------------------------
$KILL_ON_EDITOR = @("steam.exe", "Spotify.exe")
$KILL_ON_GAMER  = @("Adobe Premiere Pro.exe", "Photoshop.exe", "AfterFX.exe")
$KILL_ON_CM     = @("steam.exe")

# --- Expansion de texto (Espanso) ----------------------------------------
$ESPANSO_MATCH_SOURCE = "$SCRIPT_ROOT\espanso"       # origen en el repo
$ESPANSO_MATCH_DEST   = "$ESPANSO_DIR\match"         # destino en Windows