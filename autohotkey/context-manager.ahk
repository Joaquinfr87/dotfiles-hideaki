#Requires AutoHotkey v2.0
#Include _lib\windowlib.ahk
#Include paths.ahk

; ============================================================================
; context-manager.ahk - Cambio de contexto por hotkey (Fase 2)
;
;   Win+Shift+E  -> Editor de contenido  (mata gaming, abre Photoshop +
;                                      Premiere + assets del cliente,
;                                      posiciona ventanas en mosaico)
;   Win+Shift+U  -> CM / Univallé       (perfil Brave aislado del cliente +
;                                      Notion del cliente)
;   Win+Shift+G  -> Gamer               (mata suite Adobe, abre Steam)
;
; Cada contexto mata los procesos del rol contrario, asegurando limpieza
; de RAM y de sesiones (navegador / vault) al cambiar de cliente.
; ============================================================================

; --- Editor de contenido ---------------------------------------------------
#+e::{
    global KILL_EDITOR, PREMIERE, PHOTOSHOP, ASSETS_UNIVALLE, PROFILE_PERSONAL
    KillProcesses(KILL_EDITOR)          ; relega steam/spotify
    LaunchProfile(PROFILE_PERSONAL)     ; navegador personal de recursos
    OpenFolder(ASSETS_UNIVALLE)         ; assets del cliente
    Run(PREMIERE)
    Run(PHOTOSHOP)
    Sleep(3000)                         ; margen para que Adobe madure
    LayoutEditor("Adobe Premiere Pro", A_ScreenWidth // 2)
}

; --- Community Manager / Univallé --------------------------------------------
#+u::{
    global KILL_CM, PROFILE_UNIVALLE, NOTION
    KillProcesses(KILL_CM)              ; nada de gaming en sesion de trabajo
    LaunchProfile(PROFILE_UNIVALLE)     ; sesion AISLADA del cliente
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