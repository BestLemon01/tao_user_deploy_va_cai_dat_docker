#!/bin/bash
# ==============================================================================
# Script tự động hóa tạo user deploy, cấp quyền sudo và cài đặt Docker Engine
# Thực thi trên Ubuntu 22.04 LTS dưới quyền root
# ==============================================================================
set -e

echo "=== 1. Cập nhật hệ điều hành ==="
apt update && apt upgrade -y

echo "=== 2. Tạo User 'deploy' và cấp quyền sudo ==="
if ! id -u deploy > /dev/null 2>&1; then
    adduser --gecos "" --disabled-password deploy
    echo "deploy:Deploy@2026!Secure" | chpasswd
    usermod -aG sudo deploy
    echo "User 'deploy' đã được tạo và cấp quyền sudo thành công."
else
    echo "User 'deploy' đã tồn tại."
fi

echo "=== 3. Cài đặt các gói phụ thuộc để cấu hình kho Docker chính thức ==="
apt install -y ca-certificates curl gnupg lsb-release

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "=== 4. Cài đặt Docker Engine và Docker Compose Plugin ==="
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "=== 5. Thêm user 'deploy' vào group 'docker' ==="
usermod -aG docker deploy

echo "=== 6. Khởi động và kích hoạt dịch vụ Docker ==="
systemctl enable docker
systemctl start docker

echo "=== HOÀN TẤT THIẾT LẬP MÔI TRƯỜNG DOCKER CHO USER DEPLOY ==="
