#!/bin/bash
# MIK Help API 停止脚本

# 获取脚本所在目录
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

if [ -f app.pid ]; then
    PID=$(cat app.pid)
    echo "正在停止服务 (PID: $PID)..."
    kill $PID
    rm app.pid
    echo "服务已停止"
else
    echo "未找到 PID 文件，服务可能未运行"
fi

