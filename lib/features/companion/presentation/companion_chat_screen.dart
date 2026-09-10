import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/companion/domain/chat_message.dart';
import 'package:lev/features/companion/presentation/controllers/companion_controller.dart';
import 'package:lev/features/habits/domain/micro_habit.dart';
import 'package:lev/features/habits/presentation/habit_timer_screen.dart';

class CompanionChatScreen extends ConsumerStatefulWidget {
  const CompanionChatScreen({super.key});

  @override
  ConsumerState<CompanionChatScreen> createState() => _CompanionChatScreenState();
}

class _CompanionChatScreenState extends ConsumerState<CompanionChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
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
    final lastLevMessage = state.messages.reversed.where((m) => m.isFromLev).firstOrNull;
    final quickReplies = lastLevMessage?.quickReplies ?? const <String>[];

    ref.listen(companionProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: LevTheme.levCream,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LevTheme.levMatchaLight,
                border: Border.all(color: LevTheme.levMatcha.withValues(alpha: 0.4), width: 1.5),
              ),
              child: const Center(
                child: Text('🌱', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Aquí contigo • Sin juicios',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: LevTheme.levMatchaDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Lista de mensajes
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

            // Indicador de "Lev está sintiendo tus palabras..."
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
                      'Lev está respirando contigo...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: LevTheme.levTextMuted,
                      ),
                    ),
                  ],
                ),
              ),

            // Píldoras de respuesta rápida (Floating Action Pills)
            if (quickReplies.isNotEmpty)
              Container(
                height: 48,
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: LevTheme.levTextDark,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: LevTheme.pillRadius,
                        side: const BorderSide(color: LevTheme.levMatcha, width: 1.2),
                      ),
                      onPressed: () => _sendMessage(reply),
                    );
                  },
                ),
              ),

            // Barra de entrada de texto
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                border: const Border(top: BorderSide(color: LevTheme.levBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Cuéntale a Lev cómo estás...',
                        fillColor: LevTheme.levCream,
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
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    if (msg.isFromLev) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(top: 2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: LevTheme.levMatchaLight,
              ),
              child: const Center(
                child: Text('🌱', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(22),
                        bottomLeft: Radius.circular(22),
                        bottomRight: Radius.circular(22),
                      ),
                      border: Border.all(color: LevTheme.levBorder),
                      boxShadow: LevTheme.softShadow,
                    ),
                    child: Text(
                      msg.text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        color: LevTheme.levTextDark,
                        height: 1.45,
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
      // Mensaje del usuario
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: LevTheme.levMatcha,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                    bottomLeft: Radius.circular(22),
                  ),
                  boxShadow: LevTheme.glowShadow,
                ),
                child: Text(
                  msg.text,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LevTheme.levMatchaLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LevTheme.levMatcha.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(habit.iconEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
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
              color: LevTheme.levTextMuted,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openHabit(habit),
              icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
              label: const Text('Comenzar 60s con Lev'),
              style: ElevatedButton.styleFrom(
                backgroundColor: LevTheme.levMatcha,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
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
}

