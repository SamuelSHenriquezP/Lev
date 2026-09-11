import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/habits/data/habits_database.dart';
import 'package:lev/features/sanctuary/domain/sanctuary_state.dart';
import 'package:lev/features/sanctuary/presentation/controllers/sanctuary_controller.dart';
import 'package:lev/features/companion/presentation/companion_chat_screen.dart';

/// Botón flotante de Lev + overlay emergente de chat.
/// Se superpone sobre cualquier pantalla sin navegar.
class LevChatBubble extends ConsumerStatefulWidget {
  const LevChatBubble({super.key});

  @override
  ConsumerState<LevChatBubble> createState() => _LevChatBubbleState();
}

class _LevChatBubbleState extends ConsumerState<LevChatBubble>
    with TickerProviderStateMixin {
  late final AnimationController _levFabController;
  late final AnimationController _overlayController;
  late final AnimationController _pulseController;
  bool _isOpen = false;
  bool _isAnimating = false;

  final TextEditingController _textController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _levFabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _levFabController.dispose();
    _overlayController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (_isAnimating || _isOpen) return;
    _isAnimating = true;
    HapticsHelper.light();
    setState(() => _isOpen = true);
    await _overlayController.animateTo(1.0, curve: Curves.easeOutBack);
    _isAnimating = false;
  }

  Future<void> _close() async {
    if (_isAnimating || !_isOpen) return;
    _isAnimating = true;
    HapticsHelper.light();
    await _overlayController.animateTo(0.0, curve: Curves.easeInCubic);
    setState(() => _isOpen = false);
    _isAnimating = false;
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    HapticsHelper.light();
    _textController.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
    });

    // Respuesta de Lev (simple reglas contextuales)
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final response = _generateLevResponse(text);
      setState(() {
        _messages.add(_ChatMessage(text: response, isUser: false));
      });
      _scrollToBottom();
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateLevResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('ansio') || lower.contains('pánico') || lower.contains('agobio')) {
      return 'Siento que algo te aprieta por dentro. ¿Quieres que hagamos juntos una respiración corta ahora?';
    }
    if (lower.contains('trist') || lower.contains('llor') || lower.contains('solo')) {
      return 'Aquí estoy contigo. No tienes que cargar eso solo. ¿Me cuentas un poco más?';
    }
    if (lower.contains('bien') || lower.contains('feliz') || lower.contains('genial')) {
      return '¡Me alegra mucho escuchar eso! Tu energía positiva también me hace crecer.';
    }
    if (lower.contains('no puedo') || lower.contains('bloqueo') || lower.contains('procrastin')) {
      return 'La inercia puede ser muy pesada. ¿Probamos con un micro-paso de solo 10 segundos?';
    }
    if (lower.contains('dormir') || lower.contains('insomnio') || lower.contains('noche')) {
      return 'Las noches largas son agotadoras. Una respiración 4-7-8 puede ayudarte. ¿Lo intentamos?';
    }
    if (lower.contains('hábito') || lower.contains('pausa') || lower.contains('ejercicio')) {
      final habit = HabitsDatabase.getRecommendedForMood(input);
      return 'Encontré algo que puede ayudarte: "${habit.title}". Es de 60 segundos. ¿Lo intentamos ahora?';
    }
    if (lower.contains('gracias') || lower.contains('agradec')) {
      return 'Es un honor acompañarte. Cuidarte a ti me hace crecer a mí también.';
    }
    final fallbacks = [
      'Cuéntame más sobre lo que sientes. Estoy todo oídos.',
      'Me importa lo que me compartes. ¿Qué más está pasando?',
      'Gracias por confiar en mí. Cada cosa que me dices me importa.',
    ];
    return fallbacks[Random().nextInt(fallbacks.length)];
  }

  double _bottomOffset = 135.0;
  bool _isDragging = false;

  void _onVerticalDragStart(DragStartDetails details) {
    if (_isOpen) return;
    HapticsHelper.selection();
    setState(() => _isDragging = true);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isOpen) return;
    setState(() {
      final screenHeight = MediaQuery.of(context).size.height;
      _bottomOffset = (_bottomOffset - details.delta.dy).clamp(88.0, screenHeight - 160.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_isOpen) return;
    HapticsHelper.light();
    setState(() => _isDragging = false);
  }

  @override
  Widget build(BuildContext context) {
    final sanctuary = ref.watch(sanctuaryProvider);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Backdrop clickeable para cerrar suavemente el chat al tocar fuera
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
              child: AnimatedBuilder(
                animation: _overlayController,
                builder: (context, _) => Container(
                  color: Colors.black.withValues(
                    alpha: (_overlayController.value * 0.28).clamp(0.0, 0.28),
                  ),
                ),
              ),
            ),
          ),

        // Overlay de chat interactivo y reactivo al teclado
        if (_isOpen)
          Positioned(
            bottom: isKeyboardOpen ? keyboardHeight + 12 : 82,
            right: 14,
            left: 14,
            child: AnimatedBuilder(
              animation: _overlayController,
              builder: (context, child) {
                final scale = Curves.easeOutBack.transform(_overlayController.value);
                final slideY = (1.0 - _overlayController.value) * 24.0;
                return Transform.translate(
                  offset: Offset(0, slideY),
                  child: Transform.scale(
                    scale: scale.clamp(0.0, 1.05),
                    alignment: Alignment.bottomRight,
                    child: Opacity(
                      opacity: _overlayController.value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  ),
                );
              },
              child: _buildChatOverlay(sanctuary),
            ),
          ),

        // Botón FAB de Lev animado, compacto y arrastrable
        Positioned(
          bottom: _bottomOffset,
          right: 14,
          child: _buildLevFab(),
        ),
      ],
    );
  }

  Widget _buildLevFab() {
    const fabSize = 50.0;
    return AnimatedBuilder(
      animation: Listenable.merge([_levFabController, _pulseController]),
      builder: (context, child) {
        return GestureDetector(
          onTap: _isOpen ? _close : _open,
          onVerticalDragStart: _onVerticalDragStart,
          onVerticalDragUpdate: _onVerticalDragUpdate,
          onVerticalDragEnd: _onVerticalDragEnd,
          child: AnimatedScale(
            scale: _isDragging ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Halo pulsante de fondo suave
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LevTheme.levMatcha.withValues(
                        alpha: 0.12 + _pulseController.value * 0.10,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: fabSize,
                  height: fabSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: LevTheme.levMatcha,
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: LevTheme.levMatcha.withValues(alpha: _isDragging ? 0.38 : 0.22),
                        blurRadius: _isDragging ? 22 : 14,
                        offset: Offset(0, _isDragging ? 8 : 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _isOpen ? Icons.close_rounded : Icons.chat_bubble_outline_rounded,
                      color: LevTheme.levMatchaDark,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatOverlay(SanctuaryState sanctuary) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final overlayHeight = keyboardHeight > 0
        ? (screenHeight * 0.44).clamp(260.0, 380.0)
        : (screenHeight * 0.58).clamp(320.0, 520.0);

    return Container(
      height: overlayHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A2D3748),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: LevTheme.levBorder),
      ),
      child: Column(
        children: [
          // Header del overlay
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                // Emblema botánico de conversación en el header
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LevTheme.levMatchaLight,
                    border: Border.all(
                      color: LevTheme.levMatcha.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.spa_rounded, color: LevTheme.levMatchaDark, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lev',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levTextDark,
                        ),
                      ),
                      Text(
                        sanctuary.stageName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: LevTheme.levTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: LevTheme.levMatchaLight,
                    borderRadius: LevTheme.pillRadius,
                  ),
                  child: Text(
                    '${sanctuary.careDrops} gotas',
                    style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: LevTheme.levMatchaDark,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Pantalla completa',
                  icon: const Icon(Icons.open_in_full_rounded, size: 18, color: LevTheme.levMatchaDark),
                  visualDensity: VisualDensity.compact,
                  splashRadius: 18,
                  onPressed: () {
                    _close();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CompanionChatScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Cerrar chat',
                  icon: const Icon(Icons.close_rounded, size: 18, color: LevTheme.levTextMuted),
                  visualDensity: VisualDensity.compact,
                  splashRadius: 18,
                  onPressed: _close,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: LevTheme.levBorder),

          // Área de mensajes
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyChat(sanctuary)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) =>
                        _buildMessage(_messages[index]),
                  ),
          ),

          // Sugerencias rápidas (si no hay mensajes)
          if (_messages.isEmpty)
            _buildQuickSuggestions(),

          // Input de texto
          _buildTextInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyChat(SanctuaryState sanctuary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: LevTheme.levCream,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                sanctuary.dialogue,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontStyle: FontStyle.italic,
                  color: LevTheme.levTextDark,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    final suggestions = [
      (label: 'Me siento ansioso', icon: Icons.air_rounded),
      (label: 'Estoy triste', icon: Icons.cloud_outlined),
      (label: 'No puedo empezar', icon: Icons.hourglass_top_rounded),
      (label: 'Quiero hacer una pausa', icon: Icons.spa_rounded),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      child: Row(
        children: suggestions.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                _textController.text = item.label;
                _sendMessage();
              },
              borderRadius: LevTheme.pillRadius,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: LevTheme.levMatchaLight,
                  borderRadius: LevTheme.pillRadius,
                  border: Border.all(color: LevTheme.levMatcha.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 14, color: LevTheme.levMatchaDark),
                    const SizedBox(width: 6),
                    Text(
                      item.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LevTheme.levMatchaDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessage(_ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: msg.isUser ? LevTheme.levMatchaDark : LevTheme.levCream,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: msg.isUser ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight: msg.isUser ? const Radius.circular(4) : const Radius.circular(18),
          ),
        ),
        child: Text(
          msg.text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: msg.isUser ? Colors.white : LevTheme.levTextDark,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: LevTheme.levBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: LevTheme.levCream,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: LevTheme.levBorder),
              ),
              child: TextField(
                controller: _textController,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: LevTheme.levTextDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Cuéntame cómo te sientes...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: LevTheme.levTextMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: LevTheme.levMatcha,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}
