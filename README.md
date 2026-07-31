# PokeRetro Launcher

Launcher oficial para PokeRetro con sistema de actualización automática.

## Estructura

```
PokeRetro Launcher/
├── Dx9/                    # Cliente DirectX 9 (recomendado)
│   ├── PokePere Dx9.exe
│   └── launcher.py
├── OpenGL/                 # Cliente OpenGL (alternativo)
│   ├── PokePere OpenGL.exe
│   └── launcher.py
├── fondolauncher.jpg       # Fondo del launcher
└── GUARDAR CAMBIOS.bat     # Script para subir cambios
```

## Características

- ✨ Actualización automática del cliente desde GitHub
- 🎨 Interfaz gráfica personalizada
- 🚀 Dos versiones: DirectX 9 y OpenGL
- 📦 Sistema de caché inteligente (solo descarga cambios)
- 🔒 Verificación MD5 de archivos

## Desarrollo

### Subir cambios a GitHub

**Opción 1: Usando el .bat**
```bash
# Doble clic en GUARDAR CAMBIOS.bat
# Te pedirá un mensaje de commit
```

**Opción 2: Usando PowerShell**
```powershell
.\guardar_cambios.ps1 "Tu mensaje de commit"
```

**Opción 3: Manual**
```bash
git add -A
git commit -m "Tu mensaje"
git push origin main
```

### Recompilar el launcher

```bash
# Desde Dx9/ o OpenGL/
pyinstaller --onefile --windowed --icon perfil_icon.ico --name "PokeRetro Launcher" launcher.py
```

## Archivos importantes

- `launcher.py` - Código principal del launcher
- `manifest.json` - Lista de archivos y sus MD5 (auto-generado)
- `.gitignore` - Archivos excluidos de Git
- `.launcher_cache.json` - Caché local (no se sube a Git)

## Licencia

Todos los derechos reservados © PokeRetro
