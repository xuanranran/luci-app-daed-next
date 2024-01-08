NODE_BIN=/usr/bin/node
WEB_SQUASHFS=/usr/share/daed-next/daed-web.squashfs
PID_FILE=/tmp/log/daed-next/dashboard.pid

# 检查按钮状态
if [ -e "$PID_FILE" ]; then
    # 如果 PID 文件存在，说明进程已经在运行，因此关闭它
    PID=$(cat "$PID_FILE")
    kill $PID
    rm "$PID_FILE"
    sync && echo 3 > /proc/sys/vm/drop_caches
    umount /var/daed-next
else
    # 如果 PID 文件不存在，说明进程未在运行，因此启动它
    listen_port=$(uci -q get daed-next.config.listen_port)
    
    [ ! -d /var/daed-next ] && mkdir -p /var/daed-next
    mount -t squashfs $WEB_SQUASHFS /var/daed-next
    
    ARGS="PORT=$listen_port HOSTNAME=0.0.0.0"
    
    # 启动 Node.js 服务器，并将其 PID 写入文件
    /bin/sh -c "$ARGS $NODE_BIN /var/daed-next/server.js" &
    echo $! > "$PID_FILE"
fi
