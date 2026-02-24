#!/bin/bash

# Màu sắc cho thông báo
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Vui lòng chạy script với quyền root (sudo).${NC}"
  exit 1
fi

echo -e "${GREEN}>>> Bắt đầu cài đặt WootifyPanel...${NC}"

# 1. Cập nhật hệ thống và cài đặt dependencies
echo -e "${GREEN}[1/5] Cập nhật hệ thống và cài đặt công cụ cần thiết...${NC}"

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    LIKE=$ID_LIKE
else
    echo -e "${RED}Không thể xác định hệ điều hành. Vui lòng cài đặt thủ công các gói: curl git sqlite3 tar wget gcc.${NC}"
    exit 1
fi

if [[ "$OS" == "ubuntu" || "$OS" == "debian" || "$LIKE" == *"debian"* ]]; then
    echo -e "${GREEN}Phát hiện hệ điều hành: Debian/Ubuntu${NC}"
    apt-get update && apt-get install -y curl git sqlite3 tar wget gcc build-essential psmisc
elif [[ "$OS" == "almalinux" || "$OS" == "rocky" || "$OS" == "centos" || "$OS" == "rhel" || "$LIKE" == *"rhel"* ]]; then
    echo -e "${GREEN}Phát hiện hệ điều hành: RHEL/AlmaLinux/Rocky${NC}"
    PKG_MANAGER="dnf"
    if ! command -v dnf &> /dev/null; then PKG_MANAGER="yum"; fi
    $PKG_MANAGER install -y curl git sqlite tar wget gcc make openssl
    
    # Disable SELinux temporarily and permanently
    if command -v setenforce &> /dev/null; then
        setenforce 0 || true
        [ -f /etc/selinux/config ] && sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config || true
    fi
else
    echo -e "${RED}Hệ điều hành không được hỗ trợ tự động: $OS. Vui lòng cài đặt dependencies thủ công.${NC}"
    exit 1
fi

# 2. Cài đặt Go (nếu chưa có)
GO_VERSION="1.24.0"
if ! command -v go &> /dev/null; then
    echo -e "${GREEN}[2/5] Đang cài đặt Go (Golang) $GO_VERSION...${NC}"
    wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
    rm -rf /usr/local/go && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    if ! grep -q "/usr/local/go/bin" /etc/profile; then
        echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile
    fi
    rm go${GO_VERSION}.linux-amd64.tar.gz
else
    echo -e "${GREEN}[2/5] Go đã được cài đặt: $(go version)${NC}"
fi

# 3. Cấu hình dự án Go
echo -e "${GREEN}[3/5] Cấu hình module và tải thư viện...${NC}"
export PATH=$PATH:/usr/local/go/bin
if [ ! -f "go.mod" ]; then
    go mod init lemp-panel || true
fi
go mod tidy

# 4. Build ứng dụng
echo -e "${GREEN}[4/5] Đang build WootifyPanel...${NC}"
go build -o panel main.go

# Tạo thư mục storage nếu chưa có
mkdir -p storage
chmod 755 storage

# Kiểm tra file binary
if [ ! -f "./panel" ]; then
    echo -e "${RED}Lỗi: Build thất bại. Vui lòng kiểm tra lại code.${NC}"
    exit 1
fi

# 5. Tạo Systemd Service để chạy nền
echo -e "${GREEN}[5/5] Cấu hình Systemd Service...${NC}"
SERVICE_FILE="/etc/systemd/system/wootify-panel.service"
CURRENT_DIR=$(pwd)

cat > $SERVICE_FILE <<EOF
[Unit]
Description=WootifyPanel - VPS Management Dashboard
After=network.target

[Service]
User=root
WorkingDirectory=$CURRENT_DIR
ExecStart=$CURRENT_DIR/panel
Restart=always
RestartSec=5
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=wootify-panel

[Install]
WantedBy=multi-user.target
EOF

# Reload daemon và khởi động service
systemctl daemon-reload
systemctl enable wootify-panel
systemctl restart wootify-panel

# Lấy IP Public và Cổng (Mặc định 8088 trong source)
IP_ADDRESS=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   CÀI ĐẶT WOOTIFYPANEL HOÀN TẤT!   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo -e "Truy cập panel tại: http://$IP_ADDRESS:8080"
echo -e "Tài khoản mặc định: admin / admin"
echo -e "Logs service: journalctl -u wootify-panel -f"
echo -e "${GREEN}==============================================${NC}"
