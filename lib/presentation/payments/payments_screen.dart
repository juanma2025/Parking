import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/motion_utils.dart';
import '../owner/spaces_provider.dart';
import '../reservations/reservations_provider.dart';
import '../shared/app_card.dart';
import '../shared/app_drawer.dart';
import '../shared/avatar_button.dart';
import '../shared/pill_button.dart';
import '../shared/section_label.dart';
import '../shared/status_pill.dart';
import '../shared/two_tone_title.dart';
import 'payments_provider.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  // Form controllers
  final _amountCtrl = TextEditingController(text: '2800');
  final _plateCtrl = TextEditingController();
  final _receivedCtrl = TextEditingController(text: '5000');
  final _nequiPhoneCtrl = TextEditingController();
  final _nequiRefCtrl = TextEditingController();
  final _transferRefCtrl = TextEditingController();
  final _transferOwnerCtrl = TextEditingController();

  String _selectedMethod = 'efectivo'; // 'efectivo', 'nequi', 'transferencia'
  String _selectedBank = 'Bancolombia';
  String? _selectedSpace; // e.g. 'A-01'

  @override
  void dispose() {
    _amountCtrl.dispose();
    _plateCtrl.dispose();
    _receivedCtrl.dispose();
    _nequiPhoneCtrl.dispose();
    _nequiRefCtrl.dispose();
    _transferRefCtrl.dispose();
    _transferOwnerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeReservations = ref.watch(userReservationsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final spaces = ref.watch(parkingSpacesProvider);
    final occupiedSpaces = spaces.where((s) => s.isOccupied).toList();

    // Calculate change for cash
    final amount = double.tryParse(_amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    final received = double.tryParse(_receivedCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    final change = received - amount;

    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Hamburger, Title, Theme Mode Toggle, and Avatar
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 30 : 8),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Builder(
                        builder: (ctx) => IconButton(
                          icon: Icon(Icons.menu_rounded, color: isDark ? AppColors.white : AppColors.darkCard),
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                        ),
                      ),
                    ),
                    Text(
                      'Pases y Pagos',
                      style: AppTypography.title.copyWith(
                        fontSize: 18,
                        color: isDark ? AppColors.white : AppColors.darkCard,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Quick theme switcher button
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            tooltip: themeMode == ThemeMode.system
                                ? 'Tema: Sistema'
                                : (themeMode == ThemeMode.dark ? 'Tema: Oscuro' : 'Tema: Claro'),
                            icon: Icon(
                              themeMode == ThemeMode.system
                                  ? Icons.brightness_auto_rounded
                                  : (themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                              color: AppColors.secondary,
                              size: 20,
                            ),
                            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AvatarButton(
                          onTap: () => context.go('/profile'),
                        ),
                      ],
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
                      'PAGO DIRECTO EN PARQUEADERO',
                      color: isDark ? AppColors.secondary : null,
                    ),
                    const SizedBox(height: 6),
                    const TwoToneTitle(text: 'Pases y ', highlightText: 'pagos'),
                  ],
                ),
                index: 1,
              ),
              const SizedBox(height: 16),

              // Informative Banner: No payment gateway, QR scan on-site
              MotionUtils.staggerEntrance(
                AppCard(
                  variant: AppCardVariant.amber,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.darkCard,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.secondary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pago Presencial con QR',
                              style: AppTypography.title.copyWith(
                                color: AppColors.darkCard,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'En Pasto Parking no requieres registrar tarjetas ni usar pasarelas digitales. Presenta el código QR de tu reserva al operador del parqueadero para validar tu estancia y realizar el pago presencial en caja (efectivo, Nequi o transferencia directa).',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.darkCard.withAlpha(220),
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                index: 2,
              ),
              const SizedBox(height: 22),

              // ================================================================
              // REGISTRO DE COBROS EN TAQUILLA (EFECTIVO, NEQUI, TRANSFERENCIAS)
              // ================================================================
              SectionLabel(
                'REGISTRAR COBRO EN TAQUILLA',
                color: isDark ? AppColors.secondary : null,
              ),
              const SizedBox(height: 10),

              MotionUtils.staggerEntrance(
                AppCard(
                  variant: isDark ? AppCardVariant.dark : AppCardVariant.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Occupied Space selector
                      if (occupiedSpaces.isNotEmpty) ...[
                        Text(
                          'Selecciona bahía ocupada a liquidar:',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : AppColors.darkCard,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _selectedSpace = null),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _selectedSpace == null
                                        ? AppColors.secondary
                                        : (isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Transeúnte',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedSpace == null ? AppColors.darkCard : (isDark ? Colors.white70 : AppColors.darkCard),
                                    ),
                                  ),
                                ),
                              ),
                              for (final sp in occupiedSpaces)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedSpace = sp.spaceNumber;
                                      if (sp.plate != null && sp.plate!.isNotEmpty) {
                                        _plateCtrl.text = sp.plate!;
                                      }
                                      _amountCtrl.text = sp.hourlyRate.toInt().toString();
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _selectedSpace == sp.spaceNumber
                                          ? AppColors.secondary
                                          : (isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9)),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _selectedSpace == sp.spaceNumber ? AppColors.secondary : Colors.transparent,
                                      ),
                                    ),
                                    child: Text(
                                      '${sp.spaceNumber} (${sp.plate ?? 'Vehículo'})',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: _selectedSpace == sp.spaceNumber ? AppColors.darkCard : (isDark ? Colors.white70 : AppColors.darkCard),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Plate and Amount inputs
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _plateCtrl,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                labelText: 'Placa (ej: ABC-123)',
                                filled: true,
                                fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF8F9FA),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.pin_rounded, color: AppColors.secondary, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _amountCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: 'Total (COP)',
                                filled: true,
                                fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF8F9FA),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.secondary, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Quick rate buttons
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildQuickTariffChip('1h Moto (\$1.400)', '1400', isDark),
                            const SizedBox(width: 6),
                            _buildQuickTariffChip('1h Carro (\$2.800)', '2800', isDark),
                            const SizedBox(width: 6),
                            _buildQuickTariffChip('2h Carro (\$5.600)', '5600', isDark),
                            const SizedBox(width: 6),
                            _buildQuickTariffChip('3h Carro (\$8.400)', '8400', isDark),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Medio de pago recibido:',
                        style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : AppColors.darkCard),
                      ),
                      const SizedBox(height: 8),

                      // Payment Method Selector
                      Row(
                        children: [
                          _buildMethodCard('efectivo', 'Efectivo', Icons.payments_rounded, const Color(0xFF2E7D32), isDark),
                          const SizedBox(width: 8),
                          _buildMethodCard('nequi', 'Nequi', Icons.qr_code_2_rounded, const Color(0xFF7B1FA2), isDark),
                          const SizedBox(width: 8),
                          _buildMethodCard('transferencia', 'Transferencia', Icons.account_balance_rounded, const Color(0xFF0288D1), isDark),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Specific fields for selected method
                      if (_selectedMethod == 'efectivo') ...[
                        TextField(
                          controller: _receivedCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Monto en efectivo recibido (\$ COP)',
                            filled: true,
                            fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.monetization_on_outlined, color: Color(0xFF2E7D32)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildBillButton('5.000', isDark),
                            const SizedBox(width: 6),
                            _buildBillButton('10.000', isDark),
                            const SizedBox(width: 6),
                            _buildBillButton('20.000', isDark),
                            const SizedBox(width: 6),
                            _buildBillButton('50.000', isDark),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: change >= 0
                                ? const Color(0xFF2E7D32).withAlpha(isDark ? 50 : 25)
                                : Colors.red.withAlpha(isDark ? 50 : 25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: change >= 0 ? const Color(0xFF2E7D32) : Colors.red,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                change >= 0 ? 'VUELTAS / CAMBIO:' : 'FALTA POR RECIBIR:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: change >= 0 ? const Color(0xFF2E7D32) : Colors.red,
                                ),
                              ),
                              Text(
                                '\$${change.abs().toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} COP',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: change >= 0 ? const Color(0xFF2E7D32) : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (_selectedMethod == 'nequi') ...[
                        TextField(
                          controller: _nequiPhoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Celular Nequi del Conductor (ej: 312 456 7890)',
                            filled: true,
                            fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF7B1FA2)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nequiRefCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'N° de Comprobante M... (ej: M849102)',
                            filled: true,
                            fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.tag_rounded, color: Color(0xFF7B1FA2)),
                          ),
                        ),
                      ] else ...[
                        DropdownButtonFormField<String>(
                          initialValue: _selectedBank,
                          items: const [
                            DropdownMenuItem(value: 'Bancolombia', child: Text('Bancolombia (A la mano / QR)')),
                            DropdownMenuItem(value: 'Daviplata', child: Text('Daviplata')),
                            DropdownMenuItem(value: 'PSE', child: Text('PSE / Transferencia en línea')),
                            DropdownMenuItem(value: 'Otros', child: Text('Otros')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedBank = val);
                          },
                          decoration: InputDecoration(
                            labelText: 'Entidad Bancaria',
                            filled: true,
                            fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.account_balance_rounded, color: Color(0xFF0288D1)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _transferRefCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'N° de Referencia / Aprobación (ej: TRF-77210)',
                            filled: true,
                            fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.numbers_rounded, color: Color(0xFF0288D1)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),

                      PillButton(
                        text: '✓ Confirmar y Registrar Pago en Taquilla',
                        variant: PillButtonVariant.primary,
                        onPressed: () => _handleSubmitPayment(context, amount, received, change),
                      ),
                    ],
                  ),
                ),
                index: 3,
              ),
              const SizedBox(height: 24),

              // Active QR Passes Section
              SectionLabel(
                'TUS PASES ACTIVOS PARA PAGO',
                color: isDark ? AppColors.secondary : null,
              ),
              const SizedBox(height: 12),

              if (activeReservations.isEmpty)
                MotionUtils.staggerEntrance(
                  AppCard(
                    variant: AppCardVariant.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withAlpha(isDark ? 60 : 45),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.qr_code_2_rounded, size: 34, color: AppColors.secondary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes pases de pago pendientes',
                            textAlign: TextAlign.center,
                            style: AppTypography.title.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cuando reserves en cualquier parqueadero de San Juan de Pasto (Unicentro, Nova Centro, Único Outlet), aquí se generará tu pase QR para pagar en portería.',
                            textAlign: TextAlign.center,
                            style: AppTypography.body.copyWith(
                              color: isDark ? Colors.white.withAlpha(200) : AppColors.textSecondaryLight,
                              fontSize: 13.5,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 20),
                          PillButton(
                            text: 'Buscar parqueadero en Pasto',
                            variant: isDark ? PillButtonVariant.primary : PillButtonVariant.dark,
                            onPressed: () => context.go('/home'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  index: 4,
                )
              else
                for (int i = 0; i < activeReservations.length; i++) ...[
                  MotionUtils.staggerEntrance(
                    _buildActivePassCard(context, activeReservations[i], isDark: isDark),
                    index: 4 + i,
                  ),
                  const SizedBox(height: 16),
                ],

              const SizedBox(height: 24),

              // How it works Card (High-contrast in both Light & Dark modes)
              SectionLabel(
                '¿CÓMO FUNCIONA EL PAGO EN PASTO?',
                color: isDark ? AppColors.secondary : null,
              ),
              const SizedBox(height: 12),
              MotionUtils.staggerEntrance(
                AppCard(
                  variant: AppCardVariant.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildStepItem(
                        icon: Icons.search_rounded,
                        number: '1',
                        title: 'Reserva tu cupo en Pasto',
                        description: 'Selecciona el parqueadero deseado en el mapa y confirma las horas de estancia.',
                        isDark: isDark,
                      ),
                      Divider(height: 26, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                      _buildStepItem(
                        icon: Icons.qr_code_rounded,
                        number: '2',
                        title: 'Muestra tu código QR en portería',
                        description: 'El operador del parqueadero escanea tu código al ingresar o salir para verificar la reserva.',
                        isDark: isDark,
                      ),
                      Divider(height: 26, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                      _buildStepItem(
                        icon: Icons.storefront_rounded,
                        number: '3',
                        title: 'Paga directamente en taquilla',
                        description: 'Cancela el valor exacto en efectivo, Nequi directo o transferencia bancaria sin recargos.',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                index: 5,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard(String key, String title, IconData icon, Color color, bool isDark) {
    final isSelected = _selectedMethod == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withAlpha(isDark ? 60 : 35)
                : (isDark ? AppColors.darkSurface : const Color(0xFFF8F9FA)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : (isDark ? Colors.white60 : AppColors.textSecondaryLight), size: 22),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? (isDark ? Colors.white : AppColors.darkCard) : (isDark ? Colors.white60 : AppColors.textSecondaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTariffChip(String label, String value, bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _amountCtrl.text = value;
          final valNum = double.tryParse(value) ?? 0;
          if ((double.tryParse(_receivedCtrl.text) ?? 0) < valNum) {
            _receivedCtrl.text = value;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.darkCard),
        ),
      ),
    );
  }

  Widget _buildBillButton(String value, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _receivedCtrl.text = value.replaceAll('.', '')),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2E7D32).withAlpha(100)),
          ),
          child: Text(
            '\$$value',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32)),
          ),
        ),
      ),
    );
  }

  void _handleSubmitPayment(BuildContext context, double amount, double received, double change) {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un monto válido a cobrar.')),
      );
      return;
    }

    if (_selectedMethod == 'efectivo' && change < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El monto recibido en efectivo es menor al total a cobrar.')),
      );
      return;
    }

    final plate = _plateCtrl.text.trim();
    String? refNum;
    String? bank;

    if (_selectedMethod == 'nequi') {
      refNum = _nequiRefCtrl.text.trim().isNotEmpty ? _nequiRefCtrl.text.trim() : 'M-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    } else if (_selectedMethod == 'transferencia') {
      refNum = _transferRefCtrl.text.trim().isNotEmpty ? _transferRefCtrl.text.trim() : 'TRF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      bank = _selectedBank;
    }

    // Save payment
    ref.read(registeredPaymentsProvider.notifier).addPayment(
          amount: amount,
          method: _selectedMethod,
          plate: plate.isNotEmpty ? plate : null,
          spaceNumber: _selectedSpace,
          referenceNumber: refNum,
          bankName: bank,
          receivedAmount: _selectedMethod == 'efectivo' ? received : null,
          changeAmount: _selectedMethod == 'efectivo' ? change : null,
        );

    // If linked to an occupied space, free it!
    if (_selectedSpace != null) {
      ref.read(parkingSpacesProvider.notifier).freeSpace(_selectedSpace!);
    }

    // Show digital receipt dialog
    _showReceiptDialog(context, amount, _selectedMethod, plate, refNum, change);
  }

  void _showReceiptDialog(
    BuildContext context,
    double amount,
    String method,
    String plate,
    String? refNum,
    double change,
  ) {
    final receiptCode = 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    final formatted = '\$${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} COP';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Pago Registrado con Éxito!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Comprobante: $receiptCode',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildReceiptRow('Total Cobrado:', formatted, isBold: true),
                  const SizedBox(height: 8),
                  _buildReceiptRow('Método:', method.toUpperCase()),
                  if (plate.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildReceiptRow('Vehículo / Placa:', plate),
                  ],
                  if (_selectedSpace != null) ...[
                    const SizedBox(height: 8),
                    _buildReceiptRow('Bahía liberada:', _selectedSpace!),
                  ],
                  if (refNum != null) ...[
                    const SizedBox(height: 8),
                    _buildReceiptRow('N° Aprobación:', refNum),
                  ],
                  if (method == 'efectivo') ...[
                    const SizedBox(height: 8),
                    _buildReceiptRow('Vueltas entregadas:', '\$${change.toInt()} COP'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            PillButton(
              text: 'Aceptar y nuevo cobro',
              variant: PillButtonVariant.primary,
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _plateCtrl.clear();
                  _nequiPhoneCtrl.clear();
                  _nequiRefCtrl.clear();
                  _transferRefCtrl.clear();
                  _transferOwnerCtrl.clear();
                  _selectedSpace = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActivePassCard(BuildContext context, ActiveReservationItem item, {required bool isDark}) {
    return AppCard(
      variant: AppCardVariant.dark,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const StatusPill(
                text: 'LISTO PARA ESCANEAR',
                backgroundColor: AppColors.secondary,
                textColor: AppColors.darkCard,
              ),
              Text(
                item.spotNumber,
                style: AppTypography.bodyBold.copyWith(color: AppColors.secondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.parkingLotName,
            style: AppTypography.title.copyWith(color: AppColors.white, fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            item.address,
            style: AppTypography.caption.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 18),

          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2_rounded, size: 140, color: AppColors.darkCard),
                  const SizedBox(height: 6),
                  Text(
                    item.qrCode,
                    style: const TextStyle(
                      color: AppColors.darkCard,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL A PAGAR EN TAQUILLA', style: AppTypography.sectionLabel.copyWith(color: Colors.white60, fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(
                      item.formattedTotal,
                      style: AppTypography.title.copyWith(color: AppColors.secondary, fontSize: 19),
                    ),
                  ],
                ),
                Text(
                  '${item.hours} hora${item.hours > 1 ? 's' : ''}',
                  style: AppTypography.caption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String number,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: AppColors.darkCard,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyBold.copyWith(
                  color: isDark ? AppColors.white : const Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.caption.copyWith(
                  color: isDark ? Colors.white.withAlpha(190) : AppColors.textSecondaryLight,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
