#!/bin/bash

# 设置变量
IMAGE_NAME="math-latex-converter"
VERSION="1.0.0"
REGISTRY="your-registry" # 可以改成你的Docker Hub用户名或私有仓库

echo "🔨 开始构建Docker镜像..."

# 构建镜像
docker build -t ${IMAGE_NAME}:${VERSION} .
docker build -t ${IMAGE_NAME}:latest .

echo "✅ 镜像构建完成!"

# 可选：推送到仓库
read -p "是否要推送到Docker仓库? (y/n): " push_choice
if [ "$push_choice" = "y" ]; then
    echo "📤 推送镜像到仓库..."
    docker tag ${IMAGE_NAME}:${VERSION} ${REGISTRY}/${IMAGE_NAME}:${VERSION}
    docker tag ${IMAGE_NAME}:latest ${REGISTRY}/${IMAGE_NAME}:latest
    
    docker push ${REGISTRY}/${IMAGE_NAME}:${VERSION}
    docker push ${REGISTRY}/${IMAGE_NAME}:latest
    
    echo "✅ 镜像推送完成!"
    echo "🚀 其他人可以使用以下命令部署:"
    echo "docker run -d -p 5000:5000 -e OPENAI_API_KEY=your_key ${REGISTRY}/${IMAGE_NAME}:latest"
else
    echo "🚀 本地使用命令:"
    echo "docker run -d -p 5000:5000 -e OPENAI_API_KEY=your_key ${IMAGE_NAME}:latest"
fi