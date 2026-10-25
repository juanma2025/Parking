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
import '../vehicles/vehicles_provider.dart';

class VehicleSetupScreen extends ConsumerStatefulWidget {
  const VehicleSetupScreen({super.key});

  @override
  ConsumerState<VehicleSetupScreen> createState() => _VehicleSetupScreenState();
}

class _VehicleSetupScreenState extends ConsumerState<VehicleSetupScreen> {
  final _plateController = TextEditingController();
  final _brandModelController = TextEditingController();
  String _vehicleType = 'car'; // 'car' or 'moto'
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _plateController.dispose();
    _brandModelController.dispose();
    super.dispose();
  }

  void _finishSetup() {
    final plate = _plateController.text.trim();
    if (plate.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa el número de placa de tu vehículo.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Save active role and vehicle preferences
    ref.read(userRoleStateProvider.notifier).setRole(UserRole.vehicleOwner);

    final brandModel = _brandModelController.text.trim();
    ref.read(userVehiclesProvider.notifier).addVehicle(
      UserVehicleItem(
        id: 'veh-${DateTime.now().millisecondsSinceEpoch}',
        plate: plate.toUpperCase(),
        vehicleType: _vehicleType == 'moto' ? 'Motocicleta' : 'Sedán',
        brand: brandModel.isNotEmpty ? brandModel : 'Vehículo',
        model: '',
        year: '2024',
        color: 'Gris Plata',
        isPrimary: true,
        badges: const ['SOAT al día'],
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.darkCard,
        content: Text(
          '¡Vehículo ($plate) registrado con éxito! Bienvenido.',
          style: const TextStyle(color: AppColors.white),
        ),
      ),
    );

    context.go('/home');
  }

  void _skipSetup() {
    ref.read(userRoleStateProvider.notifier).setRole(UserRole.vehicleOwner);
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
                    'Registro de Vehículo',
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
                highlightText: 'vehículo',
                normalColor: AppColors.darkCard,
                highlightColor: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Indica si conduces carro o moto y registra tu placa para agilizar tus reservas en cualquier parqueadero.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              // Vehicle Type Selector (Carro vs Moto)
              const SectionLabel('TIPO DE VEHÍCULO', color: AppColors.darkCard),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Carro
                  Expanded(
                    child: _buildVehicleTypeCard(
                      type: 'car',
                      title: 'Carro',
                      subtitle: 'Automóvil',
                      icon: Icons.directions_car_rounded,
                      isSelected: _vehicleType == 'car',
                      onTap: () => setState(() => _vehicleType = 'car'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Moto
                  Expanded(
                    child: _buildVehicleTypeCard(
                      type: 'moto',
                      title: 'Moto',
                      subtitle: 'Motocicleta',
                      icon: Icons.two_wheeler_rounded,
                      isSelected: _vehicleType == 'moto',
                      onTap: () => setState(() => _vehicleType = 'moto'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Input: License Plate
              AppTextField(
                label: 'NÚMERO DE PLACA',
                hintText: _vehicleType == 'car' ? 'ej. ABC-123' : 'ej. XYZ-45D',
                controller: _plateController,
                fillColor: AppColors.darkCard,
                textColor: AppColors.white,
                hintColor: Colors.white60,
                iconColor: Colors.white70,
                labelColor: AppColors.darkCard,
                prefixIcon: const Icon(Icons.credit_card_rounded, color: Colors.white70),
              ),
              const SizedBox(height: 16),

              // Input: Brand / Model (Optional)
              AppTextField(
                label: 'MARCA Y MODELO (OPCIONAL)',
                hintText: _vehicleType == 'car' ? 'ej. Mazda 3 / Chevrolet Spark' : 'ej. Yamaha MT-03 / Pulsar NS',
                controller: _brandModelController,
                fillColor: AppColors.darkCard,
                textColor: AppColors.white,
                hintColor: Colors.white60,
                iconColor: Colors.white70,
                labelColor: AppColors.darkCard,
                prefixIcon: const Icon(Icons.commute_rounded, color: Colors.white70),
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
                text: 'Continuar al inicio  →',
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
                    'Omitir por ahora',
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

  Widget _buildVehicleTypeCard({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
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
          borderRadius: BorderRadius.circular(24),
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.white : Colors.black.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.darkCard, size: 22),
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
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.bodyBold.copyWith(
                color: AppColors.darkCard,
                fontSize: 15,
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
