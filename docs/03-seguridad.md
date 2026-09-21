# Política de Seguridad del Entorno de Trabajo (cuenta Trabajo)

Referencia formal de seguridad del repositorio. Cubre: **aislamiento de
sesiones de navegador**, **Control de acceso a carpetas (anti-ransomware)**,
**cifrado BitLocker** y **2FA con llaves de hardware**.

Extiende el how-to operativo de `docs/01-separacion-trabajo-gaming.md`.
Aquí se define la *política* (qué y por qué); los scripts `win/*.ps1`
la ejecutan y auditan.

---

## 1. Aislamiento de sesiones de navegador

**Política**: cada cliente y la cuenta personal usan un `--user-data-dir`
independiente. No existen sesiones mezcladas.

| Columna | Regla |
|---|---|
| Un perfil por cliente + personal | `BrowserProfiles\{personal, cliente-a, cliente-b, ...}` |
| Sesiones nunca se comparten | Loguéar solo cuentas del cliente en su perfil |
| Verificación | `brave://version` muestra el `--user-data-dir` esperado |
| Recursos compartidos | Nada global: cada perfil instala sus extensiones |

Mapeo al repo:

- Definición de perfiles: `win/config.ps1` (`$PROFILES`, `$PROFILE_ROOT`).
- Apertura automática por contexto: `autohotkey/context-manager.ahk`
  (`LaunchProfile` → `LaunchProfile($PROFILE_CLI_A)`).
- Creación/verificación: `win/env-check.ps1`.

**Criterio de aceptación**: al cambiar de cliente con `Win+Shift+C`, la
ventana abierta pertenece al perfil correcto y Bitwarden está bloqueado.

---

## 2. Control de acceso a carpetas (anti-ransomware)

**Política**: Windows Defender bloquea escritura no autorizada sobre datos
de trabajo. Aplicaciones permisas solo las de la lista blanca.

| Carpeta protegida | Motivo |
|---|---|
| `C:\Users\Trabajo\Documents` | Activos y entregables de clientes |
| `C:\Users\Trabajo\BrowserProfiles` | Sesiones y cookies aisladas |

Reglas:

- Proteger carpeta → con `-Apply`, `Add-MpPreference -ControlledFolderAccessProtectedFolders`.
- App permitida → solo las imprescindibles (Adobe, suite de agencia) vía
  `-ControlledFolderAccessAllowedApplications`.
- Verificación → `Get-MpPreference` de `win/security-harden.ps1` (modo
  auditoría) o `win/env-check.ps1`.

**Estado objetivo**: `EnableControlledFolderAccess = Enabled` (o `AuditMode`
durante la calibración inicial, para ver falsos positivos antes de bloquear).

---

## 3. Cifrado de discos (BitLocker)

**Política**: todo volumen de datos de trabajo cifrado. La recovery key
**nunca** reside en el repo ni en la máquina.

| Acción | Comando |
|---|---|
| Activar | `Enable-Bitlocker -MountPoint C: -TpmProtector` (o PIN) |
| Auditar | `.\win\bitlocker-check.ps1` |
| Ver estado | `Get-BitlockerVolume -MountPoint C:` |

Reglas:

- Guardar recovery key en copia física/pendrive **fuera del equipo**.
- `win/bitlocker-check.ps1` detecta archivos sospechosos de recovery dentro
  del repo y los señala (`.txt`, `.bev`, `.key`, `*recovery*`).
- El gaming queda sujeto a la misma política solo si se decide; los juegos
  son reinstalables y no requieren backup.

**Estado objetivo**: `ProtectionStatus = On` en `C:`.

---

## 4. 2FA con llaves de seguridad de hardware

**Política**:

- Cuentas **críticas** (clasificación): Bitwarden (maestra), mail de trabajo,
  Meta Business Suite / plataformas de gestión de clientes.
- 2FA en críticas → **llave de hardware (FIDO2/WebAuthn)**, p.ej. YubiKey.
- Cuentas secundarias → TOTP permitido (preferiblemente dentro de Bitwarden).
- **Nunca** SMS como único factor. Nunca compartir la misma llave para
  trabajo y personal sin separación de credenciales.

| Nivel | Factor 2 | Ejemplo |
|---|---|---|
| Crítico | Hardware (WebAuthn) | Bitwarden, correo, Meta Business |
| Estándar | TOTP en vault | Redes sociales secundarias |
| Prohibido | SMS único | Cualquiera |

Regla de pérdida/robo: revocar desde otro dispositivo con sesión válida,
rotar credenciales afectadas y eliminar la llave de los servicios.

Estado del repo: este documento establece la política; el 2FA es
**configuración de usuario** (manual, deliberadamente fuera de los scripts).

---

## 5. Respuesta ante incidente sospechoso (runbook)

1. **Aislar**: desconectar red/Wi-Fi; si es un adjunto o enlace, no abrirlo más.
2. **Rotar** desde otro dispositivo de confianza: contraseñas de lo expuesto y
   revocación de sesiones activas en la cuenta afectada.
3. **Verificar signos de compromiso**: pestañas/sesiones extrañas,
   extensiones no instaladas, procesos desconocidos → escanear con Defender.
4. **Reportar** al equipo/cliente si afecta datos del cliente (política de la
   agencia) y documentar en este repo si surge un patrón repetible.

---

## Checklist de aceptación de seguridad

- [ ] Perfiles aislados creados y verificados (`env-check.ps1` sin `[!!]`).
- [ ] `EnableControlledFolderAccess = Enabled`.
- [ ] BitLocker On + recovery key fuera del repo.
- [ ] 2FA hardware registrado en cuentas críticas; sin SMS único.
- [ ] `security-harden.ps1 -Apply` ejecutado y re-verificado en auditoría.