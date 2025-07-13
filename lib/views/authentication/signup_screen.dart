import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthController _authController = AuthController();
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;
  bool _showErrors = false;
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up focus nodes
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    setState(() => _showErrors = true);
    final isValid = _validateFields();
    if (isValid) {
      setState(() => _isLoading = true);
      try {
        await _authController.register(context);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  bool _validateFields() {
    final name = _authController.nameController.text;
    final email = _authController.emailController.text;
    final phone = _authController.phoneController.text;
    final password = _authController.passwordController.text;
    final confirmPassword = _authController.confirmPasswordController.text;
    _nameError = _validateName(name);
    _emailError = _validateEmail(email);
    _phoneError = _validatePhone(phone);
    _passwordError = _validatePassword(password);
    _confirmPasswordError = _validateConfirmPassword(confirmPassword, password);
    setState(() {});
    return _nameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])[A-Za-z\d\W_]{8,}$')
        .hasMatch(value)) {
      return 'Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, one number, and one special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _unfocusAllFields() {
    // Unfocus all fields
    _nameFocusNode.unfocus();
    _emailFocusNode.unfocus();
    _phoneFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    _confirmPasswordFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusAllFields, // Unfocus fields when tapping outside
      child: Scaffold(
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
                    _buildSignupForm(),
                    const SizedBox(height: 12),
                    _buildActionButtons(context),
                  ],
                ),
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
            Icons.person_add,
            color: Theme.of(context).primaryColor,
            size: 30,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign up to continue your learning journey',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Column(
      children: [
        _buildInputField(
          controller: _authController.nameController,
          label: 'Full Name',
          icon: Icons.person_outline,
          focusNode: _nameFocusNode,
          onChanged: (value) {
            if (_showErrors) {
              final error = _validateName(value);
              if (_nameError != error) setState(() => _nameError = error);
            }
          },
        ),
        if (_showErrors && _nameError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _nameError!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
          ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _authController.emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          focusNode: _emailFocusNode,
          onChanged: (value) {
            if (_showErrors) {
              final error = _validateEmail(value);
              if (_emailError != error) setState(() => _emailError = error);
            }
          },
        ),
        if (_showErrors && _emailError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _emailError!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
          ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _authController.phoneController,
          label: 'Phone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          focusNode: _phoneFocusNode,
          onChanged: (value) {
            if (_showErrors) {
              final error = _validatePhone(value);
              if (_phoneError != error) setState(() => _phoneError = error);
            }
          },
        ),
        if (_showErrors && _phoneError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _phoneError!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
          ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _authController.passwordController,
          label: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
          obscureText: _obscurePassword1,
          focusNode: _passwordFocusNode,
          onToggleVisibility: () {
            setState(() => _obscurePassword1 = !_obscurePassword1);
          },
          onChanged: (value) {
            if (_showErrors) {
              final error = _validatePassword(value);
              if (_passwordError != error) {
                setState(() => _passwordError = error);
              }
            }
          },
        ),
        if (_showErrors && _passwordError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _passwordError!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
          ),
        const SizedBox(height: 16),
        _buildInputField(
          controller: _authController.confirmPasswordController,
          label: 'Confirm Password',
          icon: Icons.lock_outline,
          isPassword: true,
          obscureText: _obscurePassword2,
          focusNode: _confirmPasswordFocusNode,
          onToggleVisibility: () {
            setState(() => _obscurePassword2 = !_obscurePassword2);
          },
          onChanged: (value) {
            if (_showErrors) {
              final error = _validateConfirmPassword(
                  value, _authController.passwordController.text);
              if (_confirmPasswordError != error) {
                setState(() => _confirmPasswordError = error);
              }
            }
          },
        ),
        if (_showErrors && _confirmPasswordError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _confirmPasswordError!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onToggleVisibility,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      color: Theme.of(context).cardColor,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? (obscureText ?? true) : false,
        keyboardType: keyboardType,
        focusNode: focusNode,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText! ? Icons.visibility_off : Icons.visibility,
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
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSignup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Already have an account? ",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false),
              child: Text(
                'Login',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
