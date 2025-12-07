#!/bin/bash
# ============================================================
# Math OCR Tool - 一键部署脚本 (Linux/Mac)
# 功能：从GitHub克隆项目，配置环境，构建并部署Docker容器
# 作者：Ryan / zhizinan1997
# 仓库：https://github.com/zhizinan1997/math-ocr-tool.git
# ============================================================

set -e  # 遇到错误立即退出

# ==================== 颜色定义 ====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ==================== 日志函数 ====================
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

# ==================== 欢迎信息 ====================
clear
echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║        📐 Math OCR Tool - 一键部署脚本                     ║"
echo "║        数学公式图片转LaTeX工具                              ║"
echo "║                                                            ║"
echo "║        GitHub: zhizinan1997/math-ocr-tool                  ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ==================== 环境检查 ====================
log_step "Step 1: 环境检查"

# 检查 Git 是否安装
log_info "检查 Git 是否已安装..."
if ! command -v git &> /dev/null; then
    log_error "Git 未安装！请先安装 Git"
    echo "  - Ubuntu/Debian: sudo apt install git"
    echo "  - CentOS/RHEL: sudo yum install git"
    echo "  - macOS: xcode-select --install"
    exit 1
fi
log_success "Git 已安装: $(git --version)"

# 检查 Docker 是否安装
log_info "检查 Docker 是否已安装..."
if ! command -v docker &> /dev/null; then
    log_error "Docker 未安装！请先安装 Docker"
    echo "  安装指南: https://docs.docker.com/get-docker/"
    exit 1
fi
log_success "Docker 已安装: $(docker --version)"

# 检查 Docker 服务是否运行
log_info "检查 Docker 服务状态..."
if ! docker info &> /dev/null; then
    log_error "Docker 服务未运行！请启动 Docker 服务"
    echo "  - Linux: sudo systemctl start docker"
    echo "  - macOS: 启动 Docker Desktop 应用"
    exit 1
fi
log_success "Docker 服务正在运行"

# ==================== 设置工作目录 ====================
log_step "Step 2: 设置工作目录"

INSTALL_DIR="${HOME}/math-ocr-tool"
log_info "默认安装目录: $INSTALL_DIR"
read -p "是否使用此目录? (y/n，直接回车使用默认): " USE_DEFAULT

if [[ "$USE_DEFAULT" == "n" || "$USE_DEFAULT" == "N" ]]; then
    read -p "请输入安装目录: " CUSTOM_DIR
    if [[ -n "$CUSTOM_DIR" ]]; then
        INSTALL_DIR="$CUSTOM_DIR"
    fi
fi

log_info "安装目录: $INSTALL_DIR"

# ==================== 克隆项目 ====================
log_step "Step 3: 克隆项目代码"

REPO_URL="https://github.com/zhizinan1997/math-ocr-tool.git"

if [[ -d "$INSTALL_DIR" ]]; then
    log_warning "目录已存在: $INSTALL_DIR"
    read -p "是否删除并重新克隆? (y/n): " RECLONE
    if [[ "$RECLONE" == "y" || "$RECLONE" == "Y" ]]; then
        log_info "删除现有目录..."
        rm -rf "$INSTALL_DIR"
    else
        log_info "使用现有目录，拉取最新代码..."
        cd "$INSTALL_DIR"
        git pull origin main || git pull origin master
    fi
fi

if [[ ! -d "$INSTALL_DIR" ]]; then
    log_info "正在从 GitHub 克隆项目..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    log_success "项目克隆完成"
fi

cd "$INSTALL_DIR"
log_success "当前工作目录: $(pwd)"

# ==================== 配置数据库 ====================
log_step "Step 4: 配置数据库连接"

echo -e "${YELLOW}请输入 PostgreSQL 数据库连接信息:${NC}"
echo ""

read -p "数据库主机地址 (默认: localhost): " DB_HOST
DB_HOST=${DB_HOST:-localhost}

read -p "数据库端口 (默认: 5432): " DB_PORT
DB_PORT=${DB_PORT:-5432}

read -p "数据库名称 (默认: postgres): " DB_NAME
DB_NAME=${DB_NAME:-postgres}

read -p "数据库用户名 (默认: postgres): " DB_USER
DB_USER=${DB_USER:-postgres}

read -sp "数据库密码 (必填): " DB_PASSWORD
echo ""

if [[ -z "$DB_PASSWORD" ]]; then
    log_error "数据库密码不能为空！"
    exit 1
fi

log_success "数据库配置完成"

# ==================== 配置 AI API ====================
log_step "Step 5: 配置 AI API"

echo -e "${YELLOW}请输入 AI API 配置信息:${NC}"
echo -e "${BLUE}提示: 支持 OpenAI 及兼容接口 (如 Azure、第三方代理等)${NC}"
echo ""

read -p "API 地址 (默认: https://api.openai.com/v1): " OPENAI_API_BASE
OPENAI_API_BASE=${OPENAI_API_BASE:-https://api.openai.com/v1}

read -sp "API 密钥 (必填): " OPENAI_API_KEY
echo ""

if [[ -z "$OPENAI_API_KEY" ]]; then
    log_error "API 密钥不能为空！"
    exit 1
fi

read -p "模型名称 (默认: gpt-4o): " OPENAI_MODEL
OPENAI_MODEL=${OPENAI_MODEL:-gpt-4o}

log_success "AI API 配置完成"

# ==================== 端口配置 ====================
log_step "Step 6: 配置服务端口"

read -p "服务端口 (默认: 5000): " PORT
PORT=${PORT:-5000}

log_info "服务将运行在端口: $PORT"

# ==================== 生成环境变量文件 ====================
log_step "Step 7: 生成配置文件"

log_info "正在生成 .env 文件..."

cat > .env << EOF
# Math OCR Tool 环境配置文件
# 自动生成于: $(date)

# 数据库配置
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD

# AI API 配置
OPENAI_API_KEY=$OPENAI_API_KEY
OPENAI_API_BASE=$OPENAI_API_BASE
OPENAI_MODEL=$OPENAI_MODEL

# 应用配置
PORT=$PORT
LOG_LEVEL=INFO
SECRET_KEY=$(openssl rand -hex 32 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
EOF

log_success ".env 文件已生成"

# ==================== 配置预览 ====================
log_step "Step 8: 配置预览"

echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│              配置信息预览                        │${NC}"
echo -e "${CYAN}├─────────────────────────────────────────────────┤${NC}"
echo -e "│ 数据库主机:    ${GREEN}$DB_HOST${NC}"
echo -e "│ 数据库端口:    ${GREEN}$DB_PORT${NC}"
echo -e "│ 数据库名称:    ${GREEN}$DB_NAME${NC}"
echo -e "│ 数据库用户:    ${GREEN}$DB_USER${NC}"
echo -e "│ 数据库密码:    ${GREEN}********${NC}"
echo -e "│ API 地址:      ${GREEN}$OPENAI_API_BASE${NC}"
echo -e "│ API 密钥:      ${GREEN}${OPENAI_API_KEY:0:8}...${NC}"
echo -e "│ 模型名称:      ${GREEN}$OPENAI_MODEL${NC}"
echo -e "│ 服务端口:      ${GREEN}$PORT${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"

echo ""
read -p "确认以上配置并开始部署? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    log_warning "部署已取消"
    exit 0
fi

# ==================== 构建 Docker 镜像 ====================
log_step "Step 9: 构建 Docker 镜像"

CONTAINER_NAME="math-ocr-tool"
IMAGE_NAME="math-ocr-tool:latest"

log_info "正在构建 Docker 镜像..."
log_info "这可能需要几分钟时间，请耐心等待..."

docker build -t "$IMAGE_NAME" .

if [[ $? -eq 0 ]]; then
    log_success "Docker 镜像构建成功: $IMAGE_NAME"
else
    log_error "Docker 镜像构建失败！"
    exit 1
fi

# ==================== 清理旧容器 ====================
log_step "Step 10: 部署容器"

log_info "检查并清理旧容器..."

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log_info "发现旧容器，正在停止并删除..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
    log_success "旧容器已清理"
fi

# ==================== 启动新容器 ====================
log_info "正在启动新容器..."

docker run -d \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    -p "${PORT}:5000" \
    -e DB_HOST="$DB_HOST" \
    -e DB_PORT="$DB_PORT" \
    -e DB_NAME="$DB_NAME" \
    -e DB_USER="$DB_USER" \
    -e DB_PASSWORD="$DB_PASSWORD" \
    -e OPENAI_API_KEY="$OPENAI_API_KEY" \
    -e OPENAI_API_BASE="$OPENAI_API_BASE" \
    -e OPENAI_MODEL="$OPENAI_MODEL" \
    -e LOG_LEVEL="INFO" \
    -v "${INSTALL_DIR}/uploads:/app/uploads" \
    "$IMAGE_NAME"

if [[ $? -eq 0 ]]; then
    log_success "容器启动成功"
else
    log_error "容器启动失败！"
    docker logs "$CONTAINER_NAME"
    exit 1
fi

# ==================== 健康检查 ====================
log_step "Step 11: 健康检查"

log_info "等待服务启动..."
sleep 5

log_info "检查服务状态..."

MAX_RETRIES=12
RETRY_COUNT=0

while [[ $RETRY_COUNT -lt $MAX_RETRIES ]]; do
    if curl -s "http://localhost:${PORT}/health" > /dev/null 2>&1; then
        log_success "服务运行正常！"
        break
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    log_info "等待服务就绪... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 3
done

if [[ $RETRY_COUNT -eq $MAX_RETRIES ]]; then
    log_warning "服务可能仍在启动中，请稍后手动检查"
fi

# ==================== 部署完成 ====================
log_step "🎉 部署完成！"

echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║                    ✅ 部署成功！                           ║"
echo "║                                                            ║"
echo "╠════════════════════════════════════════════════════════════╣"
echo "║                                                            ║"
echo "║   🌐 访问地址: http://localhost:${PORT}                      ║"
echo "║                                                            ║"
echo "║   📂 安装目录: $INSTALL_DIR"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${CYAN}常用管理命令:${NC}"
echo "  查看日志:      docker logs $CONTAINER_NAME"
echo "  实时日志:      docker logs -f $CONTAINER_NAME"
echo "  停止服务:      docker stop $CONTAINER_NAME"
echo "  启动服务:      docker start $CONTAINER_NAME"
echo "  重启服务:      docker restart $CONTAINER_NAME"
echo "  删除服务:      docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME"
echo ""
echo -e "${GREEN}感谢使用 Math OCR Tool！如有问题请访问 GitHub 提交 Issue。${NC}"
