#!/bin/bash

# 容器名
CONTAINER_NAME="atrust"
FRPC_BIN_PATH="/usr/bin/frpc"
FRPC_CONFIG_PATH="/etc/frp"
FRPC_SHELL_PATH="/usr/bin/frpc-service.sh"
MAX_RETRIES=50  # 最大重试次数
RETRY_INTERVAL=3  # 重试时间间隔（秒）

# 1. 检测docker容器是否存在
# 此处配置需按照文档修改
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Docker容器 '${CONTAINER_NAME}' 不存在"
    docker run -itd --device /dev/net/tun \
        --cap-add NET_ADMIN -ti \
        --add-host host.docker.internal:host-gateway \
        -e PASSWORD=此处配置需按照文档修改 -e URLWIN=1 \
        -v $HOME/.atrust-data:/root -p 127.0.0.1:5901:5901 \
        -p 127.0.0.1:1080:1080 -p 127.0.0.1:8888:8888 \
        -p 127.0.0.1:54631:54631 \
        --name atrust \
        -e ATRUST_OPTS='此处配置需按照文档修改' \
        --restart unless-stopped \
        -e TZ=Asia/Shanghai --shm-size 320m \
        --sysctl net.ipv4.conf.default.route_localnet=1 kenvix/docker-atrust-autologin:latest
fi

# 检查容器是否在运行，如果不在运行则启动它
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Docker容器 '${CONTAINER_NAME}' 未在运行，启动中..."
    docker start ${CONTAINER_NAME}
fi

# 2. 复制frpc文件到容器并确保可执行
echo "复制frpc到容器的${FRPC_BIN_PATH}路径..."
docker cp "$(dirname "$0")/frpc" ${CONTAINER_NAME}:${FRPC_BIN_PATH}
docker exec ${CONTAINER_NAME} chmod +x ${FRPC_BIN_PATH}

# 3. 复制frpc.toml配置文件到容器
echo "复制frp配置${FRPC_CONFIG_PATH}路径..."
docker exec ${CONTAINER_NAME} rm -rf ${FRPC_CONFIG_PATH}
docker cp "$(dirname "$0")/frp" ${CONTAINER_NAME}:${FRPC_CONFIG_PATH}

echo "复制frp SHELL${FRPC_SHELL_PATH}路径..."
docker exec ${CONTAINER_NAME} rm -rf ${FRPC_SHELL_PATH}
docker cp "$(dirname "$0")/frp/frpc-service.sh" ${CONTAINER_NAME}:${FRPC_SHELL_PATH}

# 4. 使用此配置启动frpc
echo "启动frpc..."
docker exec ${CONTAINER_NAME} pkill -SIGKILL frpc-service.sh
docker exec ${CONTAINER_NAME} pkill -SIGKILL frpc
docker exec ${CONTAINER_NAME} pkill -SIGKILL -f "busybox ping"

# 检查frp是否运行的函数
function check_frp_status {
    docker exec ${CONTAINER_NAME} pgrep -f frpc > /dev/null
    return $?  # 如果进程存在，返回0；否则返回非0
}

# 启动frp的函数
function start_frp {
    docker exec ${CONTAINER_NAME} ${FRPC_SHELL_PATH} start
}

# 主流程
retry_count=0

while [[ $retry_count -lt $MAX_RETRIES ]]; do
    start_frp  # 执行启动命令
    sleep $RETRY_INTERVAL  # 等待2秒检查

    # 检查frp是否启动成功
    if check_frp_status; then
        echo "frp started successfully."
        exit 0
    else
        echo "frp not started, retrying..."
        retry_count=$((retry_count + 1))
    fi
done

echo "frp failed to start after $MAX_RETRIES retries."

docker exec -d ${CONTAINER_NAME} busybox ping -s 768 frp服务器地址

echo "操作完成。"
