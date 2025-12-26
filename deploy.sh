#!/bin/bash

# markdown-image-kit 插件发布与部署脚本
# 作者: dong4j
# 功能:
# 1) 执行 Gradle 的 publishPlugin 流程
# 2) 将 build/distributions/markdown-image-kit-{version}.zip 重命名为 mik.zip 并上传到服务器
# 3) 部署 site 整个目录 (包含 landing.html, docs.html, docs/ 等) 到服务器
# 4) 可选部署 Nginx 配置
#
# 用法:
#   ./deploy.sh       - 执行完整流程（发布插件 + 上传 ZIP + 部署 site 目录）
#   ./deploy.sh -z    - 仅上传 mik.zip（需要先构建）
#   ./deploy.sh -d    - 仅部署 site 整个目录
#   ./deploy.sh -n    - 部署 Nginx 配置并在远程服务器上重载

set -e  # 遇到错误立即退出

# 目录与路径配置
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_DIR="$SCRIPT_DIR/../markdown-image-kit"

REMOTE_HOST="aliyun"
REMOTE_BASE_DIR="/var/www/mik"
REMOTE_DIR="$REMOTE_BASE_DIR/site"
DEST_ZIP_NAME="mik.zip"

ZIP_DIR="$PROJECT_DIR/build/distributions"
SITE_DIR="$SCRIPT_DIR/site"
DOCS_DIR="$SITE_DIR/docs"

# 默认执行所有步骤
UPLOAD_ZIP=false
PUBLISH_PLUGIN=false
DEPLOY_SITE=false
DEPLOY_NGINX=false
explicit_action=false  # 是否显式要求执行插件相关操作

# 如果第一个参数是 -n，则执行全局 Nginx 配置部署，不依赖具体插件
if [ "${1:-}" = "-n" ]; then
    REMOTE_HOST="aliyun"
    LOCAL_NGINX_CONF="$SCRIPT_DIR/mik.dong4j.site.conf"
    REMOTE_NGINX_DIR="/etc/nginx/conf.d"

    echo "================================"
    echo "开始部署全局 Nginx 配置"
    echo "本地配置文件: $LOCAL_NGINX_CONF"
    echo "远程目录: $REMOTE_NGINX_DIR"
    echo "目标服务器: $REMOTE_HOST"
    echo "================================"

    if [ ! -f "$LOCAL_NGINX_CONF" ]; then
        echo "错误: 找不到本地 Nginx 配置文件: $LOCAL_NGINX_CONF"
        exit 1
    fi

    echo "上传 Nginx 配置到 $REMOTE_HOST:$REMOTE_NGINX_DIR/ ..."
    rsync -avz --progress \
        "$LOCAL_NGINX_CONF" \
        "$REMOTE_HOST:$REMOTE_NGINX_DIR/"

    echo "Testing and reloading Nginx on server '$REMOTE_HOST'..."
    ssh "$REMOTE_HOST" "nginx -t && systemctl restart nginx"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to reload Nginx on server '$REMOTE_HOST'."
        exit 1
    fi

    echo "Nginx configuration successfully updated and reloaded on '$REMOTE_HOST'."
    echo "================================"
    exit 0
fi

# 解析命令行参数
if [ $# -eq 0 ]; then
    # 无参数：执行完整流程
    PUBLISH_PLUGIN=true
    UPLOAD_ZIP=true
    DEPLOY_SITE=true
else
    while getopts "zdn" opt; do
        case $opt in
            z)
                UPLOAD_ZIP=true
                explicit_action=true
                ;;
            d)
                DEPLOY_SITE=true
                explicit_action=true
                ;;
            n)
                DEPLOY_NGINX=true
                ;;
            *)
                echo "用法: $0 [-z] [-d] [-n]"
                echo "  -z    仅上传 mik.zip"
                echo "  -d    仅部署 site 整个目录 (包含 landing.html, docs.html, docs/ 等)"
                echo "  -n    部署 Nginx 配置并在远程服务器上重载"
                echo "  无参数 执行完整流程"
                exit 1
                ;;
        esac
    done
fi

# 如果只想部署 Nginx，且没有显式插件操作，则跳过插件相关步骤
if [ "$DEPLOY_NGINX" = true ] && [ "$explicit_action" = false ]; then
    PUBLISH_PLUGIN=false
    UPLOAD_ZIP=false
    DEPLOY_SITE=false
fi

echo "================================"
echo "开始发布与部署 markdown-image-kit"
echo "================================"
echo "插件目录: $PROJECT_DIR"
echo "站点目录: $SITE_DIR"
echo "远程基础目录: $REMOTE_BASE_DIR"
echo "远程站点目录: $REMOTE_DIR"
echo "================================"

############################################
# 1) 执行 Gradle publishPlugin
############################################
if [ "$PUBLISH_PLUGIN" = true ]; then
    echo "[1/4] 执行 Gradle 发布插件 ..."
    cd "$PROJECT_DIR"
    ./gradlew clean publishPlugin --no-daemon
    echo "✓ 插件发布完成"
else
    echo "[跳过] Gradle 发布 (根据参数设置)"
fi

############################################
# 2) 上传插件 ZIP 为 mik.zip 到服务器目录
############################################
if [ "$UPLOAD_ZIP" = true ]; then
    echo "[2/4] 查找构建产物 ZIP ..."
    if [ ! -d "$ZIP_DIR" ]; then
        echo "未找到构建目录 $ZIP_DIR，尝试先执行构建..."
        (cd "$PROJECT_DIR" && ./gradlew buildPlugin --no-daemon)
    fi

    # 选取最新的 markdown-image-kit-*.zip
    ZIP_FILE=$(ls -t "$ZIP_DIR"/markdown-image-kit-*.zip 2>/dev/null | head -n1 || true)
    if [ -z "$ZIP_FILE" ]; then
        echo "未找到 $ZIP_DIR/markdown-image-kit-*.zip，尝试先执行构建..."
        (cd "$PROJECT_DIR" && ./gradlew buildPlugin --no-daemon)
        ZIP_FILE=$(ls -t "$ZIP_DIR"/markdown-image-kit-*.zip 2>/dev/null | head -n1 || true)
        if [ -z "$ZIP_FILE" ]; then
            echo "错误: 构建后仍未找到 $ZIP_DIR/markdown-image-kit-*.zip"
            exit 1
        fi
    fi

    echo "✓ 找到 ZIP 文件: $ZIP_FILE"
    echo "正在上传 ZIP 到 $REMOTE_HOST:$REMOTE_BASE_DIR/$DEST_ZIP_NAME ..."
    # 创建远程目录（如果不存在）
    ssh "$REMOTE_HOST" "mkdir -p $REMOTE_BASE_DIR"
    rsync -avz --progress \
        "$ZIP_FILE" \
        "$REMOTE_HOST:$REMOTE_BASE_DIR/$DEST_ZIP_NAME"

    echo "设置 ZIP 文件权限..."
    ssh "$REMOTE_HOST" "chmod 644 $REMOTE_BASE_DIR/$DEST_ZIP_NAME"
    echo "✓ ZIP 文件上传完成"
else
    echo "[跳过] 上传 ZIP (根据参数设置)"
fi

############################################
# 3) 部署 site 整个目录 (landing/docs/静态资源等)
############################################
if [ "$DEPLOY_SITE" = true ]; then
    echo "[3/4] 部署 site 整个目录 ..."

    # 检查 site 目录是否存在
    if [ ! -d "$SITE_DIR" ]; then
        echo "错误: 找不到 site 目录: $SITE_DIR"
        exit 1
    fi

    # 如果存在生成文档清单脚本，先生成 docs-list.json
    GENERATE_DOCS_LIST_SCRIPT="$SCRIPT_DIR/generate-docs-list.sh"
    if [ -f "$GENERATE_DOCS_LIST_SCRIPT" ]; then
        echo "执行 generate-docs-list.sh 生成文档清单..."
        bash "$GENERATE_DOCS_LIST_SCRIPT" "$DOCS_DIR"
        if [ $? -eq 0 ]; then
            echo "✓ 文档清单生成成功"
        else
            echo "警告: 文档清单生成失败，继续部署..."
        fi
    else
        echo "提示: 未找到 generate-docs-list.sh，跳过文档清单生成"
    fi

    echo "正在全量同步 site 目录到 $REMOTE_HOST:$REMOTE_DIR ..."
    ssh "$REMOTE_HOST" "mkdir -p $REMOTE_DIR"

    # 全量同步：确保目标目录与源目录完全一致
    # -a: archive mode (保持权限、时间戳等)
    # -v: verbose
    # -z: compress during transfer
    # --progress: 显示传输进度
    # --delete: 删除目标目录中源目录不存在的文件（确保完全一致）
    rsync -avz --delete --progress \
        --exclude 'node_modules' \
        --exclude '.DS_Store' \
        --exclude '*.log' \
        "$SITE_DIR/" \
        "$REMOTE_HOST:$REMOTE_DIR/"

    echo "设置 site 目录权限..."
    ssh "$REMOTE_HOST" "find $REMOTE_DIR -type f -exec chmod 644 {} \; && find $REMOTE_DIR -type d -exec chmod 755 {} \;"
    echo "✓ site 目录部署完成"
else
    echo "[跳过] 部署 site 目录 (根据参数设置)"
fi

############################################
# 4) 部署 Nginx 配置并重载
############################################
if [ "$DEPLOY_NGINX" = true ]; then
    echo "[4/4] 部署 Nginx 配置 ..."

    LOCAL_NGINX_CONF="$SCRIPT_DIR/mik.dong4j.site.conf"
    REMOTE_NGINX_DIR="/etc/nginx/conf.d"

    if [ ! -f "$LOCAL_NGINX_CONF" ]; then
        echo "错误: 找不到本地 Nginx 配置文件: $LOCAL_NGINX_CONF"
        exit 1
    fi

    echo "上传 Nginx 配置到 $REMOTE_HOST:$REMOTE_NGINX_DIR/ ..."
    rsync -avz --progress \
        "$LOCAL_NGINX_CONF" \
        "$REMOTE_HOST:$REMOTE_NGINX_DIR/"

    echo "Testing and reloading Nginx on server '$REMOTE_HOST'..."
    ssh "$REMOTE_HOST" "nginx -t && systemctl restart nginx"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to reload Nginx on server '$REMOTE_HOST'."
        exit 1
    fi

    echo "Nginx configuration successfully updated and reloaded on '$REMOTE_HOST'."
else
    echo "[跳过] 部署 Nginx 配置 (根据参数设置)"
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
    echo "  - ZIP: $REMOTE_HOST:$REMOTE_BASE_DIR/$DEST_ZIP_NAME"
    echo "  - 下载地址: https://mik.dong4j.site/mik.zip"
fi
if [ "$DEPLOY_SITE" = true ]; then
    echo "  - site 目录: $REMOTE_HOST:$REMOTE_DIR"
    echo "  - 访问地址: https://mik.dong4j.site/"
    echo "  - 文档地址: https://mik.dong4j.site/docs.html"
fi
if [ "$DEPLOY_NGINX" = true ]; then
    echo "  - Nginx: 配置已部署到 /etc/nginx/conf.d 并完成重载"
fi
echo "================================"
