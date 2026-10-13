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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular Brand Logo "P"
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: AppColors.darkCard,
                    shape: BoxShape.circle,
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
                const SizedBox(height: 28),

                // Welcome Section Label
                const SectionLabel('BIENVENIDO', textAlign: TextAlign.center),
                const SizedBox(height: 8),

                // TwoToneTitle
                const TwoToneTitle(
                  text: 'Inicia ',
                  highlightText: 'sesión',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // Email Field
                AppTextField(
                  label: 'CORREO',
                  hintText: 'usuario@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password Field with MOSTRAR toggle
                AppTextField(
                  label: 'CONTRASEÑA',
                  hintText: '••••••••••••',
                  controller: _passwordController,
                  isPassword: true,
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

                // Dark Pill Button
                PillButton(
                  text: 'Entrar',
                  isLoading: _isLoading,
                  variant: PillButtonVariant.dark,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 24),

                // Sign Up Link
                GestureDetector(
                  onTap: () => context.go('/register'),
                  child: Text(
                    '¿No tienes cuenta? Crear cuenta',
                    style: AppTypography.bodyBold.copyWith(
                      decoration: TextDecoration.underline,
                      color: AppColors.darkCard,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Fast Demo Access Button
                GestureDetector(
                  onTap: () {
                    ref.read(userRoleStateProvider.notifier).setRole(UserRole.vehicleOwner);
                    context.go('/home');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(60),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withAlpha(80)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flash_on_rounded, size: 16, color: AppColors.darkCard),
                        const SizedBox(width: 6),
                        Text(
                          'Explorar como Conductor (Demo)',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkCard,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
