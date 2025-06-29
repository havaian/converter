@echo off
setlocal enabledelayedexpansion

echo ============================================
echo Universal File Converter - Windows Build Tool
echo ============================================
echo.

:: Check for Python installation
where python >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Python not found!
    echo Please install Python 3.8 or higher and ensure it's in your PATH.
    exit /b 1
)

:: Check Python version
python --version > pyver.tmp
set /p PYVER=<pyver.tmp
del pyver.tmp
echo Detected Python: %PYVER%

:: Check for required Python packages
echo Checking for required packages...

:: Check for PyInstaller
python -c "import PyInstaller" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo PyInstaller not found. Installing...
    python -m pip install pyinstaller
    
    :: Double-check that PyInstaller is installed regardless of pip exit code
    python -c "import PyInstaller" >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo Failed to install PyInstaller. Aborting.
        exit /b 1
    )
    echo PyInstaller installed successfully.
)

:: Check for required dependencies
python -c "import PyQt6" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo PyQt6 not found. Installing...
    python -m pip install pyqt6
    if %ERRORLEVEL% neq 0 (
        echo Failed to install PyQt6. Aborting.
        exit /b 1
    )
)

:: Check for other dependencies
for %%p in (tqdm requests) do (
    python -c "import %%p" >nul 2>&1
    if !ERRORLEVEL! neq 0 (
        echo %%p not found. Installing...
        python -m pip install %%p
        
        :: Double-check that the package is installed
        python -c "import %%p" >nul 2>&1
        if !ERRORLEVEL! neq 0 (
            echo Failed to install %%p. Aborting.
            exit /b 1
        )
        echo %%p installed successfully.
    )
)

echo All required packages found or installed.

:: Create portable_tools directory if it doesn't exist
if not exist portable_tools (
    echo Creating portable_tools directory...
    mkdir portable_tools
)

:: Create tool directories if they don't exist
for %%d in (ffmpeg pandoc libreoffice) do (
    if not exist portable_tools\%%d (
        echo Creating portable_tools\%%d directory...
        mkdir portable_tools\%%d
        mkdir portable_tools\%%d\bin
    )
)

:: Ensure src directory exists
if not exist src (
    echo Error: src directory not found!
    echo This script must be run from the project root directory.
    exit /b 1
)

:: Clean up any previous build
echo Cleaning up previous builds...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
del /q /f universal-converter.spec 2>nul

:: Create the build spec file
echo Generating PyInstaller spec file...
python -m PyInstaller --name=universal-converter ^
  --noconfirm ^
  --windowed ^
  --add-data="resources;resources" ^
  --hidden-import=PyQt6.QtCore ^
  --hidden-import=PyQt6.QtGui ^
  --hidden-import=PyQt6.QtWidgets ^
  --icon=resources\icons\app_icon.ico ^
  src\main_gui.py

:: Add the CLI version to the spec file
python -m PyInstaller --name=universal-converter-cli ^
  --noconfirm ^
  --console ^
  --add-data="resources;resources" ^
  --hidden-import=converters.ffmpeg ^
  --hidden-import=converters.pandoc ^
  --hidden-import=converters.libreoffice ^
  src\main.py

:: Better to use a custom spec file
if exist universal-converter.spec (
    echo Using custom spec file...
    copy /y universal-converter.spec pyinstaller-spec.py
) else (
    echo Using the generated spec file...
)

:: Build the package
echo Building the executable package...
python -m PyInstaller universal-converter.spec --noconfirm --clean

if %ERRORLEVEL% neq 0 (
    echo Build failed. Please check the errors above.
    exit /b 1
)

:: Copy the README and licenses
echo Copying documentation files...
copy README.md dist\universal-converter\ 2>nul
copy LICENSE dist\universal-converter\ 2>nul

:: Create version file
echo Creating version file...
echo Universal File Converter v1.0 > dist\universal-converter\version.txt
echo Build date: %date% %time% >> dist\universal-converter\version.txt

echo.
echo ============================================
echo Build completed successfully!
echo.
echo The executable package is available in:
echo %CD%\dist\universal-converter\universal-converter.exe
echo.
echo To run the command-line version:
echo %CD%\dist\universal-converter\universal-converter-cli.exe
echo ============================================

:: Add optional ZIP packaging
echo.
echo Would you like to create a ZIP package of the build? (Y/N)
set /p MAKE_ZIP=

if /i "%MAKE_ZIP%"=="Y" (
    echo Creating ZIP package...
    
    :: Check if PowerShell is available for compression
    where powershell >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        powershell -command "Compress-Archive -Path 'dist\universal-converter\*' -DestinationPath 'dist\universal-converter-%date:~10,4%%date:~4,2%%date:~7,2%.zip' -Force"
        echo ZIP package created at:
        echo %CD%\dist\universal-converter-%date:~10,4%%date:~4,2%%date:~7,2%.zip
    ) else (
        echo PowerShell not found. Please manually create a ZIP file from the dist\universal-converter directory.
    )
)

echo.
echo Build process complete. Press any key to exit.
pause > nul