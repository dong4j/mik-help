#!/bin/bash

# markdown-image-kit 插件发布与部署脚本
# 作者: dong4j
# 功能:
# 1) 执行 Gradle 的 publishPlugin 流程
# 2) 将 build/distributions/markdown-image-kit-{version}.zip 重命名为 mik.zip 并上传到服务器
# 3) 部署 landing.html 到服务器
#
# 用法:
#   ./deploy.sh       - 执行完整流程（发布插件 + 上传 ZIP + 部署 Landing）
#   ./deploy.sh -l    - 仅部署 landing.html
#   ./deploy.sh -z    - 仅上传 mik.zip（需要先构建）

set -e  # 遇到错误立即退出

# 目录与路径配置
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_DIR="$SCRIPT_DIR/../markdown-image-kit"

REMOTE_HOST="aliyun"
REMOTE_DIR="/var/www/mik-landing"
REMOTE_LANDING_PATH="$REMOTE_DIR/landing.html"
DEST_ZIP_NAME="mik.zip"

ZIP_DIR="$PROJECT_DIR/build/distributions"
LANDING_FILE="$SCRIPT_DIR/landing.html"

# 默认执行所有步骤
DEPLOY_LANDING=false
UPLOAD_ZIP=false
PUBLISH_PLUGIN=false

# 解析命令行参数
if [ $# -eq 0 ]; then
    # 无参数：执行完整流程
    PUBLISH_PLUGIN=true
    UPLOAD_ZIP=true
    DEPLOY_LANDING=true
else
    while getopts "lz" opt; do
        case $opt in
            l)
                DEPLOY_LANDING=true
                ;;
            z)
                UPLOAD_ZIP=true
                ;;
            *)
                echo "用法: $0 [-l] [-z]"
                echo "  -l    仅部署 landing.html"
                echo "  -z    仅上传 mik.zip"
                echo "  无参数 执行完整流程"
                exit 1
                ;;
        esac
    done
fi

echo "================================"
echo "开始发布与部署 markdown-image-kit"
echo "================================"

############################################
# 1) 执行 Gradle publishPlugin
############################################
if [ "$PUBLISH_PLUGIN" = true ]; then
    echo "[1/3] 执行 Gradle 发布插件 ..."
    cd "$PROJECT_DIR"
    ./gradlew publishPlugin --no-daemon
    echo "✓ 插件发布完成"
fi

############################################
# 2) 上传插件 ZIP 为 mik.zip 到服务器目录
############################################
if [ "$UPLOAD_ZIP" = true ]; then
    echo "[2/3] 查找构建产物 ZIP ..."
    if [ ! -d "$ZIP_DIR" ]; then
        echo "错误: 未找到构建目录 $ZIP_DIR，请确认构建是否成功"
        exit 1
    fi

    # 选取最新的 markdown-image-kit-*.zip
    ZIP_FILE=$(ls -t "$ZIP_DIR"/markdown-image-kit-*.zip 2>/dev/null | head -n1 || true)
    if [ -z "$ZIP_FILE" ]; then
        echo "错误: 未找到 $ZIP_DIR/markdown-image-kit-*.zip"
        exit 1
    fi

    echo "✓ 找到 ZIP 文件: $ZIP_FILE"
    echo "正在上传 ZIP 到 $REMOTE_HOST:$REMOTE_DIR/$DEST_ZIP_NAME ..."
    rsync -avz --progress \
        "$ZIP_FILE" \
        "$REMOTE_HOST:$REMOTE_DIR/$DEST_ZIP_NAME"

    echo "设置 ZIP 文件权限..."
    ssh "$REMOTE_HOST" "chmod 644 $REMOTE_DIR/$DEST_ZIP_NAME"
    echo "✓ ZIP 文件上传完成"
fi

############################################
# 3) 部署 landing.html
############################################
if [ "$DEPLOY_LANDING" = true ]; then
    echo "[3/3] 部署 Landing Page ..."

    # 检查源文件是否存在
    if [ ! -f "$LANDING_FILE" ]; then
        echo "错误: 找不到文件 $LANDING_FILE"
        exit 1
    fi

    echo "✓ 源文件检查通过: $LANDING_FILE"
    echo "正在上传文件到 $REMOTE_HOST:$REMOTE_LANDING_PATH ..."

    rsync -avz --progress \
        "$LANDING_FILE" \
        "$REMOTE_HOST:$REMOTE_LANDING_PATH"

    echo "设置 landing.html 文件权限..."
    ssh "$REMOTE_HOST" "chmod 644 $REMOTE_LANDING_PATH"
    echo "✓ Landing Page 部署完成"
fi

############################################
# 完成总结
############################################
echo "================================"
echo "✓ 部署完成！"
if [ "$PUBLISH_PLUGIN" = true ]; then
    echo "  - 插件已发布到 JetBrains Marketplace"
fi
if [ "$UPLOAD_ZIP" = true ]; then
    echo "  - ZIP: $REMOTE_HOST:$REMOTE_DIR/$DEST_ZIP_NAME"
fi
if [ "$DEPLOY_LANDING" = true ]; then
    echo "  - HTML: $REMOTE_HOST:$REMOTE_LANDING_PATH"
fi
echo "================================"
