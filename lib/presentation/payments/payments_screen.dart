import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/motion_utils.dart';
import '../shared/app_card.dart';
import '../shared/app_drawer.dart';
import '../shared/avatar_button.dart';
import '../shared/pill_button.dart';
import '../shared/section_label.dart';
import '../shared/status_pill.dart';
import '../shared/two_tone_title.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Builder(
                        builder: (ctx) => IconButton(
                          icon: const Icon(Icons.menu_rounded, color: AppColors.darkCard),
                          onPressed: () => Scaffold.of(ctx).openDrawer(),
                        ),
                      ),
                    ),
                    Text(
                      'Billetera y Pagos',
                      style: AppTypography.title.copyWith(fontSize: 18),
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel('SALDO PREPAGO Y MEDIOS'),
                    SizedBox(height: 6),
                    TwoToneTitle(text: 'Billetera ', highlightText: 'digital'),
                  ],
                ),
                index: 1,
              ),
              const SizedBox(height: 20),

              // Balance Card (Amber)
              MotionUtils.staggerEntrance(
                AppCard(
                  variant: AppCardVariant.amber,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SALDO DISPONIBLE',
                            style: AppTypography.sectionLabel.copyWith(color: AppColors.darkCard),
                          ),
                          const Icon(Icons.account_balance_wallet_rounded, color: AppColors.darkCard),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\$48.500 COP',
                        style: AppTypography.display.copyWith(color: AppColors.darkCard, fontSize: 32),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ahorra un 10% adicional reservando con saldo prepago.',
                        style: AppTypography.caption.copyWith(color: AppColors.darkCard.withAlpha(180)),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: PillButton(
                              text: '+ Recargar saldo',
                              variant: PillButtonVariant.dark,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Pasarela de recarga simulada')),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white.withAlpha(200),
                              borderRadius: BorderRadius.circular(26),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Retirar',
                              style: AppTypography.bodyBold.copyWith(color: AppColors.darkCard),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                index: 2,
              ),
              const SizedBox(height: 18),

              // Saved Cards (Dark Card)
              MotionUtils.staggerEntrance(
                AppCard(
                  variant: AppCardVariant.dark,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionLabel('MÉTODO PREDETERMINADO', color: Colors.white70),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade900,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: const Text('VISA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('•••• 4242', style: AppTypography.bodyBold.copyWith(color: AppColors.white, letterSpacing: 2)),
                                Text('Vence 08/28 • Crédito', style: AppTypography.caption.copyWith(color: Colors.white60)),
                              ],
                            ),
                          ),
                          const StatusPill(
                            text: 'ACTIVA',
                            backgroundColor: Color(0xFF333333),
                            textColor: AppColors.secondary,
                          ),
                        ],
                      ),
                      const Divider(height: 28, color: Colors.white12),
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.purple.shade700,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: const Text('NEQUI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Celular 310 ••• 7890', style: AppTypography.bodyBold.copyWith(color: AppColors.white)),
                                Text('Billetera vinculada', style: AppTypography.caption.copyWith(color: Colors.white60)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                        ],
                      ),
                    ],
                  ),
                ),
                index: 3,
              ),
              const SizedBox(height: 20),

              // Recent Transactions (White Cards)
              const SectionLabel('TRANSACCIONES RECIENTES'),
              const SizedBox(height: 10),
              MotionUtils.staggerEntrance(
                AppCard(
                  variant: AppCardVariant.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTxItem('Parqueadero San José', 'Hoy 10:30 AM', '-\$7.000 COP', Icons.directions_car_rounded, isNegative: true),
                      const Divider(height: 20),
                      _buildTxItem('Recarga de saldo PSE', 'Ayer 2:15 PM', '+\$50.000 COP', Icons.add_circle_outline_rounded, isNegative: false),
                      const Divider(height: 20),
                      _buildTxItem('Centro Comercial Andino', '10 Oct 2026', '-\$15.000 COP', Icons.directions_car_rounded, isNegative: true),
                    ],
                  ),
                ),
                index: 4,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTxItem(String title, String date, String amount, IconData icon, {required bool isNegative}) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isNegative ? AppColors.secondary.withAlpha(60) : Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isNegative ? AppColors.darkCard : Colors.green.shade700, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodyBold.copyWith(fontSize: 13.5)),
              Text(date, style: AppTypography.caption.copyWith(color: AppColors.textSecondaryLight, fontSize: 11)),
            ],
          ),
        ),
        Text(
          amount,
          style: AppTypography.bodyBold.copyWith(
            color: isNegative ? AppColors.darkCard : Colors.green.shade700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
