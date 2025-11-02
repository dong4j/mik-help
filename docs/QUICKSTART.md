# 📚 Markdown Image Kit 用户手册 - 快速开始

## 🚀 快速启动

### 方法一：使用启动脚本（推荐）

#### Mac / Linux

```bash
cd docs
./start.sh
```

#### Windows

```bash
cd docs
start.bat
```

### 方法二：使用 npm 命令

```bash
# 1. 进入文档目录
cd docs

# 2. 首次运行需要安装依赖
npm install

# 3. 启动开发服务器
npm run dev
```

### 方法三：使用全局 docsify-cli

```bash
# 1. 全局安装 docsify-cli
npm install -g docsify-cli

# 2. 进入文档目录
cd docs

# 3. 启动服务
docsify serve .
```

## 🌐 访问文档

启动成功后，在浏览器中打开：

```
http://localhost:3000
```

## 📝 文档编辑

### 编辑主文档

主文档文件位于：`docs/用户手册.md`

编辑后刷新浏览器即可看到更新（无需重启服务）。

### 自定义侧边栏

侧边栏配置文件：`docs/_sidebar.md`

格式示例：

```markdown
* [首页](/)
* [章节一](章节一.md)
  * [小节1](章节一.md#小节1)
  * [小节2](章节一.md#小节2)
* [章节二](章节二.md)
```

### 自定义封面

封面配置文件：`docs/_coverpage.md`

启用封面：修改 `docs/index.html` 中的配置：

```javascript
window.$docsify = {
  coverpage: true,  // 设置为 true
  // ...
}
```

## 🎨 主题配置

在 `docs/index.html` 中可以修改主题：

```html
<!-- Vue 主题（默认） -->
<link rel="stylesheet" href="//cdn.jsdelivr.net/npm/docsify@4/lib/themes/vue.css">

<!-- 其他可选主题 -->
<!-- <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/docsify@4/lib/themes/buble.css"> -->
<!-- <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/docsify@4/lib/themes/dark.css"> -->
<!-- <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/docsify@4/lib/themes/pure.css"> -->
```

## 🚢 部署

### 部署到 GitHub Pages

1. 推送代码到 GitHub 仓库
2. 在仓库设置中启用 GitHub Pages
3. 选择 docs 目录作为源

### 部署到 Nginx

```bash
# 复制文件到 web 目录
sudo cp -r docs/* /usr/share/nginx/html/mik-docs/

# Nginx 配置
location /mik-docs {
    root /usr/share/nginx/html;
    index index.html;
    try_files $uri $uri/ /mik-docs/index.html;
}
```

### 部署到 Vercel / Netlify

直接导入 GitHub 仓库，选择 `docs` 目录即可自动部署。

## 🔧 常见问题

### 端口被占用

修改端口：

```bash
docsify serve . --port 8080
```

或修改 `package.json`：

```json
{
  "scripts": {
    "dev": "docsify serve . --port 8080"
  }
}
```

### 图片显示问题

确保图片路径正确：

- 相对路径：`./images/pic.png`
- 绝对路径：`/docs/images/pic.png`
- 外链：`https://example.com/pic.png`

### 搜索不工作

确保 `index.html` 中已引入搜索插件：

```html
<script src="//cdn.jsdelivr.net/npm/docsify/lib/plugins/search.min.js"></script>
```

## 📚 更多资源

- [Docsify 官方文档](https://docsify.js.org/)
- [Markdown 语法指南](https://www.markdownguide.org/)
- [Markdown Image Kit 插件](https://github.com/dong4j/markdown-image-kit)

## 💡 提示

- 文档自动热更新，编辑后刷新浏览器即可
- 支持全文搜索，输入关键词即可查找
- 支持代码高亮，自动识别编程语言
- 支持图片点击放大
- 支持 Emoji 表情 :smile: :tada:

