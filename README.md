# dotfiles-ionel

Configuraciones de entorno de trabajo reproducibles para Windows 11.
Filosofía de infraestructura como código aplicada a una máquina personal.

## Roles
- **Community Manager (Agencia):** múltiples clientes, aislamiento estricto y seguridad contra phishing.
- **Editor de Video (Adobe):** gestión de recursos, caché y assets.
- **Gamer:** plataformas de terceros y mods con mitigación de malware.

## Estado por fase
| Fase | Descripción | Estado |
|------|-------------|--------|
| 1 | Estructura base e inicialización | COMPLETADO |
| 2 | Automatización con AutoHotkey | COMPLETADO |
| 3 | Expansión de texto con Espanso | COMPLETADO |
| 4 | Aislamiento y seguridad (docs + PowerShell) | COMPLETADO |
| 5 | Script de despliegue (setup.ps1) | COMPLETADO |

## Estructura
```
├── win/            # Scripts principales (setup.ps1, config.ps1)
├── autohotkey/     # Scripts .ahk y librerías compartidas
├── espanso/        # Configuración .yml de expansión de texto
├── docs/           # Documentación formal (seguridad, guías)
└── backups/        # Respaldos de configuraciones exportables
```

## Primeros pasos
1. Revisar `win/config.ps1` (rutas y nombres de perfil).
2. Seguir las fases en orden; cada una agrega archivos y lógica.
3. Ver `docs/` por fase completada para los procedimientos de despliegue.

## Despliegue (Fase 5)
En la maquina Windows de destino (cuenta Trabajo), desde la raiz del repo:

```powershell
# Modo plan: crea junction de espanso, accesos de Brave por perfil,
# acceso de AutoHotkey en Startup y audita el estado.
powershell -ExecutionPolicy Bypass -File .\setup.ps1

# Aprovisionamiento completo en maquina limpia (requiere admin):
# instala Espanso + AutoHotkey via winget, hardening de Defender,
# auditoria de BitLocker y auditoria final.
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -All
```

Es idempotente: se puede repetir sin romper nada. Detalles en
`docs/01-separacion-trabajo-gaming.md` y `docs/03-seguridad.md`.