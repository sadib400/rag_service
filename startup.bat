@echo off
setlocal EnableDelayedExpansion

:: -------------------------------
:: CONFIG: Project root directory
:: -------------------------------
set "PROJECT_DIR=D:\AI\rag_service"
cd /d "%PROJECT_DIR%"

:: -------------------------------
:: STEP 1: Generate .env
:: -------------------------------
if not exist ".env" (
    echo Generating .env...

    :: ========== Get folder paths ==========
    :get_folders
    set "VALID=1"
    set "DIR_INPUT="

    for /f "delims=" %%i in ('powershell -command "Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.Interaction]::InputBox('Give the path of the folders you want AI to get access to. Separate multiple folders with commas (e.g. D:\\docs,E:\\vault):', 'Set Accessible Folders')"') do (
        set "DIR_INPUT=%%i"
    )

    set "DIR_INPUT=!DIR_INPUT:"=!"

    :: Validate each directory and disallow root C:\
    for %%D in (!DIR_INPUT!) do (
        if "%%D"=="C:\" (
            echo ❌ ERROR: Access to C:\ is not allowed.
            set "VALID=0"
        ) else if not exist "%%D" (
            echo ❌ ERROR: Invalid path: %%D
            set "VALID=0"
        )
    )

    if !VALID! == 0 (
        echo ❌ One or more folders are invalid or not allowed. Please try again.
        goto get_folders
    )

    :: ========== Get chatd.exe (no validation) ==========
    for /f "delims=" %%i in ('powershell -command "Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.Interaction]::InputBox('Enter full path to chatd.exe (e.g. D:\\Apps\\ChatD\\chatd.exe):', 'ChatD Path')"') do (
        set "CHATD_PATH=%%i"
    )
    set "CHATD_PATH=!CHATD_PATH:"=!"

    :: ========== Get ollama.exe (no validation) ==========
    for /f "delims=" %%i in ('powershell -command "Add-Type -AssemblyName Microsoft.VisualBasic; [Microsoft.VisualBasic.Interaction]::InputBox('Enter full path to ollama.exe (e.g. C:\\Program Files\\Ollama\\ollama.exe):', 'Ollama Path')"') do (
        set "OLLAMA_PATH=%%i"
    )
    set "OLLAMA_PATH=!OLLAMA_PATH:"=!"

    (
        echo DIRECTORIES=!DIR_INPUT!
        echo SEARCH_API_KEY=
        echo CHATD_PATH=!CHATD_PATH!
        echo OLLAMA_PATH=!OLLAMA_PATH!
    ) > .env

    echo ✅ .env created successfully.
)

:: -------------------------------
:: STEP 2: Create package.json
:: -------------------------------
if not exist "package.json" (
    (
        echo {
        echo   "name": "rag-service",
        echo   "version": "1.0.0",
        echo   "type": "module",
        echo   "dependencies": {
        echo     "axios": "^1.10.0",
        echo     "body-parser": "^2.2.0",
        echo     "dotenv": "^16.3.1",
        echo     "express": "^5.1.0",
        echo     "@modelcontextprotocol/server-filesystem": "*"
        echo   }
        echo }
    ) > package.json
    echo ✅ package.json created.
)

:: -------------------------------
:: STEP 3: Copy main.js from static template
:: -------------------------------
if not exist "main.js" (
    if exist "template_main.js" (
        copy /Y "template_main.js" "main.js" >nul
        echo ✅ main.js copied from template_main.js
    ) else (
        echo ❌ template_main.js not found! Cannot create main.js
        exit /b 1
    )
)

:: -------------------------------
:: STEP 4: Install dependencies
:: -------------------------------
if not exist "node_modules" (
    echo Installing dependencies...
    call npm install
    if errorlevel 1 (
        echo ❌ Dependency installation failed.
        exit /b 1
    )
)

:: -------------------------------
:: STEP 5: Start the server
:: -------------------------------
echo ✅ Launching server on port 3000...
node main.js
exit /b
