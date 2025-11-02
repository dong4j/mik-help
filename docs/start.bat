@echo off
chcp 65001 >nul
echo 🚀 启动 Markdown Image Kit 用户手册文档服务...
echo.

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 错误: 未检测到 Node.js
    echo 请先安装 Node.js: https://nodejs.org/
    pause
    exit /b 1
)

if not exist "node_modules\" (
    echo 📦 首次运行，正在安装依赖...
    call npm install
    echo.
)

where docsify >nul 2>nul
if %errorlevel% neq 0 (
    echo ⚠️  未检测到全局 docsify-cli，使用本地依赖...
    echo 💡 建议全局安装: npm install -g docsify-cli
    echo.
    call npx docsify serve . --port 3000
) else (
    echo ✅ 使用全局 docsify-cli
    echo.
    call docsify serve . --port 3000
)

