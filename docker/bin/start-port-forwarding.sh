#!/bin/bash

# 确保 FORWARD_PORTS 变量已设置
if [ -z "$FORWARD_PORTS" ]; then
    echo "[Port forwarding] NOTE: FORWARD_PORTS is not set"
    exit 1
fi

# 启用 IP 转发
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=1

# 解析 FORWARD_PORTS 变量
IFS=',' read -ra PORTS <<< "$FORWARD_PORTS"
for entry in "${PORTS[@]}"; do
    IFS=':' read -r local_port remote_ip remote_port <<< "$entry"
    
    if [[ -z "$local_port" || -z "$remote_ip" || -z "$remote_port" ]]; then
        echo "[Port forwarding] ERROR: Port forwarding rule format error: $entry"
        continue
    fi

    echo "[Port forwarding] Setting up port forwarding: local $local_port -> remote $remote_ip:$remote_port"
    
    # 设置 PREROUTING 规则，将流量从本地端口重定向到目标地址
    iptables -t nat -A PREROUTING -p tcp --dport "$local_port" -j DNAT --to-destination "$remote_ip:$remote_port"
    iptables -t nat -A PREROUTING -p udp --dport "$local_port" -j DNAT --to-destination "$remote_ip:$remote_port"
    
    # 允许数据包通过 POSTROUTING
    iptables -t nat -A POSTROUTING -p tcp -d "$remote_ip" --dport "$remote_port" -j MASQUERADE
    iptables -t nat -A POSTROUTING -p udp -d "$remote_ip" --dport "$remote_port" -j MASQUERADE
    
    # 设置 OUTPUT 规则，将流量从本地端口重定向到目标地址
    iptables -t nat -A OUTPUT -p tcp --dport "$local_port" -j DNAT --to-destination "$remote_ip:$remote_port"
    iptables -t nat -A OUTPUT -p udp --dport "$local_port" -j DNAT --to-destination "$remote_ip:$remote_port"

    iptables -A INPUT -p tcp --dport "$local_port" -j ACCEPT
    iptables -A INPUT -p udp --dport "$local_port" -j ACCEPT
done

echo "[Port forwarding] Port forwarding configuration completed"
