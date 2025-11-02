# Docsify 文档项目说明

本文档使用 [Docsify](https://docsify.js.org/) 构建，用于展示 Markdown Image Kit 插件的用户手册。

## 📦 安装

### 1. 安装 Node.js 依赖

```bash
npm install
# 或者
yarn install
```

### 2. 全局安装 docsify-cli（可选）

```bash
npm install -g docsify-cli
```

## 🚀 本地开发

### 方法 1：使用 npm scripts

```bash
npm run dev
```

### 方法 2：使用全局 docsify-cli

```bash
docsify serve .
```

然后在浏览器中打开 [http://localhost:3000](http://localhost:3000)

## 📁 项目结构

```
mik-help/
├── index.html          # Docsify 入口文件（主配置）
├── 用户手册.md         # 主文档内容
├── _sidebar.md         # 侧边栏配置
├── _coverpage.md       # 封面页（可选）
├── .nojekyll          # GitHub Pages 配置
├── package.json       # Node.js 项目配置
└── README.md          # 项目说明
```

## 🎨 自定义配置

### 修改主题

在 `index.html` 中修改主题 CSS 链接：

```html
<!-- Vue 主题（默认） -->
<link rel="stylesheet" href="//cdn.jsdelivr.net/npm/docsify@4/lib/themes/vue.css">

<!-- 其他可选主题 -->
<!-- <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/docsify@4/lib/themes/buble.css"> -->
<!-- <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/docsify@4/lib/themes/dark.css"> -->
<!-- <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/docsify@4/lib/themes/pure.css"> -->
```

### 修改侧边栏

编辑 `_sidebar.md` 文件来自定义侧边栏导航。

### 添加封面页

如果需要启用封面页，在 `index.html` 中设置：

```javascript
window.$docsify = {
  coverpage: true,  // 改为 true
  // ... 其他配置
}
```

## 🌐 部署

### 部署到 GitHub Pages

1. 将代码推送到 GitHub 仓库

2. 在仓库设置中启用 GitHub Pages，选择主分支

3. 访问 `https://yourusername.github.io/your-repo/`

### 部署到 Nginx

将整个目录复制到 Nginx 的 web 根目录：

```bash
cp -r mik-help/* /usr/share/nginx/html/docs/
```

Nginx 配置示例（已有 `mik.dong4j.site.conf`）。

### 部署到 Vercel/Netlify

直接连接 GitHub 仓库，这些平台会自动识别并部署静态网站。

## 📝 插件说明

当前配置包含以下 Docsify 插件：

- ✅ **全文搜索**：支持中文搜索
- ✅ **代码高亮**：支持多种编程语言
- ✅ **代码复制**：一键复制代码块
- ✅ **分页导航**：上一页/下一页导航
- ✅ **Emoji 支持**：:smile: 等表情渲染
- ✅ **图片缩放**：点击图片放大查看
- ✅ **字数统计**：显示阅读时间

## 🔧 常见问题

### 1. 如何修改端口？

```bash
docsify serve . --port 8080
```

或修改 `package.json` 中的 scripts：

```json
"dev": "docsify serve . --port 8080"
```

### 2. 如何添加新页面？

创建新的 `.md` 文件，然后在 `_sidebar.md` 中添加链接。

### 3. 图片路径问题

确保图片路径正确，可以使用：

- 相对路径：`./images/pic.png`
- 绝对路径：`/images/pic.png`
- 外链：`https://example.com/pic.png`

## 📚 更多资源

- [Docsify 官方文档](https://docsify.js.org/)
- [Docsify 中文文档](https://docsify.js.org/#/zh-cn/)
- [Markdown 语法](https://www.markdownguide.org/)

## 📄 许可证

MIT License

