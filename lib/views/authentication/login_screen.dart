import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = AuthController();
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isAnyFieldFocused = false; // Track if any field is focused
  bool _showErrors = false; // Show errors only after login attempt
  String? _emailError;
  String? _phoneError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    // Add listeners to focus nodes
    _emailFocusNode.addListener(_onFocusChange);
    _phoneFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    // Clean up focus nodes
    _emailFocusNode.removeListener(_onFocusChange);
    _phoneFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onFocusChange);
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isAnyFieldFocused = _emailFocusNode.hasFocus ||
          _phoneFocusNode.hasFocus ||
          _passwordFocusNode.hasFocus;
    });
  }

  Future<void> _handleLogin() async {
    setState(() => _showErrors = true);
    final isValid = _validateFields();
    if (isValid) {
      setState(() => _isLoading = true);
      try {
        await _authController.login(context);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  bool _validateFields() {
    final email = _authController.emailController.text;
    final phone = _authController.phoneController.text;
    final password = _authController.passwordController.text;
    _emailError = _validateEmail(email);
    _phoneError = _validatePhone(phone);
    _passwordError = _validatePassword(password);
    setState(() {});
    return _emailError == null && _phoneError == null && _passwordError == null;
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

  void _unfocusAllFields() {
    // Unfocus all fields
    _emailFocusNode.unfocus();
    _phoneFocusNode.unfocus();
    _passwordFocusNode.unfocus();
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
                    _buildLoginForm(),
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
            Icons.lock_open,
            color: Theme.of(context).primaryColor,
            size: 30,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue your learning journey',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
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
          obscureText: _obscurePassword,
          focusNode: _passwordFocusNode,
          onToggleVisibility: () {
            setState(() => _obscurePassword = !_obscurePassword);
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
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
            onPressed: () {
              Navigator.pushNamed(context, '/forgot-password');
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
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
      color: Theme.of(context)
          .cardColor, // Only background color, no border or radius
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
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          errorText: null,
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
            onPressed: _isLoading ? null : _handleLogin,
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
                    'Login',
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
              "Don't have an account? ",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: Text(
                'Sign Up',
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
