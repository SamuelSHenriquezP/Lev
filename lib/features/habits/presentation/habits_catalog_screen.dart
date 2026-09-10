import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lev/core/storage/local_storage_service.dart';
import 'package:lev/core/theme/lev_theme.dart';
import 'package:lev/core/utils/haptics_helper.dart';
import 'package:lev/features/habits/data/habits_database.dart';
import 'package:lev/features/habits/domain/micro_habit.dart';
import 'habit_timer_screen.dart';

class HabitsCatalogScreen extends StatefulWidget {
  final String? initialCategoryFilter;

  const HabitsCatalogScreen({super.key, this.initialCategoryFilter});

  @override
  State<HabitsCatalogScreen> createState() => _HabitsCatalogScreenState();
}

class _HabitsCatalogScreenState extends State<HabitsCatalogScreen> {
  late String _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategoryFilter ?? 'Todos';
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoriteIds = LocalStorageService.getFavoriteHabitIds();
    });
  }

  Future<void> _toggleFavorite(String habitId) async {
    await HapticsHelper.selection();
    await LocalStorageService.toggleFavoriteHabit(habitId);
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MicroHabit> get _filteredHabits {
    List<MicroHabit> baseList;

    if (_searchQuery.isNotEmpty) {
      baseList = HabitsDatabase.searchHabits(_searchQuery);
    } else if (_selectedCategory == '⭐ Favoritos') {
      baseList = HabitsDatabase.allHabits.where((h) => _favoriteIds.contains(h.id)).toList();
    } else if (_selectedCategory == 'Todos') {
      baseList = HabitsDatabase.allHabits;
    } else {
      baseList = HabitsDatabase.getByCategory(_selectedCategory);
    }

    return baseList;
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

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Todos',
      '⭐ Favoritos',
      ...HabitsDatabase.categories.map((c) => c.name),
    ];

    return Scaffold(
      backgroundColor: LevTheme.levCream,
      appBar: AppBar(
        title: Text(
          'Microhábitos (60s)',
          style: GoogleFonts.quicksand(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: LevTheme.levTextDark,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtítulo cálido + Botón Sorpréndeme
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '24+ pausas conscientes de 1 minuto divididas por tu estado emocional.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: LevTheme.levTextMuted,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _surpriseMe,
                  icon: const Text('🎲', style: TextStyle(fontSize: 16)),
                  label: const Text('Sorpréndeme'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LevTheme.levPeach,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Buscador de Hábitos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar por síntoma (ojos, insomnio, vago, enojo)...',
                prefixIcon: const Icon(Icons.search_rounded, color: LevTheme.levTextMuted, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: LevTheme.levBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: LevTheme.levBorder),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Carrusel horizontal de chips de categorías emocionales
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == _selectedCategory;

                String displayLabel = cat;
                final catInfo = HabitsDatabase.categories.where((c) => c.name == cat).firstOrNull;
                if (catInfo != null) {
                  displayLabel = catInfo.shortName;
                }

                return ChoiceChip(
                  label: Text(displayLabel),
                  selected: isSelected,
                  selectedColor: LevTheme.levMatcha,
                  backgroundColor: Colors.white,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : LevTheme.levTextDark,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: LevTheme.pillRadius,
                    side: BorderSide(
                      color: isSelected ? LevTheme.levMatcha : LevTheme.levBorder,
                    ),
                  ),
                  onSelected: (val) {
                    if (val) {
                      HapticsHelper.selection();
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Lista de microhábitos filtrados
          Expanded(
            child: _filteredHabits.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🌱', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: 12),
                          Text(
                            _selectedCategory == '⭐ Favoritos'
                                ? 'Aún no tienes hábitos favoritos guardados.\nToca la estrella en cualquier tarjeta para fijarlo aquí.'
                                : 'No encontramos pausas para "$_searchQuery".\nPrueba con otra palabra como "ojos", "respirar" o "dormir".',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              color: LevTheme.levTextMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    itemCount: _filteredHabits.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final habit = _filteredHabits[index];
                      final isFav = _favoriteIds.contains(habit.id);
                      return _buildHabitCard(habit, isFav);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(MicroHabit habit, bool isFav) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: LevTheme.cardRadius,
        border: Border.all(color: LevTheme.levBorder),
        boxShadow: LevTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: LevTheme.cardRadius,
        child: InkWell(
          borderRadius: LevTheme.cardRadius,
          onTap: () => _openHabitTimer(habit),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: LevTheme.levMatchaLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          habit.iconEmoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: LevTheme.levSky.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              habit.category,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: LevTheme.levTextDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            habit.title,
                            style: GoogleFonts.quicksand(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: LevTheme.levTextDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón de favorito (estrella)
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.star_rounded : Icons.star_border_rounded,
                        color: isFav ? const Color(0xFFFFB056) : LevTheme.levTextMuted,
                        size: 22,
                      ),
                      onPressed: () => _toggleFavorite(habit.id),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: LevTheme.levPeach.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '60s',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: LevTheme.levPeachDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '"${habit.levIntro}"',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: LevTheme.levTextMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.psychology_outlined, size: 15, color: LevTheme.levMatchaDark),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        habit.psychologicalBasis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: LevTheme.levMatchaDark,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: LevTheme.levMatcha,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
