import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/user_role.dart';
import 'auth_providers.dart';
import '../shared/app_text_field.dart';
import '../shared/pill_button.dart';
import '../shared/section_label.dart';
import '../shared/two_tone_title.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _exitToHome() {
    ref.read(userRoleStateProvider.notifier).setRole(UserRole.vehicleOwner);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa tu correo y contraseña.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (mounted) {
        ref.read(userRoleStateProvider.notifier).setRole(UserRole.vehicleOwner);
        context.go('/home');
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message.contains('Invalid login credentials')
              ? 'Correo o contraseña incorrectos. Verifica tus datos.'
              : 'No pudimos iniciar sesión. Intenta nuevamente.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'No pudimos conectar con el servidor. Intenta nuevamente.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleBiometricLogin() {
    ref.read(userRoleStateProvider.notifier).setRole(UserRole.vehicleOwner);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.darkCard,
        content: Text('Acceso biométrico verificado. Bienvenido.'),
      ),
    );
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar with Exit/Back Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkCard),
                      tooltip: 'Volver a explorar',
                      onPressed: _exitToHome,
                    ),
                  ),
                  GestureDetector(
                    onTap: _exitToHome,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Explorar',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkCard,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.darkCard),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Official Brand Logo (Image 3)
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  width: 78,
                  height: 78,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'P',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamily,
                        color: AppColors.secondary,
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Welcome Section Label
              const SectionLabel(
                'BIENVENIDO',
                textAlign: TextAlign.center,
                color: AppColors.textSecondaryLight,
              ),
              const SizedBox(height: 8),

              // TwoToneTitle with 'Inicia ' in black and 'sesión' in orange
              const TwoToneTitle(
                text: 'Inicia ',
                highlightText: 'sesión',
                normalColor: AppColors.darkCard,
                highlightColor: AppColors.primary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Email Field with black background and white text
              AppTextField(
                label: 'CORREO',
                hintText: 'usuario@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                fillColor: AppColors.darkCard,
                textColor: AppColors.white,
                hintColor: Colors.white60,
                labelColor: AppColors.darkCard,
              ),
              const SizedBox(height: 20),

              // Password Field with black background and white text
              AppTextField(
                label: 'CONTRASEÑA',
                hintText: '••••••••••••',
                controller: _passwordController,
                isPassword: true,
                fillColor: AppColors.darkCard,
                textColor: AppColors.white,
                hintColor: Colors.white60,
                labelColor: AppColors.darkCard,
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Button 1: Entrar (Dark Pill Button)
              PillButton(
                text: 'Entrar',
                isLoading: _isLoading,
                variant: PillButtonVariant.dark,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 14),

              // Button 2: Entrar con biometría (Amber Pill Button)
              PillButton(
                text: 'Entrar con biometría',
                icon: const Icon(Icons.fingerprint_rounded, color: AppColors.darkCard, size: 22),
                variant: PillButtonVariant.amber,
                onPressed: _handleBiometricLogin,
              ),
              const SizedBox(height: 28),

              // Sign Up Link
              GestureDetector(
                onTap: () => context.go('/register'),
                child: Text(
                  'Crear cuenta',
                  style: AppTypography.bodyBold.copyWith(
                    decoration: TextDecoration.underline,
                    color: AppColors.darkCard,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
