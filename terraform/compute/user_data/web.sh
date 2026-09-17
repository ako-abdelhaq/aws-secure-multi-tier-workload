#!/bin/bash
dnf update -y
dnf install -y nginx

# Remove default welcome block if present
rm -f /etc/nginx/conf.d/default.conf

# Configure the reverse proxy using internal DNS
cat << 'EON' > /etc/nginx/conf.d/app.conf
server {
    listen 80 default_server;
    server_name _;
    server_tokens off;

    # Point to the VPC DNS resolver (10.0.0.2)
    resolver 10.0.0.2 valid=10s ipv6=off;
    set $upstream_endpoint http://api.sec-app.internal:3000;

    location / {
        proxy_pass $upstream_endpoint;
        proxy_http_version 1.2;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_connect_timeout 5s;
        proxy_read_timeout 60s;
        proxy_send_timeout 60s;
    }
}
EON

systemctl enable nginx
systemctl restart nginx