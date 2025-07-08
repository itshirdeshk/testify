import 'package:flutter/material.dart';
import 'package:testify/models/authentication.dart';
import 'package:testify/services/auth_service.dart';
import 'package:testify/widgets/custom_toast.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Form key for validation
  bool _isLoading = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _showErrors = false;
  String? _oldPasswordError;
  String? _newPasswordError;

  Future<void> _handleChangePassword() async {
    setState(() => _showErrors = true);
    final isValid = _validateFields();
    if (!isValid) return;
    setState(() => _isLoading = true);
    final AuthService authService = AuthService();
    try {
      final response = await authService.changePassword(
          ChangePasswordData(
            oldPassword: _oldPasswordController.text,
            newPassword: _newPasswordController.text,
          ),
          context);

      if (!mounted) return;

      if (response.statusCode == 200) {
        CustomToast.show(
            context: context, message: 'Password Changed Successfully');
        Navigator.pop(context);
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

  bool _validateFields() {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    _oldPasswordError = _validateOldPassword(oldPassword);
    _newPasswordError = _validateNewPassword(newPassword);
    setState(() {});
    return _oldPasswordError == null && _newPasswordError == null;
  }

  String? _validateOldPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your old password';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your new password';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])[A-Za-z\d\W_]{8,}$')
        .hasMatch(value)) {
      return 'Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character';
    }
    return null;
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
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildField(
                    'Old Password',
                    _oldPasswordController,
                    obscureText: _obscureOldPassword,
                    onToggleVisibility: () {
                      setState(
                          () => _obscureOldPassword = !_obscureOldPassword);
                    },
                    onChanged: (value) {
                      // Placeholder for onChanged
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildField(
                    'New Password',
                    _newPasswordController,
                    obscureText: _obscureNewPassword,
                    onToggleVisibility: () {
                      setState(
                          () => _obscureNewPassword = !_obscureNewPassword);
                    },
                    onChanged: (value) {
                      // Placeholder for onChanged
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSendButton(),
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
            Icons.lock_reset,
            color: Theme.of(context).primaryColor,
            size: 30,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Change Password',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your old and new password',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    String title,
    TextEditingController controller, {
    bool obscureText = true,
    VoidCallback? onToggleVisibility,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Theme.of(context).cardColor,
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: TextInputType.visiblePassword,
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            onChanged: onChanged,
            decoration: InputDecoration(
              labelText: title,
              labelStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: Theme.of(context).primaryColor,
              ),
              suffixIcon: onToggleVisibility != null
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
              errorText: null,
            ),
          ),
        ),
        if (_showErrors && title == 'Old Password' && _oldPasswordError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _oldPasswordError!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
          ),
        if (_showErrors && title == 'New Password' && _newPasswordError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _newPasswordError!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleChangePassword,
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
                'Change Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
