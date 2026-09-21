# Guía: separación total Trabajo vs Gaming — 2 usuarios Windows

Objetivo: una sola máquina Windows 11 con **dos cuentas de usuario aisladas**.
La cuenta **Trabajo** concentra toda la operativa de Community Manager
(múltiples clientes aislados entre sí). La cuenta **Gaming** queda fuera del
scope gestionado del repo, para reducir superficie de ataque sobre los datos
de trabajo.

---

## 0. Arquitectura de referencia

| | Cuenta TRABAJO | Cuenta GAMING |
|---|---|---|
| Rol | Community Manager (agencia) | Juegos, launchers, mods |
| Nivel de cuenta | **Estándar** (sin admin) | Admin (anti-cheat/launchers) |
| Cifrado | C: con BitLocker | C: (opcional) |
| Navegador | Brave con perfil por cliente | Edge/Chrome libre |
| Third-party | Adobe + herramientas laborales | Steam, Epic, emuladores |
| Riesgo asumido | Bajo (el protegido) | Alto (el aislado) |
| Gestionada por repo | **Sí** (`setup.ps1`) | No (documentado aquí) |

Principio rector: **el gaming nunca ve los datos de trabajo**, y si un mod
arrastra malware, se queda confinado en la cuenta Gaming.

---

## 1. Requisitos

- **Windows 11 Pro** (necesaria para BitLocker y Windows Sandbox). En Home,
  BitLocker no está disponible.
- **Disco**: el trabajo vive en `C:`; para juegos conviene partición/disco
  adicional `D:\Games`.
- **Llave de seguridad hardware (YubiKey)** recomendada para el 2FA de la
  cuenta de trabajo (opcional pero muy recomendado).
- 8 GB+ RAM, ~200 GB libres mínimos (por separar dos entornos).

---

## 2. Crear los dos usuarios

### 2.1 Decisión: cuenta Microsoft vs local
- **Trabajo** → cuenta **local** recomendada: no enlaza servicios personales,
  y combina mejor con el aislamiento del repo. Si la agencia exige cuenta
  Microsoft/Entra, entonces sí, única excepción.
- **Gaming** → cuenta **local** con contraseña simple (la barrera intencionada
  es que no sea "cómoda de abrir" para el uso diario).

### 2.2 Paso a paso (Configuración → Cuentas → Otros usuarios)
1. `Configuración` → `Cuentas` → `Otros usuarios` → `Agregar cuenta`.
2. `No tengo los datos de inicio de sesión de esta persona`.
3. `Agregar un usuario sin cuenta Microsoft`.
4. Nombre: `Trabajo` (o el que uses). Contraseña fuerte + pregunta de
   recuperación.
5. Repite para `Gaming`.
6. Roles:
   - `Trabajo` → **Estándar** (nunca admin).
   - `Gaming` → **Administrador** (requisito de varios anti-cheat/launchers).

> Nota: con la cuenta Trabajo **estándar**, los programas que requieran
> elevación (instalar Adobe) pedirán admin de la cuenta Gaming o del
> Administrador del sistema — exactamente la fricción que queremos.

### 2.3 Windows Hello (opcional, cómodo)
En **Trabajo** activa PIN (Windows Hello) para un desbloqueo rápido y que el
perfil se cifre con reciprocidad más fuerte. En **Gaming** déjalo con
contraseña simple.

---

## 3. Cifrado de discos (BitLocker)

Proteger la cuenta de trabajo contra robo físico del equipo:

1. `Panel de control` → `Cifrado de unidad BitLocker` → `Activar BitLocker`
   sobre `C:`.
2. Método de desbloqueo: **PIN** (mejor que ninguna) o automático con TPM.
3. **Guarda la recovery key** en archivo/dr: **NUNCA dentro del repo** y nunca
   en la misma máquina. Copia de seguridad física (pendrive/USB aparte).
4. Revisa `Get-BitlockerVolume` para validar que está `Enabled`.

> La cuenta Gaming puede también cifrarse, pero recuerda: el dólar real es que
> **los datos de trabajo estén cifrados**, los juegos son reinstalables.

---

## 4. Separación de datos y discos

Al ser cuentas distintas, cada una tiene su propio `Documents`/`Downloads` —
Windows ya aísla perfiles (`C:\Users\Trabajo\`, `C:\Users\Gaming\`).

- **Trabajo**: todo en `C:\Users\Trabajo\Documents\Clientes\...`.
- **Gaming**: juegos en `D:\Games`, mods en `D:\Games\mods`.
- **Puente entre cuentas**: usa solo `C:\Users\Public\Transfer`
  (`C:\Users\Público\Transferencia` en español). Sin simbolicos raros.

```
C:\Users\Public\Transfer\        <- único punto de intercambio
C:\Users\Trabajo\Documents\Clientes\  <- NO compartir
D:\Games\                        <- el gaming casi no toca C:
```

---

## 5. Cuenta Trabajo: perfiles de navegador por cliente

Sesiones de navegador **100% aisladas** por cliente + personal, usando el flag
`--user-data-dir` de Brave (motor Chromium).

### 5.1 Crear carpetas de perfiles
Abre `Explorador` en `C:\Users\Trabajo\BrowserProfiles\` y crea:
```
BrowserProfiles\
├── personal/      <- tus cuentas personales
├── cliente-a/     <- un cliente
└── cliente-b/     <- otro cliente (tantos como necesites)
```

### 5.2 Clonar accesos directos
1. Botón derecho sobre el acceso de Brave → `Copiar` → pegar 3 veces en el
   Escritorio.
2. En cada copia: botón derecho → `Propiedades` → campo **Destino**:
   ```
   "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe" --user-data-dir="C:\Users\Trabajo\BrowserProfiles\cliente-a" --profile-directory="Default"
   ```
   (mismo patrón para `cliente-b` y `personal`).
3. Renombra cada acceso: `Brave | Cliente A`, `Brave | Personal`, etc.
4. Cambia el **color/icono** de cada acceso (`Cambiar icono…` o personalizar
   con un png) para distinguir ventanas de un vistazo y no mezclar clientes.

### 5.3 Reglas de uso de cada perfil
- Loguéate en **solo** las cuentas de ese cliente/personal en su ventana.
- Desactiva en cada perfil la opción de "volver a abrir pestañas" si quieres
  un cierre de sesión más limpio.
- **Cada perfil tiene su propia sesión**. Cerrar el perfil `cliente-a` no afecta
  a `cliente-b`.

### 5.4 Verificación rápida
Dentro de `cliente-a` visita `brave://version` → línea
`Command Line` debe mostrar `--user-data-dir=...\cliente-a`. Si no aparece,
estás usando el perfil equivocado.

> El `context-manager.ahk` (Fase 2) abrirá estos perfiles por hotkey, y
> `win/config.ps1` ya define `$PROFILE_ROOT` y `$PROFILES` para esto.

---

## 6. Cuenta Trabajo: gestión de contraseñas

1. Instala **Bitwarden** en la cuenta Trabajo y entra en cada perfil de
   navegador (extensión por perfil).
2. Crea carpetas en el vault:
   ```
   Agencia/Cliente-A
   Agencia/Cliente-B
   Personal
   ```
   Cada credencial cae en su carpeta → imposible pegar la del cliente en una
   sesión equivocada.
3. Activa el **generador de contraseñas** (nunca reutilizar).
4. Master password sólida: memorizada o en copia física **offline** (nunca en
   el repo). Activa 2FA en Bitwarden con la **YubiKey**.
5. Guarda los **TOTP** de las cuentas de cliente dentro del propio vault de
   Bitwarden.
6. Atajo `Ctrl+Shift+L` bloquea el vault; se usará al cambiar de contexto.

> Advertencia: nunca versionar el vault ni exportaciones en claro en el repo.
> `.gitignore` ya bloquea `*.secret`.

---

## 7. Cuenta Trabajo: endurecimiento Windows Defender

### 7.1 Control de acceso a carpetas (anti-ransomware)
1. `Seguridad de Windows` → `Protección contra virus y amenazas` →
   `Protección contra ransomware` → **Control de acceso a carpetas: Activar**.
2. `Carpetas protegidas` → añadir:
   - `C:\Users\Trabajo\Documents`
   - `C:\Users\Trabajo\BrowserProfiles`
3. `Permitir una aplicación a través del control de acceso a carpetas`:
   añade solo lo imprescindible (Adobe, herramientas de la agencia).

### 7.2 Protección en navegador/descargas
1. `Configuración` → `Privacidad y seguridad` → `Buscar mi dispositivo`.
2. `Seguridad de Windows` → `Control de aplicaciones y navegador` →
   activa **SmartScreen / protección basada en reputación**.

### 7.3 Actualizaciones y firewall
- `Windows Update`: mantener la cuenta Trabajo al día (los parches curtían más).
- Firewall de Windows por defecto (activado). No abrir puertos para gaming
  desde esta cuenta.

---

## 8. Cuenta Gaming: launchers y mods

1. Instala en **Gaming** solo: Steam, Epic Games, emuladores, Discord.
2. `D:\Games\` como directorio de la biblioteca de Steam.
3. **Sandboxie-Plus** para ejecutar instaladores/ejecutables de mods o
   cracks sospechosos en un entorno con arena: si infecta, muere con el
   sandbox.
4. Regla: **ningún launcher de terceros ni mod se instala en la cuenta
   Trabajo**. Si un juego exige admin, ya está en Gaming.
5. Nota anti-cheat: varios juegos usan drivers kernel-mode; por eso el gaming
   vive en una cuenta **admin propio**, nunca en la VM ni en la de trabajo.

---

## 9. Cambio de sesión rápido

- `Ctrl` + `Alt` + `Supr` → `Cambiar de usuario` (fast user switching, activo
  por defecto).
- `Win` + `L` bloquea la sesión actual → eliges la otra en la pantalla de
  bloqueo.
- Con PIN en Trabajo: desbloqueo de 2 dígitos; Gaming requiere la contraseña
  (fricción intencionada).

---

## 10. Compartir archivos entre cuentas

Solo vía carpeta pública:

| Origen | Destino | Método |
|---|---|---|
| Trabajo → Gaming | `C:\Users\Public\Transfer` | Copiar manual |
| Gaming → Trabajo | ídem | Copiar manual |

Prohibido: exponer `C:\Users\Trabajo\Documents` en red/compartida con la
cuenta Gaming. Si necesitas intercambio frecuente, un pendrive cifrado es
mejor que red local.

---

## 11. Qué automatizará el repo vs qué es manual

| Tarea | Manual | `setup.ps1` (Fase 5) | AHK (Fase 2) |
|---|---|---|---|
| Crear cuentas de usuario | Sí | No* | No |
| BitLocker | Sí | Verificar estado | No |
| Perfil navegador por cliente | Crear carpetas | Sí | Sí (abrir) |
| Ejecutar navegador por perfil | Accesos directos | Crear accesos | Sí (hotkey) |
| Bitwarden carpetas | Sí | No | Bloquear al cambiar |
| Control acceso carpeta | Sí | Sí (script Defender) | No |
| Sandboxie/$libs gaming | Sí | No | No |

\* Por seguridad, `setup.ps1` **no** crea cuentas ni toca la cuenta Gaming.

---

## 12. Checklist final de aceptación

- [ ] Dos cuentas: Trabajo (estándar) y Gaming (admin).
- [ ] BitLocker activo en C:; recovery key fuera del repo.
- [ ] `BrowserProfiles\` con perfil por cliente + personal.
- [ ] Cada acceso directo de Brave abre su `--user-data-dir` (verificado en
      `brave://version`).
- [ ] Bitwarden con carpetas por cliente, 2FA (YubiKey) en la maestra.
- [ ] Control de acceso a carpetas protegiendo `Documents` y `BrowserProfiles`.
- [ ] Juegos/launchers TODOS bajo `D:\Games\` y solo en cuenta Gaming.
- [ ] Intercambio de archivos únicamente vía `C:\Users\Public\Transfer`.
- [ ] `Win+L` / `Ctrl+Alt+Supr` permiten saltar entre sesiones sin fricción.

---

*Estado: documento de arquitectura — se referencia desde `win/config.ps1`
(perfiles) y será la base del contenido de seguridad de la Fase 4.*