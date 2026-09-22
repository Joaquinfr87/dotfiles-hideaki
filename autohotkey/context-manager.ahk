#Requires AutoHotkey v2.0
#Include _lib\windowlib.ahk
#Include _lib\projects.ahk
#Include paths.ahk

; ============================================================================
; context-manager.ahk - Limpieza de procesos por hotkey
;
;   Win+Shift+E  -> Modo TRABAJO   : mata juegos/launchers/música que
;                                    estorban al trabajar. No abre nada.
;   Win+Shift+U  -> Modo CM        : idem que trabajo (mata distractions).
;   Win+Shift+G  -> Modo GAMER     : mata Adobe/browser/Notion/Bitwarden
;                                    para jugar sin restos ni sesiones.
;
; Cada hotkey SOLO mata procesos y muestra qué cerró (KillAndNotify).
; La apertura de programas (navegador por perfil, Premiere, etc.) se hace
; manualmente o con accesos directos, no dentro de este script.
; Las listas de procesos viven en paths.ahk (KILL_WORK, KILL_GAMER).
; ============================================================================

; --- Modo trabajo: limpiar memoria/de foco -------------------------------
#+e::{
    global KILL_WORK
    KillAndNotify(KILL_WORK, "Modo trabajo")
}

; --- Modo CM: misma limpieza de trabajo -----------------------------------
#+u::{
    global KILL_CM
    KillAndNotify(KILL_CM, "Modo CM")
}

; --- Modo gamer: cerrar apps de trabajo ----------------------------------
#+g::{
    global KILL_GAMER
    KillAndNotify(KILL_GAMER, "Modo gamer")
}