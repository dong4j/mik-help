# MIK-Help

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-1.5.9-brightgreen.svg)](https://spring.io/projects/spring-boot)

MIK-Help 是 [Markdown Image Kit](https://github.com/dong4j/markdown-image-kit) 插件的配套服务，提供两个核心功能：

1. **自定义图床上传接口演示** - 展示如何实现自定义图床的文件上传 API
2. **动态帮助文档服务** - 为插件设置页面提供可动态更新的帮助文档 URL

## 📋 目录

- [功能特性](#功能特性)
- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [快速开始](#快速开始)
- [功能详解](#功能详解)
- [API 文档](#api-文档)
- [部署指南](#部署指南)
- [配置说明](#配置说明)
- [开发指南](#开发指南)

## ✨ 功能特性

### 1. 自定义图床上传接口

为 Markdown Image Kit 插件的"自定义图床"功能提供标准实现参考，开发者可以基于此示例快速搭建自己的图床服务。

**核心特性：**

- ✅ 支持文件上传
- ✅ 自动按文件类型分类存储
- ✅ 生成唯一文件名避免冲突
- ✅ 返回标准化响应格式
- ✅ 支持静态资源访问

### 2. 动态帮助文档服务

为插件设置页面的 "Help" 按钮提供动态 URL 服务，无需更新插件即可随时调整帮助文档链接。

**核心特性：**

- ✅ 动态加载配置文件
- ✅ 支持多种云存储平台的帮助文档链接
- ✅ 配置热更新（每次请求自动刷新）
- ✅ RESTful API 设计
- ✅ 支持 HTTPS 和反向代理

## 🛠 技术栈

- **框架**: Spring Boot 1.5.9.RELEASE
- **JDK**: 1.7+
- **构建工具**: Maven 3.x
- **Web 服务器**: Nginx (反向代理)
- **部署**: 支持独立 JAR 部署

## 📁 项目结构

```
mik-help/
├── src/
│   └── main/
│       ├── java/
│       │   └── info/dong4j/idea/plugin/help/
│       │       ├── HelpApplication.java          # 主应用 + 帮助 URL 接口
│       │       ├── config/
│       │       │   └── WebMvcConfig.java         # Web MVC 配置
│       │       └── controller/
│       │           └── FileController.java        # 文件上传控制器
│       ├── resources/
│       │   ├── application.properties            # 应用配置（包含所有帮助链接）
│       │   └── nginx.conf                        # Nginx 配置示例
│       ├── assembly/
│       │   └── assembly.xml                      # Maven 打包配置
│       └── bin/
│           └── server.sh                         # 启动脚本
├── pom.xml                                       # Maven 项目配置
└── README.md                                     # 项目文档
```

## 🚀 快速开始

### 前置要求

- JDK 1.7 或更高版本
- Maven 3.x
- （可选）Nginx（用于生产环境部署）

### 本地开发

1. **克隆项目**

```bash
git clone https://github.com/dong4j/mik-help.git
cd mik-help
```

2. **配置文件上传路径**

编辑 `src/main/resources/application.properties`：

```properties
# 自定义文件上传路径
web.upload-path=/your/upload/path/
# 服务端口
server.port=12345
```

3. **运行应用**

```bash
mvn clean spring-boot:run
```

或者在 IDE 中直接运行 `HelpApplication` 类，并配置 VM 参数：

```
-Dconfig.path=src/main/resources/
```

4. **测试接口**

- 文件上传: `http://localhost:12345/upload`
- 帮助链接: `http://localhost:12345/setting/{type}`

## 📖 功能详解

### 功能一：自定义图床上传接口

#### 实现原理

自定义图床上传功能在 `FileController.java` 中实现，提供了一个标准的文件上传 RESTful API。

#### 工作流程

```
[客户端] → [POST /upload] → [FileController]
                                    ↓
                            1. 接收文件
                            2. 验证文件
                            3. 生成唯一文件名
                            4. 按类型分类存储
                            5. 返回访问 URL
                                    ↓
                            [返回 JSON 响应]
```

#### 关键代码解析

```java:1:73:mik-help/src/main/java/info/dong4j/idea/plugin/help/controller/FileController.java
@RestController
public class FileController {
    
    @Value("${web.upload-path}")
    private String path;
    
    @RequestMapping("upload")
    public ResponseEntity<?> upload(@RequestParam("fileName") MultipartFile file, 
                                    HttpServletRequest request) {
        // 1. 验证文件
        Assert.isTrue(!file.isEmpty(), "文件为空");
        
        // 2. 生成唯一文件名
        String originalFilename = file.getOriginalFilename();
        String suffix = originalFilename.substring(originalFilename.lastIndexOf(".") + 1) + "/";
        String newFileName = System.currentTimeMillis() + originalFilename;
        
        // 3. 保存文件
        String filePath = path + suffix + newFileName;
        File file1 = new File(filePath);
        if (!file1.getParentFile().exists()) {
            file1.getParentFile().mkdirs();
        }
        file.transferTo(file1);
        
        // 4. 返回访问 URL
        String urlPath = request.getScheme() + "://" + request.getServerName() 
                       + ":" + request.getServerPort() 
                       + "/archive/" + suffix + newFileName;
        
        return ResponseEntity.ok(new HashMap<String, Object>(){
            {
                put("data", new HashMap<String, String>(){
                    {
                        put("url", urlPath);
                    }
                });
            }
        });
    }
}
```

#### 在 Markdown Image Kit 中配置

1. 打开 IDEA/WebStorm 等 JetBrains IDE
2. 进入 `Settings/Preferences` → `Tools` → `Markdown Image Kit`
3. 选择 `自定义` 图床
4. 配置上传接口：`http://your-server:12345/upload`
5. 参数名：`fileName`

### 功能二：动态帮助文档服务

#### 实现原理

这是一个更巧妙的设计，通过服务端接口动态返回帮助文档 URL，实现了"配置与代码分离"，避免了频繁更新插件。

#### 完整工作流程

```
[用户点击 Help 按钮]
        ↓
[插件端] helpButton.addActionListener()
        ↓
组装请求 URL: /setting/{type}
        ↓
调用 MikNotification.helpUrl()
        ↓
[网络请求] → [ECS Nginx :443]
                ↓ (反向代理)
        [内网服务器 :12345]
                ↓
        [HelpApplication 处理]
                ↓
        1. 重新加载 application.properties
        2. 根据 type 查找对应的 URL
        3. 返回 JSON: {code: "200", url: "..."}
                ↓
[插件端] 接收 URL 并在浏览器中打开
```

#### 详细流程说明

**第 1 步：插件端监听按钮事件**

在 Markdown Image Kit 插件的设置页面，每个配置项都有一个 Help 按钮：

```java
// 在插件的设置页面代码中
this.helpButton.addActionListener(e -> {
    // 根据当前选中的图床类型组装 URL
    String type = getCurrentCloudType(); // 如: "aliyun_cloud"
    String url = "https://mik.dong4j.site/setting/" + type;
    
    // 调用通知工具类
    MikNotification.helpUrl(project, url);
});
```

**第 2 步：插件发起 HTTP 请求**

`MikNotification.helpUrl()` 方法负责：

- 发起 HTTP GET 请求到服务端
- 解析返回的 JSON 响应
- 在浏览器中打开返回的 URL

**第 3 步：Nginx 反向代理**

请求到达 ECS 服务器后，Nginx 负责 SSL 终止和反向代理：

```nginx:1:20:mik-help/src/main/resources/nginx.conf
server {
    # HTTP 重定向到 HTTPS
    listen 80;
    server_name mik.dong4j.site;
    return 301 https://$host$request_uri;
}

server {
    # HTTPS 监听
    listen 443 ssl http2;
    server_name mik.dong4j.site;
    
    # SSL 证书配置
    ssl_certificate /etc/nginx/encrypt/fullchain.pem;
    ssl_certificate_key /etc/nginx/encrypt/privkey.pem;
    
    # 反向代理到内网服务
    location / {
        proxy_pass http://2.0.0.5:12345;
    }
}
```

**第 4 步：Spring Boot 应用处理请求**

```java:62:78:mik-help/src/main/java/info/dong4j/idea/plugin/help/HelpApplication.java
@RequestMapping("/{where}/{type}")
public Map<String, String> helpUrl(@PathVariable("where") String where, 
                                   @PathVariable("type") String type) {
    Map<String, String> result = new HashMap<>(2);
    
    // 关键：每次请求都重新加载配置文件
    reload();
    
    if ("setting".equals(where)) {
        // 根据 type 查找对应的配置
        String propertyKey = "mik.help." + type;
        result.put("code", "200");
        result.put("url", properties.getProperty(propertyKey, 
                                                 properties.getProperty("mik.url")));
        return result;
    }
    
    // 默认返回主页
    result.put("code", "200");
    result.put("url", properties.getProperty("mik.url"));
    return result;
}
```

**第 5 步：配置文件热加载**

这是整个设计的核心亮点：

```java:95:102:mik-help/src/main/java/info/dong4j/idea/plugin/help/HelpApplication.java
private static void reload() {
    try {
        String configPath = System.getProperty("config.path");
        // 每次请求都重新加载配置文件
        properties.load(new FileReader(configPath + "application.properties"));
    } catch (IOException ignored) {
    }
}
```

**为什么要热加载？**

1. **灵活性**：可以随时修改帮助文档 URL，无需重启服务
2. **维护性**：文档链接更新后，用户立即生效
3. **扩展性**：添加新的帮助链接只需修改配置文件

## 📡 API 文档

### 1. 文件上传接口

**端点**: `POST /upload`

**请求参数**:

| 参数名      | 类型            | 必填 | 说明     |
|----------|---------------|----|--------|
| fileName | MultipartFile | 是  | 要上传的文件 |

**请求示例**:

```bash
curl -X POST http://localhost:12345/upload \
  -F "fileName=@/path/to/image.png"
```

**响应示例**:

```json
{
  "data": {
    "url": "http://localhost:12345/archive/png/1634567890123image.png"
  }
}
```

### 2. 帮助文档接口

**端点**: `GET /{where}/{type}`

**路径参数**:

| 参数名   | 类型     | 说明    | 示例           |
|-------|--------|-------|--------------|
| where | String | 来源位置  | setting      |
| type  | String | 云存储类型 | aliyun_cloud |

**支持的 type 值**:

- `sm_ms_cloud` - SM.MS 图床
- `aliyun_cloud` - 阿里云 OSS
- `qiniu_cloud` - 七牛云 Kodo
- `tencent_cloud` - 腾讯云 COS
- `baidu_cloud` - 百度云 BOS
- `github` - GitHub 图床
- `gitee` - Gitee 图床
- `customize` - 自定义图床
- `piclist` - PicList

**请求示例**:

```bash
curl http://localhost:12345/setting/aliyun_cloud
```

**响应示例**:

```json
{
  "code": "200",
  "url": "https://help.aliyun.com/zh/oss/"
}
```

## 🚢 部署指南

### 方式一：独立 JAR 部署

1. **打包项目**

```bash
mvn clean package
```

生成的文件位于 `target/mik-help.zip`

2. **上传到服务器并解压**

```bash
unzip mik-help.zip
cd mik-help
```

3. **修改配置**

编辑 `config/application.properties`，设置上传路径和帮助文档 URL

4. **启动服务**

```bash
chmod +x bin/server.sh
./bin/server.sh
```

或者手动启动：

```bash
nohup java -jar \
  --add-opens java.base/java.lang=ALL-UNNAMED \
  -Dconfig.path=./config/ \
  mik-help-0.0.1.jar \
  --spring.config.location=./config/ &
```

### 方式二：Nginx 反向代理部署

1. **安装 Nginx**

```bash
# Ubuntu/Debian
sudo apt-get install nginx

# CentOS/RHEL
sudo yum install nginx
```

2. **配置 SSL 证书**（推荐使用 Let's Encrypt）

```bash
sudo certbot --nginx -d your-domain.com
```

3. **配置 Nginx**

参考 `src/main/resources/nginx.conf`，创建配置文件：

```bash
sudo nano /etc/nginx/sites-available/mik-help
```

4. **启用配置并重启**

```bash
sudo ln -s /etc/nginx/sites-available/mik-help /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 方式三：Docker 部署（推荐）

创建 `Dockerfile`:

```dockerfile
FROM openjdk:8-jre-alpine
WORKDIR /app
COPY target/mik-help-0.0.1.jar app.jar
COPY src/main/resources/application.properties config/application.properties
EXPOSE 12345
CMD ["java", "-jar", "-Dconfig.path=/app/config/", "app.jar"]
```

构建并运行：

```bash
docker build -t mik-help:latest .
docker run -d -p 12345:12345 \
  -v /path/to/config:/app/config \
  -v /path/to/uploads:/uploads \
  --name mik-help \
  mik-help:latest
```

## ⚙️ 配置说明

### application.properties 详解

```properties:1:39:mik-help/src/main/resources/application.properties
# 主页 URL（默认返回）
mik.url=https://mik.dong4j.site

# 各云存储平台的帮助文档链接
mik.help.sm_ms_cloud=https://doc.sm.ms/
mik.help.aliyun_cloud=https://help.aliyun.com/zh/oss/
mik.help.qiniu_cloud=https://developer.qiniu.com/kodo/1233/console-quickstart
mik.help.tencent_cloud=https://cloud.tencent.com/document/product/436/6224
mik.help.baidu_cloud=https://cloud.baidu.com/doc/BOS/s/Ik4xtp41n
mik.help.github=https://blog.csdn.net/qq_44231797/article/details/131658184
mik.help.gitee=https://blog.csdn.net/qq_57581439/article/details/129251624
mik.help.customize=https://github.com/dong4j/mik-help
mik.help.piclist=https://piclist.cn/

# 文件上传路径（需要有写入权限）
web.upload-path=/Users/dong4j/Downloads/

# 服务端口
server.port=12345
```

### 配置热更新原理

- ✅ 每次请求自动重新加载配置文件
- ✅ 修改配置后立即生效，无需重启服务
- ✅ 适合频繁调整帮助文档链接的场景

### 安全建议

⚠️ **生产环境注意事项**：

1. **文件上传**：
    - 限制上传文件大小
    - 验证文件类型
    - 添加访问频率限制
    - 使用 CDN 加速访问

2. **配置文件**：
    - 设置适当的文件权限（600）
    - 不要将敏感信息写入配置
    - 定期备份配置文件

3. **网络安全**：
    - 使用 HTTPS（SSL/TLS）
    - 配置防火墙规则
    - 启用 Nginx 访问日志
    - 添加 API 访问认证（可选）

## 🔧 开发指南

### 添加新的帮助文档链接

1. 在 `application.properties` 中添加新配置：

```properties
mik.help.new_platform=https://new-platform.com/docs
```

2. 在插件端使用新的 type：

```java
String url = "https://mik.dong4j.site/setting/new_platform";
```

### 自定义响应格式

修改 `HelpApplication.java` 中的响应结构：

```java
@RequestMapping("/{where}/{type}")
public Map<String, Object> helpUrl(@PathVariable("where") String where, 
                                   @PathVariable("type") String type) {
    Map<String, Object> result = new HashMap<>();
    reload();
    
    result.put("code", "200");
    result.put("url", properties.getProperty("mik.help." + type));
    result.put("timestamp", System.currentTimeMillis());
    // 添加更多自定义字段
    
    return result;
}
```

### 扩展文件上传功能

可以在 `FileController.java` 中添加更多功能：

- 图片压缩
- 格式转换
- 水印添加
- 文件加密
- 访问统计

## 📝 使用场景

### 场景一：团队内部图床

适合团队搭建内部图床服务，统一管理文档图片：

1. 部署 mik-help 服务到内网服务器
2. 配置 `web.upload-path` 到共享存储
3. 团队成员在 IDE 中配置自定义图床
4. 实现团队文档图片统一管理

### 场景二：个人博客图床

作为个人博客的图片存储方案：

1. 部署到个人 VPS/云服务器
2. 配合 Nginx 实现 HTTPS 访问
3. 结合 Markdown Image Kit 插件快速上传
4. 提升写作效率

### 场景三：多环境帮助文档

为不同环境提供不同的帮助文档：

```properties
# 开发环境
mik.help.aliyun_cloud=http://dev-docs.example.com/aliyun

# 生产环境
mik.help.aliyun_cloud=https://docs.example.com/aliyun
```

## 🤝 贡献指南

欢迎贡献代码、报告问题或提出改进建议！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目基于 [MIT License](LICENSE) 开源。

## 🔗 相关链接

- [Markdown Image Kit 插件](https://github.com/dong4j/markdown-image-kit)
- [插件文档站点](https://mik.dong4j.site)
- [问题反馈](https://github.com/dong4j/mik-help/issues)

## 👤 作者

**dong4j**

- Email: dong4j@gmail.com
- GitHub: [@dong4j](https://github.com/dong4j)

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者！

---

如果这个项目对你有帮助，请给一个 ⭐️ Star 支持一下！

