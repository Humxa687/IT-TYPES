import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../providers/theme_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Register controllers
  final TextEditingController _regUsernameController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regVerifyEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _regVerifyPasswordController = TextEditingController();

  // Login controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  bool _rememberMe = true;

  @override
  void dispose() {
    _regUsernameController.dispose();
    _regEmailController.dispose();
    _regVerifyEmailController.dispose();
    _regPasswordController.dispose();
    _regVerifyPasswordController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister(GameState gameState) {
    final username = _regUsernameController.text.trim();
    final email = _regEmailController.text.trim();
    final verifyEmail = _regVerifyEmailController.text.trim();
    final password = _regPasswordController.text;
    final verifyPassword = _regVerifyPasswordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all register fields.')),
      );
      return;
    }

    if (email != verifyEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emails do not match.')),
      );
      return;
    }

    if (password != verifyPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    gameState.login(email, username);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Welcome, $username! Registered successfully.')),
    );
    Navigator.pop(context);
  }

  void _handleLogin(GameState gameState) {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in login credentials.')),
      );
      return;
    }

    // Mock username extraction from email
    final username = email.split('@')[0];
    gameState.login(email, username);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Welcome back, $username! Signed in.')),
    );
    Navigator.pop(context);
  }

  void _handleSocialLogin(GameState gameState, String provider) {
    gameState.login('$provider@ittypes.com', '${provider}Typist');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Successfully authenticated with $provider.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 750;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header navigation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: themeProvider.textColor, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'ACCOUNT SECURITY',
                      style: themeProvider.getHeadingStyle(fontSize: 16, fontWeight: FontWeight.bold).copyWith(
                            letterSpacing: 1.0,
                          ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 850),
                      child: isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildRegisterColumn(context),
                                const SizedBox(height: 48),
                                _buildDividerOrSpacer(context, isMobile: true),
                                const SizedBox(height: 48),
                                _buildLoginColumn(context),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildRegisterColumn(context)),
                                _buildDividerOrSpacer(context, isMobile: false),
                                Expanded(child: _buildLoginColumn(context)),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDividerOrSpacer(BuildContext context, {required bool isMobile}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    if (isMobile) {
      return Row(
        children: [
          Expanded(child: Divider(color: themeProvider.borderColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'OR',
              style: themeProvider.getMonospaceTextStyle(fontSize: 10, fontWeight: FontWeight.bold).copyWith(color: themeProvider.subtextColor),
            ),
          ),
          Expanded(child: Divider(color: themeProvider.borderColor)),
        ],
      );
    } else {
      return Container(
        width: 1.5,
        height: 420,
        margin: const EdgeInsets.symmetric(horizontal: 32),
        color: themeProvider.borderColor.withOpacity(0.4),
      );
    }
  }

  Widget _buildRegisterColumn(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: themeProvider.accentColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'register',
              style: themeProvider.getHeadingStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildTextField(context, _regUsernameController, 'username'),
        const SizedBox(height: 12),
        _buildTextField(context, _regEmailController, 'email'),
        const SizedBox(height: 12),
        _buildTextField(context, _regVerifyEmailController, 'verify email'),
        const SizedBox(height: 12),
        _buildTextField(context, _regPasswordController, 'password', obscureText: true),
        const SizedBox(height: 12),
        _buildTextField(context, _regVerifyPasswordController, 'verify password', obscureText: true),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeProvider.cardColor,
            foregroundColor: themeProvider.textColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: themeProvider.borderColor),
            ),
          ),
          onPressed: () => _handleRegister(gameState),
          icon: const Icon(Icons.person_add_rounded, size: 16),
          label: Text(
            'sign up',
            style: themeProvider.getMonospaceTextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginColumn(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.login_rounded, color: themeProvider.accentColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'login',
              style: themeProvider.getHeadingStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Social Buttons Block
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: themeProvider.borderColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _handleSocialLogin(gameState, 'Google'),
                child: Text(
                  'G Google',
                  style: themeProvider.getMonospaceTextStyle(fontSize: 12, fontWeight: FontWeight.bold).copyWith(color: themeProvider.textColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: themeProvider.borderColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _handleSocialLogin(gameState, 'GitHub'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.code_rounded, size: 14, color: themeProvider.textColor),
                    const SizedBox(width: 6),
                    Text(
                      'GitHub',
                      style: themeProvider.getMonospaceTextStyle(fontSize: 12, fontWeight: FontWeight.bold).copyWith(color: themeProvider.textColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: Divider(color: themeProvider.borderColor.withOpacity(0.5))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or',
                style: themeProvider.getMonospaceTextStyle(fontSize: 10).copyWith(color: themeProvider.subtextColor),
              ),
            ),
            Expanded(child: Divider(color: themeProvider.borderColor.withOpacity(0.5))),
          ],
        ),
        const SizedBox(height: 20),

        _buildTextField(context, _loginEmailController, 'email'),
        const SizedBox(height: 12),
        _buildTextField(context, _loginPasswordController, 'password', obscureText: true),
        const SizedBox(height: 12),

        // Remember Me checkbox row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: themeProvider.accentColor,
                    checkColor: themeProvider.isDark ? Colors.black87 : Colors.white,
                    onChanged: (val) {
                      setState(() {
                        _rememberMe = val ?? true;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'remember me',
                  style: themeProvider.getMonospaceTextStyle(fontSize: 10).copyWith(color: themeProvider.subtextColor),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mock reset email sent.')),
                );
              },
              child: Text(
                'forgot password?',
                style: themeProvider.getMonospaceTextStyle(fontSize: 10).copyWith(color: themeProvider.subtextColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeProvider.accentColor,
            foregroundColor: themeProvider.isDark ? Colors.black87 : Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => _handleLogin(gameState),
          icon: Icon(Icons.login_rounded, size: 16, color: themeProvider.isDark ? Colors.black87 : Colors.white),
          label: Text(
            'sign in',
            style: themeProvider.getMonospaceTextStyle(fontSize: 12, fontWeight: FontWeight.bold).copyWith(
                  color: themeProvider.isDark ? Colors.black87 : Colors.white,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String hint, {
    bool obscureText = false,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: themeProvider.borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: themeProvider.getMonospaceTextStyle(fontSize: 12),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: TextStyle(color: themeProvider.subtextColor.withOpacity(0.5), fontSize: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
