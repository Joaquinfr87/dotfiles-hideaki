#Requires AutoHotkey v2.0

; ============================================================================
; windowlib.ahk - Funciones compartidas para los scripts de contexto
; Cualquier utilidad reutilizable (posicionado, kill, lanzadores) vive aqui.
; ============================================================================

; --- Mata procesos por nombre de imagen --------------------------------------
KillProcesses(procs) {
    for proc in procs
        RunWait('taskkill /IM "' proc '" /F', , "Hide")
}

; --- Mata procesos y muestra un aviso de cuáles cerró -------------------------
; title: nombre que se muestra en el mensaje. No abre ningún programa.
KillAndNotify(procs, title) {
    killed := []
    for proc in procs {
        if ProcessExist(proc) {
            RunWait('taskkill /IM "' proc '" /F', , "Hide")
            killed.Push(proc)
        }
    }
    if killed.Length {
        msg := "Se cerraron " killed.Length " proceso(s):`n`n"
        for k in killed
            msg .= "  - " k "`n"
    } else {
        msg := "No había ningún proceso de la lista ejecutándose."
    }
    MsgBox(msg, title, "T64")
}

; --- Lanza el navegador (Brave) sobre un perfil aislado (--user-data-dir) -----
LaunchProfile(dataDir) {
    global BROWSER_EXE
    Run(Format('"{1}" --user-data-dir="{2}" --profile-directory="Default"',
        BROWSER_EXE, dataDir))
}

; --- Abre una carpeta en el Explorador ---------------------------------------
OpenFolder(path) {
    Run('explorer.exe "' path '"')
}

; --- Posiciona/activa una ventana por titulo ---------------------------------------------------
; Uso: Tile("Adobe Premiere Pro", 0, 0, A_ScreenWidth // 2, A_ScreenHeight)
Tile(title, x, y, w, h) {
    if WinExist(title) {
        WinRestore(title)
        WinMove(x, y, w, h, title)
        WinActivate(title)
    }
}

; --- Layout tiled tipico de editor: app izq + navegador der -------------------------------
LayoutEditor(appTitle, w) {
    Tile(appTitle, 0, 0, w, A_ScreenHeight)
    Tile("Brave", w, 0, A_ScreenWidth - w, A_ScreenHeight)
}

; --- Layout tiled de CM: navegador izq + Notion der ------------------------------------------
LayoutCM(w) {
    Tile("Brave", 0, 0, w, A_ScreenHeight)
    Tile("Notion", w, 0, A_ScreenWidth - w, A_ScreenHeight)
}