# MIK Upload API - Kotlin 实现

使用 Ktor 框架实现的文件上传和预览服务。

## 特性

- ✅ 基于 Ktor 异步框架
- ✅ 协程支持，高性能
- ✅ 类型安全的 Kotlin DSL
- ✅ 简洁优雅的代码
- ✅ 自动按文件类型分类存储

## 快速开始

### 前置要求

- JDK 17 或更高版本
- Gradle 8.5 或更高版本

### 运行

```bash
# 使用 Gradle 运行
./gradlew run

# 或编译后运行
./gradlew build
java -jar build/libs/mik-upload-api-1.0.0.jar
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

在 `Application.kt` 中修改常量：

```kotlin
const val UPLOAD_PATH = "./uploads/"
const val SERVER_PORT = 12345
```

## 部署

### 构建 Fat JAR

```bash
# 构建
./gradlew build

# 运行
java -jar build/libs/mik-upload-api-1.0.0-all.jar
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
WorkingDirectory=/path/to/upload-api/kotlin
ExecStart=/usr/bin/java -jar /path/to/upload-api/kotlin/build/libs/mik-upload-api-1.0.0.jar
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

启动服务：

```bash
sudo systemctl start mik-upload-api
sudo systemctl enable mik-upload-api
```

### 使用 Docker

创建 `Dockerfile`:

```dockerfile
FROM gradle:8.5-jdk17 AS build
WORKDIR /app
COPY . .
RUN gradle build --no-daemon

FROM openjdk:17-slim
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar
EXPOSE 12345
CMD ["java", "-jar", "app.jar"]
```

构建并运行：

```bash
docker build -t mik-upload-api .
docker run -d -p 12345:12345 -v /path/to/uploads:/app/uploads mik-upload-api
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

**端点**: `GET /archive/{ext}/{filename}`

### 健康检查

**端点**: `GET /health`

**响应**:

```json
{
  "status": "ok"
}
```

## 扩展开发

### 添加认证

```kotlin
install(Authentication) {
    basic("auth-basic") {
        realm = "Access to upload"
        validate { credentials ->
            if (credentials.name == "user" && credentials.password == "pass") {
                UserIdPrincipal(credentials.name)
            } else null
        }
    }
}
```

### 添加日志

```kotlin
install(CallLogging) {
    level = Level.INFO
}
```

## 许可证

MIT License

