# WootifyPanel - Quick Deployment Guide

Hướng dẫn cài đặt nhanh WootifyPanel cho các hệ điều hành Ubuntu và RHEL-based (AlmaLinux, Rocky Linux, CentOS).

## 🚀 One-Line Installation

Sử dụng lệnh sau để cài đặt nhanh chóng (yêu cầu quyền root):

```bash
curl -L https://raw.githubusercontent.com/accnet/Wootify-Data/main/deploy.sh -o deploy.sh && chmod +x deploy.sh && sudo ./deploy.sh
```

---

## 🛠 Hướng dẫn chi tiết

Nếu bạn muốn thực hiện từng bước hoặc sử dụng bản release tùy chỉnh:

### Bước 1: Tải Script Deploy
```bash
wget https://raw.githubusercontent.com/accnet/Wootify-Data/main/deploy.sh
```

### Bước 2: Cấp quyền thực thi
```bash
chmod +x deploy.sh
```

### Bước 3: Chạy cài đặt
```bash
sudo ./deploy.sh
```
*Lưu ý: Script sẽ tự động tải file nén `wootify-panel-release.zip` từ repo này và cấu hình toàn bộ hệ thống.*

---

## 📋 Thông tin quan trọng

*   **Cổng truy cập**: `8088` (Hãy đảm bảo bạn đã mở cổng này trong Firewall/Security Group).
*   **Tài khoản mặc định**: 
    *   User: `admin`
    *   Password: `admin`
*   **Thư mục cài đặt**: `/opt/wootify-panel`
*   **Quản lý dịch vụ**: 
    *   Xem trạng thái: `systemctl status wootify-panel`
    *   Xem Log: `journalctl -u wootify-panel -f`

## 🖥 Hệ điều hành hỗ trợ
*   **Ubuntu**: 20.04, 22.04, 24.04+
*   **Debian**: 11, 12+
*   **AlmaLinux / Rocky Linux / RHEL**: 8, 9+
