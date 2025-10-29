#!/bin/bash
# MIK Help API 启动脚本

# 获取脚本所在目录
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

# 设置配置文件路径（如果未指定）
if [ -z "$CONFIG_PATH" ]; then
    export CONFIG_PATH="$DIR/config.json"
fi

# 设置端口（如果未指定）
if [ -z "$PORT" ]; then
    export PORT=12346
fi

echo "================================"
echo "启动 MIK Help API"
echo "配置文件: $CONFIG_PATH"
echo "监听端口: $PORT"
echo "================================"

# 启动服务
nohup node index.js > logs/app.log 2>&1 &

# 保存进程 ID
echo $! > app.pid

echo "服务已启动，PID: $(cat app.pid)"
echo "查看日志: tail -f logs/app.log"

