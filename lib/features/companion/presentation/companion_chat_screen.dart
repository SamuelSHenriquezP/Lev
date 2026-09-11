import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/companion/domain/chat_message.dart';
import 'package:lev/features/companion/presentation/controllers/companion_controller.dart';
import 'package:lev/features/habits/domain/micro_habit.dart';
import 'package:lev/features/habits/presentation/habit_timer_screen.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'package:lev/features/sanctuary/presentation/widgets/living_seed_spirit_painter.dart';
import '../../../core/widgets/pin_protection_gate.dart';

class CompanionChatScreen extends ConsumerStatefulWidget {
  const CompanionChatScreen({super.key});

  @override
  ConsumerState<CompanionChatScreen> createState() => _CompanionChatScreenState();
}

class _CompanionChatScreenState extends ConsumerState<CompanionChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _levAnimController;
  bool _isHeaderExpanded = true;

  @override
  void initState() {
    super.initState();
    _levAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _levAnimController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _sendMessage([String? quickText]) {
    final text = quickText ?? _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(companionProvider.notifier).sendUserMessage(text);
    if (quickText == null) {
      _textController.clear();
    }
    _scrollToBottom();
  }

  void _openHabit(MicroHabit habit) {
    HapticsHelper.light();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitTimerScreen(habit: habit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companionProvider);
    final sanctuaryState = ref.watch(sanctuaryProvider);
    final lastLevMessage = state.messages.reversed.where((m) => m.isFromLev).firstOrNull;
    final quickReplies = lastLevMessage?.quickReplies ?? const <String>[];

    ref.listen(companionProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return PinProtectionGate(
      child: Scaffold(
        backgroundColor: LevTheme.levCream,
        appBar: AppBar(
          backgroundColor: LevTheme.levCream,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 16,
          title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LevTheme.levMatchaLight,
                border: Border.all(color: LevTheme.levMatcha.withValues(alpha: 0.35), width: 1.5),
              ),
              child: const Center(
                child: Icon(Icons.spa_rounded, color: LevTheme.levMatchaDark, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lev',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: LevTheme.levTextDark,
                    ),
                  ),
                  Text(
                    _getStatusSubtitle(sanctuaryState.emotion),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: LevTheme.levMatchaDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isHeaderExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: LevTheme.levTextMuted,
            ),
            tooltip: _isHeaderExpanded ? 'Minimizar a Lev' : 'Mostrar a Lev',
            onPressed: () {
              HapticsHelper.selection();
              setState(() {
                _isHeaderExpanded = !_isHeaderExpanded;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- TARJETA COMPAÑERO REACTIVA (LEV VIVO EN 60 FPS) ---
            if (_isHeaderExpanded)
              _buildReactiveLevHeader(sanctuaryState),

            // --- LISTA DE MENSAJES ESTILO TARJETAS ---
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final msg = state.messages[index];
                  return _buildMessageItem(msg);
                },
              ),
            ),

            // Indicador sutil de respiración/escucha
            if (state.isTyping)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(LevTheme.levMatcha),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Lev está sintiendo tus palabras...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: LevTheme.levTextMuted,
                      ),
                    ),
                  ],
                ),
              ),

            // --- PÍLDORAS TÁCTILES DE RESPUESTA RÁPIDA ---
            if (quickReplies.isNotEmpty)
              Container(
                height: 46,
                margin: const EdgeInsets.only(top: 4, bottom: 6),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: quickReplies.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final reply = quickReplies[index];
                    return ActionChip(
                      label: Text(reply),
                      backgroundColor: Colors.white,
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: LevTheme.levTextDark,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: LevTheme.pillRadius,
                        side: BorderSide(color: LevTheme.levMatcha.withValues(alpha: 0.5), width: 1.2),
                      ),
                      onPressed: () => _sendMessage(reply),
                    );
                  },
                ),
              ),

            // --- BARRA DE ENTRADA DE TEXTO ---
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                border: const Border(top: BorderSide(color: LevTheme.levBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: LevTheme.levTextDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cuéntale a Lev cómo estás...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: LevTheme.levTextMuted,
                        ),
                        fillColor: LevTheme.levCream,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: LevTheme.pillRadius,
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: LevTheme.pillRadius,
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: LevTheme.pillRadius,
                          borderSide: const BorderSide(color: LevTheme.levMatcha, width: 1.5),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: LevTheme.levMatcha,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
                      onPressed: () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  /// Tarjeta compañera interactiva en la parte superior donde Lev vive y reacciona
  Widget _buildReactiveLevHeader(SanctuaryState sanctuary) {
    final statusColor = _getStatusColor(sanctuary.emotion);
    final statusText = _getStatusBadgeText(sanctuary.emotion);

    return GestureDetector(
      onTap: () => ref.read(sanctuaryProvider.notifier).petLev(),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: LevTheme.squareRadius,
          border: Border.all(color: statusColor.withValues(alpha: 0.22)),
          boxShadow: LevTheme.softShadow,
        ),
        child: Row(
          children: [
            // Lev animado en vector a 60 FPS
            SizedBox(
              width: 86,
              height: 86,
              child: AnimatedBuilder(
                animation: _levAnimController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(86, 86),
                    painter: LivingSeedSpiritPainter(
                      animationValue: _levAnimController.value,
                      emotion: sanctuary.emotion,
                      isPetting: sanctuary.isPetting,
                      sizeScale: 0.82,
                      leafWrapProgress: sanctuary.emotion == LevEmotion.sheltered ? 1.0 : 0.0,
                      sleepProgress: sanctuary.emotion == LevEmotion.sleeping ? 1.0 : 0.0,
                      breathingProgress: sanctuary.emotion == LevEmotion.breathing ? 1.0 : 0.0,
                      happyProgress: sanctuary.emotion == LevEmotion.happy ? 1.0 : 0.0,
                      jumpProgress: sanctuary.emotion == LevEmotion.joyJump ? 1.0 : 0.0,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Estado y mensaje sutil
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: LevTheme.pillRadius,
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sanctuary.dialogue,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      height: 1.35,
                      color: LevTheme.levTextDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toca a Lev para acariciarlo 🌿',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: LevTheme.levTextMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    if (msg.isFromLev) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LevTheme.levMatchaLight,
                border: Border.all(color: LevTheme.levMatcha.withValues(alpha: 0.3), width: 1),
              ),
              child: const Center(
                child: Icon(Icons.eco_rounded, size: 16, color: LevTheme.levMatchaDark),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta de mensaje no-obvio
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                        topLeft: Radius.circular(6),
                      ),
                      border: Border.all(color: LevTheme.levBorder),
                      boxShadow: LevTheme.softShadow,
                    ),
                    child: Text(
                      msg.text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: LevTheme.levTextDark,
                        height: 1.48,
                      ),
                    ),
                  ),
                  if (msg.recommendedHabit != null) ...[
                    const SizedBox(height: 10),
                    _buildEmbeddedHabitCard(msg.recommendedHabit!),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Mensaje del usuario en tarjeta
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: LevTheme.levMatcha,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(6),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  boxShadow: LevTheme.softShadow,
                ),
                child: Text(
                  msg.text,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildEmbeddedHabitCard(MicroHabit habit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LevTheme.levMatchaLight.withValues(alpha: 0.65),
        borderRadius: LevTheme.squareRadius,
        border: Border.all(color: LevTheme.levMatcha.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(habit.icon, size: 20, color: LevTheme.levMatchaDark),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  habit.title,
                  style: GoogleFonts.quicksand(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levTextDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '60s',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levMatchaDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            habit.psychologicalBasis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.35,
              color: LevTheme.levTextMuted,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openHabit(habit),
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Hacer 60s con Lev'),
              style: ElevatedButton.styleFrom(
                backgroundColor: LevTheme.levMatcha,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: LevTheme.pillRadius,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusSubtitle(LevEmotion emotion) {
    switch (emotion) {
      case LevEmotion.breathing:
        return 'Respirando contigo • Sin juicios';
      case LevEmotion.sleeping:
        return 'Descansando en paz • En silencio';
      case LevEmotion.sheltered:
        return 'Protegiéndote con su hoja';
      case LevEmotion.curious:
        return 'Curioso y atento contigo';
      case LevEmotion.joyJump:
      case LevEmotion.happy:
      case LevEmotion.celebrating:
        return 'Sintiendo tu alivio';
      case LevEmotion.sad:
        return 'Acompañándote en la tristeza';
      case LevEmotion.anxious:
        return 'Calmando juntos la tormenta';
      case LevEmotion.tired:
        return 'Descansando a tu lado';
      case LevEmotion.peaceful:
        return 'Aquí contigo • Sin juicios';
    }
  }

  String _getStatusBadgeText(LevEmotion emotion) {
    switch (emotion) {
      case LevEmotion.breathing:
      case LevEmotion.anxious:
        return 'Lev respira contigo';
      case LevEmotion.sleeping:
      case LevEmotion.tired:
        return 'Lev descansa en silencio';
      case LevEmotion.sheltered:
      case LevEmotion.sad:
        return 'Lev te cobija con su hojita';
      case LevEmotion.curious:
        return 'Lev mira con curiosidad';
      case LevEmotion.joyJump:
      case LevEmotion.happy:
      case LevEmotion.celebrating:
        return 'Lev celebra tu tranquilidad';
      case LevEmotion.peaceful:
        return 'Lev está en calma a tu lado';
    }
  }

  Color _getStatusColor(LevEmotion emotion) {
    switch (emotion) {
      case LevEmotion.breathing:
      case LevEmotion.anxious:
        return const Color(0xFF6A994E);
      case LevEmotion.sleeping:
      case LevEmotion.tired:
        return const Color(0xFF5C6B73);
      case LevEmotion.sheltered:
      case LevEmotion.sad:
        return const Color(0xFF5B7065);
      case LevEmotion.curious:
        return const Color(0xFF3D7A80);
      case LevEmotion.joyJump:
      case LevEmotion.happy:
      case LevEmotion.celebrating:
        return const Color(0xFFC67D28);
      case LevEmotion.peaceful:
        return LevTheme.levMatchaDark;
    }
  }
}

