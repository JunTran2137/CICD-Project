#!/bin/sh
set -e

# Inject runtime‐env
envsubst '${APP_API_HOST} ${APP_API_PORT}' \
  < /app/env-config.js.template \
  > /usr/share/nginx/html/env-config.js

# Chọn config Nginx
if [ -n "$APP_API_HOST" ]; then
  # Docker Compose / direct-service: proxy nội bộ
  envsubst '${APP_API_HOST} ${APP_API_PORT}' \
    < /etc/nginx/conf.d/default.conf.template \
    > /etc/nginx/conf.d/default.conf
else
  # Kubernetes Ingress: serve SPA
  cp /etc/nginx/conf.d/default.conf.ingress \
     /etc/nginx/conf.d/default.conf
fi

# Start Nginx
exec nginx -g 'daemon off;'
