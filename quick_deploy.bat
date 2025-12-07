@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ============================================================
:: Math OCR Tool - 一键部署脚本 (Windows)
:: 功能：从GitHub克隆项目，配置环境，构建并部署Docker容器
:: 作者：Ryan / zhizinan1997
:: 仓库：https://github.com/zhizinan1997/math-ocr-tool.git
:: ============================================================

:: ==================== 欢迎信息 ====================
cls
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║        📐 Math OCR Tool - 一键部署脚本                     ║
echo ║        数学公式图片转LaTeX工具                              ║
echo ║                                                            ║
echo ║        GitHub: zhizinan1997/math-ocr-tool                  ║
echo ║                                                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

:: ==================== 环境检查 ====================
echo ========================================
echo Step 1: 环境检查
echo ========================================
echo.

:: 检查 Git 是否安装
echo [INFO] 检查 Git 是否已安装...
where git >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Git 未安装！请先安装 Git
    echo   下载地址: https://git-scm.com/download/win
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('git --version') do echo [SUCCESS] %%i
echo.

:: 检查 Docker 是否安装
echo [INFO] 检查 Docker 是否已安装...
where docker >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker 未安装！请先安装 Docker Desktop
    echo   下载地址: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('docker --version') do echo [SUCCESS] %%i
echo.

:: 检查 Docker 服务是否运行
echo [INFO] 检查 Docker 服务状态...
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker 服务未运行！请启动 Docker Desktop
    pause
    exit /b 1
)
echo [SUCCESS] Docker 服务正在运行
echo.

:: ==================== 设置工作目录 ====================
echo ========================================
echo Step 2: 设置工作目录
echo ========================================
echo.

set "INSTALL_DIR=%USERPROFILE%\math-ocr-tool"
echo [INFO] 默认安装目录: %INSTALL_DIR%
set /p USE_DEFAULT="是否使用此目录? (y/n，直接回车使用默认): "

if /i "!USE_DEFAULT!"=="n" (
    set /p INSTALL_DIR="请输入安装目录: "
)

echo [INFO] 安装目录: %INSTALL_DIR%
echo.

:: ==================== 克隆项目 ====================
echo ========================================
echo Step 3: 克隆项目代码
echo ========================================
echo.

set "REPO_URL=https://github.com/zhizinan1997/math-ocr-tool.git"

if exist "%INSTALL_DIR%" (
    echo [WARNING] 目录已存在: %INSTALL_DIR%
    set /p RECLONE="是否删除并重新克隆? (y/n): "
    if /i "!RECLONE!"=="y" (
        echo [INFO] 删除现有目录...
        rmdir /s /q "%INSTALL_DIR%"
    ) else (
        echo [INFO] 使用现有目录，拉取最新代码...
        cd /d "%INSTALL_DIR%"
        git pull origin main 2>nul || git pull origin master
    )
)

if not exist "%INSTALL_DIR%" (
    echo [INFO] 正在从 GitHub 克隆项目...
    git clone "%REPO_URL%" "%INSTALL_DIR%"
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] 克隆失败！请检查网络连接
        pause
        exit /b 1
    )
    echo [SUCCESS] 项目克隆完成
)

cd /d "%INSTALL_DIR%"
echo [SUCCESS] 当前工作目录: %CD%
echo.

:: ==================== 配置数据库 ====================
echo ========================================
echo Step 4: 配置数据库连接
echo ========================================
echo.
echo 请输入 PostgreSQL 数据库连接信息:
echo.

set /p DB_HOST="数据库主机地址 (默认: localhost): "
if "!DB_HOST!"=="" set "DB_HOST=localhost"

set /p DB_PORT="数据库端口 (默认: 5432): "
if "!DB_PORT!"=="" set "DB_PORT=5432"

set /p DB_NAME="数据库名称 (默认: postgres): "
if "!DB_NAME!"=="" set "DB_NAME=postgres"

set /p DB_USER="数据库用户名 (默认: postgres): "
if "!DB_USER!"=="" set "DB_USER=postgres"

set /p DB_PASSWORD="数据库密码 (必填): "
if "!DB_PASSWORD!"=="" (
    echo [ERROR] 数据库密码不能为空！
    pause
    exit /b 1
)

echo [SUCCESS] 数据库配置完成
echo.

:: ==================== 配置 AI API ====================
echo ========================================
echo Step 5: 配置 AI API
echo ========================================
echo.
echo 请输入 AI API 配置信息:
echo 提示: 支持 OpenAI 及兼容接口
echo.

set /p OPENAI_API_BASE="API 地址 (默认: https://api.openai.com/v1): "
if "!OPENAI_API_BASE!"=="" set "OPENAI_API_BASE=https://api.openai.com/v1"

set /p OPENAI_API_KEY="API 密钥 (必填): "
if "!OPENAI_API_KEY!"=="" (
    echo [ERROR] API 密钥不能为空！
    pause
    exit /b 1
)

set /p OPENAI_MODEL="模型名称 (默认: gpt-4o): "
if "!OPENAI_MODEL!"=="" set "OPENAI_MODEL=gpt-4o"

echo [SUCCESS] AI API 配置完成
echo.

:: ==================== 端口配置 ====================
echo ========================================
echo Step 6: 配置服务端口
echo ========================================
echo.

set /p PORT="服务端口 (默认: 5000): "
if "!PORT!"=="" set "PORT=5000"

echo [INFO] 服务将运行在端口: !PORT!
echo.

:: ==================== 生成环境变量文件 ====================
echo ========================================
echo Step 7: 生成配置文件
echo ========================================
echo.

echo [INFO] 正在生成 .env 文件...

(
echo # Math OCR Tool 环境配置文件
echo # 自动生成于: %DATE% %TIME%
echo.
echo # 数据库配置
echo DB_HOST=!DB_HOST!
echo DB_PORT=!DB_PORT!
echo DB_NAME=!DB_NAME!
echo DB_USER=!DB_USER!
echo DB_PASSWORD=!DB_PASSWORD!
echo.
echo # AI API 配置
echo OPENAI_API_KEY=!OPENAI_API_KEY!
echo OPENAI_API_BASE=!OPENAI_API_BASE!
echo OPENAI_MODEL=!OPENAI_MODEL!
echo.
echo # 应用配置
echo PORT=!PORT!
echo LOG_LEVEL=INFO
) > .env

echo [SUCCESS] .env 文件已生成
echo.

:: ==================== 配置预览 ====================
echo ========================================
echo Step 8: 配置预览
echo ========================================
echo.
echo ┌─────────────────────────────────────────────────┐
echo │              配置信息预览                        │
echo ├─────────────────────────────────────────────────┤
echo │ 数据库主机:    !DB_HOST!
echo │ 数据库端口:    !DB_PORT!
echo │ 数据库名称:    !DB_NAME!
echo │ 数据库用户:    !DB_USER!
echo │ 数据库密码:    ********
echo │ API 地址:      !OPENAI_API_BASE!
echo │ API 密钥:      !OPENAI_API_KEY:~0,8!...
echo │ 模型名称:      !OPENAI_MODEL!
echo │ 服务端口:      !PORT!
echo └─────────────────────────────────────────────────┘
echo.

set /p CONFIRM="确认以上配置并开始部署? (y/n): "
if /i not "!CONFIRM!"=="y" (
    echo [WARNING] 部署已取消
    pause
    exit /b 0
)
echo.

:: ==================== 构建 Docker 镜像 ====================
echo ========================================
echo Step 9: 构建 Docker 镜像
echo ========================================
echo.

set "CONTAINER_NAME=math-ocr-tool"
set "IMAGE_NAME=math-ocr-tool:latest"

echo [INFO] 正在构建 Docker 镜像...
echo [INFO] 这可能需要几分钟时间，请耐心等待...
echo.

docker build -t "%IMAGE_NAME%" .

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker 镜像构建失败！
    pause
    exit /b 1
)

echo [SUCCESS] Docker 镜像构建成功: %IMAGE_NAME%
echo.

:: ==================== 清理旧容器 ====================
echo ========================================
echo Step 10: 部署容器
echo ========================================
echo.

echo [INFO] 检查并清理旧容器...

docker ps -a --format "{{.Names}}" | findstr /C:"%CONTAINER_NAME%" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [INFO] 发现旧容器，正在停止并删除...
    docker stop %CONTAINER_NAME% >nul 2>&1
    docker rm %CONTAINER_NAME% >nul 2>&1
    echo [SUCCESS] 旧容器已清理
)

:: ==================== 启动新容器 ====================
echo [INFO] 正在启动新容器...

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
    echo [ERROR] 容器启动失败！
    docker logs %CONTAINER_NAME%
    pause
    exit /b 1
)

echo [SUCCESS] 容器启动成功
echo.

:: ==================== 健康检查 ====================
echo ========================================
echo Step 11: 健康检查
echo ========================================
echo.

echo [INFO] 等待服务启动...
timeout /t 5 /nobreak >nul

echo [INFO] 检查服务状态...

set "RETRY_COUNT=0"
set "MAX_RETRIES=12"

:health_check_loop
if !RETRY_COUNT! GEQ !MAX_RETRIES! goto health_check_timeout

curl -s "http://localhost:!PORT!/health" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] 服务运行正常！
    goto health_check_done
)

set /a RETRY_COUNT+=1
echo [INFO] 等待服务就绪... (!RETRY_COUNT!/!MAX_RETRIES!)
timeout /t 3 /nobreak >nul
goto health_check_loop

:health_check_timeout
echo [WARNING] 服务可能仍在启动中，请稍后手动检查

:health_check_done
echo.

:: ==================== 部署完成 ====================
echo ========================================
echo 🎉 部署完成！
echo ========================================
echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║                    ✅ 部署成功！                           ║
echo ║                                                            ║
echo ╠════════════════════════════════════════════════════════════╣
echo ║                                                            ║
echo ║   🌐 访问地址: http://localhost:!PORT!                       ║
echo ║                                                            ║
echo ║   📂 安装目录: %INSTALL_DIR%
echo ║                                                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo 常用管理命令:
echo   查看日志:      docker logs %CONTAINER_NAME%
echo   实时日志:      docker logs -f %CONTAINER_NAME%
echo   停止服务:      docker stop %CONTAINER_NAME%
echo   启动服务:      docker start %CONTAINER_NAME%
echo   重启服务:      docker restart %CONTAINER_NAME%
echo   删除服务:      docker stop %CONTAINER_NAME% ^&^& docker rm %CONTAINER_NAME%
echo.
echo 感谢使用 Math OCR Tool！如有问题请访问 GitHub 提交 Issue。
echo.

pause
