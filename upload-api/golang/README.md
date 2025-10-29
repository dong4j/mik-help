# MIK Upload API - Golang 实现

使用 Go 标准库实现的轻量级文件上传和预览服务。

## 特性

- ✅ 零依赖，仅使用 Go 标准库
- ✅ 高性能并发处理
- ✅ 简洁的代码实现
- ✅ 自动按文件类型分类存储
- ✅ 静态文件服务

## 快速开始

### 前置要求

- Go 1.21 或更高版本

### 运行

```bash
# 直接运行
go run main.go

# 或编译后运行
go build -o mik-upload-api
./mik-upload-api
```

服务将在 `http://localhost:12345` 启动

### 测试

```bash
# 上传文件
curl -X POST http://localhost:12345/upload \
  -F "fileName=@/path/to/image.png"

# 访问返回的 URL 预览图片
```

## 配置

在代码中修改常量：

```go
const (
    uploadPath = "./uploads/"  // 上传目录
    serverPort = "12345"       // 服务端口
)
```

或使用环境变量：

```bash
export UPLOAD_PATH="./uploads/"
export PORT="12345"
```

## 部署

### 编译

```bash
# Linux
GOOS=linux GOARCH=amd64 go build -o mik-upload-api

# Windows
GOOS=windows GOARCH=amd64 go build -o mik-upload-api.exe

# macOS
GOOS=darwin GOARCH=amd64 go build -o mik-upload-api
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
WorkingDirectory=/path/to/upload-api/golang
ExecStart=/path/to/upload-api/golang/mik-upload-api
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

启动服务：

```bash
sudo systemctl start mik-upload-api
sudo systemctl enable mik-upload-api
```

## API 文档

### 上传文件

**端点**: `POST /upload`

**请求**: `multipart/form-data`

**参数**: `fileName` - 文件

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

直接在浏览器访问上传接口返回的 URL 即可预览。

## 许可证

MIT License

