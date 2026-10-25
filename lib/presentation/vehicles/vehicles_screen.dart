import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/motion_utils.dart';
import '../reservations/reservations_provider.dart';
import '../shared/app_card.dart';
import '../shared/app_drawer.dart';
import '../shared/avatar_button.dart';
import '../shared/pill_button.dart';
import '../shared/section_label.dart';
import '../shared/status_pill.dart';
import '../shared/two_tone_title.dart';
import '../shared/app_text_field.dart';
import 'vehicles_provider.dart';

class VehiclesScreen extends ConsumerStatefulWidget {
  const VehiclesScreen({super.key});

  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(userVehiclesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              MotionUtils.staggerEntrance(
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Builder(
                        builder: (ctx) => IconButton(
                          icon: Icon(
                            Icons.menu_rounded,
                            color: isDark ? AppColors.white : AppColors.darkCard,
                          ),
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                        ),
                      ),
                    ),
                    Text(
                      'Mis Vehículos',
                      style: AppTypography.title.copyWith(
                        fontSize: 18,
                        color: isDark ? AppColors.white : AppColors.darkCard,
                      ),
                    ),
                    AvatarButton(
                      onTap: () => context.go('/profile'),
                    ),
                  ],
                ),
                index: 0,
              ),
              const SizedBox(height: 20),

              MotionUtils.staggerEntrance(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(
                      'GARAJE VIRTUAL',
                      color: isDark ? AppColors.secondary : null,
                    ),
                    const SizedBox(height: 6),
                    const TwoToneTitle(text: 'Tus ', highlightText: 'vehículos'),
                  ],
                ),
                index: 1,
              ),
              const SizedBox(height: 8),
              Text(
                'Registra y administra tus placas para ingreso automatizado por cámaras LPR en San Juan de Pasto.',
                style: AppTypography.body.copyWith(
                  color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 22),

              // Empty state or Vehicle cards list
              if (vehicles.isEmpty)
                MotionUtils.staggerEntrance(
                  AppCard(
                    variant: AppCardVariant.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withAlpha(isDark ? 60 : 50),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.directions_car_outlined,
                              size: 30,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes vehículos registrados',
                            style: AppTypography.title.copyWith(
                              fontSize: 18,
                              color: isDark ? AppColors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Agrega tu vehículo para reservar fácilmente en los parqueaderos de Pasto.',
                            textAlign: TextAlign.center,
                            style: AppTypography.body.copyWith(
                              color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  index: 2,
                )
              else
                for (int i = 0; i < vehicles.length; i++) ...[
                  MotionUtils.staggerEntrance(
                    _buildVehicleCard(context, vehicles[i], i, isDark),
                    index: 2 + i,
                  ),
                  const SizedBox(height: 16),
                ],

              const SizedBox(height: 12),

              MotionUtils.staggerEntrance(
                PillButton(
                  text: 'Registrar nuevo vehículo +',
                  variant: isDark ? PillButtonVariant.primary : PillButtonVariant.dark,
                  onPressed: () => _showAddVehicleModal(context, isDark),
                ),
                index: 2 + vehicles.length,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(
    BuildContext context,
    UserVehicleItem vehicle,
    int index,
    bool isDark,
  ) {
    // Style variations matching existing design
    final AppCardVariant cardVariant;
    if (vehicle.isPrimary || index == 0) {
      cardVariant = AppCardVariant.dark;
    } else if (index == 1) {
      cardVariant = AppCardVariant.amber;
    } else {
      cardVariant = AppCardVariant.white;
    }

    final bool isDarkCard = cardVariant == AppCardVariant.dark;
    final bool isAmberCard = cardVariant == AppCardVariant.amber;

    final Color titleColor = isDarkCard
        ? AppColors.white
        : (isAmberCard ? AppColors.darkCard : (isDark ? AppColors.white : const Color(0xFF0F172A)));

    final Color captionColor = isDarkCard
        ? Colors.white60
        : (isAmberCard ? AppColors.darkCard.withAlpha(180) : (isDark ? Colors.white60 : AppColors.textSecondaryLight));

    return AppCard(
      variant: cardVariant,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDarkCard
                      ? AppColors.secondary
                      : (isAmberCard
                          ? AppColors.white
                          : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0))),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  vehicle.plate,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamily,
                    color: isDarkCard
                        ? AppColors.darkCard
                        : (isAmberCard ? AppColors.darkCard : (isDark ? AppColors.white : AppColors.darkCard)),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              StatusPill(
                text: vehicle.isPrimary
                    ? 'PRINCIPAL'
                    : vehicle.vehicleType.toUpperCase(),
                backgroundColor: isDarkCard
                    ? const Color(0xFF333333)
                    : (isAmberCard
                        ? AppColors.white
                        : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE8F5E9))),
                textColor: isDarkCard
                    ? AppColors.secondary
                    : (isAmberCard
                        ? AppColors.darkCard
                        : (vehicle.vehicleType.toLowerCase().contains('moto')
                            ? const Color(0xFF2E7D32)
                            : (isDark ? AppColors.white : AppColors.darkCard))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            vehicle.displayName,
            style: AppTypography.title.copyWith(color: titleColor, fontSize: 19),
          ),
          const SizedBox(height: 4),
          Text(
            '${vehicle.vehicleType} • ${vehicle.color}',
            style: AppTypography.caption.copyWith(color: captionColor),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final badge in vehicle.badges) ...[
                _buildVehicleBadge(
                  badge,
                  badge.contains('SOAT')
                      ? Icons.verified_user_rounded
                      : (badge.contains('Tag')
                          ? Icons.nfc_rounded
                          : (badge.contains('Tarifa')
                              ? Icons.local_offer_rounded
                              : Icons.aspect_ratio_rounded)),
                  isDarkCard
                      ? Colors.greenAccent
                      : (isAmberCard
                          ? AppColors.darkCard
                          : (isDark ? AppColors.secondary : AppColors.primary)),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: isDarkCard
                ? Colors.white12
                : (isAmberCard ? Colors.black12 : (isDark ? Colors.white12 : const Color(0xFFE2E8F0))),
          ),
          const SizedBox(height: 12),
          // Action Buttons: Edit and Delete with Wrap layout to prevent pixel overflow
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 10,
            children: [
              if (!vehicle.isPrimary)
                MotionUtils.pressable(
                  onTap: () {
                    ref.read(userVehiclesProvider.notifier).setPrimary(vehicle.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.darkCard,
                        content: Text('${vehicle.displayName} marcado como principal'),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDarkCard
                          ? Colors.white.withAlpha(22)
                          : (isAmberCard ? Colors.black.withAlpha(15) : (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9))),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_outline_rounded,
                          size: 14,
                          color: isDarkCard ? Colors.white70 : AppColors.darkCard,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Hacer principal',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isDarkCard ? Colors.white70 : AppColors.darkCard,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MotionUtils.pressable(
                    key: Key('edit_vehicle_${vehicle.id}'),
                    onTap: () => _showEditVehicleModal(context, vehicle, isDark),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDarkCard
                            ? AppColors.secondary.withAlpha(35)
                            : (isAmberCard ? AppColors.white.withAlpha(200) : AppColors.primary.withAlpha(30)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: isDarkCard ? AppColors.secondary : (isAmberCard ? AppColors.darkCard : AppColors.primary),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Editar',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDarkCard ? AppColors.secondary : (isAmberCard ? AppColors.darkCard : AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  MotionUtils.pressable(
                    key: Key('delete_vehicle_${vehicle.id}'),
                    onTap: () => _handleDeleteVehicle(context, vehicle),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 14,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Eliminar',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  void _handleDeleteVehicle(BuildContext context, UserVehicleItem vehicle) {
    final activeReservations = ref.read(userReservationsProvider);
    final hasActiveReservation = activeReservations.any(
      (res) => res.isActiveOrConfirmed && res.cleanPlate == vehicle.cleanPlate,
    );

    // Criterio de Aceptación:
    // No se permite eliminar un vehículo con reservas pendientes, confirmadas o activas.
    if (hasActiveReservation) {
      final activeRes = activeReservations.firstWhere(
        (res) => res.isActiveOrConfirmed && res.cleanPlate == vehicle.cleanPlate,
      );

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFE5A642), size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Vehículo con reserva activa',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            'No se puede eliminar ${vehicle.displayName} (${vehicle.plate}) porque cuenta con una reserva activa o confirmada (${activeRes.spotNumber} en ${activeRes.parkingLotName}).\n\nDebes cancelar o concluir tu estancia antes de eliminar el vehículo.',
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/my-reservations');
              },
              child: const Text('Ver mis reservas'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkCard,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    // Si no tiene reservas activas, pedir confirmación y proceder
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 26),
            SizedBox(width: 8),
            Text('¿Eliminar vehículo?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar ${vehicle.displayName} (${vehicle.plate}) de tu cuenta? Esta acción no se puede deshacer.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              final result = ref
                  .read(userVehiclesProvider.notifier)
                  .deleteVehicle(vehicle.id, activeReservations);

              if (result.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.darkCard,
                    content: Text(
                      'Vehículo ${vehicle.plate} eliminado con éxito.',
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.error,
                    content: Text(result.errorMessage ?? 'Error al eliminar vehículo.'),
                  ),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showEditVehicleModal(
    BuildContext context,
    UserVehicleItem vehicle,
    bool isDark,
  ) {
    final plateCtrl = TextEditingController(text: vehicle.plate);
    final brandCtrl = TextEditingController(text: vehicle.brand);
    final modelCtrl = TextEditingController(text: vehicle.model);
    final yearCtrl = TextEditingController(text: vehicle.year);
    final colorCtrl = TextEditingController(text: vehicle.color);
    String selectedType = vehicle.vehicleType;
    bool isPrimary = vehicle.isPrimary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Editar Vehículo',
                  style: AppTypography.title.copyWith(
                    color: isDark ? AppColors.white : AppColors.darkCard,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Modifica los datos de tu vehículo registrado.',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Número de Placa',
                  controller: plateCtrl,
                  hintText: 'ABC · 123',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Marca',
                        controller: brandCtrl,
                        hintText: 'Mazda',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Modelo',
                        controller: modelCtrl,
                        hintText: '3 Touring',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Año',
                        controller: yearCtrl,
                        hintText: '2023',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Color',
                        controller: colorCtrl,
                        hintText: 'Gris Titanio',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Tipo de Vehículo',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : AppColors.darkCard,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Sedán', 'Camioneta SUV', 'Motocicleta'].map((type) {
                    final isSel = selectedType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSel,
                      selectedColor: AppColors.secondary,
                      backgroundColor: isDark ? const Color(0xFF2C2C2C) : AppColors.white,
                      labelStyle: TextStyle(
                        color: isSel
                            ? AppColors.darkCard
                            : (isDark ? AppColors.white : AppColors.darkCard),
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setModalState(() => selectedType = type);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Vehículo principal',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.darkCard,
                    ),
                  ),
                  subtitle: Text(
                    'Se seleccionará por defecto al reservar cupos.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                    ),
                  ),
                  value: isPrimary,
                  activeThumbColor: AppColors.secondary,
                  onChanged: (val) => setModalState(() => isPrimary = val),
                ),
                const SizedBox(height: 20),
                PillButton(
                  text: 'Guardar Cambios',
                  variant: PillButtonVariant.primary,
                  onPressed: () {
                    final updated = vehicle.copyWith(
                      plate: plateCtrl.text.trim().toUpperCase(),
                      brand: brandCtrl.text.trim(),
                      model: modelCtrl.text.trim(),
                      year: yearCtrl.text.trim(),
                      color: colorCtrl.text.trim(),
                      vehicleType: selectedType,
                      isPrimary: isPrimary,
                    );
                    ref.read(userVehiclesProvider.notifier).updateVehicle(updated);
                    Navigator.of(modalCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.darkCard,
                        content: Text(
                          'Vehículo ${updated.plate} actualizado exitosamente.',
                          style: const TextStyle(color: AppColors.white),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddVehicleModal(BuildContext context, bool isDark) {
    final plateCtrl = TextEditingController();
    final brandCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final yearCtrl = TextEditingController(text: '2024');
    final colorCtrl = TextEditingController();
    String selectedType = 'Sedán';
    bool isPrimary = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Registrar Nuevo Vehículo',
                  style: AppTypography.title.copyWith(
                    color: isDark ? AppColors.white : AppColors.darkCard,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ingresa los datos para registrar un vehículo en tu garaje.',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Número de Placa',
                  controller: plateCtrl,
                  hintText: 'Ej. MNQ · 567',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Marca',
                        controller: brandCtrl,
                        hintText: 'Chevrolet',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Modelo',
                        controller: modelCtrl,
                        hintText: 'Onix Turbo',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Año',
                        controller: yearCtrl,
                        hintText: '2024',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Color',
                        controller: colorCtrl,
                        hintText: 'Rojo Carmesí',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Tipo de Vehículo',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : AppColors.darkCard,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Sedán', 'Camioneta SUV', 'Motocicleta'].map((type) {
                    final isSel = selectedType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSel,
                      selectedColor: AppColors.secondary,
                      backgroundColor: isDark ? const Color(0xFF2C2C2C) : AppColors.white,
                      labelStyle: TextStyle(
                        color: isSel
                            ? AppColors.darkCard
                            : (isDark ? AppColors.white : AppColors.darkCard),
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setModalState(() => selectedType = type);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Vehículo principal',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.darkCard,
                    ),
                  ),
                  subtitle: Text(
                    'Se seleccionará por defecto al reservar cupos.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                    ),
                  ),
                  value: isPrimary,
                  activeThumbColor: AppColors.secondary,
                  onChanged: (val) => setModalState(() => isPrimary = val),
                ),
                const SizedBox(height: 20),
                PillButton(
                  text: 'Registrar Vehículo',
                  variant: PillButtonVariant.primary,
                  onPressed: () {
                    final plate = plateCtrl.text.trim().toUpperCase();
                    if (plate.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor ingresa la placa.')),
                      );
                      return;
                    }

                    final newVehicle = UserVehicleItem(
                      id: 'veh-${DateTime.now().millisecondsSinceEpoch}',
                      plate: plate,
                      brand: brandCtrl.text.trim().isEmpty ? 'Vehículo' : brandCtrl.text.trim(),
                      model: modelCtrl.text.trim(),
                      year: yearCtrl.text.trim().isEmpty ? '2024' : yearCtrl.text.trim(),
                      color: colorCtrl.text.trim().isEmpty ? 'Estándar' : colorCtrl.text.trim(),
                      vehicleType: selectedType,
                      isPrimary: isPrimary,
                      badges: const ['SOAT al día'],
                    );

                    ref.read(userVehiclesProvider.notifier).addVehicle(newVehicle);
                    Navigator.of(modalCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.darkCard,
                        content: Text(
                          '¡Vehículo $plate registrado exitosamente!',
                          style: const TextStyle(color: AppColors.white),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
