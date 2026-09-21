#Requires AutoHotkey v2.0
#Include _lib\windowlib.ahk
#Include paths.ahk

; ============================================================================
; context-manager.ahk - Cambio de contexto por hotkey (Fase 2)
;
;   Win+Shift+E  -> Editor de video   (mata gaming, abre Premiere + assets,
;                                      posiciona ventanas en mosaico)
;   Win+Shift+C  -> CM / Cliente A    (perfil Brave aislado del cliente +
;                                      Notion del cliente)
;   Win+Shift+G  -> Gamer             (mata suite Adobe, abre Steam)
;
; Cada contexto mata los procesos del rol contrario, asegurando limpieza
; de RAM y de sesiones (navegador / vault) al cambiar de cliente.
; ============================================================================

; --- Editor de video ---------------------------------------------------------
#+e::{
    global KILL_EDITOR, PREMIERE, ASSETS_CLI_A, PROFILE_PERSONAL
    KillProcesses(KILL_EDITOR)          ; relega steam/spotify
    LaunchProfile(PROFILE_PERSONAL)     ; navegador personal de recursos
    OpenFolder(ASSETS_CLI_A)            ; assets del cliente
    Run(PREMIERE)
    Sleep(3000)                         ; margen para que Premiere madure
    LayoutEditor("Adobe Premiere Pro", A_ScreenWidth // 2)
}

; --- Community Manager / Cliente A --------------------------------------------
#+c::{
    global KILL_CM, PROFILE_CLI_A, NOTION
    KillProcesses(KILL_CM)              ; nada de gaming en sesion de trabajo
    LaunchProfile(PROFILE_CLI_A)        ; sesion AISLADA del cliente
    Run(NOTION)
    Sleep(2000)
    LayoutCM(A_ScreenWidth // 2)
}

; --- Gamer ----------------------------------------------------------------------
#+g::{
    global KILL_GAMER, STEAM
    KillProcesses(KILL_GAMER)           ; relega la suite Adobe
    Run(STEAM)
    ; El gaming NO abre navegador de trabajo por diseno: sesion aislada.
}