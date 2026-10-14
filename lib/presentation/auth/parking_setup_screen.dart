import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/user_role.dart';
import 'auth_providers.dart';
import '../shared/app_text_field.dart';
import '../shared/pill_button.dart';
import '../shared/section_label.dart';
import '../shared/two_tone_title.dart';

class ParkingSetupScreen extends ConsumerStatefulWidget {
  const ParkingSetupScreen({super.key});

  @override
  ConsumerState<ParkingSetupScreen> createState() => _ParkingSetupScreenState();
}

class _ParkingSetupScreenState extends ConsumerState<ParkingSetupScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _openTimeController = TextEditingController(text: '06:00 AM');
  final _closeTimeController = TextEditingController(text: '10:00 PM');
  final _carSpacesController = TextEditingController(text: '12');
  final _motoSpacesController = TextEditingController(text: '8');

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _carSpacesController.dispose();
    _motoSpacesController.dispose();
    super.dispose();
  }

  void _finishSetup() {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || address.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa el nombre y la ubicación de tu parqueadero.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Save active role and parking preferences
    ref.read(userRoleStateProvider.notifier).setRole(UserRole.parkingOwner);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.darkCard,
        content: Text(
          '¡Parqueadero "$name" configurado con éxito! Bienvenido al panel de anfitrión.',
          style: const TextStyle(color: AppColors.white),
        ),
      ),
    );

    context.go('/owner-summary');
  }

  void _skipSetup() {
    ref.read(userRoleStateProvider.notifier).setRole(UserRole.parkingOwner);
    context.go('/owner-summary');
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
              // Header Navigation Bar
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
                      tooltip: 'Volver al paso 1',
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/register');
                        }
                      },
                    ),
                  ),
                  Text(
                    'Registro de Parqueadero',
                    style: AppTypography.title.copyWith(fontSize: 18, color: AppColors.darkCard),
                  ),
                  GestureDetector(
                    onTap: _skipSetup,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7A4100),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: AppColors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Step Progress: Paso 2 de 3
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionLabel('PASO 2 DE 3', color: AppColors.textSecondaryLight),
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
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // TwoToneTitle & Subtitle
              const TwoToneTitle(
                text: 'Datos de tu ',
                highlightText: 'parqueadero',
                normalColor: AppColors.darkCard,
                highlightColor: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Registra tu espacio, define tus horarios y capacidad para comenzar a recibir reservas de conductores.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              // Input: Parking Lot Name
              AppTextField(
                label: 'NOMBRE DEL PARQUEADERO',
                hintText: 'ej. Parqueadero Central Express',
                controller: _nameController,
                fillColor: AppColors.darkCard,
                textColor: AppColors.white,
                hintColor: Colors.white60,
                iconColor: Colors.white70,
                labelColor: AppColors.darkCard,
                prefixIcon: const Icon(Icons.local_parking_rounded, color: Colors.white70),
              ),
              const SizedBox(height: 16),

              // Input: Location / Address
              AppTextField(
                label: 'UBICACIÓN',
                hintText: 'ej. Calle 72 # 11-45, Chapinero',
                controller: _addressController,
                fillColor: AppColors.darkCard,
                textColor: AppColors.white,
                hintColor: Colors.white60,
                iconColor: Colors.white70,
                labelColor: AppColors.darkCard,
                prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.white70),
              ),
              const SizedBox(height: 16),

              // Inputs: Opening & Closing Hours
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'HORA DE APERTURA',
                      hintText: '06:00 AM',
                      controller: _openTimeController,
                      fillColor: AppColors.darkCard,
                      textColor: AppColors.white,
                      hintColor: Colors.white60,
                      iconColor: Colors.white70,
                      labelColor: AppColors.darkCard,
                      prefixIcon: const Icon(Icons.access_time_rounded, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AppTextField(
                      label: 'HORA DE CIERRE',
                      hintText: '10:00 PM',
                      controller: _closeTimeController,
                      fillColor: AppColors.darkCard,
                      textColor: AppColors.white,
                      hintColor: Colors.white60,
                      iconColor: Colors.white70,
                      labelColor: AppColors.darkCard,
                      prefixIcon: const Icon(Icons.nightlight_round, color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Inputs: Quantity of spaces for Cars and Motorcycles
              const SectionLabel('CANTIDAD DE ESPACIOS DISPONIBLES', color: AppColors.darkCard),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'ESPACIOS CARROS',
                      hintText: 'ej. 12',
                      controller: _carSpacesController,
                      keyboardType: TextInputType.number,
                      fillColor: AppColors.darkCard,
                      textColor: AppColors.white,
                      hintColor: Colors.white60,
                      iconColor: Colors.white70,
                      labelColor: AppColors.textSecondaryLight,
                      prefixIcon: const Icon(Icons.directions_car_rounded, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AppTextField(
                      label: 'ESPACIOS MOTOS',
                      hintText: 'ej. 8',
                      controller: _motoSpacesController,
                      keyboardType: TextInputType.number,
                      fillColor: AppColors.darkCard,
                      textColor: AppColors.white,
                      hintColor: Colors.white60,
                      iconColor: Colors.white70,
                      labelColor: AppColors.textSecondaryLight,
                      prefixIcon: const Icon(Icons.two_wheeler_rounded, color: Colors.white70),
                    ),
                  ),
                ],
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

              // Submit Button
              PillButton(
                text: 'Publicar y Gestionar  →',
                isLoading: _isLoading,
                variant: PillButtonVariant.dark,
                onPressed: _finishSetup,
              ),
              const SizedBox(height: 18),

              // Skip Action
              Center(
                child: GestureDetector(
                  onTap: _skipSetup,
                  child: Text(
                    'Configurar más tarde',
                    style: AppTypography.bodyBold.copyWith(
                      color: AppColors.textSecondaryLight,
                      decoration: TextDecoration.underline,
                    ),
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
