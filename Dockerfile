FROM alpine:latest

# Установка утилит
RUN apk add --no-cache curl unzip ca-certificates jq

# Прямая загрузка и распаковка ядра Xray (без капризных скриптов установки)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then XRAY_ARCH="64"; \
    elif [ "$ARCH" = "aarch64" ]; then XRAY_ARCH="arm64-v8a"; \
    else XRAY_ARCH="64"; fi && \
    curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-$XRAY_ARCH.zip && \
    mkdir -p /usr/local/bin /etc/xray && \
    unzip /tmp/xray.zip -d /usr/local/bin/ && \
    rm /tmp/xray.zip

# Создание конфигурации Xray (VLESS + WebSocket)
RUN echo '{\
  "log": {"loglevel": "warning"},\
  "inbounds": [{\
    "port": 10000,\
    "protocol": "vless",\
    "settings": {\
      "clients": [{"id": "b83a38e5-3224-42df-8b3f-b3d6836791e8", "level": 0}],\
      "decryption": "none"\
    },\
    "streamSettings": {\
      "network": "ws",\
      "wsSettings": {"path": "/vless-ws"}\
    }\
  }],\
  "outbounds": [{"protocol": "freedom"}]\
}' > /etc/xray/config.json

EXPOSE 10000

CMD ["xray", "run", "-config", "/etc/xray/config.json"]
