// lib/main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Đăng Ký',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const RegisterPage(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  DateTime? _selectedDate;
  String? _gender = "Nam";
  bool _isAgree = false;

  // Chọn ngày sinh
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Hàm kiểm tra email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _submitForm() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Kiểm tra
    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email không hợp lệ")),
      );
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(phone) || phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Số điện thoại phải là 10 chữ số")),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu phải ≥ 6 ký tự")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu không khớp")),
      );
      return;
    }

    if (!_isAgree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn phải đồng ý với điều khoản")),
      );
      return;
    }

    // Lưu dữ liệu vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", name);
    await prefs.setString("email", email);
    await prefs.setString("phone", phone);
    await prefs.setString("gender", _gender ?? "");
    await prefs.setString("dob", _selectedDate.toString());

    // Chuyển sang màn hình OTP
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OtpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Đăng Ký Tài Khoản",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Họ & tên",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Số điện thoại",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: "Mật khẩu",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 15),

            TextFormField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: "Xác nhận mật khẩu",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 15),

            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Ngày sinh",
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _selectedDate == null
                      ? "Chọn ngày sinh"
                      : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                ),
              ),
            ),
            const SizedBox(height: 15),

            const Text("Giới tính"),
            RadioListTile(
              title: const Text("Nam"),
              value: "Nam",
              groupValue: _gender,
              onChanged: (value) => setState(() => _gender = value.toString()),
            ),
            RadioListTile(
              title: const Text("Nữ"),
              value: "Nữ",
              groupValue: _gender,
              onChanged: (value) => setState(() => _gender = value.toString()),
            ),
            RadioListTile(
              title: const Text("Khác"),
              value: "Khác",
              groupValue: _gender,
              onChanged: (value) => setState(() => _gender = value.toString()),
            ),

            CheckboxListTile(
              value: _isAgree,
              onChanged: (value) => setState(() => _isAgree = value!),
              title: const Text("Tôi đồng ý với điều khoản sử dụng"),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Đăng Ký"),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= OTP Page ====================
class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();

  void _verifyOtp() {
    if (_otpController.text == "123456") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mã OTP không đúng")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xác minh OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Nhập mã OTP (123456)"),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: "OTP",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOtp,
              child: const Text("Xác minh"),
            )
          ],
        ),
      ),
    );
  }
}
