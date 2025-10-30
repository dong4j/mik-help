#!/bin/bash

# 部署 landing.html 到 ECS 服务器
# 作者: dong4j
# 用途: 使用 rsync 上传 landing.html 到服务器

set -e  # 遇到错误立即退出

# 配置
SOURCE_FILE="landing.html"
REMOTE_HOST="aliyun"
REMOTE_PATH="/var/www/mik-landing/landing.html"

echo "================================"
echo "开始部署 Landing Page"
echo "================================"

# 检查源文件是否存在
if [ ! -f "$SOURCE_FILE" ]; then
    echo "错误: 找不到文件 $SOURCE_FILE"
    exit 1
fi

echo "✓ 源文件检查通过: $SOURCE_FILE"

# 使用 rsync 上传文件
echo "正在上传文件到 $REMOTE_HOST:$REMOTE_PATH ..."

rsync -avz --progress \
    "$SOURCE_FILE" \
    "$REMOTE_HOST:$REMOTE_PATH"

# 设置文件权限
echo "设置文件权限..."
ssh "$REMOTE_HOST" "chmod 644 $REMOTE_PATH"

# 检查上传结果
if [ $? -eq 0 ]; then
    echo "================================"
    echo "✓ 部署成功！"
    echo "文件已上传到: $REMOTE_HOST:$REMOTE_PATH"
    echo "================================"
else
    echo "================================"
    echo "✗ 部署失败！"
    echo "================================"
    exit 1
fi

