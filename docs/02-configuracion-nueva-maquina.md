# Guía: puesta a punto de la máquina nueva (cuenta Trabajo)

Pasos en orden para la máquina Windows recién instalada. Todo se ejecuta
**dentro de la cuenta Trabajo** (usuario no administrador) salvo lo marcado
como `[ADMIN]`.

---

## 0. Traer el repo a la máquina

1. Copia la carpeta `dotfiles-ionel` al equipo (pendrive/red/clone git).
   Ruta recomendada: `C:\dotfiles-ionel` (raíz del disco, sin espacios).
2. Abre PowerShell y verifica:
   ```powershell
   cd C:\dotfiles-ionel
   Get-Content .\README.md -TotalCount 3
   ```

---

## 1. Cuenta Trabajo: delimitar el usuario

- La cuenta ya debe existir como **Estándar** (sin admin). Si no:
  `Configuración` → `Cuentas` → `Otros usuarios` → asignar rol Estándar.
- Activa **PIN** en la cuenta Trabajo (Windows Hello) para desbloqueo rápido:
  `Configuración` → `Cuentas` → `Opciones de inicio de sesión` → PIN.

---

## 2. Instalación de aplicaciones

Desde la cuenta Trabajo instala (winget si está disponible):

```powershell
# Navegador de trabajo (perfiles aislados por cliente)
winget install --silent --accept-package-agreements --accept-source-agreements Brave.Brave

# Gestor de contraseñas
winget install --silent --accept-package-agreements --accept-source-agreements Bitwarden.Bitwarden

# Expansión de texto (lo automatiza setup.ps1 -All, pero por si acaso)
winget install --silent --accept-package-agreements --accept-source-agreements Espanso.Espanso
winget install --silent --accept-package-agreements --accept-source-agreements AutoHotkey.AutoHotkey
```

> El navegador de trabajo NO comparte nada con el de la cuenta Gaming: cada
> cuenta instala su propio Brave.

---

## 3. Adobe (instalación con administrador)

Adobe requiere elevación → la pedirá desde la cuenta Gaming (admin del sistema).

1. Instala **Adobe Creative Cloud** (`winget install adobe.creativesuite` o
   desde creativecloud.adobe.com) iniciando sesión con tu Adobe ID.
2. Desde Creative Cloud instala **Premiere Pro** y **Photoshop**.
3. Canva: es web, vive en el perfil `personal` del navegador (o la app de
   Microsoft Store si la prefieres).

> La suite Adobe se instala una vez a nivel de sistema: aparece en ambas
> cuentas, pero en Gaming no la usarás.

---

## 4. Despliegue automático (setup.ps1)

Desde la cuenta Trabajo, en PowerShell:

```powershell
cd C:\dotfiles-ionel

# Modo PLAN: crea perfiles de navegador, junction de espanso, acceso de
# AutoHotkey en inicio y accesos de Brave por perfil. No requiere admin.
powershell -ExecutionPolicy Bypass -File .\setup.ps1

# Provisionamiento completo (REQUIERE ADMIN): instala Espanso+AutoHotkey,
# hardening de Defender, auditoria de BitLocker. Te pedira elevar.
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -All
```

Al terminar:
- Escritorio debe tener `Brave | Personal` y `Brave | Univallé`.
- Espanso queda apuntando a `C:\dotfiles-ionel\espanso` (junction).
- `context-manager.ahk` queda en el directorio de Inicio.

---

## 5. Estructura de carpetas de trabajo

**Automático (recomendado):** usa `win/nuevo-proyecto.ps1` de la cuenta Trabajo.
Crea el árbol completo del cliente + proyecto en un paso, sin admin:

```powershell
powershell -ExecutionPolicy Bypass -File .\win\nuevo-proyecto.ps1 -Register   # una vez: clic derecho -> "Nuevo proyecto de edición"
powershell -ExecutionPolicy Bypass -File .\win\nuevo-proyecto.ps1 -Cliente univalle -Proyecto "campaña-verano"
```

El `-Register` registra el menú contextual a nivel de **usuario (HKCU)**, por lo
que funciona desde la cuenta Trabajo sin necesidad de elevación. Solo se
registra una vez por máquina. A partir de entonces, clic derecho sobre el
fondo de una carpeta → *Nuevo proyecto de edición*.

### 5.0 Árbol completo (referencia)

```
C:\Users\Trabajo\Documents\
│
├── Clientes\                                  ← info + entregables FINALES
│   └── univalle\
│       ├── 01-informacion\
│       │   ├── marca\             (logo, manual, paleta, fuentes del cliente)
│       │   └── documentos\        (contratos, presentaciones, propuestas)
│       ├── 02-entregables\        (resultados aprobados para publicar)
│       │   ├── video\
│       │   ├── imagen\
│       │   └── documentos\
│       └── 03-admin\              (facturas, accesos, logística)
│
└── Proyectos\                                ← trabajo EN CURSO por proyecto
    └── univalle\
        └── <proyecto>\            (ej. campana-verano)
            ├── 00-planificacion\  (brief, guion, storyboard)
            ├── 01-origen\         (material bruto: video, audio, fotos, graficos)
            ├── 02-trabajo\        (archivos editables: premiere, photoshop, canva, assets)
            ├── 03-export\         (renders/salidas SIN aprobar para revisión)
            ├── 04-referencias\    (inspiración/moodboard del proyecto)
            └── 05-entrega\        (versión final aprobada)
```

### 5.1 Desglose del proyecto (video + imagen + Canva)

```
Proyectos\univalle\<proyecto>\
│
├── 00-planificacion\
│   ├── brief.txt               (encargo, objetivos, plazo)
│   ├── guion\                  (textos, escaletas)
│   └── storyboard\             (planos/guiones graficos)
│
├── 01-origen\                  (material bruto — NO se modifica)
│   ├── video\                  (camara, b-roll, entrevistas)
│   ├── audio\
│   │   └── musica\             (musica, voice-over, ambiente)
│   ├── fotos\                  (imagenes en bruto)
│   └── graficos\               (aportados por cliente: logos, PDF, prints)
│
├── 02-trabajo\                 (archivos editables del software)
│   ├── premiere\               (.prproj + secuencias)
│   ├── photoshop\              (.psd / .tif + capas)
│   ├── canva\                  (borradores descargados de Canva, WIP)
│   └── assets\                 (elementos reutilizables del proyecto)
│       ├── logos\
│       ├── tipografias\
│       └── overlays\           (intros, transiciones, textos graficos)
│
├── 03-export\                  (salidas SIN aprobar — para revision)
│   ├── video\                  (MP4/masters provisionales)
│   └── imagen\                 (render de imagen provisional)
│
├── 04-referencias\
│   └── moodboard\              (inspiracion del proyecto)
│
└── 05-entrega\                 (version FINAL aprobada por el cliente)
    └── video\                  (se copia tambien a Clientes\02-entregables)
```

Flujo de trabajo:
```
01-origen → 02-trabajo → 03-export (revisión) → 05-entrega → Clientes\02-entregables
```

Al terminar un proyecto, copia el resultado final a
`Clientes\univalle\02-entregables\` (video/imagen/documentos) y deja la carpeta
de proyecto como histórico del trabajo.

---

## 6. Brave: perfiles aislados por cliente

Los accesos del escritorio ya abren cada perfil con `--user-data-dir`.

1. Abre **Brave | Personal** → cierra sesión/login de tus cuentas.
   - Loguéate aquí SOLO con tu correo/redes personales.
2. Abre **Brave | Univallé** → primer uso → loguéate SOLO con las cuentas
   del cliente (Instagram, FB, etc.).
3. Verificación de que no te mezclas: en cada ventana visita `brave://version`
   y mira la línea `Command Line` — debe apuntar a su carpeta (personale/univalle).
4. Pon íconos/colores distintos a cada acceso del escritorio para distinguirlos.

> Regla: nunca loguees la cuenta del cliente en `personal` ni tu cuenta en
> `univalle`.

---

## 7. Bitwarden

1. Crea/abre tu vault (master password FUERTE, guardada en papel offline).
2. Estructura de carpetas:
   ```
   Agencia/Univallé
   Personal
   ```
3. Cada credencial del cliente cae en su carpeta (imposible confundir sesiones).
4. Activa **2FA en la maestra** (hoy: app TOTP / mejor: YubiKey). Nunca SMS único.
5. Instala la **extensión de Bitwarden** en cada perfil de Brave (se instala
   por perfil, no global). Loguéate en cada extensión según el perfil
   (la de `univalle` solo ve `Agencia/Univallé`).
6. Atajo `Ctrl+Shift+L` bloquea el vault: úsalo al cambiar de cliente.

---

## 8. AutoHotkey y Espanso (automatización)

- **AutoHotkey**: el `context-manager.ahk` arranca con Windows (está en Inicio).
  Hotkeys activos en la cuenta Trabajo:

  | Hotkey | Acción |
  |---|---|
  | `Win+Shift+E` | Modo editor: abre Premiere + Photoshop + assets de univalle + navegador personal, mata gaming |
  | `Win+Shift+U` | Modo CM Univallé: abre perfil aislado del cliente + folder de assets |
  | `Win+Shift+G` | Modo gamer: mata Adobe (solo tiene sentido cruzar para liberar RAM) |

  Para recargar tras editar un script: clic derecho en el icono del tray → Reload.

- **Espanso**: empieza a escribir los triggers sobre cualquier app:
  - `:u1`…`:u5` → respuestas de atención para Univallé
  - `:firma`, `:adios`, `:acuse` → respuestas transversales
  - `:h30`, `:hotel`, `:food` → bloques de hashtags
  - `:pitch`, `:follow`, `:reporte` → plantillas de correo
  - `Alt+Space` → buscador de macros de Espanso

  Espanso muestra una notificación al ser invocado. Los `[corchetes]`
  son marcadores: rellénalos con los datos reales la primera vez y luego
  edita el `.yml` correspondiente.

---

## 9. Seguridad y endurecimiento

- `win/security-harden.ps1 -Apply` ya corrió (desde setup.ps1). Verifica:
  ```powershell
  .\win\env-check.ps1      # auditoria de todo el entorno
  .\win\security-harden.ps1 # modo auditoria de Defender
  ```
- **BitLocker en C:**: `Panel de control` → `Cifrado de unidad BitLocker`.
  Guarda la recovery key en pendrive FUERA del equipo y fuera del repo.
- Turn on SmartScreen y firewall (ya activados por el hardening).

---

## 10. Escritorio personalizado (distinto en cada cuenta)

Windows aísla el escritorio por usuario. Para la cuenta Trabajo:

1. Clic derecho en el escritorio → `Personalizar`:
   - Fondo: nombre de cuenta de usuario debe reflejarse (imagen sobria de agencia/cliente).
   - Tema oscuro para sesiones largas de edición.
2. Accesos del escritorio Trabajo (ya creados por setup.ps1):
   - `Brave | Personal`
   - `Brave | Univallé`
   - Carpeta `Clientes` (o acceso a `Documents\Clientes`)
   - `Bitwarden`, `Espanso`, `Notion`
3. **Barra de tareas**: fija solo apps de trabajo (Brave, Bitwarden, Explorer).
   Nada de Steam ni herramientas gaming.
4. El escritorio de Gaming queda igual de separado (juegos, Discord, etc.).

> Cada cuenta tiene su tema propio: la personalización no se mezcla.

---

## 11. Checklist de aceptación

- [ ] Cuenta Trabajo es **Estándar** con PIN.
- [ ] Espanso, AutoHotkey, Brave y Bitwarden instalados en Trabajo.
- [ ] Premiere + Photoshop instalados (vía admin) y operativos.
- [ ] `setup.ps1 -All` ejecutado sin errores.
- [ ] `BrowserProfiles\personal` y `BrowserProfiles\univalle` creados.
- [ ] Accesos `Brave | Personal` y `Brave | Univallé` en el escritorio,
      verificados en `brave://version`.
- [ ] Bitwarden con carpetas `Agencia/Univallé` y `Personal` + 2FA activado.
- [ ] Extensión Bitwarden instalada en cada perfil de navegador.
- [ ] `C:\Users\Trabajo\Documents\Clientes\univalle\` con la estructura del paso 5.
- [ ] Hotkeys `Win+Shift+E` y `Win+Shift+U` funcionan.
- [ ] Triggers `:u1`…`:u5` expanden en Espanso.
- [ ] `env-check.ps1` sin `[!!]`.
- [ ] BitLocker On en C: y recovery key fuera del equipo.
- [ ] Escritorio Trabajo sin iconos de la cuenta Gaming.