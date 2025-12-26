# MIK Help API

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-%3E%3D8.0.0-brightgreen.svg)](https://nodejs.org/)

为 [Markdown Image Kit](https://github.com/dong4j/markdown-image-kit) 插件提供动态帮助文档 URL 服务的 Node.js 实现。

## 📋 目录

- [项目简介](#项目简介)
- [核心特性](#核心特性)
- [快速开始](#快速开始)
- [配置说明](#配置说明)
- [API 文档](#api-文档)
- [部署指南](#部署指南)
- [工作原理](#工作原理)

## 📖 项目简介

Help API 是一个轻量级的 HTTP 服务，为 Markdown Image Kit 插件设置页面的 "Help" 按钮提供动态帮助文档链接。通过服务端接口返回帮助文档
URL，实现了文档链接的热更新，无需更新插件即可随时调整帮助内容。

### 为什么需要这个服务？

**传统方式的问题**：

- 帮助文档 URL 硬编码在插件中
- 每次更新链接都需要发布新版本
- 用户需要更新插件才能看到新文档
- 无法针对不同版本提供不同文档

**Help API 的优势**：

- 📝 配置与代码分离
- 🔄 配置热更新，无需重启服务
- 🚀 插件无需更新即可获取最新链接
- 🎯 可根据请求类型返回不同文档
- 💡 轻量级，单文件实现

## ✨ 核心特性

- ✅ 基于 Node.js 原生 HTTP 模块，无第三方依赖
- ✅ 配置文件热加载，每次请求自动刷新
- ✅ 支持多种云存储平台的帮助文档链接
- ✅ RESTful API 设计
- ✅ CORS 支持，跨域友好
- ✅ 健康检查接口
- ✅ 优雅关闭机制
- ✅ 简洁的单文件实现

## 🚀 快速开始

### 前置要求

- Node.js >= 8.0.0

### 安装与运行

1. **进入项目目录**

```bash
cd help-api
```

2. **配置帮助文档链接**

编辑 `config.json`：

```json
{
  "defaultUrl": "https://mik.dong4j.site/docs.html",
  "help": {
    "aliyun_cloud": "https://help.aliyun.com/zh/oss/",
    "qiniu_cloud": "https://developer.qiniu.com/kodo/1233/console-quickstart"
  }
}
```

3. **启动服务**

```bash
node index.js
```

或使用启动脚本（Linux/Mac）：

```bash
chmod +x start.sh
./start.sh
```

4. **测试接口**

```bash
# 健康检查
curl http://localhost:12346/health

# 获取帮助链接
curl http://localhost:12346/setting/aliyun_cloud
```

预期响应：

```json
{
  "code": "200",
  "url": "https://help.aliyun.com/zh/oss/"
}
```

## ⚙️ 配置说明

### config.json

```json
{
  "defaultUrl": "https://mik.dong4j.site/docs.html",
  "help": {
    "sm_ms_cloud": "https://doc.sm.ms/",
    "aliyun_cloud": "https://help.aliyun.com/zh/oss/",
    "qiniu_cloud": "https://developer.qiniu.com/kodo/1233/console-quickstart",
    "tencent_cloud": "https://cloud.tencent.com/document/product/436/6224",
    "baidu_cloud": "https://cloud.baidu.com/doc/BOS/s/Ik4xtp41n",
    "github": "https://blog.csdn.net/qq_44231797/article/details/131658184",
    "gitee": "https://blog.csdn.net/qq_57581439/article/details/129251624",
    "customize": "https://github.com/dong4j/mik-help",
    "piclist": "https://piclist.cn/"
  }
}
```

**配置项说明**：

| 字段          | 类型     | 说明                   |
|-------------|--------|----------------------|
| defaultUrl  | String | 默认返回的 URL（当找不到对应类型时） |
| help        | Object | 各类型对应的帮助文档链接         |
| help.{type} | String | 具体类型的帮助文档 URL        |

### 环境变量

| 变量          | 默认值           | 说明     |
|-------------|---------------|--------|
| PORT        | 12346         | 服务监听端口 |
| CONFIG_PATH | ./config.json | 配置文件路径 |

使用环境变量启动：

```bash
PORT=8080 CONFIG_PATH=/path/to/config.json node index.js
```

### 配置热更新原理

**关键特性**：每次 API 请求都会重新读取配置文件，实现配置的热更新。

```javascript
function reloadConfig() {
    const data = fs.readFileSync(CONFIG_PATH, 'utf8');
    config = JSON.parse(data);
}

// 每次请求都调用
server.on('request', (req, res) => {
    reloadConfig();  // 重新加载配置
    // 处理请求...
});
```

**优势**：

- ✅ 修改配置后立即生效
- ✅ 无需重启服务
- ✅ 零停机时间
- ✅ 适合频繁调整文档链接的场景

## 📡 API 文档

### 1. 获取帮助文档 URL

**端点**: `GET /{where}/{type}`

**路径参数**:

| 参数    | 类型     | 说明    | 示例           |
|-------|--------|-------|--------------|
| where | String | 来源位置  | setting      |
| type  | String | 云存储类型 | aliyun_cloud |

**支持的 type 值**:

| Type          | 说明        |
|---------------|-----------|
| sm_ms_cloud   | SM.MS 图床  |
| aliyun_cloud  | 阿里云 OSS   |
| qiniu_cloud   | 七牛云 Kodo  |
| tencent_cloud | 腾讯云 COS   |
| baidu_cloud   | 百度云 BOS   |
| github        | GitHub 图床 |
| gitee         | Gitee 图床  |
| customize     | 自定义图床     |
| piclist       | PicList   |

**请求示例**:

```bash
curl http://localhost:12346/setting/aliyun_cloud
```

**成功响应** (200):

```json
{
  "code": "200",
  "url": "https://help.aliyun.com/zh/oss/"
}
```

**未找到类型** (200，返回默认 URL):

```json
{
  "code": "200",
  "url": "https://mik.dong4j.site/docs.html"
}
```

### 2. 健康检查

**端点**: `GET /health`

**请求示例**:

```bash
curl http://localhost:12346/health
```

**响应**:

```json
{
  "code": "200",
  "status": "ok",
  "timestamp": 1634567890123
}
```

### 3. 默认路由

**端点**: `GET /*`

**说明**: 任何不匹配上述路由的请求都会返回默认 URL

**响应**:

```json
{
  "code": "200",
  "url": "https://mik.dong4j.site/docs.html"
}
```

## 🚢 部署指南

### 本地开发

```bash
node index.js
```

### 后台运行（Linux/Mac）

使用提供的启动脚本：

```bash
# 启动
./start.sh

# 停止
./stop.sh
```

或使用 nohup：

```bash
nohup node index.js > logs/app.log 2>&1 &
echo $! > app.pid
```

### 使用 PM2（推荐）

1. **安装 PM2**

```bash
npm install -g pm2
```

2. **启动服务**

```bash
pm2 start index.js --name mik-help-api
```

3. **管理服务**

```bash
# 查看状态
pm2 status

# 查看日志
pm2 logs mik-help-api

# 重启服务
pm2 restart mik-help-api

# 停止服务
pm2 stop mik-help-api

# 删除服务
pm2 delete mik-help-api

# 开机自启
pm2 startup
pm2 save
```

4. **使用配置文件**

创建 `ecosystem.config.js`：

```javascript
module.exports = {
  apps: [{
    name: 'mik-help-api',
    script: './index.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '200M',
    env: {
      NODE_ENV: 'production',
      PORT: 12346,
      CONFIG_PATH: './config.json'
    }
  }]
};
```

启动：

```bash
pm2 start ecosystem.config.js
```

### 使用 Systemd（Linux）

创建服务文件 `/etc/systemd/system/mik-help-api.service`：

```ini
[Unit]
Description=MIK Help API Service
After=network.target

[Service]
Type=simple
User=your-user
WorkingDirectory=/path/to/help-api
Environment="PORT=12346"
Environment="CONFIG_PATH=/path/to/help-api/config.json"
ExecStart=/usr/bin/node /path/to/help-api/index.js
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

管理服务：

```bash
# 启动
sudo systemctl start mik-help-api

# 停止
sudo systemctl stop mik-help-api

# 重启
sudo systemctl restart mik-help-api

# 开机自启
sudo systemctl enable mik-help-api

# 查看状态
sudo systemctl status mik-help-api

# 查看日志
sudo journalctl -u mik-help-api -f
```

### Docker 部署

1. **创建 Dockerfile**

```dockerfile
FROM node:14-alpine
WORKDIR /app
COPY index.js package.json ./
COPY config.json ./
EXPOSE 12346
ENV PORT=12346
ENV CONFIG_PATH=/app/config.json
CMD ["node", "index.js"]
```

2. **构建镜像**

```bash
docker build -t mik-help-api:latest .
```

3. **运行容器**

```bash
docker run -d \
  --name mik-help-api \
  -p 12346:12346 \
  -v /path/to/config.json:/app/config.json \
  mik-help-api:latest
```

### Nginx 反向代理

配置 Nginx 将 HTTPS 请求代理到 Help API：

```nginx
server {
    listen 80;
    server_name mik.dong4j.site;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name mik.dong4j.site;
    
    ssl_certificate /etc/nginx/encrypt/fullchain.pem;
    ssl_certificate_key /etc/nginx/encrypt/privkey.pem;
    
    location / {
        proxy_pass http://localhost:12346;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 🔍 工作原理

### 完整请求流程

```
[用户点击插件 Help 按钮]
        ↓
[MIK 插件] 组装请求 URL
        ↓
GET https://mik.dong4j.site/api/setting/aliyun_cloud
        ↓
[Nginx 反向代理] :443 → :12346
        ↓
[Help API] index.js
        ↓
1. 重新加载 config.json
2. 解析路由 /{where}/{type}
3. 查找 config.help[type]
4. 返回 JSON: {code: "200", url: "..."}
        ↓
[MIK 插件] 接收 URL
        ↓
[浏览器] 打开帮助文档
```

### 代码结构

```javascript
// 1. 配置加载
function reloadConfig() {
    const data = fs.readFileSync(CONFIG_PATH, 'utf8');
    config = JSON.parse(data);
}

// 2. HTTP 服务器
const server = http.createServer((req, res) => {
    // 3. 路由解析
    const matches = pathname.match(/^\/([^\/]+)\/([^\/]+)$/);
    
    // 4. 重新加载配置（热更新）
    reloadConfig();
    
    // 5. 处理请求
    if (where === 'setting') {
        const helpUrl = config.help[type];
        res.end(JSON.stringify({ code: '200', url: helpUrl }));
    }
});

// 6. 启动服务
server.listen(PORT);
```

### 关键特性实现

**配置热更新**：

```javascript
// 每次请求都重新读取配置文件
reloadConfig();
```

**CORS 支持**：

```javascript
res.setHeader('Access-Control-Allow-Origin', '*');
res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
```

**优雅关闭**：

```javascript
process.on('SIGTERM', () => {
    server.close(() => process.exit(0));
});
```

## 🔧 扩展开发

### 添加新的帮助文档类型

1. 编辑 `config.json`：

```json
{
  "help": {
    "new_platform": "https://new-platform.com/docs"
  }
}
```

2. 无需重启服务，配置立即生效！

### 添加访问日志

```javascript
server.on('request', (req, res) => {
    const timestamp = new Date().toISOString();
    const ip = req.socket.remoteAddress;
    console.log(`[${timestamp}] ${req.method} ${req.url} - ${ip}`);
    // 处理请求...
});
```

### 添加访问统计

```javascript
const stats = {};

function recordAccess(type) {
    stats[type] = (stats[type] || 0) + 1;
}

// 在处理请求时调用
recordAccess(type);

// 添加统计接口
if (pathname === '/stats') {
    res.end(JSON.stringify(stats));
}
```

### 添加缓存控制

```javascript
res.setHeader('Cache-Control', 'no-cache');
res.setHeader('Expires', '0');
```

## 🔍 常见问题

**Q: 配置修改后没有生效？**

A: 配置是每次请求时重新加载的，请检查 `config.json` 格式是否正确（使用 JSON 校验工具）。

**Q: 如何修改端口？**

A: 设置环境变量 `PORT=8080 node index.js` 或修改代码中的默认值。

**Q: 为什么使用 Node.js 而不是 Java？**

A: Node.js 部署更轻量，单文件实现，适合这种简单的 HTTP 服务。Help API 和 Upload API 职责不同，分开实现更清晰。

**Q: 可以使用数据库存储配置吗？**

A: 可以，修改 `reloadConfig()` 函数从数据库读取配置即可。

## 📄 许可证

本项目基于 [MIT License](../LICENSE) 开源。

## 🔗 相关链接

- [Markdown Image Kit 插件](https://github.com/dong4j/markdown-image-kit)
- [MIK Upload API](../upload-api/)
- [问题反馈](https://github.com/dong4j/mik-help/issues)

## 👤 作者

**dong4j**

- Email: dong4j@gmail.com
- GitHub: [@dong4j](https://github.com/dong4j)

---

如果这个项目对你有帮助，请给一个 ⭐️ Star 支持一下！

