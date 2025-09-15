# Stage 1: build React
FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json ./
RUN npm install --legacy-peer-deps
COPY . .
RUN npm run build

# Stage 2: serve với Nginx
FROM nginx:stable-alpine
WORKDIR /app

# Copy runtime templates + entrypoint
COPY public/env-config.js.template /app/env-config.js.template
COPY nginx/default.conf.template   /etc/nginx/conf.d/default.conf.template
COPY nginx/default.conf.ingress    /etc/nginx/conf.d/default.conf.ingress
COPY entrypoint.sh                 /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy build output
COPY --from=builder /app/dist      /usr/share/nginx/html

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
