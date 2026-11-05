FROM alpine:latest
RUN apk add --no-cache nginx curl unzip ca-certificates \
 && curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v26.10.21/Xray-linux-64.zip \
 && unzip -o /tmp/xray.zip -d /tmp/xray \
 && mv /tmp/xray/xray /usr/local/bin/xray \
 && mkdir -p /usr/local/share/xray /etc/xray \
 && cp /tmp/xray/geoip.dat /tmp/xray/geosite.dat /usr/local/share/xray/ \
 && chmod +x /usr/local/bin/xray \
 && rm -rf /tmp/xray /tmp/xray.zip
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
