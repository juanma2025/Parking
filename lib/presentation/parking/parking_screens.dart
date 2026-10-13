import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../shared/app_card.dart';
import '../shared/app_drawer.dart';
import '../shared/avatar_button.dart';
import '../shared/pill_button.dart';
import '../shared/section_label.dart';
import '../shared/status_pill.dart';
import '../shared/two_tone_title.dart';

Widget _buildSubHeader(BuildContext context, {required String title, VoidCallback? onBack}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkCard),
                onPressed: onBack,
              )
            : Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: AppColors.darkCard),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
      ),
      Text(
        title,
        style: AppTypography.title.copyWith(fontSize: 18),
      ),
      AvatarButton(
        onTap: () => context.go('/profile'),
      ),
    ],
  );
}

// ============================================================================
// ADD SCREEN (/add)
// ============================================================================
class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubHeader(context, title: 'Acción Rápida'),
              const SizedBox(height: 24),
              const SectionLabel('CREAR O AGREGAR'),
              const SizedBox(height: 6),
              const TwoToneTitle(text: '¿Qué deseas ', highlightText: 'hacer?'),
              const SizedBox(height: 24),

              AppCard(
                variant: AppCardVariant.amber,
                padding: const EdgeInsets.all(20),
                onTap: () => context.go('/vehicles'),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(color: AppColors.darkCard, shape: BoxShape.circle),
                      child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.secondary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Registrar Vehículo', style: AppTypography.title.copyWith(fontSize: 17, color: AppColors.darkCard)),
                          Text('Añade un auto o moto a tu cuenta', style: AppTypography.caption.copyWith(color: AppColors.darkCard.withAlpha(180))),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: AppColors.darkCard),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              AppCard(
                variant: AppCardVariant.dark,
                padding: const EdgeInsets.all(20),
                onTap: () => context.go('/home'),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                      child: const Icon(Icons.near_me_rounded, color: AppColors.darkCard),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Buscar Parqueadero', style: AppTypography.title.copyWith(fontSize: 17, color: AppColors.white)),
                          Text('Explorar mapa en vivo y reservar', style: AppTypography.caption.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: AppColors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PARKING DETAIL SCREEN (/parking/:id)
// ============================================================================
class ParkingDetailScreen extends StatelessWidget {
  const ParkingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubHeader(context, title: 'Detalle de Parqueadero', onBack: () => context.go('/home')),
              const SizedBox(height: 20),

              // Hero Banner Amber Card
              AppCard(
                variant: AppCardVariant.amber,
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatusPill(
                          text: '12 CUPOS LIBRES',
                          backgroundColor: AppColors.darkCard,
                          textColor: AppColors.secondary,
                        ),
                        Text('★ 4.8 (124 reseñas)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Hospital San José', style: AppTypography.display.copyWith(color: AppColors.darkCard, fontSize: 26)),
                    const SizedBox(height: 4),
                    Text('Cra. 13 #72-40 • Chapinero • Abierto 24 Horas', style: AppTypography.body.copyWith(color: AppColors.darkCard.withAlpha(180))),
                    const SizedBox(height: 18),
                    Text('\$3.500 / hora', style: AppTypography.title.copyWith(color: AppColors.darkCard, fontSize: 22)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Amenities Dark Card
              AppCard(
                variant: AppCardVariant.dark,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('SERVICIOS INCLUIDOS', color: Colors.white70),
                    const SizedBox(height: 12),
                    _buildAmenity(Icons.roofing_rounded, 'Techado y seguro'),
                    _buildAmenity(Icons.videocam_outlined, 'Cámaras de vigilancia 24/7'),
                    _buildAmenity(Icons.local_car_wash_rounded, 'Lavado opcional de vehículos'),
                    _buildAmenity(Icons.ev_station_rounded, 'Punto de carga eléctrica disponible'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              PillButton(
                text: 'Reservar cupo ahora',
                variant: PillButtonVariant.dark,
                onPressed: () => context.go('/reserve/mock-1'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmenity(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Text(text, style: AppTypography.body.copyWith(color: AppColors.white)),
        ],
      ),
    );
  }
}

// ============================================================================
// RESERVE SCREEN (/reserve/:id)
// ============================================================================
class ReserveScreen extends StatefulWidget {
  const ReserveScreen({super.key});

  @override
  State<ReserveScreen> createState() => _ReserveScreenState();
}

class _ReserveScreenState extends State<ReserveScreen> {
  int _selectedHours = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubHeader(context, title: 'Configurar Reserva', onBack: () => context.go('/home')),
              const SizedBox(height: 20),
              const SectionLabel('PARQUEADERO SAN JOSÉ'),
              const SizedBox(height: 6),
              const TwoToneTitle(text: 'Confirma tu ', highlightText: 'estancia'),
              const SizedBox(height: 20),

              // Hours Selector (Amber Card)
              AppCard(
                variant: AppCardVariant.amber,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DURACIÓN ESTIMADA', style: AppTypography.sectionLabel.copyWith(color: AppColors.darkCard)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [1, 2, 3, 4].map((h) {
                        final isSel = _selectedHours == h;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedHours = h),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.darkCard : AppColors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '$h hora${h > 1 ? 's' : ''}',
                              style: TextStyle(
                                color: isSel ? AppColors.white : AppColors.darkCard,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text('Total a pagar: \$${_selectedHours * 3500} COP', style: AppTypography.title.copyWith(fontSize: 18, color: AppColors.darkCard)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              PillButton(
                text: 'Confirmar y generar pase',
                variant: PillButtonVariant.dark,
                onPressed: () => context.go('/confirmation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CONFIRMATION SCREEN (/confirmation)
// ============================================================================
class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              const TwoToneTitle(text: '¡Reserva ', highlightText: 'confirmada!'),
              const SizedBox(height: 10),
              Text(
                'Tu cupo #A-14 en Parqueadero San José está listo. Puedes ingresar ahora.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 32),

              AppCard(
                variant: AppCardVariant.dark,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_2_rounded, size: 140, color: AppColors.secondary),
                    const SizedBox(height: 12),
                    Text('CÓDIGO: RES-84920', style: AppTypography.bodyBold.copyWith(color: AppColors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              PillButton(
                text: 'Ver en Mis Reservas',
                variant: PillButtonVariant.primary,
                onPressed: () => context.go('/my-reservations'),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.go('/home'),
                child: Text('Volver al Inicio', style: AppTypography.bodyBold.copyWith(decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// FORGOT PASSWORD SCREEN (/forgot-password)
// ============================================================================
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const TwoToneTitle(text: 'Recuperar ', highlightText: 'contraseña'),
              const SizedBox(height: 16),
              const Text('Ingresa tu correo para recibir las instrucciones de restablecimiento.'),
              const SizedBox(height: 24),
              PillButton(text: 'Volver a iniciar sesión', variant: PillButtonVariant.dark, onPressed: () => context.go('/login')),
            ],
          ),
        ),
      ),
    );
  }
}
