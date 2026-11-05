#!/bin/sh
set -e
PORT="${PORT:-8080}"
cat > /etc/nginx/nginx.conf <<EOF
worker_processes 1;
error_log /dev/stdout warn;
pid /tmp/nginx.pid;
events { worker_connections 256; }
http {
  access_log off;
  client_body_temp_path /tmp/nginx-body;
  proxy_temp_path /tmp/nginx-proxy;
  fastcgi_temp_path /tmp/nginx-fastcgi;
  uwsgi_temp_path /tmp/nginx-uwsgi;
  scgi_temp_path /tmp/nginx-scgi;
  server {
    listen $PORT;
    location = /health { access_log off; return 200 'ok'; }
    location = /claw-ws {
      proxy_pass http://127.0.0.1:10000;
      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Host \$host;
    }
    location / { return 404; }
  }
}
EOF
mkdir -p /etc/xray
if [ -n "$XRAY_CONFIG" ]; then
  printf '%s' "$XRAY_CONFIG" > /etc/xray/config.json
fi
nginx
exec /usr/local/bin/xray run -config /etc/xray/config.json
