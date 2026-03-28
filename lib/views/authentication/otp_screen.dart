import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  bool _isLoading = false;
  int _focusedOtpIndex = -1;
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _otpFocusNodes.length; i++) {
      final node = _otpFocusNodes[i];
      node.addListener(() {
        if (!mounted) return;

        if (node.hasFocus) {
          if (_focusedOtpIndex != i) {
            setState(() {
              _focusedOtpIndex = i;
            });
          }
          return;
        }

        final currentFocusedIndex =
            _otpFocusNodes.indexWhere((focusNode) => focusNode.hasFocus);
        if (_focusedOtpIndex != currentFocusedIndex) {
          setState(() {
            _focusedOtpIndex = currentFocusedIndex;
          });
        }
      });
    }
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
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
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 8.0;
            final maxFieldWidth = (constraints.maxWidth - (spacing * 5)) / 6;
            final fieldWidth = maxFieldWidth.clamp(38.0, 45.0).toDouble();

            return Wrap(
              alignment: WrapAlignment.center,
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(
                6,
                (index) => _buildOtpDigitField(index, width: fieldWidth),
              ),
            );
          },
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

  Widget _buildOtpDigitField(int index, {double width = 45}) {
    final bool isFocused = _focusedOtpIndex == index;
    final outlineColor = Theme.of(context).colorScheme.outline;
    final borderColor = isFocused
        ? Theme.of(context).primaryColor
        : outlineColor.withValues(alpha: 0.75);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: width,
      height: 55,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: isFocused ? 1.5 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: TextFormField(
          controller: _authController.otpControllers[index],
          focusNode: _otpFocusNodes[index],
          onTap: () {
            if (_focusedOtpIndex != index) {
              setState(() {
                _focusedOtpIndex = index;
              });
            }
          },
          keyboardType: TextInputType.number,
          textInputAction:
              index < 5 ? TextInputAction.next : TextInputAction.done,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          maxLength: 1,
          cursorColor: Theme.of(context).primaryColor,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            counterText: '',
            isDense: true,
            fillColor: Theme.of(context).cardColor,
            filled: true,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '';
            }
            return null;
          },
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index < 5) {
                setState(() {
                  _focusedOtpIndex = index + 1;
                });
                _otpFocusNodes[index + 1].requestFocus();
              } else {
                setState(() {
                  _focusedOtpIndex = -1;
                });
                _otpFocusNodes[index].unfocus();
                _handleVerifyOtp(); // Submit OTP if the last field is filled
              }
            } else if (index > 0) {
              setState(() {
                _focusedOtpIndex = index - 1;
              });
              _otpFocusNodes[index - 1].requestFocus();
            }
          },
        ),
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
