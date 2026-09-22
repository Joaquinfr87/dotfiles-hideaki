#Requires AutoHotkey v2.0

; ============================================================================
; projects.ahk - Creacion de carpetas de trabajo por pantalla (GUI)
; Sin PowerShell ni comandos. Dos hotkeys SEPARADOS:
;
;   Win+Alt+C  -> Nuevo CLIENTE   crea Clientes\<cliente>\ (una vez por cliente)
;   Win+Alt+N  -> Nuevo PROYECTO  crea Proyectos\<cliente>\<proyecto>\ (por trabajo)
;
; El cliente y el proyecto se crean por separado, como pidio el usuario.
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

; EnvGet falla en NUL estrictos; validamos igual que el .ps1.
PROJECT_LAST_CLIENT := ""   ; recuerda el ultimo cliente para no volver a teclearlo

; --- Crea SOLO el arbol del cliente ------------------------------------------
NewClientFolders() {
    global PROJECT_LAST_CLIENT
    baseClientes := EnvGet("USERPROFILE") "\Documents\Clientes"

    ib := InputBox(
        "Nombre del cliente (ej. univalle).`nSe crean solo las carpetas de Clientes.",
        "Nuevo cliente",
        "w360 h130",
        "univalle"
    )
    if ib.Result != "OK"
        return false
    cliente := Trim(ib.Value)
    if cliente = ""
        return false

    dirCliente := baseClientes "\" cliente
    for d in PROJECT_CLIENT_DIRS
        DirCreate(dirCliente "\" d)

    PROJECT_LAST_CLIENT := cliente
    MsgBox(
        "Cliente creado:`n" dirCliente "`n`n"
        "Los entregables finales irán a 02-entregables. Cada proyecto nuevo se crea aparte con Win+Alt+N.",
        "Listo",
        "T64"
    )
    return true
}

; --- Crea SOLO el arbol del proyecto ----------------------------------------
NewProjectFolders() {
    global PROJECT_LAST_CLIENT
    baseProyectos := EnvGet("USERPROFILE") "\Documents\Proyectos"

    ; Cliente: sugiere el ultimo usado, permite cambiar
    defaultClient := PROJECT_LAST_CLIENT != "" ? PROJECT_LAST_CLIENT : "univalle"
    ib := InputBox(
        "Nombre del cliente (ej. univalle):",
        "Nuevo proyecto de edición",
        "w360 h130",
        defaultClient
    )
    if ib.Result != "OK"
        return false
    cliente := Trim(ib.Value)
    if cliente = ""
        return false
    PROJECT_LAST_CLIENT := cliente

    ib2 := InputBox(
        "Nombre del proyecto (ej. campana-verano).`nSe crean las carpetas de Proyectos.",
        "Nuevo proyecto de edición",
        "w360 h130"
    )
    if ib2.Result != "OK"
        return false
    proyecto := Trim(ib2.Value)
    if proyecto = ""
        return false

    dirProyecto := baseProyectos "\" cliente "\" proyecto
    for d in PROJECT_DIRS
        DirCreate(dirProyecto "\" d)

    MsgBox(
        "Proyecto creado:`n" dirProyecto "`n`n"
        "Flujo: 01-origen -> 02-trabajo -> 03-export -> 05-entrega.`n"
        "El resultado final se copia a Clientes\" cliente "\02-entregables.",
        "Listo",
        "T64"
    )
    return true
}

; --- Hotkeys (Win+Alt para evitar conflictos con atajos de Windows) ---------
#!c::NewClientFolders()      ; Nuevo cliente (carpetas de Clientes)
#!n::NewProjectFolders()     ; Nuevo proyecto (carpetas de Proyectos)