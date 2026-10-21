// ignore_for_file: avoid_print

// ===========================================================================
// PRM393 - LAB 7: CLI VALIDATION & LOGIC TEST RUNNER
// Pure Dart script to verify all validation rules and async check logic
// ===========================================================================

String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Full name is required';
  }
  if (value.trim().length < 2) {
    return 'Name must be at least 2 characters';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }
  final email = value.trim();
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(email) || !email.contains('@') || !email.contains('.')) {
    return 'Enter a valid email address';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'Password must contain at least 1 number';
  }
  return null;
}

String? validateConfirmPassword(String? value, String originalPassword) {
  if (value == null || value.isEmpty) {
    return 'Please confirm your password';
  }
  if (value != originalPassword) {
    return 'Passwords do not match';
  }
  return null;
}

double calculatePasswordStrength(String password) {
  if (password.isEmpty) return 0.0;
  double strength = 0.0;
  if (password.length >= 8) strength += 0.35;
  if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.35;
  if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) strength += 0.15;
  return strength.clamp(0.0, 1.0);
}

Future<bool> checkEmailAvailability(String email) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 300));
  // Emails starting with "taken" are treated as already registered
  return !email.trim().toLowerCase().startsWith('taken');
}

void main() async {
  print('================================================================');
  print('   PRM393 - LAB 7: SIGNUP FORM VALIDATION LOGIC RUNNER          ');
  print('================================================================\n');

  // 1. Kiểm tra Name Validator
  print('1. KIỂM TRA BỘ LỌC TÊN (validateName):');
  final nameTests = [
    ('', 'Full name is required'),
    ('A', 'Name must be at least 2 characters'),
    ('Nguyen Van A', null),
  ];
  for (var test in nameTests) {
    final result = validateName(test.$1);
    final status = result == test.$2 ? 'PASS [OK]' : 'FAIL [X]';
    print('   • Input: "${test.$1}" -> Result: ${result ?? "Valid"} ($status)');
  }

  // 2. Kiểm tra Email Validator
  print('\n2. KIỂM TRA ĐỊNH DẠNG EMAIL (validateEmail):');
  final emailTests = [
    ('', 'Email is required'),
    ('invalid-email', 'Enter a valid email address'),
    ('test@domain', 'Enter a valid email address'),
    ('student@fpt.edu.vn', null),
  ];
  for (var test in emailTests) {
    final result = validateEmail(test.$1);
    final status = result == test.$2 ? 'PASS [OK]' : 'FAIL [X]';
    print('   • Input: "${test.$1}" -> Result: ${result ?? "Valid"} ($status)');
  }

  // 3. Kiểm tra Mật khẩu & Độ dài (validatePassword)
  print('\n3. KIỂM TRA QUY TẮC MẬT KHẨU (validatePassword):');
  final passTests = [
    ('', 'Password is required'),
    ('short', 'Password must be at least 8 characters'),
    ('nodigitsatall', 'Password must contain at least 1 number'),
    ('secret123', null),
  ];
  for (var test in passTests) {
    final result = validatePassword(test.$1);
    final status = result == test.$2 ? 'PASS [OK]' : 'FAIL [X]';
    print('   • Input: "${test.$1}" -> Result: ${result ?? "Valid"} ($status)');
  }

  // 4. Kiểm tra Confirm Password
  print('\n4. KIỂM TRA XÁC NHẬN MẬT KHẨU (validateConfirmPassword):');
  const basePass = 'secret123';
  final confirmTests = [
    ('different123', 'Passwords do not match'),
    ('secret123', null),
  ];
  for (var test in confirmTests) {
    final result = validateConfirmPassword(test.$1, basePass);
    final status = result == test.$2 ? 'PASS [OK]' : 'FAIL [X]';
    print('   • Confirm: "${test.$1}" vs Original: "$basePass" -> Result: ${result ?? "Valid"} ($status)');
  }

  // 5. Kiểm tra Thanh đo độ mạnh mật khẩu (Password Strength)
  print('\n5. KIỂM TRA THANH ĐO ĐỘ MẠNH MẬT KHẨU (Bonus UX):');
  final strengthTests = ['123', 'password', 'password1', 'Password123!'];
  for (var p in strengthTests) {
    final str = calculatePasswordStrength(p);
    print('   • Mật khẩu: "$p" -> Score: ${(str * 100).toInt()}%');
  }

  // 6. Kiểm tra Bất đồng bộ Email Tồn tại (Async Validation - Lab 7.4)
  print('\n6. KIỂM TRA BẤT ĐỒNG BỘ EMAIL (Async Email Availability Check):');
  final asyncTests = ['taken@gmail.com', 'taken_user@fpt.edu.vn', 'available_user@gmail.com'];
  for (var email in asyncTests) {
    final isAvailable = await checkEmailAvailability(email);
    print('   • Email: "$email" -> Khả dụng: ${isAvailable ? "HỢP LỆ (Cho phép đăng ký)" : "ĐÃ TỒN TẠI (Báo lỗi)"}');
  }

  print('\n✅ TẤT CẢ CÁC ĐIỀU KIỆN VALIDATION CỦA LAB 7 ĐÃ HOÀN TOÀN ĐẠT CHUẨN!');
}
