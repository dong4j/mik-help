# MIK Upload API - Python 实现

使用 Flask 框架实现的文件上传和预览服务。

## 特性

- ✅ 基于 Flask 轻量级框架
- ✅ 简洁易懂的代码
- ✅ 自动按文件类型分类存储
- ✅ 支持环境变量配置
- ✅ 生产环境就绪

## 快速开始

### 前置要求

- Python 3.8 或更高版本

### 安装依赖

```bash
# 创建虚拟环境（推荐）
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 安装依赖
pip install -r requirements.txt
```

### 运行

```bash
python app.py
```

服务将在 `http://localhost:12345` 启动

### 测试

```bash
# 上传文件
curl -X POST http://localhost:12345/upload \
  -F "filename=@/path/to/image.png"

# 访问返回的 URL 预览图片
```

## 配置

### 环境变量

```bash
export UPLOAD_PATH="./uploads/"
export PORT="12345"
```

### 代码配置

在 `app.py` 中修改：

```python
UPLOAD_PATH = os.getenv('UPLOAD_PATH', './uploads/')
SERVER_PORT = int(os.getenv('PORT', 12345))
MAX_CONTENT_LENGTH = 10 * 1024 * 1024  # 10 MB
```

## 部署

### 使用 Gunicorn（推荐）

```bash
# 安装 Gunicorn
pip install gunicorn

# 启动服务
gunicorn -w 4 -b 0.0.0.0:12345 app:app
```

### 使用 uWSGI

```bash
# 安装 uWSGI
pip install uwsgi

# 启动服务
uwsgi --http 0.0.0.0:12345 --wsgi-file app.py --callable app --processes 4
```

### 使用 Systemd

创建 `/etc/systemd/system/mik-upload-api.service`:

```ini
[Unit]
Description=MIK Upload API Service
After=network.target

[Service]
Type=simple
User=your-user
WorkingDirectory=/path/to/upload-api/python
Environment="UPLOAD_PATH=./uploads/"
ExecStart=/path/to/venv/bin/gunicorn -w 4 -b 0.0.0.0:12345 app:app
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

## API 文档

### 上传文件

**端点**: `POST /upload`

**请求**: `multipart/form-data`

**参数**: `filename` - 文件

**响应**:

```json
{
  "data": {
    "url": "http://localhost:12345/archive/png/1634567890123image.png"
  }
}
```

### 预览文件

**端点**: `GET /archive/{path}`

### 健康检查

**端点**: `GET /health`

**响应**:

```json
{
  "status": "ok"
}
```

## 许可证

MIT License

