#Requires AutoHotkey v2.0

; ============================================================================
; projects.ahk - Creacion de carpetas de proyecto/edicion por pantalla (GUI)
; Sin PowerShell ni comandos: pide el cliente y el proyecto con InputBox y
; crea toda la estructura. Complementa a win\nuevo-proyecto.ps1 (ambos crean
; el mismo arbol; este es para uso por clic/hotkey con AutoHotkey).
; ============================================================================

; --- Arbol del cliente (Clientes\<cliente>) --------------------------------
PROJECT_CLIENT_DIRS := [
    "01-informacion\marca",
    "01-informacion\documentos",
    "02-entregables\video",
    "02-entregables\imagen",
    "02-entregables\documentos",
    "03-admin"
]

; --- Arbol del proyecto (Proyectos\<cliente>\<proyecto>) -------------------
PROJECT_DIRS := [
    "00-planificacion\guion",
    "00-planificacion\storyboard",
    "01-origen\video",
    "01-origen\audio\musica",
    "01-origen\fotos",
    "01-origen\graficos",
    "02-trabajo\premiere",
    "02-trabajo\photoshop",
    "02-trabajo\canva",
    "02-trabajo\assets\logos",
    "02-trabajo\assets\tipografias",
    "02-trabajo\assets\overlays",
    "03-export\video",
    "03-export\imagen",
    "04-referencias\moodboard",
    "05-entrega\video"
]

; --- Crea el arbol completo preguntando por pantalla -------------------------
NewProjectFolders() {
    baseClientes  := EnvGet("USERPROFILE") "\Documents\Clientes"
    baseProyectos := EnvGet("USERPROFILE") "\Documents\Proyectos"

    ib := InputBox("Nombre del cliente (ej. univalle)", "Nuevo proyecto de edición", "w360 h130 donivalle")
    if ib.Result != "OK"
        return false
    cliente := Trim(ib.Value)
    if cliente = ""
        return false

    ib2 := InputBox("Nombre del proyecto (ej. campana-verano)", "Nuevo proyecto de edición", "w360 h130")
    if ib2.Result != "OK"
        return false
    proyecto := Trim(ib2.Value)
    if proyecto = ""
        return false

    dirCliente  := baseClientes  "\" cliente
    dirProyecto := baseProyectos "\" cliente "\" proyecto

    for d in PROJECT_CLIENT_DIRS
        DirCreate(dirCliente "\" d)
    for d in PROJECT_DIRS
        DirCreate(dirProyecto "\" d)

    MsgBox(
        "Proyecto creado:`n" dirProyecto "`n`n"
        "Los entregables finales van a:`n" dirCliente "\02-entregables",
        "Listo",
        "T64"  ; icono de informacion
    )
    return true
}

; --- Hotkey global: Win+Shift+N = Nuevo proyecto de edicion -----------------
#+n::NewProjectFolders()