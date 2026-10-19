import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/motion_utils.dart';
import '../../data/datasources/pasto_landmarks_data.dart';
import '../reservations/reservations_provider.dart';
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
    final lotId = GoRouterState.of(context).pathParameters['id'] ?? 'pasto-unicentro-1';
    final lot = PastoDataService.getParkingLotById(lotId) ?? PastoDataService.getAllParkingLots().first;

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatusPill(
                          text: '${lot.carSpaces} CARROS • ${lot.motoSpaces} MOTOS',
                          backgroundColor: AppColors.darkCard,
                          textColor: AppColors.secondary,
                        ),
                        Text('★ ${lot.rating} (Reseñas)', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(lot.name, style: AppTypography.display.copyWith(color: AppColors.darkCard, fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(
                      '${lot.address} • San Juan de Pasto • ${lot.openingHours}',
                      style: AppTypography.body.copyWith(color: AppColors.darkCard.withAlpha(180)),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '${lot.formattedPrice} • A pie: ${lot.distanceMeters} m',
                      style: AppTypography.title.copyWith(color: AppColors.darkCard, fontSize: 20),
                    ),
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
                    const SectionLabel('SERVICIOS Y COMODIDADES', color: Colors.white70),
                    const SizedBox(height: 12),
                    _buildAmenity(
                      Icons.roofing_rounded,
                      lot.isCovered ? 'Instalación techada y protegida' : 'Parqueadero al aire libre con cerramiento',
                    ),
                    _buildAmenity(
                      Icons.videocam_outlined,
                      lot.hasSecurity ? 'Cámaras de vigilancia 24/7 y celador privado' : 'Vigilancia en horas de servicio',
                    ),
                    _buildAmenity(
                      Icons.access_time_filled_rounded,
                      'Horario de atención: ${lot.openingHours}',
                    ),
                    _buildAmenity(
                      lot.hasCharging ? Icons.ev_station_rounded : Icons.two_wheeler_rounded,
                      lot.hasCharging
                          ? 'Punto de carga eléctrica para vehículos'
                          : 'Zona exclusiva y señalizada para motos',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              PillButton(
                text: 'Reservar cupo ahora',
                variant: PillButtonVariant.dark,
                onPressed: () => context.go('/reserve/${lot.id}'),
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
          Expanded(
            child: Text(text, style: AppTypography.body.copyWith(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// RESERVE SCREEN (/reserve/:id)
// ============================================================================
class ReserveScreen extends ConsumerStatefulWidget {
  const ReserveScreen({super.key});

  @override
  ConsumerState<ReserveScreen> createState() => _ReserveScreenState();
}

class _ReserveScreenState extends ConsumerState<ReserveScreen> {
  int _selectedHours = 2;

  @override
  Widget build(BuildContext context) {
    final lotId = GoRouterState.of(context).pathParameters['id'] ?? 'pasto-unicentro-1';
    final lot = PastoDataService.getParkingLotById(lotId) ?? PastoDataService.getAllParkingLots().first;
    final total = _selectedHours * lot.pricePerHour.toInt();
    final formattedTotal = '\$${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} COP';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubHeader(context, title: 'Configurar Reserva', onBack: () => context.go('/parking/${lot.id}')),
              const SizedBox(height: 20),
              SectionLabel(lot.name.toUpperCase()),
              const SizedBox(height: 6),
              const TwoToneTitle(text: 'Confirma tu ', highlightText: 'estancia'),
              const SizedBox(height: 20),

              // Hours Selector (Amber Card with evenly distributed hours, zero overflow)
              AppCard(
                variant: AppCardVariant.amber,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DURACIÓN ESTIMADA', style: AppTypography.sectionLabel.copyWith(color: AppColors.darkCard)),
                    const SizedBox(height: 14),
                    Row(
                      children: [1, 2, 3, 4].map((h) {
                        final isSel = _selectedHours == h;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: MotionUtils.pressable(
                              onTap: () => setState(() => _selectedHours = h),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.darkCard : AppColors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(isSel ? 20 : 6),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '$h hora${h > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      color: isSel ? AppColors.white : AppColors.darkCard,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Total a pagar: $formattedTotal',
                      style: AppTypography.title.copyWith(fontSize: 18, color: AppColors.darkCard),
                    ),
                    Text(
                      'Tarifa: ${lot.formattedPrice}',
                      style: AppTypography.caption.copyWith(color: AppColors.darkCard.withAlpha(180)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              PillButton(
                text: 'Confirmar y generar pase',
                variant: PillButtonVariant.dark,
                onPressed: () {
                  ref.read(userReservationsProvider.notifier).addReservation(
                    parkingLotName: lot.name,
                    address: '${lot.address}, Pasto',
                    hours: _selectedHours,
                    formattedTotal: formattedTotal,
                  );
                  context.go('/confirmation?lot=${lot.id}');
                },
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
class ConfirmationScreen extends ConsumerWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotId = GoRouterState.of(context).uri.queryParameters['lot'] ?? 'pasto-unicentro-1';
    final lot = PastoDataService.getParkingLotById(lotId) ?? PastoDataService.getAllParkingLots().first;
    final reservations = ref.watch(userReservationsProvider);
    final currentRes = reservations.isNotEmpty ? reservations.first : null;
    final qrCode = currentRes?.qrCode ?? 'QR-PAS-PASTO';
    final spotNumber = currentRes?.spotNumber ?? '#P-01';

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
                'Tu cupo $spotNumber en ${lot.name} (${lot.address}, Pasto) está confirmado. Presenta este código QR al operador del parqueadero para validar tu entrada y realizar el pago en taquilla.',
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
                    Text('CÓDIGO: $qrCode', style: AppTypography.bodyBold.copyWith(color: AppColors.white)),
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
