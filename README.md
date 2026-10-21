# PRM393 - LAB 7: BUILDING A SIGNUP FORM WITH VALIDATION & GOOD UX

> **Học phần**: PRM393 - Mobile Programming (Flutter & Dart)  
> **Chủ đề**: Forms & Validation (Module 7)  
> **Mục tiêu**: Xây dựng màn hình đăng ký tài khoản (Signup Form) hoàn chỉnh, trực quan với cơ chế kiểm thực dữ liệu đồng bộ và bất đồng bộ (Synchronous & Asynchronous Validation), quản lý bàn phím và con trỏ chuột mượt mà (Focus Management), cùng trải nghiệm người dùng chuẩn Material 3.

---

## 1. TỔNG QUAN VỀ DỰ ÁN

Dự án triển khai trọn vẹn cả 4 Sub-tasks theo đúng yêu cầu học phần trong tài liệu Lab 7:
- **Lab 7.1 – Basic Registration Form**:
  - Quản lý biểu mẫu bằng `Form` và `GlobalKey<FormState>`.
  - Thu thập đầy đủ 4 trường: Full Name, Email Address, Password, Confirm Password.
  - Xử lý sự kiện Submit với `validate()` và `save()`.
- **Lab 7.2 – Validation Rules & Password Strength**:
  - Tất cả các trường bắt buộc không được để trống (`required`).
  - Định dạng Email hợp lệ (phải chứa ký tự `@` và `.`).
  - Quy tắc mật khẩu an toàn: Tối thiểu 8 ký tự và phải chứa ít nhất 1 chữ số (`RegExp(r'[0-9]')`).
  - Xác nhận mật khẩu (`Confirm Password`) phải trùng khớp 100% với mật khẩu đã nhập.
  - Phản hồi lỗi tức thì theo thời gian thực nhờ `AutovalidateMode.onUserInteraction`.
  - Tách bạch các hàm validator riêng biệt (`validateName`, `validateEmail`, `validatePassword`, `validateConfirmPassword`) để dễ bảo trì và kiểm thử đơn vị.
- **Lab 7.3 – Focus & Keyboard Management**:
  - Gán `FocusNode` riêng biệt cho từng trường nhập liệu.
  - Cấu hình `TextInputAction.next` giúp người dùng nhấn nút Next trên bàn phím để tự động nhảy từ Full Name ➔ Email ➔ Password ➔ Confirm Password.
  - Trường Confirm Password gán `TextInputAction.done` để tự động kích hoạt nộp form.
  - Bao bọc toàn màn hình bằng `GestureDetector` gọi `FocusScope.of(context).unfocus()` để ẩn bàn phím khi chạm ra ngoài form.
  - Sử dụng `SingleChildScrollView` chống tràn pixel (RenderFlex Overflow) khi bàn phím ảo bật lên trên thiết bị di động.
- **Lab 7.4 – Asynchronous Validation (Email Availability Check)**:
  - Giả lập kiểm tra email đã được đăng ký hay chưa thông qua API bất đồng bộ (`Future.delayed(const Duration(seconds: 2))`).
  - Quy ước kiểm tra: Email bắt đầu bằng `"taken"` (ví dụ: `taken@example.com`) sẽ bị từ chối với thông báo "This email is already taken".
  - Trong lúc kiểm tra: Nút Submit tự động chuyển sang trạng thái Disabled và hiển thị biểu tượng quay vòng `CircularProgressIndicator`.
  - Khi đăng ký thành công: Hiển thị hộp thoại `AlertDialog` chúc mừng kèm bảng tóm tắt thông tin tài khoản vừa tạo.

Ngoài ra, dự án bổ sung các **tính năng nâng cao (Bonus UX Enhancements)**:
- Hộp kiểm điều khoản dịch vụ **Terms & Conditions** (`CheckboxListTile`) bắt buộc người dùng đồng ý trước khi đăng ký.
- Nút icon **Show / Hide Password** (mắt ẩn/hiện) cho cả 2 ô mật khẩu.
- Thanh đo độ mạnh mật khẩu trực quan (**Live Password Strength Indicator**) tự động đổi màu theo 3 cấp độ (Yếu: Đỏ ➔ Trung bình: Cam ➔ Mạnh: Xanh).
- Nút làm mới nhanh (**Reset / Clear All Fields**) đưa toàn bộ biểu mẫu về trạng thái ban đầu.

---

## 2. CẤU TRÚC THƯ MỤC DỰ ÁN

```text
prm393_lab_7/
├── bin/
│   └── cli_runner.dart            # Script kiểm thử độc lập các hàm validator & logic async
├── lib/
│   ├── main.dart                  # Toàn bộ mã nguồn ứng dụng hoàn chỉnh
│   └── dartpad_single_file.dart   # File đơn độc lập, copy trực tiếp vào DartPad Flutter
├── test/
│   └── widget_test.dart           # Bộ widget tests kiểm tra layout, validation và submit flow
├── pubspec.yaml                   # Cấu hình dự án (Hoàn toàn dùng Flutter SDK thuần, 0 dependency)
└── README.md                      # Báo cáo học thuật và tài liệu hướng dẫn thuyết trình
```

---

## 3. CHI TIẾT CÁC SUB-TASK VÀ GIẢI THÍCH MÃ NGUỒN

### 🎯 Lab 7.1: Khởi tạo Form và Quản trị State
- Khởi tạo khóa quản lý trạng thái form:
  ```dart
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ```
- Luồng Submit chuẩn:
  ```dart
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    // Thực thi đăng ký
  }
  ```

### 🎯 Lab 7.2: Quy tắc Validation & Kiểm tra Mật khẩu
- Tất cả logic kiểm thực được chuẩn hóa thành các hàm thuần túy (pure functions):
  ```dart
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Password must contain at least 1 number';
    return null;
  }
  ```
- Xác nhận mật khẩu:
  ```dart
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }
  ```

### 🎯 Lab 7.3: Quản lý Tiêu điểm (Focus) & Trải nghiệm Bàn phím
- Dịch chuyển tiêu điểm mượt mà qua thuộc tính `onFieldSubmitted`:
  ```dart
  TextFormField(
    controller: _nameController,
    focusNode: _nameFocusNode,
    textInputAction: TextInputAction.next,
    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocusNode),
  )
  ```
- Đóng bàn phím khi bấm ra ngoài:
  ```dart
  GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    child: Scaffold(...),
  )
  ```

### 🎯 Lab 7.4: Kiểm tra Email Bất đồng bộ (Async Validation)
- Giả lập kiểm tra tồn tại phía Backend:
  ```dart
  setState(() => _isCheckingEmail = true);
  await Future.delayed(const Duration(seconds: 2));

  if (_emailController.text.trim().toLowerCase().startsWith('taken')) {
    setState(() {
      _isCheckingEmail = false;
      _asyncEmailError = 'This email is already taken. Try another.';
    });
    _formKey.currentState?.validate();
    _emailFocusNode.requestFocus();
    return;
  }
  ```

---

## 4. HƯỚNG DẪN CHẠY VÀ KIỂM THỬ

### Cách 1: Chạy trực tiếp trên Web (Chrome) hoặc Windows Desktop
```powershell
cd D:\1.Work\Programs\flutter\prm393_lab_7
flutter run -d chrome
# Hoặc chạy trên Windows Desktop:
flutter run -d windows
```

### Cách 2: Chạy kiểm thử tự động (Widget Tests)
Xác thực tất cả các trường hợp: trường rỗng, email sai, mật khẩu yếu, kiểm tra email trùng và đăng ký thành công:
```powershell
flutter test
```
*Kết quả xác thực: `00:02 +1: All tests passed!`*

### Cách 3: Chạy Dart CLI runner (Không cần mở máy ảo)
```powershell
dart run bin/cli_runner.dart
```

### Cách 4: Chạy online trên DartPad
1. Mở trình duyệt truy cập: [https://dartpad.dev/](https://dartpad.dev/)
2. Góc dưới cùng bên phải chọn **Flutter**.
3. Mở file [`lib/dartpad_single_file.dart`](file:///d:/1.Work/Programs/flutter/prm393_lab_7/lib/dartpad_single_file.dart), copy toàn bộ nội dung và dán vào DartPad.
4. Bấm **Run** để chạy ngay trên trình duyệt.

---

## 5. KỊCH BẢN THUYẾT MINH 3 PHÚT TRƯỚC GIẢNG VIÊN

| Thời gian | Nội dung trình bày | Thao tác demo trực quan |
| :--- | :--- | :--- |
| **00:00 - 00:45** | Chào thầy/cô, giới thiệu mục tiêu Lab 7: Xây dựng Form đăng ký tài khoản với quy chuẩn Validation đồng bộ & bất đồng bộ, kết hợp quản lý bàn phím nâng cao (Focus Management). | Mở app trên Chrome hoặc Windows. Chỉ vào giao diện Card bo tròn, có sẵn 4 ô nhập liệu và các icon tương ứng. |
| **00:45 - 01:30** | Demo tính năng kiểm thực lỗi (Lab 7.1 & 7.2): Bấm "Create Account" khi form còn trống. Sau đó nhập thử tên quá ngắn ("A"), email sai định dạng ("test@"), mật khẩu không có số ("password"). | Bấm nút Submit khi chưa nhập gì: 4 lỗi đỏ hiện lên đồng thời. Nhập thử dữ liệu sai để thầy thấy thông báo lỗi chi tiết theo thời gian thực nhờ `onUserInteraction`. |
| **01:30 - 02:15** | Demo tính năng Focus bàn phím (Lab 7.3) và thước đo mật khẩu (Bonus): Bấm phím Enter/Next để con trỏ tự động nhảy tuần tự từ Tên ➔ Email ➔ Mật khẩu. Nhập mật khẩu để thanh màu đổi từ Đỏ sang Xanh. | Gõ phím Next trên bàn phím để di chuyển focus. Nhập mật khẩu "Secret123" để thanh Strength nhảy lên 70% màu Cam và hiện nhãn "Medium". Bấm nút mắt xem mật khẩu. |
| **02:15 - 03:00** | Demo tính năng Async Email Validation (Lab 7.4): Nhập email `taken@gmail.com` để xem nút Submit quay vòng 2 giây rồi báo lỗi email đã tồn tại. Sau đó đổi sang `student@fpt.edu.vn` để đăng ký thành công và bật hộp thoại chúc mừng. | Nhập `taken@test.com` và Submit ➔ Nút hiện vòng xoay "Checking email..." rồi báo lỗi đỏ. Đổi sang email hợp lệ và tích chọn Terms ➔ Hộp thoại "Signup Successful!" hiện lên với đầy đủ thông tin tài khoản. |
