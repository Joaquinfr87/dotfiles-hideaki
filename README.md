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
| 1 | Estructura base e inicialización | EN CURSO |
| 2 | Automatización con AutoHotkey | Pendiente |
| 3 | Expansión de texto con Espanso | Pendiente |
| 4 | Aislamiento y seguridad (docs + PowerShell) | Pendiente |
| 5 | Script de despliegue (setup.ps1) | Pendiente |

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