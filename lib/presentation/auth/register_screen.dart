import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/user_role.dart';
import '../shared/app_text_field.dart';
import '../shared/pill_button.dart';
import '../shared/section_label.dart';
import '../shared/two_tone_title.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.vehicleOwner;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor completa todos los campos.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'La contraseña debe tener al menos 6 caracteres.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'role': _selectedRole.toDbValue(),
        },
      );

      if (response.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.success,
              content: Text('¡Cuenta creada con éxito! Bienvenido.'),
            ),
          );
          context.go('/home');
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message.contains('already registered')
              ? 'Este correo ya se encuentra registrado. Inicia sesión.'
              : 'No pudimos crear la cuenta. Intenta nuevamente.';
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Navigation Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkCard),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/login');
                      }
                    },
                  ),
                  Text(
                    'Register Account',
                    style: AppTypography.title.copyWith(fontSize: 18),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: AppColors.darkCard, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Step Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionLabel('PASO 1 DE 3'),
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(80),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // TwoToneTitle & Subtitle
              const TwoToneTitle(
                text: 'Crea tu ',
                highlightText: 'cuenta',
              ),
              const SizedBox(height: 8),
              Text(
                'Reserva tu espacio ideal en segundos o comparte tu garaje con conductores confiables.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              // Role Selector Cards
              Row(
                children: [
                  // Vehicle Owner Card
                  Expanded(
                    child: _buildRoleCard(
                      isSelected: _selectedRole == UserRole.vehicleOwner,
                      title: 'Busco parqueadero',
                      subtitle: 'Conductor',
                      icon: Icons.directions_car_rounded,
                      onTap: () => setState(() => _selectedRole = UserRole.vehicleOwner),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Parking Owner Card
                  Expanded(
                    child: _buildRoleCard(
                      isSelected: _selectedRole == UserRole.parkingOwner,
                      title: 'Tengo parqueadero',
                      subtitle: 'Anfitrión',
                      iconText: 'P',
                      onTap: () => setState(() => _selectedRole = UserRole.parkingOwner),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Input: Full Name
              AppTextField(
                label: 'NOMBRE COMPLETO',
                hintText: 'Juan Pérez',
                controller: _nameController,
                prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 16),

              // Input: Email
              AppTextField(
                label: 'CORREO ELECTRÓNICO',
                hintText: 'juan@ejemplo.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 16),

              // Input: Password
              AppTextField(
                label: 'CONTRASEÑA',
                hintText: '••••••••••••',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondaryLight),
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

              const SizedBox(height: 20),

              // Security Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(160),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, color: AppColors.darkCard, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tus datos están protegidos. Sin cargos ocultos ni sorpresas al reservar.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.darkCard.withAlpha(200),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Continue Button
              PillButton(
                text: 'Continuar  →',
                isLoading: _isLoading,
                variant: PillButtonVariant.dark,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 24),

              // Bottom Sign In Link
              Center(
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: RichText(
                    text: TextSpan(
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondaryLight),
                      children: [
                        const TextSpan(text: '¿Ya tienes una cuenta registrada? '),
                        TextSpan(
                          text: 'Iniciar sesión',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.darkCard,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required bool isSelected,
    required String title,
    required String subtitle,
    IconData? icon,
    String? iconText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.white : Colors.black.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: iconText != null
                      ? Text(
                          iconText,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        )
                      : Icon(icon, color: AppColors.darkCard, size: 20),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.darkCard : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: AppColors.white, size: 14)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.bodyBold.copyWith(
                color: AppColors.darkCard,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
