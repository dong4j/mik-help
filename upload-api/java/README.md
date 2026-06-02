# MIK Upload API - Java 实现

基于 Spring Boot 的图片上传 API 实现，提供简洁、可靠的文件上传和预览功能。

## 📋 目录

- [技术栈](#技术栈)
- [功能特性](#功能特性)
- [快速开始](#快速开始)
- [配置说明](#配置说明)
- [API 文档](#api-文档)
- [部署指南](#部署指南)
- [扩展开发](#扩展开发)

## 🛠 技术栈

- **框架**: Spring Boot 3.5.4
- **JDK**: 17+
- **构建工具**: Maven 3.x
- **依赖**: Spring Web MVC

## ✨ 功能特性

- ✅ RESTful 文件上传接口
- ✅ 自动按文件扩展名分类存储
- ✅ 时间戳生成唯一文件名
- ✅ 静态资源映射实现图片预览
- ✅ 支持打包部署
- ✅ 简洁的代码实现

## 🚀 快速开始

### 前置要求

- JDK 17 或更高版本
- Maven 3.x

### 本地开发

1. **进入项目目录**

```bash
cd upload-api/java
```

2. **配置上传路径**

编辑 `src/main/resources/application.properties`：

```properties
# 设置文件上传路径（需要有写入权限）
web.upload-path=/your/upload/path/
# 服务端口
server.port=12345
```

3. **运行应用**

**方式一：使用 Maven**

```bash
mvn clean spring-boot:run
```

**方式二：在 IDE 中运行**

直接运行 `UploadApplication` 类的 `main` 方法。

4. **测试接口**

上传图片：

```bash
curl -X POST http://localhost:12345/upload \
  -F "filename=@/path/to/image.png"
```

预览图片（使用返回的 URL）：

```
http://localhost:12345/archive/png/1634567890123image.png
```

## ⚙️ 配置说明

### application.properties

```properties
# 文件上传路径（需要有写入权限）
# Windows: web.upload-path=D:/upload/
# Linux/Mac: web.upload-path=/home/user/upload/
web.upload-path=~/Downloads/

# 服务端口
server.port=12345
```

### 上传文件大小限制

如需修改上传文件大小限制，添加以下配置：

```properties
# 单个文件大小限制
spring.servlet.multipart.max-file-size=10MB
# 请求总大小限制
spring.servlet.multipart.max-request-size=10MB
```

## 📡 API 文档

### 上传文件

**端点**: `POST /upload`

**请求格式**: `multipart/form-data`

**请求参数**:

| 参数名      | 类型   | 必填 | 说明     |
|----------|------|----|--------|
| filename | File | 是  | 要上传的文件 |

**请求示例**:

```bash
curl -X POST http://localhost:12345/upload \
  -F "filename=@/path/to/image.png"
```

**成功响应** (200):

```json
{
  "data": {
    "url": "http://localhost:12345/archive/png/1634567890123image.png"
  }
}
```

**失败响应** (400):

```json
{
  "timestamp": 1634567890123,
  "status": 400,
  "error": "Bad Request",
  "message": "文件为空"
}
```

### 预览文件

**端点**: `GET /archive/{type}/{filename}`

**说明**: 直接在浏览器中访问上传成功后返回的 URL 即可预览图片。

**示例**:

```
http://localhost:12345/archive/png/1634567890123image.png
```

## 🚢 部署指南

### 打包应用

```bash
mvn clean package
```

生成的文件位于: `target/mik-upload-api-1.0.0.jar`

### 运行 JAR

```bash
# 直接运行
java -jar target/mik-upload-api-1.0.0.jar

# 后台运行
nohup java -jar target/mik-upload-api-1.0.0.jar &

# 查看日志
tail -f nohup.out
```

### 自定义配置

创建 `application.properties` 文件：

```properties
web.upload-path=/your/upload/path/
server.port=12345
```

使用自定义配置启动：

```bash
java -jar mik-upload-api-1.0.0.jar --spring.config.location=./application.properties
```

或使用命令行参数：

```bash
java -jar mik-upload-api-1.0.0.jar --web.upload-path=/your/path/ --server.port=8080
```

### 使用 Systemd 管理（推荐）

创建服务文件 `/etc/systemd/system/mik-upload-api.service`：

```ini
[Unit]
Description=MIK Upload API Service
After=network.target

[Service]
Type=simple
User=your-user
WorkingDirectory=/path/to/mik-upload-api
ExecStart=/usr/bin/java -jar /path/to/mik-upload-api/mik-upload-api-1.0.0.jar \
  --web.upload-path=/path/to/uploads/
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

管理服务：

```bash
# 启动服务
sudo systemctl start mik-upload-api

# 停止服务
sudo systemctl stop mik-upload-api

# 重启服务
sudo systemctl restart mik-upload-api

# 开机自启
sudo systemctl enable mik-upload-api

# 查看状态
sudo systemctl status mik-upload-api

# 查看日志
sudo journalctl -u mik-upload-api -f
```

### Docker 部署

1. **创建 Dockerfile**

```dockerfile
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY target/mik-upload-api-1.0.0.jar app.jar
VOLUME /uploads
EXPOSE 12345
CMD ["java", "-jar", "app.jar", "--web.upload-path=/uploads/"]
```

2. **构建镜像**

```bash
docker build -t mik-upload-api:latest .
```

3. **运行容器**

```bash
docker run -d \
  --name mik-upload-api \
  -p 12345:12345 \
  -v /path/to/uploads:/uploads \
  mik-upload-api:latest
```

## 🔧 扩展开发

### 核心代码说明

**主应用类** - `UploadApplication.java`

```java
@SpringBootApplication
public class UploadApplication {
    public static void main(String[] args) {
        SpringApplication.run(UploadApplication.class);
    }
}
```

**文件上传控制器** - `FileController.java`

```java
@RestController
public class FileController {
    
    @Value("${web.upload-path}")
    private String path;
    
    @RequestMapping("upload")
    public ResponseEntity<?> upload(@RequestParam("filename") MultipartFile file,
                                    HttpServletRequest request) {
        // 1. 验证文件
        Assert.isTrue(!file.isEmpty(), "文件为空");
        
        // 2. 生成文件名和路径
        String originalFilename = file.getOriginalFilename();
        String suffix = originalFilename.substring(
            originalFilename.lastIndexOf(".") + 1) + "/";
        String newFileName = System.currentTimeMillis() + originalFilename;
        String filePath = path + suffix + newFileName;
        
        // 3. 保存文件
        File targetFile = new File(filePath);
        if (!targetFile.getParentFile().exists()) {
            targetFile.getParentFile().mkdirs();
        }
        file.transferTo(targetFile);
        
        // 4. 返回 URL
        String urlPath = request.getScheme() + "://" 
                       + request.getServerName() + ":" 
                       + request.getServerPort() 
                       + "/archive/" + suffix + newFileName;
        
        return ResponseEntity.ok(new HashMap<String, Object>() {{
            put("data", new HashMap<String, String>() {{
                put("url", urlPath);
            }});
        }});
    }
}
```

**Web MVC 配置** - `WebMvcConfig.java`

```java
@Configuration
public class WebMvcConfig extends WebMvcConfigurerAdapter {
    
    @Value("${web.upload-path}")
    public String fileRootPath;
    
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 将 /archive/** 映射到文件存储路径
        registry.addResourceHandler("/archive/**")
                .addResourceLocations("file:" + fileRootPath);
    }
}
```

### 扩展示例

#### 1. 添加文件类型验证

```java
@RequestMapping("upload")
public ResponseEntity<?> upload(@RequestParam("filename") MultipartFile file) {
    // 验证文件类型
    String contentType = file.getContentType();
    if (!contentType.startsWith("image/")) {
        return ResponseEntity.badRequest()
            .body(Collections.singletonMap("error", "只允许上传图片文件"));
    }
    
    // 继续处理...
}
```

#### 2. 添加图片压缩（使用 Thumbnailator）

pom.xml 添加依赖：

```xml
<dependency>
    <groupId>net.coobird</groupId>
    <artifactId>thumbnailator</artifactId>
    <version>0.4.14</version>
</dependency>
```

代码实现：

```java
import net.coobird.thumbnailator.Thumbnails;

// 压缩图片
Thumbnails.of(file.getInputStream())
    .size(1920, 1080)
    .outputQuality(0.8)
    .toFile(new File(filePath));
```

#### 3. 上传到阿里云 OSS

pom.xml 添加依赖：

```xml
<dependency>
    <groupId>com.aliyun.oss</groupId>
    <artifactId>aliyun-sdk-oss</artifactId>
    <version>3.15.0</version>
</dependency>
```

代码实现：

```java
@Value("${aliyun.oss.endpoint}")
private String endpoint;

@Value("${aliyun.oss.accessKeyId}")
private String accessKeyId;

@Value("${aliyun.oss.accessKeySecret}")
private String accessKeySecret;

@Value("${aliyun.oss.bucketName}")
private String bucketName;

@RequestMapping("upload")
public ResponseEntity<?> upload(@RequestParam("filename") MultipartFile file) {
    // 创建 OSSClient
    OSS ossClient = new OSSClientBuilder()
        .build(endpoint, accessKeyId, accessKeySecret);
    
    try {
        // 生成对象名
        String objectName = "images/" + System.currentTimeMillis() 
                          + file.getOriginalFilename();
        
        // 上传文件
        ossClient.putObject(bucketName, objectName, file.getInputStream());
        
        // 生成访问 URL
        String url = "https://" + bucketName + "." + endpoint + "/" + objectName;
        
        return ResponseEntity.ok(new HashMap<String, Object>() {{
            put("data", new HashMap<String, String>() {{
                put("url", url);
            }});
        }});
    } finally {
        ossClient.shutdown();
    }
}
```

#### 4. 添加访问日志

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

private static final Logger logger = LoggerFactory.getLogger(FileController.class);

@RequestMapping("upload")
public ResponseEntity<?> upload(@RequestParam("filename") MultipartFile file,
                                HttpServletRequest request) {
    String clientIp = request.getRemoteAddr();
    logger.info("收到上传请求 - IP: {}, 文件: {}, 大小: {} bytes", 
                clientIp, file.getOriginalFilename(), file.getSize());
    
    // 处理上传...
    
    logger.info("上传成功 - IP: {}, URL: {}", clientIp, urlPath);
    return ResponseEntity.ok(result);
}
```

## 🔍 常见问题

**Q: 上传后提示找不到文件？**

A: 检查 `web.upload-path` 配置的路径是否存在且有写入权限。

**Q: 图片预览 404？**

A: 确保 `WebMvcConfig` 中的资源映射配置正确，路径要以 `file:` 开头。

**Q: 上传大文件失败？**

A: 检查 `spring.servlet.multipart.max-file-size` 配置是否足够大。

**Q: 如何修改端口？**

A: 修改 `application.properties` 中的 `server.port` 配置。

## 📄 许可证

本项目基于 [MIT License](../../LICENSE) 开源。

## 🔗 相关链接

- [MIK Upload API 总览](../)
- [Markdown Image Kit 插件](https://github.com/dong4j/markdown-image-kit)
- [问题反馈](https://github.com/dong4j/mik-help/issues)

---

如果这个项目对你有帮助，请给一个 ⭐️ Star 支持一下！

