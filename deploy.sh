#!/bin/bash
# 数学公式转LaTeX - 一键部署脚本
echo "🚀 数学公式图片转LaTeX工具 - 一键部署"
echo "================================================"
# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装，请先安装Docker"
    echo "安装方法: https://docs.docker.com/get-docker/"
    exit 1
fi
# 设置默认值
IMAGE_NAME="ryanzhi1997/math-ocr-tool:latest" # 已修改
CONTAINER_NAME="math-latex-converter" # 容器名可以保持不变，但如果你想与镜像名一致，也可以改为 math-ocr-tool
DEFAULT_PORT="5000"
DEFAULT_API_BASE="https://api.openai.com/v1"
DEFAULT_MODEL="gpt-4o"
DEFAULT_MAX_TOKENS="1000"
DEFAULT_TEMPERATURE="0.1"
DEFAULT_IMAGE_MAX_SIZE="1024"
DEFAULT_IMAGE_QUALITY="85"
echo ""
echo "📝 请配置API参数："
# 获取API密钥
if [ -z "$OPENAI_API_KEY" ]; then
    read -p "🔑 请输入API密钥 (必填): " API_KEY
    if [ -z "$API_KEY" ]; then
        echo "❌ API密钥不能为空"
        exit 1
    fi
else
    API_KEY=$OPENAI_API_KEY
    echo "🔑 使用环境变量中的API密钥: ${API_KEY:0:10}..."
fi
# 获取API基础地址
read -p "🌐 请输入API基础地址 (默认: $DEFAULT_API_BASE): " API_BASE
if [ -z "$API_BASE" ]; then
    API_BASE=$DEFAULT_API_BASE
fi
# 获取模型名称
echo ""
echo "📋 常用模型："
echo "   - gpt-4o (OpenAI)"
echo "   - gpt-4-turbo (OpenAI)"
echo "   - gpt-4-vision-preview (OpenAI)"
echo "   - claude-3-sonnet (如果使用第三方代理)"
read -p "🤖 请输入模型名称 (默认: $DEFAULT_MODEL): " MODEL
if [ -z "$MODEL" ]; then
    MODEL=$DEFAULT_MODEL
fi
# 获取端口
read -p "🔌 请输入服务端口 (默认: $DEFAULT_PORT): " PORT
if [ -z "$PORT" ]; then
    PORT=$DEFAULT_PORT
fi
echo ""
echo "⚙️ 高级配置 (可直接按回车使用默认值)："
# 获取最大tokens
read -p "📝 最大输出tokens (默认: $DEFAULT_MAX_TOKENS): " MAX_TOKENS
if [ -z "$MAX_TOKENS" ]; then
    MAX_TOKENS=$DEFAULT_MAX_TOKENS
fi
# 获取温度参数
read -p "🌡️ 模型温度 0.0-1.0 (默认: $DEFAULT_TEMPERATURE): " TEMPERATURE
if [ -z "$TEMPERATURE" ]; then
    TEMPERATURE=$DEFAULT_TEMPERATURE
fi
# 获取图片最大尺寸
read -p "🖼️ 图片最大尺寸 (默认: $DEFAULT_IMAGE_MAX_SIZE): " IMAGE_MAX_SIZE
if [ -z "$IMAGE_MAX_SIZE" ]; then
    IMAGE_MAX_SIZE=$DEFAULT_IMAGE_MAX_SIZE
fi
# 获取图片质量
read -p "📷 图片质量 1-100 (默认: $DEFAULT_IMAGE_QUALITY): " IMAGE_QUALITY
if [ -z "$IMAGE_QUALITY" ]; then
    IMAGE_QUALITY=$DEFAULT_IMAGE_QUALITY
fi
# 确认配置
echo ""
echo "📋 配置总览："
echo "   API密钥: ${API_KEY:0:10}...${API_KEY: -4}"
echo "   API地址: $API_BASE"
echo "   模型: $MODEL"
echo "   端口: $PORT"
echo "   最大tokens: $MAX_TOKENS"
echo "   温度: $TEMPERATURE"
echo "   图片尺寸: $IMAGE_MAX_SIZE"
echo "   图片质量: $IMAGE_QUALITY"
echo ""
read -p "确认部署? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "❌ 部署已取消"
    exit 0
fi
# 停止并删除现有容器
echo ""
echo "🧹 清理现有容器..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true
# 检查镜像是否存在，如果不存在则提示用户
if ! docker images | grep -q "ryanzhi1997/math-ocr-tool"; then # 已修改
    echo ""
    echo "⚠️ 本地没有找到镜像，请选择："
    echo "1. 使用预构建镜像 (推荐)"
    echo "2. 从源码构建" # 如果 ryanzhi1997/math-ocr-tool 没有 Dockerfile，则此选项可能无效
    read -p "请选择 (1/2): " BUILD_CHOICE
    if [ "$BUILD_CHOICE" = "2" ]; then
        echo "📦 从源码构建镜像..."
        if [ ! -f "Dockerfile" ]; then
            echo "❌ 未找到Dockerfile，请确保在项目根目录运行此脚本"
            exit 1
        fi
        docker build -t ryanzhi1997/math-ocr-tool:latest . # 已修改
        if [ $? -ne 0 ]; then
            echo "❌ 镜像构建失败"
            exit 1
        fi
    else
        echo "📥 拉取预构建镜像..."
        docker pull ryanzhi1997/math-ocr-tool:latest # 已修改
        if [ $? -ne 0 ]; then
            echo "❌ 镜像拉取失败，请检查网络连接或使用源码构建"
            exit 1
        fi
        IMAGE_NAME="ryanzhi1997/math-ocr-tool:latest" # 已修改
    fi
fi
# 运行容器
echo ""
echo "🚀 启动服务..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:5000 \
    -e OPENAI_API_KEY="$API_KEY" \
    -e OPENAI_API_BASE="$API_BASE" \
    -e OPENAI_MODEL="$MODEL" \
    -e MODEL_MAX_TOKENS="$MAX_TOKENS" \
    -e MODEL_TEMPERATURE="$TEMPERATURE" \
    -e IMAGE_MAX_SIZE="$IMAGE_MAX_SIZE" \
    -e IMAGE_QUALITY="$IMAGE_QUALITY" \
    -e LOG_LEVEL="INFO" \
    --restart unless-stopped \
    $IMAGE_NAME
# 检查容器状态
echo "⏳ 等待服务启动..."
sleep 5
if docker ps | grep -q $CONTAINER_NAME; then
    echo ""
    echo "✅ 部署成功!"
    echo "🌐 访问地址: http://localhost:$PORT"
    echo "📋 容器名称: $CONTAINER_NAME"
    # 测试服务是否正常
    echo "🔍 测试服务状态..."
    for i in {1..10}; do
        if curl -s "http://localhost:$PORT/health" > /dev/null 2>&1; then # 假设 /health 是健康检查端点
            echo "✅ 服务运行正常!"
            break
        fi
        if [ $i -eq 10 ]; then
            echo "⚠️ 服务可能还在启动中，请稍后访问"
        fi
        sleep 2
    done
    echo ""
    echo "📝 管理命令:"
    echo "  查看日志: docker logs $CONTAINER_NAME"
    echo "  查看实时日志: docker logs -f $CONTAINER_NAME"
    echo "  停止服务: docker stop $CONTAINER_NAME"
    echo "  重启服务: docker restart $CONTAINER_NAME"
    echo "  删除服务: docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME"
    echo ""
    echo "🎉 享受使用吧！如有问题请查看日志或联系开发者。"
else
    echo ""
    echo "❌ 部署失败，错误日志:"
    docker logs $CONTAINER_NAME
    echo ""
    echo "🔧 故障排除建议:"
    echo "  1. 检查API密钥是否有效"
    echo "  2. 检查端口 $PORT 是否被占用: netstat -tlnp | grep :$PORT"
    echo "  3. 检查Docker是否有足够权限"
    echo "  4. 查看完整日志: docker logs $CONTAINER_NAME"
fi
