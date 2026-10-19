import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/errors/failure.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/user_role.dart';
import 'auth_providers.dart';
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
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _exitToHome() {
    ref.read(userRoleStateProvider.notifier).setRole(UserRole.guest);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
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

    if (password.length < 8) {
      setState(() {
        _errorMessage = 'La contraseña debe tener al menos 8 caracteres.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final signUpUseCase = ref.read(signUpUseCaseProvider);
      final res = await signUpUseCase.execute(
        email: email,
        password: password,
        fullName: name,
        role: _selectedRole,
      );

      if (res.session == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'No se inició sesión automáticamente. "Confirm email" sigue activo en Supabase. Desactívalo para permitir el acceso directo.';
          });
        }
        return;
      }

      if (mounted) {
        ref.read(userRoleStateProvider.notifier).setRole(_selectedRole);
        if (_selectedRole == UserRole.parkingOwner) {
          context.push('/register/parking-setup');
        } else {
          context.push('/register/vehicle-setup');
        }
      }
    } on Failure catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'No pudimos crear la cuenta. Intenta nuevamente.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    if (password.isEmpty) return const SizedBox.shrink();

    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 8 && RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (password.length >= 8 && RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (password.length >= 10 && RegExp(r'[!@#\$&*~%^()_+=|<>?{}\[\]-]').hasMatch(password)) strength++;
    if (strength == 0 && password.isNotEmpty) strength = 1;

    String label;
    Color activeColor;
    switch (strength) {
      case 1:
        label = 'Seguridad baja';
        activeColor = const Color(0xFFC75D38);
        break;
      case 2:
        label = 'Seguridad media';
        activeColor = const Color(0xFF7A4100);
        break;
      case 3:
        label = 'Seguridad alta';
        activeColor = const Color(0xFF5F8B42);
        break;
      case 4:
      default:
        label = 'Seguridad muy alta';
        activeColor = const Color(0xFF2E7D32);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(4, (index) {
                final isActive = index < strength;
                return Expanded(
                  child: Container(
                    height: 3.5,
                    margin: EdgeInsets.only(right: index < 3 ? 5 : 0),
                    decoration: BoxDecoration(
                      color: isActive ? activeColor : const Color(0xFFE2D8CD),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: activeColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Navigation Bar with Exit/Back Button
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
                      tooltip: 'Volver o salir a inicio',
                      onPressed: _exitToHome,
                    ),
                  ),
                  Text(
                    'Register Account',
                    style: AppTypography.title.copyWith(fontSize: 18),
                  ),
                  GestureDetector(
                    onTap: _exitToHome,
                    child: Tooltip(
                      message: 'Ir a inicio',
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7A4100), // Brown avatar circle
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: AppColors.white, size: 20),
                      ),
                    ),
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
                        width: 36,
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
                          color: AppColors.primary.withAlpha(90),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(90),
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
                normalColor: AppColors.darkCard,
                highlightColor: AppColors.primary,
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
                      title: 'Conductor',
                      subtitle: 'Busco parqueadero',
                      icon: Icons.directions_car_rounded,
                      onTap: () => setState(() => _selectedRole = UserRole.vehicleOwner),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Parking Owner Card
                  Expanded(
                    child: _buildRoleCard(
                      isSelected: _selectedRole == UserRole.parkingOwner,
                      title: 'Parqueadero',
                      subtitle: 'Tengo parqueadero',
                      iconText: 'P',
                      onTap: () => setState(() => _selectedRole = UserRole.parkingOwner),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Input: Full Name with black background and white text
              AppTextField(
                label: 'NOMBRE COMPLETO',
                hintText: 'Juan Pérez',
                controller: _nameController,
                fillColor: AppColors.darkCard,
                textColor: AppColors.white,
                hintColor: Colors.white60,
                iconColor: Colors.white70,
                labelColor: AppColors.darkCard,
                prefixIcon: const Icon(Icons.badge_outlined, color: Colors.white70),
              ),
              const SizedBox(height: 16),

              // Input: Email with black background and white text
              AppTextField(
                label: 'CORREO ELECTRÓNICO',
                hintText: 'juan@ejemplo.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                fillColor: AppColors.darkCard,
                textColor: AppColors.white,
                hintColor: Colors.white60,
                iconColor: Colors.white70,
                labelColor: AppColors.darkCard,
                prefixIcon: const Icon(Icons.mail_outline_rounded, color: Colors.white70),
              ),
              const SizedBox(height: 16),

              // Input: Password with black background, white text and eye toggle
              AppTextField(
                label: 'CONTRASEÑA',
                hintText: '••••••••••••',
                controller: _passwordController,
                isPassword: true,
                showEyeToggle: true,
                fillColor: AppColors.darkCard,
                textColor: AppColors.white,
                hintColor: Colors.white60,
                iconColor: Colors.white70,
                labelColor: AppColors.darkCard,
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white70),
              ),
              _buildPasswordStrengthIndicator(),

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
                  color: const Color(0xFFF2ECE4),
                  borderRadius: BorderRadius.circular(20),
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
                      child: const Icon(Icons.verified_user_outlined, color: AppColors.darkCard, size: 20),
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
                            color: const Color(0xFF7A4100),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.white : Colors.black.withAlpha(15),
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: iconText != null
                      ? Text(
                          iconText,
                          style: const TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            color: AppColors.darkCard,
                            letterSpacing: -0.5,
                          ),
                        )
                      : Icon(icon, color: AppColors.darkCard, size: 21),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.darkCard : const Color(0xFFE0E0E0),
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: AppColors.white, size: 14)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTypography.bodyBold.copyWith(
                color: AppColors.darkCard,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: isSelected ? AppColors.darkCard.withAlpha(180) : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
