#!/bin/bash
set -e

# Logging colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}>>> Bắt đầu triển khai WootifyPanel...${NC}"

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Vui lòng chạy script này dưới quyền root (sudo ./deploy.sh)${NC}"
  exit 1
fi

# 1. Cài đặt các thư viện cần thiết (unzip, ufw/firewalld)
echo -e "${GREEN}[1/5] Đang kiểm tra và cài đặt thư viện cần thiết...${NC}"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    LIKE=$ID_LIKE
fi

IS_DEBIAN=false
IS_RHEL=false

if [[ "$OS" == "ubuntu" || "$OS" == "debian" || "$LIKE" == *"debian"* ]]; then
    IS_DEBIAN=true
    apt-get update -y > /dev/null 2>&1
    apt-get install -y unzip ufw > /dev/null 2>&1
elif [[ "$OS" == "centos" || "$OS" == "rhel" || "$OS" == "fedora" || "$OS" == "almalinux" || "$OS" == "rocky" || "$LIKE" == *"rhel"* || "$LIKE" == *"fedora"* ]]; then
    IS_RHEL=true
    if command -v dnf &> /dev/null; then
        dnf install -y unzip firewalld > /dev/null 2>&1
    else
        yum install -y unzip firewalld > /dev/null 2>&1
    fi
fi

# 2. Giải nén file release
echo -e "${GREEN}[2/5] Đang giải nén wootify-panel-release.zip...${NC}"
if [ ! -f "wootify-panel-release.zip" ]; then
    echo -e "${RED}Lỗi: Không tìm thấy file wootify-panel-release.zip trong thư mục hiện tại!${NC}"
    exit 1
fi

INSTALL_DIR="/opt/wootify-panel"
mkdir -p "$INSTALL_DIR"
unzip -o wootify-panel-release.zip -d "$INSTALL_DIR" > /dev/null 2>&1

# 3. Phân quyền
echo -e "${GREEN}[3/5] Đang cấu hình phân quyền...${NC}"
chmod +x "$INSTALL_DIR/panel"
chmod -R +x "$INSTALL_DIR/scripts/"

# 4. Mở cổng 8080
echo -e "${GREEN}[4/5] Đang cấu hình tường lửa (mở cổng 8080, 80, 443)...${NC}"
if [ "$IS_DEBIAN" = true ]; then
    ufw allow 8080/tcp > /dev/null 2>&1 || true
    ufw allow 80/tcp > /dev/null 2>&1 || true
    ufw allow 443/tcp > /dev/null 2>&1 || true
    ufw reload > /dev/null 2>&1 || true
elif [ "$IS_RHEL" = true ]; then
    systemctl start firewalld || true
    systemctl enable firewalld || true
    firewall-cmd --permanent --add-port=8080/tcp > /dev/null 2>&1 || true
    firewall-cmd --permanent --add-service=http > /dev/null 2>&1 || true
    firewall-cmd --permanent --add-service=https > /dev/null 2>&1 || true
    firewall-cmd --reload > /dev/null 2>&1 || true
fi

# 5. Thiết lập systemd service chạy ngầm
echo -e "${GREEN}[5/5] Đang thiết lập Systemd Service (tự khởi động cùng VPS)...${NC}"
cat > /etc/systemd/system/wootify-panel.service <<SERVICE_EOF
[Unit]
Description=WootifyPanel Dashboard Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/panel
EnvironmentFile=$INSTALL_DIR/.env
Restart=always
RestartSec=5
# Output logs
StandardOutput=append:/var/log/wootify_panel.log
StandardError=append:/var/log/wootify_panel_error.log

[Install]
WantedBy=multi-user.target
SERVICE_EOF

systemctl daemon-reload
systemctl enable wootify-panel
systemctl restart wootify-panel

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN} HOÀN TẤT TRIỂN KHAI!${NC}"
echo -e "${GREEN} WootifyPanel đang chạy ngầm dưới hệ thống.${NC}"
echo -e "${GREEN} Truy cập ngay tại: ${YELLOW}http://<IP_CỦA_BẠN>:8080${NC}"
echo -e "${GREEN} Tài khoản mặc định: admin / CHANGE_ME_STRONG_PASSWORD${NC}"
echo -e "${GREEN} (Nếu quên mật khẩu, hãy sửa file $INSTALL_DIR/.env rồi khởi động lại: systemctl restart wootify-panel)${NC}"
echo -e "${GREEN}====================================================${NC}"
