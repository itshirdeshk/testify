import 'dart:async';
import 'package:flutter/material.dart';
import 'package:testify/controllers/auth_controller.dart';
import 'package:testify/services/auth_service.dart';
import 'package:testify/widgets/custom_toast.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final bool screen;

  const OtpScreen({super.key, required this.email, required this.screen});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final AuthController _authController = AuthController();
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  bool _isLoading = false;
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleVerifyOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authController.verifyOtp(context, widget.email, widget.screen);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResetPassword() async {
    setState(() => _isLoading = true);
    final AuthService authService = AuthService();
    try {
      final response = await authService.sendOtpAgain(widget.email, context);

      if (!mounted) return;

      if (response.statusCode == 200) {
        CustomToast.show(
          context: context,
          message: 'OTP send successfully',
        );
      } else {
        CustomToast.show(
          context: context,
          message: response.data['message'],
          isError: true,
        );
      }
    } catch (e) {
      CustomToast.show(
        context: context,
        message: 'An error occurred',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey, // Assign the form key
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildOtpFields(),
                  const SizedBox(height: 12),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.verified_user_outlined,
            color: Theme.of(context).primaryColor,
            size: 30,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Verify OTP',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the verification code sent to ${widget.email}',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpFields() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => _buildOtpDigitField(index)),
        ),
        const SizedBox(height: 16),
        Text(
          'Didn\'t receive the code?',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        TextButton(
          onPressed: _resendTimer == 0
              ? () async {
                  setState(() => _resendTimer = 30);
                  _startResendTimer();
                  // Implement resend OTP logic
                  await _handleResetPassword();
                }
              : null,
          child: Text(
            _resendTimer > 0
                ? 'Resend OTP in $_resendTimer seconds'
                : 'Resend OTP',
            style: TextStyle(
              color: _resendTimer == 0
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpDigitField(int index) {
    return Container(
      width: 45,
      height: 55,
      color: Theme.of(context).cardColor,
      child: TextFormField(
        controller: _authController.otpControllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '';
          }
          return null;
        },
        onChanged: (value) {
          if (value.length == 1) {
            if (index < 5) {
              FocusScope.of(context).nextFocus(); // Move to the next field
            } else {
              _handleVerifyOtp(); // Submit OTP if the last field is filled
            }
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context)
                .previousFocus(); // Move to the previous field
          }
        },
        onTap: () {
          // Clear the field when tapped (optional)
          _authController.otpControllers[index].clear();
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleVerifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          label: Text(
            'Go Back',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }
}
