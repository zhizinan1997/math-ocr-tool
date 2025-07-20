# 📐 数学公式图片转LaTeX工具 | Math Formula OCR Tool
<div align="center">
[![Docker Pulls](https://img.shields.io/docker/pulls/ryanzhi1997/math-ocr-tool.svg)](https://hub.docker.com/r/ryanzhi1997/math-ocr-tool)
[![GitHub Stars](https://img.shields.io/github/stars/ryanzhi1997/math-ocr-tool.svg)](https://github.com/ryanzhi1997/math-ocr-tool/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker Image Size](https://img.shields.io/docker/image-size/ryanzhi1997/math-ocr-tool)](https://hub.docker.com/r/ryanzhi1997/math-ocr-tool)
[English](#english) | [中文](#中文)
<img src="https://raw.githubusercontent.com/ryanzhi1997/math-ocr-tool/main/demo.gif" alt="Demo" width="600">
</div>
## 中文
### ✨ 功能特点
- 🤖 **AI智能识别** - 使用先进的AI模型精准识别数学公式
- 📸 **多种上传方式** - 支持拖拽上传、点击选择、粘贴截图(Ctrl+V)
- 🎯 **高识别准确率** - 支持复杂数学公式，包括分数、积分、矩阵等
- 📋 **一键复制** - 快速复制生成的LaTeX代码
- 🔍 **实时预览** - MathJax实时渲染LaTeX公式预览
- 📱 **响应式设计** - 完美支持PC和移动设备
- 🚀 **一键部署** - Docker容器化，部署简单快捷
- 🔧 **灵活配置** - 支持自定义OpenAI格式API服务商和模型


  ![网页捕获_20-7-2025_151448_103 242 3 76](https://github.com/user-attachments/assets/9f09f17d-6019-4e2a-b0d5-072f2a18c60e)


### 🚀 快速开始

#### 方式1：使用一键部署脚本（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/zhizinan1997/math-ocr-tool/main/deploy.sh | bash
```

#### 方式2：使用Docker命令

```bash
docker run -d \
    --name math-ocr-tool \
    -p 5000:5000 \
    -e OPENAI_API_KEY="你的API密钥" \
    -e OPENAI_API_BASE="API地址" \
    -e OPENAI_MODEL="模型名称" \
    --restart unless-stopped \
    zhizinan1997/math-ocr-tool:latest
```

#### 方式3：使用docker-compose

1. 创建 `docker-compose.yml` 文件：

```yaml
version: '3.8'

services:
  math-ocr-tool:
    image: zhizinan1997/math-ocr-tool:latest
    container_name: math-ocr-tool
    ports:
      - "5000:5000"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - OPENAI_API_BASE=${OPENAI_API_BASE:-https://api.openai.com/v1}
      - OPENAI_MODEL=${OPENAI_MODEL:-gpt-4o}
    restart: unless-stopped
```

2. 创建 `.env` 文件并设置环境变量：

```bash
OPENAI_API_KEY=你的API密钥
OPENAI_API_BASE=https://api.openai.com/v1
OPENAI_MODEL=gpt-4o
```

3. 启动服务：

```bash
docker-compose up -d
```

### ⚙️ 配置说明

#### 必填配置

| 环境变量 | 说明 | 示例 |
|---------|------|------|
| `OPENAI_API_KEY` | API密钥 | `sk-xxxxxxxxxxxxxxxx` |
| `OPENAI_API_BASE` | API基础地址 | `https://api.openai.com/v1` |
| `OPENAI_MODEL` | 模型名称 | `gpt-4o` |

#### 可选配置

| 环境变量 | 默认值 | 说明 |
|---------|--------|------|
| `MODEL_MAX_TOKENS` | `1000` | 最大输出tokens |
| `MODEL_TEMPERATURE` | `0.1` | 模型温度(0-1) |
| `IMAGE_MAX_SIZE` | `1024` | 图片最大尺寸 |
| `IMAGE_QUALITY` | `85` | 图片压缩质量(1-100) |
| `LOG_LEVEL` | `INFO` | 日志级别 |
| `MAX_CONTENT_LENGTH` | `16777216` | 最大上传文件大小(字节) |

#### 常用API配置示例







### 📖 使用指南

1. 访问 `http://localhost:5000`
2. 上传数学公式图片：
   - 🖱️ 点击上传区域选择文件
   - 🎯 拖拽图片到上传区域
   - 📋 直接粘贴截图 (Ctrl+V)
3. 点击"开始转换"按钮
4. 等待AI识别完成
5. 复制生成的LaTeX代码
6. 在Word/LaTeX编辑器中使用：
   - Word: 按 `Alt + =` 打开公式编辑器，选择LaTeX输入
   - LaTeX: 直接粘贴使用

### 🛠️ 本地开发

1. 克隆仓库：
```bash
git clone https://github.com/zhizinan1997/math-ocr-tool.git
cd math-ocr-tool
```

2. 创建虚拟环境：
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# 或
venv\Scripts\activate  # Windows
```

3. 安装依赖：
```bash
pip install -r requirements.txt
```

4. 设置环境变量：
```bash
export OPENAI_API_KEY="你的API密钥"
export OPENAI_API_BASE="https://api.openai.com/v1"
export OPENAI_MODEL="gpt-4o"
```

5. 运行应用：
```bash
python app.py
```

### 📊 API使用统计

应用会自动统计转换次数，可以通过以下方式查看：

- 网页右上角显示总转换次数
- API端点: `GET /stats`
- 健康检查: `GET /health`

### 🔧 故障排除







### 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

### 📄 开源协议

本项目采用 MIT 协议 - 查看 [LICENSE](LICENSE) 文件了解详情

### 🙏 致谢

- [OpenAI](https://openai.com/) - 提供强大的AI识别能力
- [MathJax](https://www.mathjax.org/) - LaTeX公式渲染
- [Flask](https://flask.palletsprojects.com/) - Web框架
- [Docker](https://www.docker.com/) - 容器化部署

---

## English

### ✨ Features

- 🤖 **AI-Powered Recognition** - Advanced AI models for accurate math formula recognition
- 📸 **Multiple Upload Methods** - Drag & drop, click to select, or paste screenshots (Ctrl+V)
- 🎯 **High Accuracy** - Supports complex formulas including fractions, integrals, matrices
- 📋 **One-Click Copy** - Quickly copy generated LaTeX code
- 🔍 **Live Preview** - Real-time LaTeX formula preview with MathJax
- 📱 **Responsive Design** - Perfect support for both PC and mobile devices
- 🚀 **Easy Deployment** - Dockerized for simple deployment
- 🔧 **Flexible Configuration** - Support custom API providers and models

### 🚀 Quick Start

#### Option 1: One-Click Deploy Script (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/zhizinan1997/math-ocr-tool/main/deploy.sh | bash
```

#### Option 2: Docker Command

```bash
docker run -d \
    --name math-ocr-tool \
    -p 5000:5000 \
    -e OPENAI_API_KEY="your-api-key" \
    -e OPENAI_API_BASE="api-base-url" \
    -e OPENAI_MODEL="model-name" \
    --restart unless-stopped \
    zhizinan1997/math-ocr-tool:latest
```

#### Option 3: Docker Compose

1. Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  math-ocr-tool:
    image: zhizinan1997/math-ocr-tool:latest
    container_name: math-ocr-tool
    ports:
      - "5000:5000"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - OPENAI_API_BASE=${OPENAI_API_BASE:-https://api.openai.com/v1}
      - OPENAI_MODEL=${OPENAI_MODEL:-gpt-4o}
    restart: unless-stopped
```

2. Create `.env` file:

```bash
OPENAI_API_KEY=your-api-key
OPENAI_API_BASE=https://api.openai.com/v1
OPENAI_MODEL=gpt-4o
```

3. Start service:

```bash
docker-compose up -d
```

### ⚙️ Configuration

#### Required Settings

| Variable | Description | Example |
|----------|-------------|---------|
| `OPENAI_API_KEY` | API Key | `sk-xxxxxxxxxxxxxxxx` |
| `OPENAI_API_BASE` | API Base URL | `https://api.openai.com/v1` |
| `OPENAI_MODEL` | Model Name | `gpt-4o` |

#### Optional Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `MODEL_MAX_TOKENS` | `1000` | Maximum output tokens |
| `MODEL_TEMPERATURE` | `0.1` | Model temperature (0-1) |
| `IMAGE_MAX_SIZE` | `1024` | Maximum image size |
| `IMAGE_QUALITY` | `85` | Image compression quality (1-100) |
| `LOG_LEVEL` | `INFO` | Logging level |
| `MAX_CONTENT_LENGTH` | `16777216` | Maximum upload size (bytes) |

### 📖 Usage Guide

1. Visit `http://localhost:5000`
2. Upload math formula image:
   - 🖱️ Click upload area to select file
   - 🎯 Drag and drop image
   - 📋 Paste screenshot (Ctrl+V)
3. Click "Start Conversion" button
4. Wait for AI recognition
5. Copy generated LaTeX code
6. Use in Word/LaTeX editor:
   - Word: Press `Alt + =` to open equation editor, select LaTeX input
   - LaTeX: Paste directly

### 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### 🙏 Acknowledgments

- [OpenAI](https://openai.com/) - AI recognition capabilities
- [MathJax](https://www.mathjax.org/) - LaTeX formula rendering
- [Flask](https://flask.palletsprojects.com/) - Web framework
- [Docker](https://www.docker.com/) - Containerization

---

<div align="center">
Made with ❤️ by <a href="https://github.com/zhizinan1997">zhizinan1997</a>
</div>
```

这个 README.md 文件包含了：

1. **双语支持** - 中英文说明
2. **徽章展示** - Docker下载量、GitHub星标等
3. **功能特点** - 清晰列出所有功能
4. **多种部署方式** - 适合不同用户需求
5. **详细配置说明** - 包括必填和可选配置
6. **使用指南** - 步骤清晰
7. **故障排除** - 常见问题解决
8. **本地开发指南** - 方便贡献者
9. **贡献指南** - 鼓励社区参与
10. **致谢部分** - 感谢使用的开源项目

你可能还需要：
1. 上传一个 demo.gif 演示动画到仓库
2. 上传一些截图到 screenshots 文件夹
3. 根据实际情况调整 Docker Hub 的用户名和仓库名

有什么需要调整的地方吗？

—————————请注意—————————
⭐️Ryan AI的内容未必全部正确，请务必仔细核实⭐️
https://chat.zhizinan.top
—————————请注意—————————
