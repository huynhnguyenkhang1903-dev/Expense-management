# 💰 MoneyFlow — Ứng dụng Quản lý Tài chính & Chi tiêu Cá nhân

> **Đồ án Chuyên ngành Công nghệ Phần mềm**  
> Kiến trúc: **Clean Architecture (ASP.NET Core 10 Web API) + Feature-First (Flutter 3.x) + Microsoft SQL Server**

---

## 🏗️ 1. Cấu trúc Hệ thống (Monorepo)

```text
App quản lý chi tiêu/
├── backend/                               # Backend RESTful API (.NET 10)
│   ├── MoneyFlow.sln
│   └── src/
│       ├── MoneyFlow.Domain/              # Thực thể (Entities), Enums, BaseEntity
│       ├── MoneyFlow.Application/         # DTOs, Business Interfaces, PagedResult, ApiResponse
│       ├── MoneyFlow.Infrastructure/      # AppDbContext, EF Core Migrations, JWT Token, BCrypt, Services
│       └── MoneyFlow.Api/                 # Web API Controllers, Middleware, Scalar API Documentation
├── mobile/                                # Flutter Mobile Client (Android & iOS)
│   ├── pubspec.yaml
│   └── lib/
│       ├── core/                          # Theme tài chính, ApiClient (Dio), StorageService, Formatter
│       └── features/                      # Auth, Dashboard, Wallets, Transactions, Budgets, Reports, Settings
└── docs/                                  # Tài liệu phân tích, ERD, Use Case
```

---

## ⚡ 2. Hướng dẫn Khởi chạy Nhanh Nhất (1-Click)

Bạn có thể chạy dự án cực kỳ dễ dàng bằng 2 cách:

### 🌟 Cách 1: Chạy bằng file 1-Click (Khuyên Dùng)
1. **Chạy Backend**: Nhấp đúp chuột vào file `1_Chay_Backend.bat` ở thư mục gốc.
   - API Backend sẽ mở tại: `http://localhost:5000`
   - Tài liệu API tương tác (Scalar UI): `http://localhost:5000/scalar/v1`
2. **Chạy Mobile App (Web Chrome)**: Nhấp đúp chuột vào file `2_Chay_Mobile_Web.bat`.
   - Ứng dụng sẽ tự động mở trên Google Chrome với giao diện Obsidian Dark sang trọng.
3. **Chạy trên Android Emulator**: Khởi động máy ảo Android Studio rồi nhấp đúp file `3_Chay_Mobile_Android.bat`.

---

### 💻 Cách 2: Khởi chạy bằng lệnh Terminal trong VS Code
- **Terminal 1 (Backend)**:
  ```bash
  cd backend
  dotnet run --project src/MoneyFlow.Api --no-launch-profile --urls "http://localhost:5000"
  ```
- **Terminal 2 (Mobile App)**:
  ```bash
  cd mobile
  flutter run -d chrome
  ```

---

## 🌟 3. Các Tính Năng Đỉnh Cao Chuẩn Doanh Nghiệp (Enterprise VIP Suite)

Hệ thống được thiết kế theo tiêu chuẩn phần mềm tài chính quy mô lớn của các tập đoàn công nghệ & ngân hàng quốc tế:

1. **🏆 Chỉ số Sức Khỏe Tài Chính (Financial Health Score 0 - 1.000)**:
   - Tự động đánh giá theo **4 Trụ Cột Độc Lập** (mỗi trụ cột tối đa 250 điểm):
     1. *Tích Lũy & Tiết Kiệm*: Tỷ lệ tích lũy ròng trên tổng thu nhập.
     2. *Kiểm Soát Chi Tiêu*: Tỷ trọng dòng tiền chi/thu.
     3. *Quỹ Dự Phòng Khẩn Cấp (Emergency Runway)*: Số tháng có thể duy trì sinh hoạt với số dư khả dụng hiện tại.
     4. *Kỷ Luật Ngân Sách*: Mức độ tuân thủ hạn mức chi tiêu đã đề ra.
   - Phân cấp hội viên: **AAA+ Private Client**, **AA Ưu Tiên**, **Hạng Vàng**, **Hạng Bạc**, **Hạng C**.

2. **🤖 Trợ Lý Cố Vấn Tài Chính AI (MoneyFlow AI Advisor)**:
   - Trực tiếp hỏi đáp bằng ngôn ngữ tự nhiên: "Tháng này tôi đã chi tiêu bao nhiêu?", "Hạn mức mua sắm an toàn cho một món đồ là bao nhiêu?", "Làm sao tăng điểm sức khỏe tài chính?".
   - Hệ thống tự động truy vấn dữ liệu thời gian thực và phân tích đưa ra lời khuyên cá nhân hóa.

3. **📸 Mô Phỏng Quét Hóa Đơn Thông Minh (AI Smart OCR Scanner)**:
   - Hiệu ứng quét laser hiện đại, tự động trích xuất: Số tiền, Danh mục, Đơn vị bán lẻ (Highlands Coffee, WinMart, Petrolimex...) và tự động điền sẵn vào màn hình tạo giao dịch.

4. **🎯 Hũ Tiết Kiệm & Quỹ Tích Lũy Tự Động (Savings Goals & Vaults)**:
   - Thiết lập mục tiêu tài chính (Mua laptop, Quỹ dự phòng 6 tháng, Du lịch...).
   - Tính toán tiến độ %, số tiền còn thiếu, đếm ngược ngày đến hạn.
   - Thao tác **1-Chạm nạp thêm tiền** trích trực tiếp từ nguồn ví thực tế.

5. **📑 Sổ Nợ & Cho Vay Chuyên Nghiệp (Debts & Loans Management)**:
   - Tách biệt rõ ràng nghiệp vụ "Cho Vay (Phải Thu)" và "Tôi Nợ (Phải Trả)" tránh tính trùng dòng tiền chi tiêu (chuẩn mực kế toán doanh nghiệp).
   - Hỗ trợ thanh toán từng phần, theo dõi dư nợ giảm dần và tự động cập nhật số dư ví.

6. **🧾 Hóa Đơn & Gói Thuê Bao Định Kỳ (Bills & Subscriptions)**:
   - Quản lý tiền nhà, điện nước, mạng Internet, gói Netflix, Spotify...
   - Tự động đếm ngược ngày đến hạn, gắn cờ cảnh báo quá hạn.
   - **Thanh toán 1-Chạm**: Tự động trừ tiền ví, tạo giao dịch chi tiêu và dời hạn sang chu kỳ tháng kế tiếp.

7. **🛡️ Bảo Mật Riêng Tư & Báo Cáo Doanh Nghiệp**:
   - **Chế độ Riêng Tư 1-Chạm (Privacy Mode)**: Ẩn toàn bộ số dư và số tiền trên màn hình (`•••••••• ₫`).
   - **Xuất Dữ Liệu CSV Chuẩn ERP**: Xuất dữ liệu giao dịch UTF-8 BOM sẵn sàng mở trên Microsoft Excel mà không bị lỗi font tiếng Việt.
   - **Nhật Ký Kiểm Toán (Audit Logs)**: Ghi nhận sự kiện bảo mật theo chuẩn ISO 27001.

---

## 💎 4. Kiến Trúc Kỹ Thuật Đồ Án
- **Backend**: C# 13, ASP.NET Core 10 Web API, Entity Framework Core 10, SQL Server LocalDB.
- **Mobile**: Flutter 3.x, Dart 3.x, Provider State Management, Dio HTTP Client, FL Chart.
- **Giao diện**: Obsidian Dark Luxury Theme (#090D16, #131B2A, #10B981, #F59E0B).
