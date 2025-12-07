# config.py
# 项目配置文件
# 所有敏感信息通过环境变量配置，便于安全部署
import os

# --- 数据库配置 ---
# PostgreSQL 数据库连接信息 (通过环境变量配置)
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', 'postgres')
DB_USER = os.getenv('DB_USER', 'postgres')
DB_PASSWORD = os.getenv('DB_PASSWORD', '')  # 必须通过环境变量设置

# 数据库连接字符串 (自动生成，无需修改)
DB_URI = f"postgres://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"


# --- AI API 配置 ---
# OpenAI API 密钥 (通过环境变量配置)
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY', '')  # 必须通过环境变量设置

# API 基础地址 (支持 OpenAI 兼容接口)
OPENAI_API_BASE = os.getenv('OPENAI_API_BASE', 'https://api.openai.com/v1')

# 使用的模型名称
OPENAI_MODEL = os.getenv('OPENAI_MODEL', 'gpt-4o')

# 模型参数配置
MODEL_MAX_TOKENS = int(os.getenv('MODEL_MAX_TOKENS', '1000'))
MODEL_TEMPERATURE = float(os.getenv('MODEL_TEMPERATURE', '0.1'))


# --- 其他应用配置 ---
# Flask Secret Key (用于Session加密)
SECRET_KEY = os.getenv('SECRET_KEY', 'dev_secret_key_please_change_in_production')

# 图片处理配置
IMAGE_MAX_SIZE = int(os.getenv('IMAGE_MAX_SIZE', '1024'))  # 图片最大尺寸（像素）
IMAGE_QUALITY = int(os.getenv('IMAGE_QUALITY', '85'))      # 图片压缩质量 (1-100)

# 上传文件配置
MAX_CONTENT_LENGTH = int(os.getenv('MAX_CONTENT_LENGTH', str(16 * 1024 * 1024)))  # 最大上传限制 16MB
UPLOAD_FOLDER = 'uploads'
USAGE_LOG_FILE = 'usage.log'
STATS_FILE = 'conversion_stats.txt'
LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
