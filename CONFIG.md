# 配置说明文档

## 环境变量配置

### API配置
- `OPENAI_API_KEY`: sk-xxxxxxxx
- `OPENAI_API_BASE`: API基础地址（默认: https://xxxxxx.com/v1）
- `OPENAI_MODEL`: 使用的模型名称（默认: gemini-2.5-flash-lite-preview-06-17）

### 模型参数配置
- `MODEL_MAX_TOKENS`: 最大输出token数（默认: 1000）
- `MODEL_TEMPERATURE`: 模型温度参数，控制输出随机性（默认: 0.1）
- `IMAGE_MAX_SIZE`: 图片最大尺寸（默认: 1024）
- `IMAGE_QUALITY`: 图片压缩质量（默认: 85）

### 应用配置
- `FLASK_ENV`: Flask环境（production/development）
- `FLASK_DEBUG`: 是否开启调试模式（true/false）
- `LOG_LEVEL`: 日志级别（INFO/DEBUG/ERROR）
- `MAX_CONTENT_LENGTH`: 最大上传文件大小（字节）
- `UPLOAD_FOLDER`: 上传文件目录

## 常用配置示例

### NewAPI2服务配置
```env
OPENAI_API_KEY=sk-w4eyFPGlmIRm1gZBZeyfXKGX6dIL7iy2LAe0j6fw4Ws3aXDM
OPENAI_API_BASE=https://newapi2.zhizinan.top/v1
OPENAI_MODEL=gemini-2.5-flash-lite-preview-06-17
