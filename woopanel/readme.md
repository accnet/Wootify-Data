# 🚀 WooPanel (WootifyPanel)

**WooPanel** là một giải pháp quản trị VPS và WordPress mạnh mẽ, được phát triển bằng ngôn ngữ **Go (Gin Framework)**. Panel cung cấp giao diện hiện đại, nhẹ nhàng và hiệu năng cao để quản lý Stack (Nginx, PHP, MariaDB), Website, SSL, và giám sát hệ thống Real-time.

---
## 🚀 Cài đặt nhanh (Deployment)

Dành cho các hệ điều hành **Ubuntu/Debian** và **RHEL-based** (AlmaLinux, Rocky Linux).

### � One-Line Installer
Sử dụng script cài đặt tự động (yêu cầu quyền root):

```bash
curl -L https://github.com/accnet/Public/raw/refs/heads/main/woopanel/deploy.sh -o deploy.sh && chmod +x deploy.sh && sudo ./deploy.sh
```

> **Lưu ý:** Script sẽ tự động thiết lập môi trường, tải bản build mới nhất và cấu hình dịch vụ hệ thống.

---

## ✨ Tính năng nổi bật

- 🏗️ **Quản lý Stack:** Cài đặt và cấu hình nhanh Nginx, PHP, MariaDB.
- 🌐 **Quản trị Website:** Thêm/xóa site, quản lý Virtual Host, cấu hình bảo mật.
- 🔒 **SSL Let's Encrypt:** Tự động cấp phát và gia hạn SSL miễn phí.
- 📊 **Monitoring:** Thống kê CPU, RAM, Disk và Băng thông thời gian thực.
- 🛡️ **Bảo mật:** Tích hợp Rate Limiting, chặn Bot, WAF cơ bản và quản lý Firewall.
- 📂 **File Manager:** (Đang phát triển) Trình quản lý tệp tin trực tiếp trên web.
- ⚡ **Siêu nhẹ:** Binary duy nhất, không yêu cầu dependency phức tạp, tiêu tốn cực ít tài nguyên.

---


