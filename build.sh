#!/bin/bash

# Màu sắc cho log
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}>>> Bắt đầu quy trình đóng gói Release WootifyPanel...${NC}"

# Đường dẫn bộ GO cài đặt
if [ -d "$HOME/go_dist/go/bin" ]; then
    export PATH=$HOME/go_dist/go/bin:$PATH
fi

# Kiểm tra xem có zip không, cài nếu thiếu
if ! command -v zip &> /dev/null; then
    echo -e "${YELLOW}Chưa cài đặt 'zip'. Đang thử cài đặt...${NC}"
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install zip -y
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y zip
    elif command -v yum &> /dev/null; then
        sudo yum install -y zip
    else
        echo -e "${RED}Không thể cài 'zip' tự động. Vui lòng cài thủ công.${NC}"
        exit 1
    fi
fi

# 1. Xóa các build cũ nếu có
rm -f panel
rm -rf release_build
rm -f wootify-panel-release.zip

# 2. Build ứng dụng
echo -e "${GREEN}[1/4] Đang biên dịch mã nguồn Go sang Binary...${NC}"
env GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o panel main.go

if [ ! -f "panel" ]; then
    echo -e "${RED}Lỗi: Biên dịch Go thất bại!${NC}"
    exit 1
fi
echo -e "${GREEN}Biên dịch thành công (Binary: panel)${NC}"

# 3. Gom file vào thư mục rỗng
echo -e "${GREEN}[2/4] Đang gom các file cần thiết vào thư mục release_build...${NC}"
mkdir release_build

# Copy file chạy
cp panel release_build/
# Copy frontend
cp -r public release_build/
# Copy các script system
cp -r scripts release_build/
# Copy config mẫu thành .env mặc định
cp .env.example release_build/.env

# Đảm bảo quyền thực thi cho các file script bash trước khi zip
chmod +x release_build/panel
chmod -R +x release_build/scripts/


# 4. Nén file zip
echo -e "${GREEN}[3/4] Đang tạo file nén wootify-panel-release.zip...${NC}"
cd release_build
zip -r ../wootify-panel-release.zip ./* .env
cd ..

# 5. Dọn dẹp
echo -e "${GREEN}[4/4] Đang dọn dẹp thư mục tạm...${NC}"
rm -rf release_build
rm -f panel

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN} HOÀN TẤT! Đã tạo thành công bản release: ${YELLOW}wootify-panel-release.zip${NC}"
echo -e "${GREEN} Bây giờ bạn có thể mang file zip này lên VPS thật để deploy.${NC}"
echo -e "${GREEN}====================================================${NC}"
