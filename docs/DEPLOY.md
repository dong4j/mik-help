# 📦 用户手册文档部署指南

本文档介绍如何将 Docsify 用户手册部署到服务器。

## 🚀 快速部署（使用 deploy.sh）

### 完整部署

```bash
# 在 mik-help 目录执行
./deploy.sh
```

这将执行：

1. 发布插件到 JetBrains Marketplace
2. 上传插件 ZIP 包
3. 部署 landing.html
4. **部署用户手册文档**

### 仅部署文档

```bash
# 仅部署用户手册文档
./deploy.sh -d
```

## 🔧 手动部署

如果你想手动部署或自定义配置，按照以下步骤操作：

### 1. 服务器准备

#### 创建文档目录

```bash
# SSH 登录到服务器
ssh your-server

# 创建文档目录
sudo mkdir -p /var/www/mik-docs

# 设置权限
sudo chown -R www-data:www-data /var/www/mik-docs
# 或者设置为你的用户
sudo chown -R $USER:$USER /var/www/mik-docs
```

### 2. 上传文档文件

#### 方法一：使用 rsync（推荐）

```bash
# 在本地 mik-help 目录执行
rsync -avz --progress \
  --exclude 'node_modules' \
  --exclude '.DS_Store' \
  --exclude '*.log' \
  --delete \
  docs/ \
  your-server:/var/www/mik-docs/
```

参数说明：

- `-a`：归档模式，保留权限和时间戳
- `-v`：显示详细信息
- `-z`：传输时压缩
- `--progress`：显示进度
- `--exclude`：排除不需要的文件
- `--delete`：删除服务器上多余的文件

#### 方法二：使用 scp

```bash
# 压缩后上传
cd docs
tar czf ../docs.tar.gz .
cd ..
scp docs.tar.gz your-server:/tmp/

# SSH 到服务器解压
ssh your-server
cd /var/www/mik-docs
tar xzf /tmp/docs.tar.gz
rm /tmp/docs.tar.gz
```

### 3. Nginx 配置

#### 更新 Nginx 配置文件

编辑 `/etc/nginx/sites-available/mik.dong4j.site.conf`（或你的配置文件）：

```nginx
server {
    listen 443 ssl http2;
    server_name mik.dong4j.site;

    # SSL 配置
    ssl_certificate /etc/nginx/encrypt/fullchain.pem;
    ssl_certificate_key /etc/nginx/encrypt/privkey.pem;

    # 其他配置...

    # 用户手册文档 (Docsify)
    location /guide {
        alias /var/www/mik-docs/;
        index index.html;
        try_files $uri $uri/ /guide/index.html;
    }

    # 其他 location 配置...
}
```

#### 测试并重启 Nginx

```bash
# 测试配置文件语法
sudo nginx -t

# 重新加载配置
sudo systemctl reload nginx
# 或
sudo nginx -s reload
```

### 4. 验证部署

访问以下 URL 检查部署是否成功：

```
https://mik.dong4j.site/docs
```

应该能看到用户手册的主页。

## 📝 配置说明

### deploy.sh 配置

编辑 `deploy.sh` 修改以下配置：

```bash
# 远程服务器配置（SSH 别名）
REMOTE_HOST="aliyun"

# 文档部署目录
REMOTE_DOCS_DIR="/var/www/mik-docs"
```

### SSH 别名配置

在本地 `~/.ssh/config` 中配置服务器别名：

```
Host aliyun
    HostName your.server.ip
    User your-username
    Port 22
    IdentityFile ~/.ssh/id_rsa
```

## 🔍 故障排查

### 问题 1：404 Not Found

**可能原因：**

- 文档文件未正确上传
- Nginx 配置路径错误
- 权限问题

**解决方法：**

```bash
# 检查文件是否存在
ssh your-server "ls -la /var/www/mik-docs/"

# 检查权限
ssh your-server "ls -ld /var/www/mik-docs"

# 检查 Nginx 配置
sudo nginx -t
```

### 问题 2：CSS/JS 加载失败

**可能原因：**

- CDN 被墙
- 路径配置错误

**解决方法：**

1. 检查 `index.html` 中的 CDN 链接
2. 考虑使用国内 CDN（如 jsdelivr 或 unpkg）
3. 或下载资源到本地

### 问题 3：文档更新不生效

**可能原因：**

- 浏览器缓存
- Nginx 缓存
- 文件未正确同步

**解决方法：**

```bash
# 强制刷新浏览器（Ctrl+F5）

# 清除 Nginx 缓存（如果配置了缓存）
sudo rm -rf /var/cache/nginx/*
sudo systemctl reload nginx

# 重新同步文件
./deploy.sh -d
```

### 问题 4：权限被拒绝

**解决方法：**

```bash
# 设置正确的权限
ssh your-server "sudo chown -R www-data:www-data /var/www/mik-docs"
ssh your-server "sudo find /var/www/mik-docs -type f -exec chmod 644 {} \;"
ssh your-server "sudo find /var/www/mik-docs -type d -exec chmod 755 {} \;"
```

## 🎯 最佳实践

### 1. 使用 Git 钩子自动部署

创建 `.git/hooks/post-commit`：

```bash
#!/bin/bash
# 检测 docs 目录是否有变更
if git diff HEAD~1 --name-only | grep -q "^docs/"; then
    echo "检测到文档变更，自动部署..."
    ./deploy.sh -d
fi
```

### 2. 添加部署前检查

在部署前验证文档：

```bash
# 本地启动测试
cd docs
npm run dev

# 在浏览器中验证：http://localhost:3000
```

### 3. 备份旧版本

```bash
# 在部署前备份
ssh your-server "tar czf /var/backups/mik-docs-$(date +%Y%m%d-%H%M%S).tar.gz -C /var/www mik-docs"
```

### 4. 使用 CI/CD

使用 GitHub Actions 自动部署：

```yaml
name: Deploy Docs
on:
  push:
    paths:
      - 'mik-help/docs/**'
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to Server
        run: |
          cd mik-help
          ./deploy.sh -d
```

## 📚 相关文档

- [Docsify 官方文档](https://docsify.js.org/)
- [Nginx 配置指南](https://nginx.org/en/docs/)
- [Rsync 使用手册](https://rsync.samba.org/documentation.html)

## 💡 提示

- 部署前请确保已在本地测试过文档
- 建议使用 SSH 密钥认证而非密码
- 定期备份文档内容
- 监控服务器磁盘空间

