import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/habits/data/habits_database.dart';
import 'package:lev/features/habits/domain/micro_habit.dart';
import 'emotion_detail_screen.dart';
import 'habit_timer_screen.dart';
import 'widgets/somatic_focus_minigames.dart';
import 'package:lev/features/detox/presentation/phone_down_screen.dart';

/// Catálogo de Microhábitos en Cuadraditos Táctiles e Inmersivos.
/// Se reemplazaron las listas largas y la sobrecarga visual por:
/// 1. Minijuegos somáticos de concentración (Burbujas, Arena Zen, Foco EMDR).
/// 2. Mosaico de cuadraditos emocionales donde el usuario entra en su estado.
class HabitsCatalogScreen extends StatefulWidget {
  final String? initialCategoryFilter;

  const HabitsCatalogScreen({super.key, this.initialCategoryFilter});

  @override
  State<HabitsCatalogScreen> createState() => _HabitsCatalogScreenState();
}

class _HabitsCatalogScreenState extends State<HabitsCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoriteIds = LocalStorageService.getFavoriteHabitIds();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openHabitTimer(MicroHabit habit) {
    HapticsHelper.light();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitTimerScreen(habit: habit),
      ),
    );
  }

  void _surpriseMe() {
    HapticsHelper.medium();
    final randomHabit = HabitsDatabase.getRandomHabit();
    _openHabitTimer(randomHabit);
  }

  void _openEmotion(String category, [String emoji = '']) {
    HapticsHelper.selection();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmotionDetailScreen(
          categoryName: category,
          emoji: emoji,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = _searchQuery.isNotEmpty
        ? HabitsDatabase.searchHabits(_searchQuery)
        : <MicroHabit>[];

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Microhábitos (60s)',
          style: GoogleFonts.quicksand(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          // Botón "Sorpréndeme"
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: InkWell(
              onTap: _surpriseMe,
              borderRadius: LevTheme.pillRadius,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: LevTheme.levMatcha,
                  borderRadius: LevTheme.pillRadius,
                  boxShadow: LevTheme.glowShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shuffle_rounded, size: 15, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      'Sorpréndeme',
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. BUSCADOR MINIMALISTA ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: LevTheme.pillRadius,
                  border: Border.all(color: LevTheme.levBorder),
                  boxShadow: LevTheme.softShadow,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: LevTheme.levTextDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Buscar por síntoma (ojos, pecho, dormir...)',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      color: LevTheme.levTextMuted,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: LevTheme.levMatchaDark, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- CASO A: RESULTADOS DE BÚSQUEDA DIRECTA ---
              if (_searchQuery.isNotEmpty) ...[
                Text(
                  'Resultados (${searchResults.length})',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levTextDark,
                  ),
                ),
                const SizedBox(height: 14),
                if (searchResults.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'No encontramos pausas para "$_searchQuery".\nPrueba con "ansiedad", "cuello" o "soltar".',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: LevTheme.levTextMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: searchResults.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.96,
                    ),
                    itemBuilder: (context, index) {
                      final habit = searchResults[index];
                      final bgColor = LevTheme.getEmotionBgColor(habit.category);
                      final accentColor = LevTheme.getEmotionAccentColor(habit.category);
                      return _buildSearchResultSquare(habit, bgColor, accentColor);
                    },
                  ),
              ] else ...[
                // --- CASO B: MODO EXPLORACIÓN COZY Y TÁCTIL ---

                // --- SECCIÓN HERO: MODO SOLTAR EL TELÉFONO ---
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF233B32),
                        Color(0xFF14241E),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF233B32).withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: LevTheme.levMatcha.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text('📵', style: TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Soltar el Teléfono',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.quicksand(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: LevTheme.levMatcha.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Meta Principal',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: LevTheme.levMatchaLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Tu meta hoy es alejarte de la pantalla.',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'El cerebro no descansa consumiendo contenido; descansa en el mundo real. Inicia una pausa, pon tu teléfono boca abajo y gana presencia.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          height: 1.45,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticsHelper.selection();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PhoneDownScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LevTheme.levMatcha,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.bedtime_rounded, size: 18),
                          label: Text(
                            'Iniciar Desconexión (5 - 60 min)',
                            style: GoogleFonts.quicksand(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. SECCIÓN: MINIJUEGOS SOMÁTICOS DE CONCENTRACIÓN
                Text(
                  'Minijuegos de Concentración',
                  style: GoogleFonts.quicksand(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: LevTheme.levTextDark,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 118,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildMinigameQuickCard(
                        icon: Icons.bubble_chart_rounded,
                        title: 'Burbujas Pop',
                        subtitle: 'Descarga de tensión',
                        color: const Color(0xFFD0E8F2),
                        accent: const Color(0xFF2C6D91),
                        onTap: () => SomaticMinigameModal.open(context, initialGameIndex: 0),
                      ),
                      const SizedBox(width: 12),
                      _buildMinigameQuickCard(
                        icon: Icons.landscape_rounded,
                        title: 'Arena Zen',
                        subtitle: 'Rastreo y grounding',
                        color: const Color(0xFFF2ECE1),
                        accent: const Color(0xFF6B5841),
                        onTap: () => SomaticMinigameModal.open(context, initialGameIndex: 1),
                      ),
                      const SizedBox(width: 12),
                      _buildMinigameQuickCard(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Foco de Luz',
                        subtitle: 'Calma visual EMDR',
                        color: const Color(0xFF243B33),
                        accent: const Color(0xFFFFD166),
                        isDark: true,
                        onTap: () => SomaticMinigameModal.open(context, initialGameIndex: 2),
                      ),
                      const SizedBox(width: 12),
                      _buildMinigameQuickCard(
                        icon: Icons.water_drop_rounded,
                        title: 'Gotas de Agua',
                        subtitle: 'Hidroterapia y ondas',
                        color: const Color(0xFFE0F2F1),
                        accent: const Color(0xFF00796B),
                        onTap: () => SomaticMinigameModal.open(context, initialGameIndex: 3),
                      ),
                      const SizedBox(width: 12),
                      _buildMinigameQuickCard(
                        icon: Icons.notifications_active_rounded,
                        title: 'Cuenco Zen',
                        subtitle: 'Vibración armónica',
                        color: const Color(0xFFFFF8E1),
                        accent: const Color(0xFFB78103),
                        onTap: () => SomaticMinigameModal.open(context, initialGameIndex: 4),
                      ),
                      const SizedBox(width: 12),
                      _buildMinigameQuickCard(
                        icon: Icons.nature_people_rounded,
                        title: 'Diente de León',
                        subtitle: 'Soltar pensamientos',
                        color: const Color(0xFFF1F8E9),
                        accent: const Color(0xFF558B2F),
                        onTap: () => SomaticMinigameModal.open(context, initialGameIndex: 5),
                      ),
                      const SizedBox(width: 12),
                      _buildMinigameQuickCard(
                        icon: Icons.filter_hdr_rounded,
                        title: 'Piedras Zen',
                        subtitle: 'Equilibrio y paciencia',
                        color: const Color(0xFFECEFF1),
                        accent: const Color(0xFF455A64),
                        onTap: () => SomaticMinigameModal.open(context, initialGameIndex: 6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 3. SECCIÓN: REJILLA DE CUADRADITOS EMOCIONALES
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '¿Qué estás sintiendo ahora?',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levTextDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Entra a tu emoción',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: LevTheme.levTextMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.05,
                  children: [
                    _buildEmotionSquare(
                      category: 'Doomscrolling / Sobrecarga Digital',
                      title: 'Sobrecarga',
                      subtitle: 'Pantallas & TikTok',
                      icon: Icons.smartphone_rounded,
                      count: HabitsDatabase.getByCategory('Doomscrolling / Sobrecarga Digital').length,
                    ),
                    _buildEmotionSquare(
                      category: 'Ansiedad / Ataque de Pánico / Agobio',
                      title: 'Ansiedad',
                      subtitle: 'Pecho apretado',
                      icon: Icons.waves_rounded,
                      count: HabitsDatabase.getByCategory('Ansiedad / Ataque de Pánico / Agobio').length,
                    ),
                    _buildEmotionSquare(
                      category: 'Tristeza / Soledad / Desgano',
                      title: 'Tristeza',
                      subtitle: 'Soledad y desgano',
                      icon: Icons.spa_rounded,
                      count: HabitsDatabase.getByCategory('Tristeza / Soledad / Desgano').length,
                    ),
                    _buildEmotionSquare(
                      category: 'Frustración / Enojo / Irritabilidad',
                      title: 'Frustración',
                      subtitle: 'Rabia y tensión',
                      icon: Icons.bolt_rounded,
                      count: HabitsDatabase.getByCategory('Frustración / Enojo / Irritabilidad').length,
                    ),
                    _buildEmotionSquare(
                      category: 'Insomnio / Rumiación Nocturna',
                      title: 'Insomnio',
                      subtitle: 'Mente no para',
                      icon: Icons.bedtime_rounded,
                      count: HabitsDatabase.getByCategory('Insomnio / Rumiación Nocturna').length,
                    ),
                    _buildEmotionSquare(
                      category: 'Culpa / Autocrítica / Impostor',
                      title: 'Culpa',
                      subtitle: 'Autocrítica dura',
                      icon: Icons.favorite_border_rounded,
                      count: HabitsDatabase.getByCategory('Culpa / Autocrítica / Impostor').length,
                    ),
                    _buildEmotionSquare(
                      category: 'Bloqueo / Procrastinación / Parálisis TDAH',
                      title: 'Bloqueo',
                      subtitle: 'Parálisis al iniciar',
                      icon: Icons.lock_open_rounded,
                      count: HabitsDatabase.getByCategory('Bloqueo / Procrastinación / Parálisis TDAH').length,
                    ),
                    _buildFavoritesSquare(),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinigameQuickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color accent,
    required VoidCallback onTap,
    bool isDark = false,
  }) {
    return InkWell(
      onTap: () {
        HapticsHelper.light();
        onTap();
      },
      borderRadius: LevTheme.cardRadius,
      child: Container(
        width: 148,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: LevTheme.cardRadius,
          border: Border.all(color: accent.withValues(alpha: 0.20)),
          boxShadow: LevTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Colors.white12 : accent.withValues(alpha: 0.12),
                  ),
                  child: Icon(icon, size: 18, color: accent),
                ),
                const Spacer(),
                Icon(Icons.play_circle_fill_rounded, size: 18, color: accent),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : LevTheme.levTextDark,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: isDark ? Colors.white.withValues(alpha: 0.75) : LevTheme.levTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionSquare({
    required String category,
    required String title,
    required String subtitle,
    required IconData icon,
    required int count,
  }) {
    final bgColor = LevTheme.getEmotionBgColor(category);
    final accentColor = LevTheme.getEmotionAccentColor(category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openEmotion(category),
        borderRadius: LevTheme.squareRadius,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: LevTheme.squareRadius,
            border: Border.all(color: LevTheme.levBorder),
            boxShadow: LevTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icono en cápsula suave con color temático
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(icon, size: 22, color: accentColor),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? LevTheme.levDarkSurfaceVariant
                          : LevTheme.levCream,
                      borderRadius: LevTheme.pillRadius,
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: LevTheme.levTextDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: LevTheme.levTextMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesSquare() {
    final favCount = _favoriteIds.length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticsHelper.selection();
          // Abre favoritos
          final favHabits = HabitsDatabase.allHabits.where((h) => _favoriteIds.contains(h.id)).toList();
          if (favHabits.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Aún no tienes favoritos marcados con estrella ⭐'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            _openHabitTimer(favHabits.first);
          }
        },
        borderRadius: LevTheme.squareRadius,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEA),
            borderRadius: LevTheme.squareRadius,
            border: Border.all(color: const Color(0xFFFFE082)),
            boxShadow: LevTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECB3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.star_rounded, size: 24, color: Color(0xFFB88235)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: LevTheme.pillRadius,
                    ),
                    child: Text(
                      '$favCount',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB88235),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Favoritos',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: LevTheme.levTextDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tus pausas clave',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: LevTheme.levTextMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultSquare(MicroHabit habit, Color bgColor, Color accentColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openHabitTimer(habit),
        borderRadius: LevTheme.squareRadius,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: LevTheme.squareRadius,
            border: Border.all(color: LevTheme.levBorder),
            boxShadow: LevTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Icon(habit.icon, size: 20, color: LevTheme.levMatchaDark),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? LevTheme.levDarkSurfaceVariant
                          : LevTheme.levCream,
                      borderRadius: LevTheme.pillRadius,
                    ),
                    child: Text(
                      '60s',
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                habit.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: LevTheme.levTextDark,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Iniciar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 13, color: accentColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
