# 📐 Math OCR Tool | 数学公式图片转LaTeX工具

<div align="center">

[![GHCR](https://img.shields.io/badge/GHCR-ghcr.io%2Fzhizinan1997%2Fmath--ocr--tool-blue)](https://github.com/zhizinan1997/math-ocr-tool/pkgs/container/math-ocr-tool)
[![GitHub Stars](https://img.shields.io/github/stars/zhizinan1997/math-ocr-tool.svg)](https://github.com/zhizinan1997/math-ocr-tool/stargazers)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**AI驱动的数学公式识别与LaTeX代码生成工具**

[快速开始](#-快速开始) • [部署指南](#-部署指南) • [配置说明](#️-配置说明) • [使用教程](#-使用教程) • [English](#english)

</div>

---

## ✨ 功能特点

| 功能 | 描述 |
|------|------|
| 🤖 **AI智能识别** | 基于先进AI模型，精准识别手写及印刷数学公式 |
| 📸 **多种上传方式** | 拖拽上传、点击选择、粘贴截图 (Ctrl+V) |
| 🎯 **高识别准确率** | 支持复杂公式：分数、积分、矩阵、求和等 |
| 🔍 **实时预览** | MathJax 实时渲染 LaTeX 公式预览 |
| 📋 **一键复制** | 快速复制生成的 LaTeX 代码到剪贴板 |
| 🔐 **用户认证** | 双表验证（auth + user），支持账户激活状态管理 |
| 👤 **角色管理** | 支持 admin、user、pending 三种角色状态 |
| 📝 **历史记录** | 自动保存用户上传的图片和AI识别结果，便于管理 |
| 🐳 **Docker部署** | 一键脚本，快速部署到任何服务器 |

---

## 🚀 快速开始

### 方式一：一键部署脚本（推荐）

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/zhizinan1997/math-ocr-tool/main/quick_deploy.sh -o quick_deploy.sh && chmod +x quick_deploy.sh && ./quick_deploy.sh
```

**Windows (PowerShell):**
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/zhizinan1997/math-ocr-tool/main/quick_deploy.bat" -OutFile "quick_deploy.bat"; .\quick_deploy.bat
```

脚本将引导您完成：
1. 从 GitHub 克隆项目
2. 配置数据库连接信息
3. 配置 AI API 密钥
4. 自动构建 Docker 镜像
5. 部署并启动服务

### 方式二：Docker 命令

```bash
docker run -d \
    --name math-ocr-tool \
    -p 5000:5000 \
    -e DB_HOST="数据库主机" \
    -e DB_PORT="5432" \
    -e DB_NAME="postgres" \
    -e DB_USER="postgres" \
    -e DB_PASSWORD="数据库密码" \
    -e OPENAI_API_KEY="your-api-key" \
    -e OPENAI_API_BASE="https://api.openai.com/v1" \
    -e OPENAI_MODEL="gpt-4o" \
    --restart unless-stopped \
    ghcr.io/zhizinan1997/math-ocr-tool:latest
```

### 方式三：Docker Compose

1. 创建 `docker-compose.yml`：

```yaml
version: '3.8'

services:
  math-ocr-tool:
    image: ghcr.io/zhizinan1997/math-ocr-tool:latest
    container_name: math-ocr-tool
    ports:
      - "5000:5000"
    environment:
      - DB_HOST=${DB_HOST}
      - DB_PORT=${DB_PORT:-5432}
      - DB_NAME=${DB_NAME:-postgres}
      - DB_USER=${DB_USER:-postgres}
      - DB_PASSWORD=${DB_PASSWORD}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - OPENAI_API_BASE=${OPENAI_API_BASE:-https://api.openai.com/v1}
      - OPENAI_MODEL=${OPENAI_MODEL:-gpt-4o}
    restart: unless-stopped
```

2. 创建 `.env` 文件：

```env
DB_HOST=your-database-host
DB_PASSWORD=your-database-password
OPENAI_API_KEY=your-api-key
OPENAI_API_BASE=https://api.openai.com/v1
OPENAI_MODEL=gpt-4o
```

3. 启动：

```bash
docker-compose up -d
```

---

## 📖 部署指南

### 前置要求

- Docker 20.0+
- PostgreSQL 12+ (用于用户认证)
- 支持图像识别的 AI API (OpenAI GPT-4o 或兼容接口)

### 数据库准备

本工具使用两个数据表进行用户认证和权限管理：

#### 1. `auth` 表 - 存储登录凭证

```sql
CREATE TABLE auth (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建用户 (密码建议使用 bcrypt 哈希)
INSERT INTO auth (email, password) VALUES ('admin@example.com', 'your-hashed-password');
```

#### 2. `user` 表 - 存储用户角色和激活状态

```sql
CREATE TABLE "user" (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 设置用户角色
-- role 可选值: 'admin', 'user', 'pending'
-- 'pending' = 待审核（无法登录）
-- 'user' = 普通用户（可登录）
-- 'admin' = 管理员（可登录）
INSERT INTO "user" (email, role) VALUES ('admin@example.com', 'admin');
```

### 用户认证流程

登录验证按以下顺序进行：

1. ❌ 邮箱在 `auth` 表不存在 → "用户不存在"
2. ❌ 密码错误 → "密码错误"
3. ❌ 邮箱在 `user` 表不存在 → "用户信息不完整，请联系管理员"
4. ❌ `user` 表中 role = "pending" → "账户未激活，请等待管理员审核"
5. ✅ role = "admin" 或 "user" → 登录成功

### 用户管理

管理员可以通过修改 `user` 表的 `role` 列来管理用户权限：

```sql
-- 激活用户
UPDATE "user" SET role = 'user' WHERE email = 'newuser@example.com';

-- 禁用用户（设为待审核状态，会立即踢出已登录用户）
UPDATE "user" SET role = 'pending' WHERE email = 'banned@example.com';

-- 删除用户（从两个表中删除，会立即踢出已登录用户）
DELETE FROM auth WHERE email = 'deleted@example.com';
DELETE FROM "user" WHERE email = 'deleted@example.com';
```

> ⚠️ **注意**: 当用户被删除或设为 pending 状态时，该用户会在下次访问任何页面时被立即踢出登录。

### 从源码构建

```bash
# 克隆仓库
git clone https://github.com/zhizinan1997/math-ocr-tool.git
cd math-ocr-tool

# 构建镜像
docker build -t math-ocr-tool:latest .

# 运行容器
docker run -d --name math-ocr-tool -p 5000:5000 \
    -e DB_HOST="..." \
    -e DB_PASSWORD="..." \
    -e OPENAI_API_KEY="..." \
    math-ocr-tool:latest
```

---

## ⚙️ 配置说明

### 必填环境变量

| 变量名 | 描述 | 示例 |
|--------|------|------|
| `DB_HOST` | PostgreSQL 数据库主机 | `localhost` |
| `DB_PASSWORD` | 数据库密码 | `your-password` |
| `OPENAI_API_KEY` | AI API 密钥 | `sk-xxxxx` |

### 可选环境变量

| 变量名 | 默认值 | 描述 |
|--------|--------|------|
| `DB_PORT` | `5432` | 数据库端口 |
| `DB_NAME` | `postgres` | 数据库名称 |
| `DB_USER` | `postgres` | 数据库用户名 |
| `OPENAI_API_BASE` | `https://api.openai.com/v1` | API 基础地址 |
| `OPENAI_MODEL` | `gpt-4o` | 使用的模型名称 |
| `MODEL_MAX_TOKENS` | `1000` | 最大输出 tokens |
| `MODEL_TEMPERATURE` | `0.1` | 模型温度 (0-1) |
| `IMAGE_MAX_SIZE` | `1024` | 图片最大尺寸 (px) |
| `IMAGE_QUALITY` | `85` | 图片压缩质量 (1-100) |
| `USER_HISTORY_FOLDER` | `user_history` | 用户历史记录保存目录 |
| `LOG_LEVEL` | `INFO` | 日志级别 |

### 支持的 AI 服务

本工具支持任何兼容 OpenAI API 格式的服务：

| 服务商 | API Base URL |
|--------|--------------|
| OpenAI | `https://api.openai.com/v1` |
| Azure OpenAI | `https://your-resource.openai.azure.com/openai/deployments/your-deployment` |
| 第三方代理 | 按服务商提供的地址配置 |

---

## 📝 使用教程

1. 访问 `http://localhost:5000`
2. 使用邮箱和密码登录
3. 上传数学公式图片：
   - 🖱️ 点击上传区域选择文件
   - 📂 拖拽图片到上传区域
   - 📋 直接粘贴截图 (Ctrl+V)
4. 点击「开始转换」
5. 等待 AI 识别完成
6. 复制生成的 LaTeX 代码

### 在 Word 中使用

1. 按 `Alt + =` 打开公式编辑器
2. 点击顶部「LaTeX」按钮切换模式
3. 粘贴 LaTeX 代码
4. 按回车完成输入

---

## � 用户历史记录

系统会自动保存每个用户的上传记录，方便管理员审计和管理。

### 目录结构

```
user_history/
├── john_at_example_com/
│   ├── 20251208_143000_123456/
│   │   ├── image.png          # 用户上传的原始图片
│   │   ├── result.txt         # AI返回的LaTeX代码
│   │   └── metadata.json      # 元数据（时间、状态等）
│   └── 20251208_144530_789012/
│       └── ...
└── jane_at_test_com/
    └── ...
```

### 元数据示例 (metadata.json)

```json
{
  "email": "john@example.com",
  "timestamp": "2025-12-08T14:30:00.123456",
  "success": true,
  "latex_length": 156
}
```

---

## �🔧 故障排除

| 问题 | 解决方案 |
|------|----------|
| 容器启动失败 | 检查环境变量是否正确配置 |
| 数据库连接失败 | 确认数据库地址、端口、密码正确 |
| API 调用失败 | 检查 API 密钥是否有效，模型是否支持图像 |
| "用户不存在" | 确认邮箱在 `auth` 表中存在 |
| "密码错误" | 确认密码正确（支持明文或 bcrypt 哈希） |
| "账户未激活" | 管理员需在 `user` 表中将 role 改为 'user' 或 'admin' |
| "用户信息不完整" | 需要在 `user` 表中添加对应邮箱的记录 |
| 被踢出登录 | 账户可能已被删除或设为 pending 状态 |

查看容器日志：
```bash
docker logs math-ocr-tool
```

---

## 📊 API 接口

| 接口 | 方法 | 描述 | 认证 |
|------|------|------|------|
| `/health` | GET | 健康检查 | 否 |
| `/stats` | GET | 获取转换统计 | 否 |
| `/login` | GET/POST | 用户登录 | 否 |
| `/logout` | GET | 用户登出 | 否 |
| `/` | GET | 主页 | 需要登录 |
| `/upload` | POST | 上传图片文件 | 需要登录 |
| `/upload_base64` | POST | 上传 Base64 图片 | 需要登录 |
| `/download_word` | POST | 下载 Word 文档 | 需要登录 |

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建分支：`git checkout -b feature/your-feature`
3. 提交更改：`git commit -m 'Add your feature'`
4. 推送分支：`git push origin feature/your-feature`
5. 提交 Pull Request

---

## 📄 开源协议

本项目采用 [MIT License](LICENSE) 开源协议。

---

## English

### Quick Start

**One-Click Deploy (Linux/macOS):**
```bash
curl -fsSL https://raw.githubusercontent.com/zhizinan1997/math-ocr-tool/main/quick_deploy.sh -o quick_deploy.sh && chmod +x quick_deploy.sh && ./quick_deploy.sh
```

**Docker:**
```bash
docker run -d --name math-ocr-tool -p 5000:5000 \
    -e DB_HOST="your-db-host" \
    -e DB_PASSWORD="your-db-password" \
    -e OPENAI_API_KEY="your-api-key" \
    ghcr.io/zhizinan1997/math-ocr-tool:latest
```

### Features

- 🤖 AI-powered math formula recognition
- 📸 Multiple upload methods (drag & drop, click, paste)
- 🔍 Real-time LaTeX preview with MathJax
- 📋 One-click copy to clipboard
- 🔐 User authentication with role-based access control
- 📝 User history logging for admin management
- 🐳 Docker deployment ready

### Database Setup

This tool requires two tables for authentication:

1. **`auth` table** - Stores login credentials (email, password)
2. **`user` table** - Stores user roles (admin, user, pending)

Users with `role = 'pending'` cannot log in until an admin changes their role.

### Configuration

| Variable | Required | Description |
|----------|----------|-------------|
| `DB_HOST` | Yes | PostgreSQL database host |
| `DB_PASSWORD` | Yes | Database password |
| `OPENAI_API_KEY` | Yes | AI API key |
| `OPENAI_API_BASE` | No | API base URL (default: OpenAI) |
| `OPENAI_MODEL` | No | Model name (default: gpt-4o) |
| `USER_HISTORY_FOLDER` | No | User history folder (default: user_history) |

---

<div align="center">

Made with ❤️ by [zhizinan1997](https://github.com/zhizinan1997)

</div>
