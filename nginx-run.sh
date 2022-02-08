#!/bin/sh
# Docker Entrypoint Script to reconfigure the official nginx:stable with HTTPS
set -ex
if [ ! -e /etc/ssl/example_ca/example.pem ]; then
  mkdir -p /etc/ssl/example_ca
  cd /etc/ssl/example_ca
  openssl genrsa -out example_ca.key 2048
  openssl req -x509 -new -nodes -key example_ca.key -days 36500 \
    -out example_ca.pem -sha256 -subj '/O=Example/CN=example ca'
  openssl genrsa -out example.key 2048
  openssl req -new -key example.key -out example.csr \
    -subj '/O=Example/CN=*.example.com'
  echo "extendedKeyUsage = clientAuth, serverAuth" > /tmp/san.txt
  echo "subjectAltName=IP:127.0.0.1,DNS:example.com,DNS:*.example.com" >> /tmp/san.txt
  openssl x509 -req -in example.csr -CA example_ca.pem \
    -CAkey example_ca.key -CAcreateserial -days 36500 \
    -out example.pem -sha256 -extfile /tmp/san.txt
  cat /etc/ssl/example_ca/example.pem /etc/ssl/example_ca/example_ca.pem > /etc/ssl/example_ca/example_chain.pem
  test -d /usr/share/ca-certificates/example_ca || mkdir /usr/share/ca-certificates/example_ca
  cp -f /etc/ssl/example_ca/example_ca.pem /usr/share/ca-certificates/example_ca/example_ca.pem
  echo "example_ca/example_ca.pem" >> /etc/ca-certificates.conf
  update-ca-certificates -f
  openssl verify /etc/ssl/example_ca/example.pem
fi
BACKEND=${BACKEND:-"localhost:8080"}
cat <<EOF> /etc/nginx/conf.d/default.conf
server_tokens off;
upstream backend {
  server $BACKEND;
}
EOF
cat <<'EOF'>> /etc/nginx/conf.d/default.conf
server {
  listen      80;
  server_name  _;
  listen 443 ssl;
  ssl_certificate /etc/ssl/example_ca/example.pem;
  ssl_certificate_key /etc/ssl/example_ca/example.key;
  ssl_protocols TLSv1.2;
  ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;
  if ($scheme = http) {
    return 301 https://$host$request_uri;
  }
  location / {
    proxy_pass http://backend;
    proxy_http_version 1.1;
    proxy_buffering off;
    proxy_set_header Host $http_host;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Port $server_port;
    proxy_set_header Proxy "";
    proxy_redirect off;
  }
  location = /favicon.ico {
    log_not_found off;
    access_log off;
  }
  error_page 401 403 404 @40x;
  location @40x {
    default_type text/html;
    return 404 "<html>\n<head><title>Not Found!</title></head>\n<body>\n<center><h1>Not Found!</h1></center>\n</body>\n</html>\n";
  }
  error_page 500 502 503 504 @50x;
  location @50x {
    default_type text/html;
    return 500 "<html>\n<head><title>Internal Server Error!</title></head>\n<body>\n<center><h1>Internal Server Error!</h1></center>\n</body>\n</html>\n";
  }
}
EOF
exec nginx -g 'daemon off;'