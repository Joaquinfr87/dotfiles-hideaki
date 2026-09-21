#Requires AutoHotkey v2.0

; ============================================================================
; paths.ahk - Rutas y datos por contexto (espejo lógico de win/config.ps1)
; En Fase 5, setup.ps1 podra GENERAR este archivo a partir de config.ps1
; para tener una unica fuente de verdad.
; ============================================================================

; --- Navegador y perfiles aislados -----------------------------------------
BROWSER_EXE  := "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
PROFILE_ROOT := "C:\Users\Trabajo\BrowserProfiles"

PROFILE_PERSONAL := PROFILE_ROOT "\personal"
PROFILE_CLI_A    := PROFILE_ROOT "\cliente-a"
PROFILE_CLI_B    := PROFILE_ROOT "\cliente-b"

; --- Aplicaciones por contexto (Fase: sustituir por las reales) ------------
PREMIERE := "C:\Program Files\Adobe\Adobe Premiere Pro 2025\Adobe Premiere Pro.exe"
NOTION   := "C:\Users\Trabajo\AppData\Local\Programs\Notion\Notion.exe"
STEAM    := "C:\Program Files (x86)\Steam\steam.exe"

; --- Assets / carpetas de trabajo ------------------------------------------
ASSETS_CLI_A := "C:\Users\Trabajo\Documents\Clientes\cliente-a\assets"

; --- Procesos a matar al entrar a un contexto -------------------------------
; Aparte de liberar RAM, evita que queden sesiones abiertas del rol anterior.
KILL_EDITOR := ["steam.exe", "Spotify.exe"]
KILL_GAMER  := ["Adobe Premiere Pro.exe", "AfterFX.exe", "Photoshop.exe"]
KILL_CM     := ["steam.exe"]