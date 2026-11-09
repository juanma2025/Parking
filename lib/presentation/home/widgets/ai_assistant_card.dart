import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/motion_utils.dart';
import '../../../data/datasources/gemini_chat_service.dart';
import '../../shared/app_card.dart';
import '../../shared/glass_container.dart';

/// Card compacta del Chatbot con IA (Gemini) ubicada debajo de las sugerencias
/// de parqueaderos en HomeScreen.
class AiAssistantCard extends StatelessWidget {
  const AiAssistantCard({super.key});

  void _openChatSheet(BuildContext context, {String? initialPrompt}) {
    MotionUtils.triggerHaptic(HapticType.mediumImpact);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AiChatbotSheet(initialPrompt: initialPrompt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      variant: AppCardVariant.dark,
      padding: const EdgeInsets.all(16),
      borderRadius: DesignTokens.radiusCard,
      onTap: () => _openChatSheet(context),
      semanticLabel: 'Abrir asistente inteligente Parking AI',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(70),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.darkCard,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Asistente Parking AI',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title.copyWith(
                              color: AppColors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.secondary.withAlpha(110),
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            'IA',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pregunta por cupos libres, tarifas o zonas en Pasto',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF333333),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.secondary,
                  size: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _QuickPromptChip(
                  label: '✨ ¿Dónde parquear en Unicentro?',
                  onTap: () => _openChatSheet(
                    context,
                    initialPrompt: '¿Dónde puedo parquear cerca a Unicentro?',
                  ),
                ),
                const SizedBox(width: 8),
                _QuickPromptChip(
                  label: '💰 Parqueadero más económico',
                  onTap: () => _openChatSheet(
                    context,
                    initialPrompt:
                        '¿Cuál es el parqueadero más económico en Pasto?',
                  ),
                ),
                const SizedBox(width: 8),
                _QuickPromptChip(
                  label: '🏥 Cupos cerca a Hospital San Pedro',
                  onTap: () => _openChatSheet(
                    context,
                    initialPrompt:
                        '¿Qué parqueaderos hay cerca al Hospital San Pedro?',
                  ),
                ),
              ],
            ),
          ),
          if (!isDark) const SizedBox(height: 2),
        ],
      ),
    );
  }
}

class _QuickPromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickPromptChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MotionUtils.pressable(
      onTap: onTap,
      haptic: HapticType.selectionClick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withAlpha(24),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class AiChatbotSheet extends StatefulWidget {
  final String? initialPrompt;

  const AiChatbotSheet({super.key, this.initialPrompt});

  @override
  State<AiChatbotSheet> createState() => _AiChatbotSheetState();
}

class _AiChatbotSheetState extends State<AiChatbotSheet> {
  final GeminiChatService _chatService = GeminiChatService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<AiChatMessage> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      AiChatMessage(
        id: 'welcome',
        text:
            '¡Hola! Soy tu asistente inteligente Parking Pasto AI. Pregúntame por tarifas, cupos en tiempo real o parqueaderos cerca a clínicas y centros comerciales.',
        isUser: false,
        createdAt: DateTime.now(),
      ),
    );
    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendText(widget.initialPrompt!);
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _sendText(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || _isSending) return;

    MotionUtils.triggerHaptic(HapticType.lightImpact);
    _inputController.clear();

    final historySnapshot = List<AiChatMessage>.from(_messages);
    setState(() {
      _messages.add(
        AiChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: text,
          isUser: true,
          createdAt: DateTime.now(),
        ),
      );
      _isSending = true;
    });
    _scrollToBottom();

    final reply = await _chatService.sendMessage(
      userMessage: text,
      history: historySnapshot,
    );

    if (!mounted) return;
    setState(() {
      _messages.add(
        AiChatMessage(
          id: '${DateTime.now().microsecondsSinceEpoch}_ai',
          text: reply,
          isUser: false,
          createdAt: DateTime.now(),
        ),
      );
      _isSending = false;
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 680,
              maxHeight: 620,
            ),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 24, 12, 12),
              decoration: BoxDecoration(
                color: isDark
                    ? DesignTokens.darkBackground
                    : DesignTokens.lightBackground,
                borderRadius: BorderRadius.circular(DesignTokens.radiusCardLg),
                border: Border.all(
                  color: DesignTokens.outline(isDark),
                ),
              ),
              child: Column(
                children: [
                  // Header limpio sin botón ni texto de API Key
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                    child: GlassContainer(
                      borderRadius: DesignTokens.radiusCardSm,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: DesignTokens.brandAccent,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: DesignTokens.onBrandAccent,
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Parking Pasto AI',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: DesignTokens.headline(isDark),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: DesignTokens.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Asistente inteligente · En línea',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: DesignTokens.caption(isDark),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Cerrar',
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close_rounded,
                              color: DesignTokens.onSurface(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Lista de mensajes
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _messages.length + (_isSending ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: DesignTokens.surface(isDark),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: DesignTokens.outline(isDark),
                                ),
                              ),
                              child: Text(
                                'Analizando parqueaderos en Pasto...',
                                style: DesignTokens.caption(isDark),
                              ),
                            ),
                          );
                        }

                        final msg = _messages[index];
                        return Align(
                          alignment: msg.isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 320),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: msg.isUser
                                  ? DesignTokens.brandAccent
                                  : DesignTokens.surface(isDark),
                              borderRadius: BorderRadius.circular(18),
                              border: msg.isUser
                                  ? null
                                  : Border.all(
                                      color: DesignTokens.outline(isDark),
                                    ),
                            ),
                            child: Text(
                              msg.text,
                              style: DesignTokens.body(isDark).copyWith(
                                color: msg.isUser
                                    ? DesignTokens.onBrandAccent
                                    : DesignTokens.onSurface(isDark),
                                fontWeight: msg.isUser
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Barra de entrada de mensaje
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: DesignTokens.surface(isDark),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: DesignTokens.outline(isDark),
                              ),
                            ),
                            child: TextField(
                              controller: _inputController,
                              onSubmitted: _sendText,
                              style: DesignTokens.body(isDark).copyWith(
                                color: DesignTokens.onSurface(isDark),
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Pregunta sobre cupos o tarifas en Pasto...',
                                hintStyle: DesignTokens.caption(isDark),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        MotionUtils.pressable(
                          onTap: () => _sendText(_inputController.text),
                          haptic: HapticType.mediumImpact,
                          semanticLabel: 'Enviar mensaje',
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: DesignTokens.minTouchTarget,
                            height: DesignTokens.minTouchTarget,
                            decoration: const BoxDecoration(
                              color: DesignTokens.brandAccent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.send_rounded,
                              color: DesignTokens.onBrandAccent,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
