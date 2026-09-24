#!/bin/bash

# Install Nginx
dnf update -y
dnf install -y nginx

sudo systemctl stop nginx
sleep 5

# Remove default welcome block if present
rm -f /etc/nginx/conf.d/default.conf || true

# Write the Nginx config
# Note: Using 'EOF' with single quotes tells Bash to ignore the $ variables
# so Nginx variables like $host aren't destroyed during boot.
cat << 'EOF' > /etc/nginx/conf.d/app.conf
server {
    listen 80;

    # Amazon VPC DNS resolver
    resolver 169.254.169.253 valid=30s;

    location /health {
        access_log off;
        return 200 '{
            "success": true,
            "message": "web is working properly!",
            "data": {
                "status": "healthy"
            }
        }';
        add_header Content-Type text/plain;
    }


    location /app-health {
        set $health_target "http://app.sec-app.internal:3000/health";
        proxy_pass $health_target;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location / {
        set $upstream_endpoint http://app.sec-app.internal;

        proxy_pass $upstream_endpoint:3000;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

# Clean up defaults and start Nginx
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/conf.d/default.conf

systemctl enable nginx
systemctl start nginx
