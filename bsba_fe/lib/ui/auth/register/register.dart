import 'package:flutter/material.dart';
import 'register_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final RegisterViewModel _viewModel;

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = RegisterViewModel();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _viewModel.register(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 600;

    return Scaffold(
      backgroundColor: isDesktop ? const Color(0xFF1E2022) : const Color(0xFFF9F9FF),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: isDesktop ? 450 : screenWidth,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: isDesktop ? BorderRadius.circular(24) : null,
              boxShadow: isDesktop
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, child) {
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildLogoIcon(),
                          const SizedBox(width: 12),
                          const Text(
                            'Tabletop Haven',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0056C6),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Title & Subtitle
                      const Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1C1E),
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Join our community of tabletop enthusiasts.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Full Name Field
                      const Text(
                        'Full Name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _fullNameController,
                        enabled: !_viewModel.isLoading,
                        decoration: _inputDecoration(
                          hintText: 'John Doe',
                          prefixIcon: Icons.person_outline,
                        ),
                        onChanged: _viewModel.setFullName,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone Number Field
                      const Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: !_viewModel.isLoading,
                        decoration: _inputDecoration(
                          hintText: '+1 (555) 000-0000',
                          prefixIcon: Icons.phone_outlined,
                        ),
                        onChanged: _viewModel.setPhone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_viewModel.isLoading,
                        decoration: _inputDecoration(
                          hintText: 'email@example.com',
                          prefixIcon: Icons.email_outlined,
                        ),
                        onChanged: _viewModel.setEmail,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _viewModel.obscurePassword,
                        enabled: !_viewModel.isLoading,
                        decoration: _inputDecoration(
                          hintText: '••••••••••••',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _viewModel.obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF9CA3AF),
                              size: 22,
                            ),
                            onPressed: _viewModel.isLoading
                                ? null
                                : _viewModel.togglePasswordVisibility,
                          ),
                        ),
                        onChanged: _viewModel.setPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Register Button
                      ElevatedButton(
                        onPressed: _viewModel.isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0056C6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _viewModel.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),

                      // Divider "OR"
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Color(0xFFE5E7EB),
                              thickness: 1.2,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xFFE5E7EB),
                              thickness: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Google Register Button
                      MouseRegion(
                        onEnter: (_) => _viewModel.setHoverGoogle(true),
                        onExit: (_) => _viewModel.setHoverGoogle(false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: _viewModel.isHoveringGoogle || _viewModel.isLoading
                                ? const Color(0xFFF9FAFB)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _viewModel.isHoveringGoogle
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFFD1D5DB),
                              width: 1.2,
                            ),
                          ),
                          child: InkWell(
                            onTap: _viewModel.isLoading
                                ? null
                                : () => _viewModel.loginWithSocial('Google', context),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildGoogleLogo(),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Register with Google',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Footer: Already have an account? Log In
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          GestureDetector(
                            onTap: _viewModel.isLoading
                                ? null
                                : () {
                                    Navigator.of(context).pop();
                                  },
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0056C6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Input styling decoration matching the premium placeholder design in the image
  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 15,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: const Color(0xFF9CA3AF),
        size: 22,
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 16,
      ),
      filled: true,
      fillColor: const Color(0xFFEEF0FA), // matching the soft lavender/gray background in image
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFF0056C6),
          width: 2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 2,
        ),
      ),
    );
  }

  // Build Tabletop Haven Dice Logo Icon matching the image
  Widget _buildLogoIcon() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF0056C6),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(6),
      child: CustomPaint(
        painter: _DicePainter(),
      ),
    );
  }

  // Draw a beautiful vector Google G logo manually to ensure no asset failures!
  Widget _buildGoogleLogo() {
    return CustomPaint(
      size: const Size(18, 18),
      painter: _GoogleLogoPainter(),
    );
  }
}

// Custom Painter to draw a high-fidelity dice face with 5 dots (pips)
class _DicePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;
    final double r = w * 0.09; // dot radius

    // 5 dots coordinates
    final dots = [
      Offset(w * 0.25, h * 0.25), // top left
      Offset(w * 0.75, h * 0.25), // top right
      Offset(w * 0.5, h * 0.5),   // center
      Offset(w * 0.25, h * 0.75), // bottom left
      Offset(w * 0.75, h * 0.75), // bottom right
    ];

    for (final dot in dots) {
      canvas.drawCircle(dot, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter to draw a high-fidelity Google "G" logo
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w / 2;

    final Rect rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Paint for fills
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 1. Red Top Area
    final Path redPath = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx - r * 0.707, cy - r * 0.707)
      ..arcTo(rect, -2.356, 1.571, false)
      ..lineTo(cx + r * 0.707, cy - r * 0.707)
      ..close();
    paint.color = const Color(0xFFEA4335);
    canvas.drawPath(redPath, paint);

    // 2. Yellow Left Area
    final Path yellowPath = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx - r * 0.707, cy + r * 0.707)
      ..arcTo(rect, -3.927, 1.571, false)
      ..lineTo(cx - r * 0.707, cy - r * 0.707)
      ..close();
    paint.color = const Color(0xFFFBBC05);
    canvas.drawPath(yellowPath, paint);

    // 3. Green Bottom Area
    final Path greenPath = Path()
      ..moveTo(cx, cy)
      ..lineTo(cx + r * 0.85, cy + r * 0.5)
      ..arcTo(rect, 0.523, 2.094, false)
      ..lineTo(cx - r * 0.707, cy + r * 0.707)
      ..close();
    paint.color = const Color(0xFF34A853);
    canvas.drawPath(greenPath, paint);

    // 4. Blue Right & Bar Area
    final Path bluePath = Path()
      ..moveTo(cx, cy)
      ..lineTo(w, cy)
      ..arcTo(rect, 0, -1.047, false)
      ..lineTo(cx + r * 0.5, cy - r * 0.866)
      ..close();
    paint.color = const Color(0xFF4285F4);
    canvas.drawPath(bluePath, paint);

    // Blue horizontal bar
    final Path barPath = Path()
      ..moveTo(cx, cy - r * 0.2)
      ..lineTo(w, cy - r * 0.2)
      ..lineTo(w, cy + r * 0.2)
      ..lineTo(cx, cy + r * 0.2)
      ..close();
    canvas.drawPath(barPath, paint);

    // Inner Cutout to make it a letter "G" rather than filled sectors
    final Paint cutoutPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.55, cutoutPaint);

    // Small fix to ensure the white cutout and the horizontal bar intersect beautifully
    final Paint connectionPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTRB(cx, cy - r * 0.18, cx + r * 0.6, cy + r * 0.18),
      connectionPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
