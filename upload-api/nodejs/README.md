# MIK Upload API - Node.js 实现

使用 Express 和 Multer 实现的文件上传和预览服务。

## 特性

- ✅ 基于 Express 框架
- ✅ 使用 Multer 处理文件上传
- ✅ 自动按文件类型分类存储
- ✅ 完善的错误处理
- ✅ 支持环境变量配置

## 快速开始

### 前置要求

- Node.js 14 或更高版本

### 安装依赖

```bash
npm install
```

### 运行

```bash
# 生产模式
npm start

# 开发模式（需要安装 nodemon）
npm run dev
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

在 `index.js` 中修改：

```javascript
const PORT = process.env.PORT || 12345;
const UPLOAD_PATH = process.env.UPLOAD_PATH || './uploads/';
```

修改文件大小限制：

```javascript
const upload = multer({
    storage: storage,
    limits: {
        fileSize: 10 * 1024 * 1024 // 10 MB
    }
});
```

## 部署

### 使用 PM2（推荐）

```bash
# 安装 PM2
npm install -g pm2

# 启动服务
pm2 start index.js --name mik-upload-api

# 开机自启
pm2 startup
pm2 save
```

### 使用 Docker

创建 `Dockerfile`:

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 12345
CMD ["node", "index.js"]
```

构建并运行：

```bash
docker build -t mik-upload-api .
docker run -d -p 12345:12345 -v /path/to/uploads:/app/uploads mik-upload-api
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
WorkingDirectory=/path/to/upload-api/nodejs
Environment="PORT=12345"
ExecStart=/usr/bin/node /path/to/upload-api/nodejs/index.js
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

**端点**: `GET /archive/{type}/{filename}`

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

