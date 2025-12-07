@echo off
setlocal EnableDelayedExpansion

:: ============================================================
:: Math OCR Tool - Quick Deploy Script (Windows)
:: Repository: https://github.com/zhizinan1997/math-ocr-tool.git
:: ============================================================

cls
echo.
echo ========================================
echo   Math OCR Tool - Quick Deploy
echo   GitHub: zhizinan1997/math-ocr-tool
echo ========================================
echo.

:: Check Git
echo [INFO] Checking Git installation...
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Git not installed! Please install Git first.
    echo   Download: https://git-scm.com/download/win
    pause
    exit /b 1
)
echo [SUCCESS] Git is installed
echo.

:: Check Docker
echo [INFO] Checking Docker installation...
where docker >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker not installed! Please install Docker Desktop.
    echo   Download: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo [SUCCESS] Docker is installed
echo.

:: Check Docker service
echo [INFO] Checking Docker service...
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker service not running! Please start Docker Desktop.
    pause
    exit /b 1
)
echo [SUCCESS] Docker service is running
echo.

:: Set installation directory
set "INSTALL_DIR=%USERPROFILE%\math-ocr-tool"
echo [INFO] Default installation directory: %INSTALL_DIR%
set /p USE_DEFAULT="Use this directory? (y/n, press Enter for default): "

if /i "!USE_DEFAULT!"=="n" (
    set /p INSTALL_DIR="Enter installation directory: "
)

echo [INFO] Installation directory: %INSTALL_DIR%
echo.

:: Clone repository
set "REPO_URL=https://github.com/zhizinan1997/math-ocr-tool.git"

if exist "%INSTALL_DIR%" (
    echo [WARNING] Directory already exists: %INSTALL_DIR%
    set /p RECLONE="Delete and re-clone? (y/n): "
    if /i "!RECLONE!"=="y" (
        echo [INFO] Deleting existing directory...
        rmdir /s /q "%INSTALL_DIR%"
    ) else (
        echo [INFO] Using existing directory, pulling latest code...
        cd /d "%INSTALL_DIR%"
        git pull origin main 2>nul || git pull origin master
    )
)

if not exist "%INSTALL_DIR%" (
    echo [INFO] Cloning from GitHub...
    git clone "%REPO_URL%" "%INSTALL_DIR%"
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Clone failed! Please check network connection.
        pause
        exit /b 1
    )
    echo [SUCCESS] Project cloned
)

cd /d "%INSTALL_DIR%"
echo [SUCCESS] Current directory: %CD%
echo.

:: Configure Database
echo ========================================
echo Database Configuration
echo ========================================
echo.
echo Enter PostgreSQL database connection info:
echo.

set /p DB_HOST="Database host (default: localhost): "
if "!DB_HOST!"=="" set "DB_HOST=localhost"

set /p DB_PORT="Database port (default: 5432): "
if "!DB_PORT!"=="" set "DB_PORT=5432"

set /p DB_NAME="Database name (default: postgres): "
if "!DB_NAME!"=="" set "DB_NAME=postgres"

set /p DB_USER="Database user (default: postgres): "
if "!DB_USER!"=="" set "DB_USER=postgres"

set /p DB_PASSWORD="Database password (required): "
if "!DB_PASSWORD!"=="" (
    echo [ERROR] Database password cannot be empty!
    pause
    exit /b 1
)

echo [SUCCESS] Database configured
echo.

:: Configure AI API
echo ========================================
echo AI API Configuration
echo ========================================
echo.
echo Enter AI API configuration:
echo Note: Supports OpenAI and compatible APIs
echo.

set /p OPENAI_API_BASE="API base URL (default: https://api.openai.com/v1): "
if "!OPENAI_API_BASE!"=="" set "OPENAI_API_BASE=https://api.openai.com/v1"

set /p OPENAI_API_KEY="API key (required): "
if "!OPENAI_API_KEY!"=="" (
    echo [ERROR] API key cannot be empty!
    pause
    exit /b 1
)

set /p OPENAI_MODEL="Model name (default: gpt-4o): "
if "!OPENAI_MODEL!"=="" set "OPENAI_MODEL=gpt-4o"

echo [SUCCESS] AI API configured
echo.

:: Configure Port
echo ========================================
echo Port Configuration
echo ========================================
echo.

set /p PORT="Service port (default: 5000): "
if "!PORT!"=="" set "PORT=5000"

echo [INFO] Service will run on port: !PORT!
echo.

:: Generate .env file
echo ========================================
echo Generating Configuration File
echo ========================================
echo.

echo [INFO] Creating .env file...

(
echo # Math OCR Tool Environment Configuration
echo # Generated: %DATE% %TIME%
echo.
echo # Database Configuration
echo DB_HOST=!DB_HOST!
echo DB_PORT=!DB_PORT!
echo DB_NAME=!DB_NAME!
echo DB_USER=!DB_USER!
echo DB_PASSWORD=!DB_PASSWORD!
echo.
echo # AI API Configuration
echo OPENAI_API_KEY=!OPENAI_API_KEY!
echo OPENAI_API_BASE=!OPENAI_API_BASE!
echo OPENAI_MODEL=!OPENAI_MODEL!
echo.
echo # Application Configuration
echo PORT=!PORT!
echo LOG_LEVEL=INFO
) > .env

echo [SUCCESS] .env file created
echo.

:: Configuration Preview
echo ========================================
echo Configuration Preview
echo ========================================
echo.
echo Database Host:    !DB_HOST!
echo Database Port:    !DB_PORT!
echo Database Name:    !DB_NAME!
echo Database User:    !DB_USER!
echo Database Pass:    ********
echo API Base URL:     !OPENAI_API_BASE!
echo API Key:          !OPENAI_API_KEY:~0,8!...
echo Model Name:       !OPENAI_MODEL!
echo Service Port:     !PORT!
echo.

set /p CONFIRM="Confirm configuration and start deployment? (y/n): "
if /i not "!CONFIRM!"=="y" (
    echo [WARNING] Deployment canceled
    pause
    exit /b 0
)
echo.

:: Build Docker Image
echo ========================================
echo Building Docker Image
echo ========================================
echo.

set "CONTAINER_NAME=math-ocr-tool"
set "IMAGE_NAME=math-ocr-tool:latest"

echo [INFO] Building Docker image...
echo [INFO] This may take a few minutes, please wait...
echo.

docker build -t "%IMAGE_NAME%" .

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker image build failed!
    pause
    exit /b 1
)

echo [SUCCESS] Docker image built: %IMAGE_NAME%
echo.

:: Clean old container
echo ========================================
echo Deploying Container
echo ========================================
echo.

echo [INFO] Checking and cleaning old container...

docker ps -a --format "{{.Names}}" | findstr /C:"%CONTAINER_NAME%" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [INFO] Found old container, stopping and removing...
    docker stop %CONTAINER_NAME% >nul 2>&1
    docker rm %CONTAINER_NAME% >nul 2>&1
    echo [SUCCESS] Old container cleaned
)

:: Start new container
echo [INFO] Starting new container...

docker run -d ^
    --name "%CONTAINER_NAME%" ^
    --restart unless-stopped ^
    -p !PORT!:5000 ^
    -e DB_HOST="!DB_HOST!" ^
    -e DB_PORT="!DB_PORT!" ^
    -e DB_NAME="!DB_NAME!" ^
    -e DB_USER="!DB_USER!" ^
    -e DB_PASSWORD="!DB_PASSWORD!" ^
    -e OPENAI_API_KEY="!OPENAI_API_KEY!" ^
    -e OPENAI_API_BASE="!OPENAI_API_BASE!" ^
    -e OPENAI_MODEL="!OPENAI_MODEL!" ^
    -e LOG_LEVEL="INFO" ^
    -v "%INSTALL_DIR%\uploads:/app/uploads" ^
    "%IMAGE_NAME%"

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Container start failed!
    docker logs %CONTAINER_NAME%
    pause
    exit /b 1
)

echo [SUCCESS] Container started
echo.

:: Health Check
echo ========================================
echo Health Check
echo ========================================
echo.

echo [INFO] Waiting for service to start...
timeout /t 5 /nobreak >nul

echo [INFO] Checking service status...

set "RETRY_COUNT=0"
set "MAX_RETRIES=12"

:health_check_loop
if !RETRY_COUNT! GEQ !MAX_RETRIES! goto health_check_timeout

curl -s "http://localhost:!PORT!/health" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Service is running!
    goto health_check_done
)

set /a RETRY_COUNT+=1
echo [INFO] Waiting for service... (!RETRY_COUNT!/!MAX_RETRIES!)
timeout /t 3 /nobreak >nul
goto health_check_loop

:health_check_timeout
echo [WARNING] Service may still be starting, please check manually

:health_check_done
echo.

:: Deployment Complete
echo ========================================
echo Deployment Complete!
echo ========================================
echo.
echo   Access URL: http://localhost:!PORT!
echo   Install Dir: %INSTALL_DIR%
echo.
echo Common Commands:
echo   View logs:      docker logs %CONTAINER_NAME%
echo   Live logs:      docker logs -f %CONTAINER_NAME%
echo   Stop service:   docker stop %CONTAINER_NAME%
echo   Start service:  docker start %CONTAINER_NAME%
echo   Restart:        docker restart %CONTAINER_NAME%
echo   Remove:         docker stop %CONTAINER_NAME% ^&^& docker rm %CONTAINER_NAME%
echo.
echo Thank you for using Math OCR Tool!
echo.

pause
