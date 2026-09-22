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
Crea el árbol del cliente y las carpetas de proyecto en un paso:

```powershell
powershell -ExecutionPolicy Bypass -File .\win\nuevo-proyecto.ps1 -Register   # [ADMIN] clic derecho -> "Nuevo proyecto de edicion"
powershell -ExecutionPolicy Bypass -File .\win\nuevo-proyecto.ps1 -Cliente univalle -Proyecto "campaña-verano"
```

El `-Register` añade al Explorador la opción *clic derecho → Nuevo proyecto de
edición*: crea `Proyectos\<cliente>\<proyecto>\{01-origen,02-trabajo,03-export}`
y, si falta, el árbol de `Clientes\<cliente>\` (información + entregables).

**Manual:** crea esta estructura en `C:\Users\Trabajo\Documents\`:

```
Clientes\
└── univalle\
    ├── 01-informacion\       # datos del cliente, presentaciones, contratos
    ├── 02-entregables\       # resultados FINALES para publicar
    │   ├── imagenes\
    │   ├── videos\
    │   └── documentos\
    └── 03-admin\             # facturas, accesos, logistica

Proyectos\                    # trabajo en curso (separado)
└── univalle\
    └── <proyecto>\
        ├── 01-origen\        # videos/fotos originales
        ├── 02-trabajo\       # archivos .prproj, .psd
        └── 03-export\        # render/salida pendiente de entrega
```

Al terminar un proyecto, mueve el resultado final a
`Clientes\univalle\02-entregables\` (imagenes/videos/documentos).

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