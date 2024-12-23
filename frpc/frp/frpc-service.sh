#!/bin/bash

# 定义frpc的启动命令和配置文件
FRPC_BIN="/usr/bin/frpc"
FRPC_CONF="/etc/frp/frpc.toml"
FRPC_CMD="$FRPC_BIN -c $FRPC_CONF"

# 定义pid文件路径
PID_FILE="/var/run/frpc.pid"

start_frpc() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "frpc 已经在运行 (PID: $(cat $PID_FILE))。"
        exit 0
    fi

    echo "启动 frpc..."
    nohup $0 watcher > /var/log/frpc.log 2>&1 &
    echo $! > "$PID_FILE"
    disown # 确保脚本 fork 后继续运行
    echo "frpc 已启动 (监控 PID: $(cat $PID_FILE))。"
}

stop_frpc() {
    if [ ! -f "$PID_FILE" ] || ! kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "frpc 未在运行。"
        exit 0
    fi

    echo "停止 frpc (监控 PID: $(cat $PID_FILE))..."
    kill -TERM $(cat "$PID_FILE") 2>/dev/null
    rm -f "$PID_FILE"
    echo "frpc 已停止。"
}

status_frpc() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "frpc 正在运行 (监控 PID: $(cat $PID_FILE))。"
    else
        echo "frpc 未在运行。"
    fi
}

restart_frpc() {
    echo "重启 frpc..."
    stop_frpc
    start_frpc
}

watcher() {
    while true; do
        if ! pgrep -f "$FRPC_CMD" > /dev/null 2>&1; then
            echo "frpc 崩溃，重新启动..."
            $FRPC_CMD &
        fi
        sleep 5
    done
}

case "$1" in
    start)
        start_frpc
        ;;
    stop)
        stop_frpc
        ;;
    status)
        status_frpc
        ;;
    restart)
        restart_frpc
        ;;
    watcher)
        watcher
        ;;
    *)
        echo "使用方法: $0 {start|stop|status|restart}"
        exit 1
        ;;
esac

exit 0
