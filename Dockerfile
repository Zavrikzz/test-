FROM alpine:latest

# Установка необходимых утилит и Xray
RUN apk add --no-cache curl bash jq ca-certificates unzip && \
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Создание конфигурации Xray (VLESS + WebSocket)
# Render автоматически передает нужный порт через переменную среды $PORT
RUN mkdir -p /etc/xray
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
