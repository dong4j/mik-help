#!/bin/bash

# Markdown Image Kit 文档服务启动脚本

echo "🚀 启动 Markdown Image Kit 用户手册文档服务..."
echo ""

# 检查是否安装了 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 未检测到 Node.js"
    echo "请先安装 Node.js: https://nodejs.org/"
    exit 1
fi

# 检查是否安装了 npm
if ! command -v npm &> /dev/null; then
    echo "❌ 错误: 未检测到 npm"
    exit 1
fi

# 检查是否安装了依赖
if [ ! -d "node_modules" ]; then
    echo "📦 首次运行，正在安装依赖..."
    npm install
    echo ""
fi

# 检查是否全局安装了 docsify-cli
if ! command -v docsify &> /dev/null; then
    echo "⚠️  未检测到全局 docsify-cli，使用本地依赖..."
    echo "💡 建议全局安装: npm install -g docsify-cli"
    echo ""
    npx docsify serve . --port 3000
else
    echo "✅ 使用全局 docsify-cli"
    echo ""
    docsify serve . --port 3000
fi

