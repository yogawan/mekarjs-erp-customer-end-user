import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/api.dart';

class VerifyOtpPage extends StatefulWidget {
  final String nama;
  final String email;
  final String password;

  const VerifyOtpPage({
    super.key,
    required this.nama,
    required this.email,
    required this.password,
  });

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  Future<void> verifyOtp() async {
    if (otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kode OTP tidak boleh kosong")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final dio = Dio();

      final response = await dio.post(
        "${Api.baseUrl}/api/customer/account/verify-otp",
        data: {
          "nama": widget.nama,
          "email": widget.email,
          "password": widget.password,
          "otp": otpController.text.trim(),
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        final msg = response.data["message"] ?? "Akun berhasil diverifikasi & dibuat!";
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );

          // Navigate back to login page (pop twice: OTP page and create account page)
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = "Gagal verifikasi OTP";
        
        if (e is DioException && e.response != null) {
          errorMsg = e.response?.data["message"] ?? errorMsg;
        } else {
          errorMsg = "$errorMsg: $e";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFEEEEEE),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Verifikasi Akun Anda",
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Kode OTP telah dikirim ke email ${widget.email}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Kode OTP",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: "Masukan kode OTP 6 digit",
                filled: true,
                fillColor: Colors.white,
                counterText: "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFBB00), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : verifyOtp,
                icon: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(LucideIcons.checkCircle, size: 20),
                label: const Text(
                  "Verifikasi",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFBB00),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}