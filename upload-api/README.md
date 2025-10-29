# MIK Upload API

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

多语言实现的自定义图床上传接口示例，为 [Markdown Image Kit](https://github.com/dong4j/markdown-image-kit) 插件提供自定义图床功能参考实现。

## 📋 目录

- [项目简介](#项目简介)
- [设计理念](#设计理念)
- [实现列表](#实现列表)
- [快速开始](#快速开始)
- [API 规范](#api-规范)
- [使用场景](#使用场景)
- [扩展开发](#扩展开发)

## 📖 项目简介

本项目提供了多种编程语言实现的图片上传 API 示例，帮助开发者快速搭建自己的图床服务。每个实现都遵循相同的 API 规范，但采用各自语言的最佳实践和最简实现方式。

### 核心特性

- ✅ 多语言实现示例（Java、Node.js、Python、Go 等）
- ✅ 统一的 RESTful API 接口
- ✅ 文件按类型自动分类存储
- ✅ 生成唯一文件名避免冲突
- ✅ 支持静态资源预览
- ✅ 简洁的代码实现，易于理解和扩展

## 💡 设计理念

### 为什么需要这个项目？

Markdown Image Kit 插件内置了多种主流图床的支持（阿里云 OSS、七牛云、腾讯云 COS 等），但每个用户的需求不同：

1. **隐私保护**：不想将图片上传到公有云
2. **成本控制**：避免云服务商的费用
3. **内网部署**：企业内部文档系统需要内网图床
4. **特殊需求**：需要自定义图片处理逻辑（水印、压缩等）

### 两种使用方式

#### 方式一：本地图床（推荐入门）

直接运行示例代码，搭建一个简单的本地图床服务：

```
[MIK 插件] → [本地 Upload API] → [本地存储]
                                    ↓
                              [预览访问]
```

**适用场景**：

- 个人笔记、博客写作
- 内网文档系统
- 快速原型开发

#### 方式二：中转服务（推荐进阶）

将 Upload API 作为中转层，在接收到文件后，再上传到其他图床：

```
[MIK 插件] → [Upload API 中转] → [自定义逻辑] → [目标图床]
                                   ↓
                           • 图片压缩
                           • 添加水印
                           • 格式转换
                           • 权限控制
                           • 日志记录
```

**适用场景**：

- 需要图片预处理
- 统一多个图床的上传接口
- 需要访问控制和审计
- 企业级应用

### 设计优势

**减轻 MIK 插件的复杂度**：插件不需要集成所有图床的 SDK 和逻辑，只需要调用统一的上传接口。用户可以自由选择后端实现，插件保持简洁和稳定。

## 🗂 实现列表

### Java 实现

**目录**: `java/`

**技术栈**: Spring Boot 3.5.4 + Maven + JDK 17

**特点**:

- 企业级 Java 应用架构
- 完善的异常处理
- 支持大文件上传
- 易于集成到现有 Spring 项目
- 使用最新的 Spring Boot 3.x

**启动方式**:

```bash
cd java
mvn clean package
java -jar target/mik-upload-api-1.0.0.jar
```

**详细文档**: [Java 实现文档](java/README.md)

---

### Golang 实现

**目录**: `golang/`

**技术栈**: Go 1.21 + 标准库

**特点**:

- 零依赖，仅使用标准库
- 高性能并发处理
- 编译成单个二进制文件
- 部署简单，资源占用低

**启动方式**:

```bash
cd golang
go run main.go
```

**详细文档**: [Golang 实现文档](golang/README.md)

---

### Python 实现

**目录**: `python/`

**技术栈**: Python 3.8+ + Flask

**特点**:

- 简洁易懂的代码
- Flask 轻量级框架
- 支持 Gunicorn/uWSGI 部署
- 适合快速原型开发

**启动方式**:

```bash
cd python
pip install -r requirements.txt
python app.py
```

**详细文档**: [Python 实现文档](python/README.md)

---

### Node.js 实现

**目录**: `nodejs/`

**技术栈**: Node.js 14+ + Express + Multer

**特点**:

- 基于 Express 框架
- 异步非阻塞 I/O
- 完善的错误处理
- 支持 PM2 进程管理

**启动方式**:

```bash
cd nodejs
npm install
npm start
```

**详细文档**: [Node.js 实现文档](nodejs/README.md)

---

### Kotlin 实现

**目录**: `kotlin/`

**技术栈**: Kotlin 1.9 + Ktor + JDK 17

**特点**:

- 基于 Ktor 异步框架
- 协程支持，高性能
- 类型安全的 DSL
- 简洁优雅的 Kotlin 代码

**启动方式**:

```bash
cd kotlin
./gradlew run
```

**详细文档**: [Kotlin 实现文档](kotlin/README.md)

---

### 其他语言实现（欢迎贡献）

| 语言   | 技术栈              | 状态      |
|------|------------------|---------|
| PHP  | Laravel/Slim     | 💡 欢迎贡献 |
| Rust | Actix-web/Rocket | 💡 欢迎贡献 |
| C#   | ASP.NET Core     | 💡 欢迎贡献 |
| Ruby | Rails/Sinatra    | 💡 欢迎贡献 |

**欢迎贡献**：如果您有其他语言的实现，欢迎提交 PR！查看[贡献指南](#贡献指南)了解详情。

## 🚀 快速开始

### 选择语言实现

根据您熟悉的编程语言，选择对应的实现：

#### Java（企业级，稳定）

```bash
cd java
mvn clean package
java -jar target/mik-upload-api-1.0.0.jar
```

#### Golang（高性能，单文件）

```bash
cd golang
go run main.go
```

#### Python（简洁，快速开发）

```bash
cd python
pip install -r requirements.txt
python app.py
```

#### Node.js（异步，生态丰富）

```bash
cd nodejs
npm install
npm start
```

#### Kotlin（现代，类型安全）

```bash
cd kotlin
./gradlew run
```

所有实现的服务都运行在 `http://localhost:12345`

### 测试上传

```bash
curl -X POST http://localhost:12345/upload \
  -F "fileName=@/path/to/image.png"
```

### 配置 MIK 插件

1. 打开 IDE：`Settings/Preferences` → `Tools` → `Markdown Image Kit`
2. 选择 `自定义` 图床
3. 配置：
    - URL: `http://localhost:12345/upload`
    - 参数名: `fileName`
    - JSON Path: `data.url`

### 语言选择建议

| 场景    | 推荐语言           | 理由           |
|-------|----------------|--------------|
| 企业级应用 | Java/Kotlin    | 成熟稳定，生态完善    |
| 高性能场景 | Golang         | 并发性能优秀，资源占用低 |
| 快速原型  | Python/Node.js | 开发效率高，代码简洁   |
| 现有技术栈 | 与团队技术栈一致       | 降低学习成本       |

## 📡 API 规范

所有语言实现都遵循以下统一的 API 规范：

### 上传接口

**端点**: `POST /upload`

**请求格式**: `multipart/form-data`

**请求参数**:

| 参数名      | 类型   | 必填 | 说明     |
|----------|------|----|--------|
| fileName | File | 是  | 要上传的文件 |

**请求示例**:

```bash
curl -X POST http://localhost:12345/upload \
  -F "fileName=@/path/to/image.png"
```

**响应格式**: `application/json`

**成功响应** (HTTP 200):

```json
{
  "data": {
    "url": "http://localhost:12345/archive/png/1634567890123image.png"
  }
}
```

**失败响应** (HTTP 400/500):

```json
{
  "error": "错误描述信息"
}
```

### 预览接口

**端点**: `GET /archive/{type}/{filename}`

**说明**: 访问已上传的图片

**示例**:

```
http://localhost:12345/archive/png/1634567890123image.png
```

### 文件存储结构

上传的文件按照以下结构存储：

```
upload-path/
├── png/
│   ├── 1634567890123image.png
│   └── 1634567890456photo.png
├── jpg/
│   ├── 1634567890789picture.jpg
│   └── 1634567890012snapshot.jpg
├── gif/
│   └── 1634567890345animation.gif
└── ...
```

**命名规则**: `{timestamp}{original-filename}`

**分类依据**: 文件扩展名

## 📝 使用场景

### 场景一：个人本地图床

**需求**: 不想将图片上传到云端，希望保存在本地。

**方案**:

1. 运行 Upload API 在本机（localhost）
2. 设置上传路径到本地磁盘
3. MIK 插件配置为 `http://localhost:12345/upload`
4. 图片保存在本地，Markdown 引用本地路径

**优点**:

- 完全离线工作
- 无需担心隐私泄露
- 无存储成本

**缺点**:

- 图片仅在本机可访问
- 不适合分享给他人

### 场景二：内网团队图床

**需求**: 团队内部文档系统，图片存储在内网服务器。

**方案**:

1. 在内网服务器部署 Upload API
2. 配置 NAS 或共享存储作为上传路径
3. 团队成员配置内网地址：`http://192.168.1.100:12345/upload`
4. 所有图片统一管理

**优点**:

- 团队共享访问
- 统一管理备份
- 内网安全可控

**缺点**:

- 需要服务器资源
- 需要网络配置

### 场景三：云端图床中转

**需求**: 使用非主流图床（如自建 MinIO、WebDAV 等），但 MIK 插件未内置支持。

**方案**:

1. 基于示例代码扩展 Upload API
2. 在接收文件后，调用目标图床的 SDK 上传
3. 返回目标图床的 URL 给插件

**示例代码**（Java）:

```java
@RequestMapping("upload")
public ResponseEntity<?> upload(@RequestParam("fileName") MultipartFile file) {
    // 1. 接收文件
    String originalFilename = file.getOriginalFilename();
    
    // 2. 上传到目标图床（如 MinIO）
    String minioUrl = minioClient.upload(file.getInputStream(), originalFilename);
    
    // 3. 返回 URL
    return ResponseEntity.ok(new HashMap<String, Object>() {{
        put("data", new HashMap<String, String>() {{
            put("url", minioUrl);
        }});
    }});
}
```

**优点**:

- 支持任意图床
- 可自定义处理逻辑
- MIK 插件无需修改

### 场景四：图片预处理服务

**需求**: 上传前自动压缩图片、添加水印。

**方案**:

1. 在 Upload API 中集成图片处理库
2. 接收文件后进行处理
3. 保存处理后的图片

**示例代码**（Java + Thumbnailator）:

```java
// 压缩图片
Thumbnails.of(file.getInputStream())
    .size(1920, 1080)
    .outputQuality(0.8)
    .toFile(new File(filePath));

// 添加水印
Thumbnails.of(filePath)
    .watermark(Positions.BOTTOM_RIGHT, watermarkImage, 0.5f)
    .toFile(new File(filePath));
```

**优点**:

- 自动优化图片
- 减少存储空间
- 统一图片风格

## 🔧 扩展开发

### 添加图片压缩

使用图片处理库（如 Java 的 Thumbnailator、Node.js 的 Sharp）:

```java
// Java 示例
Thumbnails.of(file.getInputStream())
    .size(1920, 1080)
    .outputQuality(0.8)
    .toFile(targetFile);
```

### 上传到其他图床

集成目标图床的 SDK：

```java
// 上传到阿里云 OSS
OSSClient ossClient = new OSSClient(endpoint, accessKeyId, accessKeySecret);
PutObjectResult result = ossClient.putObject(bucketName, objectName, inputStream);
String url = "https://" + bucketName + "." + endpoint + "/" + objectName;
```

### 添加访问控制

```java
@RequestMapping("upload")
public ResponseEntity<?> upload(@RequestHeader("Authorization") String token,
                                @RequestParam("fileName") MultipartFile file) {
    // 验证 token
    if (!isValidToken(token)) {
        return ResponseEntity.status(401).body("Unauthorized");
    }
    
    // 处理上传...
}
```

### 添加文件大小限制

```java
// application.properties
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
```

### 添加文件类型检查

```java
String contentType = file.getContentType();
if (!contentType.startsWith("image/")) {
    throw new IllegalArgumentException("只允许上传图片文件");
}
```

### 添加病毒扫描

集成 ClamAV 等病毒扫描工具：

```java
// 扫描病毒
if (virusScanner.scan(file.getInputStream())) {
    throw new SecurityException("文件包含病毒");
}
```

## 🤝 贡献指南

我们欢迎各种语言的实现！如果您想贡献新的语言实现，请遵循以下规范：

### 基本要求

1. **遵循 API 规范**：确保接口格式与现有实现一致
2. **简洁实现**：使用语言的标准框架，代码简洁易懂
3. **完整文档**：提供独立的 README 和运行说明
4. **测试验证**：确保上传和预览功能正常工作

### 目录结构

```
upload-api/
├── {language}/
│   ├── README.md          # 该语言的详细说明
│   ├── src/               # 源代码
│   ├── config/            # 配置文件
│   └── tests/             # 测试用例（可选）
```

### 提交流程

1. Fork 本仓库
2. 创建您的语言实现目录
3. 编写代码和文档
4. 测试功能完整性
5. 提交 Pull Request

## 📄 许可证

本项目基于 [MIT License](../LICENSE) 开源。

## 🔗 相关链接

- [Markdown Image Kit 插件](https://github.com/dong4j/markdown-image-kit)
- [MIK Help API](../help-api/)
- [问题反馈](https://github.com/dong4j/mik-help/issues)

## 👤 作者

**dong4j**

- Email: dong4j@gmail.com
- GitHub: [@dong4j](https://github.com/dong4j)

---

如果这个项目对你有帮助，请给一个 ⭐️ Star 支持一下！

