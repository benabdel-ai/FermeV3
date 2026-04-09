import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/app_provider.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/category_list_item.dart';
import '../widgets/filter_dropdown.dart';

// ── Palette de couleurs pour les catégories ────────────────────────────────
const List<Color> _kCatColors = [
  Color(0xFFE53935),
  Color(0xFF00897B),
  Color(0xFFFB8C00),
  Color(0xFF3949AB),
  Color(0xFF7CB342),
  Color(0xFF8E24AA),
  Color(0xFF00ACC1),
  Color(0xFFE91E63),
  Color(0xFF43A047),
  Color(0xFFFF7043),
  Color(0xFF1E88E5),
  Color(0xFF6D4C41),
];

// ── Emoji par mots-clés ────────────────────────────────────────────────────
String _iconForCategory(String name) {
  final n = name.toLowerCase();
  if (n.contains('aliment') || n.contains('nourriture') || n.contains('paille') || n.contains('foin')) return '🌾';
  if (n.contains('mouton') || n.contains('brebis') || n.contains('bélier') || n.contains('agneau')) return '🐑';
  if (n.contains('vétérin') || n.contains('santé') || n.contains('médic') || n.contains('vaccin')) return '💊';
  if (n.contains('transport') || n.contains('camion') || n.contains('voiture')) return '🚗';
  if (n.contains('maison') || n.contains('bâtiment') || n.contains('ferme')) return '🏠';
  if (n.contains('eau') || n.contains('irrigation')) return '💧';
  if (n.contains('électricité') || n.contains('énergie')) return '⚡';
  if (n.contains('main') || n.contains('salaire') || n.contains('travail')) return '👷';
  if (n.contains('vente') || n.contains('lait') || n.contains('laine')) return '💰';
  if (n.contains('récolte') || n.contains('olive') || n.contains('culture')) return '🌿';
  if (n.contains('achat')) return '🛒';
  return '📦';
}

class RapportsScreen extends StatefulWidget {
  const RapportsScreen({super.key});

  @override
  State<RapportsScreen> createState() => _RapportsScreenState();
}

class _RapportsScreenState extends State<RapportsScreen> {
  String _selectedType = 'Dépense';
  String _selectedPeriod = 'Mensuel';
  String _selectedMonth = DateFormat('MMMM', 'fr_FR').format(DateTime.now());
  String _selectedYear = '${DateTime.now().year}';
  String _selectedFerme = 'Toutes les fermes';
  String _sortMode = 'montant';

  static const List<String> _types = ['Dépense', 'Revenu'];
  static const List<String> _periods = ['Mensuel', 'Annuel', 'Hebdomadaire', 'Tout'];
  static const List<String> _months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];
  static const List<String> _fermes = [
    'Toutes les fermes',
    'Ferme Rhamna',
    'Ferme Srahna',
  ];

  bool _matchesFerme(String fermeId) {
    if (_selectedFerme == 'Toutes les fermes') return true;
    if (_selectedFerme == 'Ferme Rhamna') return fermeId == 'rhamna';
    if (_selectedFerme == 'Ferme Srahna') return fermeId == 'srahna';
    return true;
  }

  bool _matchesPeriod(DateTime date) {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Mensuel':
        final moisIdx = _months.indexOf(_selectedMonth) + 1;
        final annee = int.tryParse(_selectedYear) ?? now.year;
        return date.year == annee && date.month == moisIdx;
      case 'Annuel':
        final annee = int.tryParse(_selectedYear) ?? now.year;
        return date.year == annee;
      case 'Hebdomadaire':
        final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
        return !date.isBefore(startOfWeek);
      default:
        return true;
    }
  }

  List<_CatEntry> _buildCategories(AppProvider provider) {
    final grouped = <String, double>{};
    final counts = <String, int>{};

    if (_selectedType == 'Dépense') {
      for (final d in provider.depenses) {
        if (!_matchesFerme(d.fermeId)) continue;
        if (!_matchesPeriod(d.date)) continue;
        grouped[d.categorie] = (grouped[d.categorie] ?? 0) + d.montant;
        counts[d.categorie] = (counts[d.categorie] ?? 0) + 1;
      }
    } else {
      for (final r in provider.revenus) {
        if (!_matchesFerme(r.fermeId)) continue;
        if (!_matchesPeriod(r.date)) continue;
        grouped[r.categorie] = (grouped[r.categorie] ?? 0) + r.montant;
        counts[r.categorie] = (counts[r.categorie] ?? 0) + 1;
      }
    }

    final entries = grouped.entries
        .map((e) => _CatEntry(name: e.key, amount: e.value, count: counts[e.key] ?? 0))
        .toList();

    switch (_sortMode) {
      case 'nom':
        entries.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'count':
        entries.sort((a, b) => b.count.compareTo(a.count));
        break;
      default:
        entries.sort((a, b) => b.amount.compareTo(a.amount));
    }
    return entries;
  }

  List<String> _availableYears(AppProvider provider) {
    final years = <int>{DateTime.now().year};
    for (final d in provider.depenses) years.add(d.date.year);
    for (final r in provider.revenus) years.add(r.date.year);
    return (years.toList()..sort((a, b) => b.compareTo(a))).map((y) => '$y').toList();
  }

  void _showFermePicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: _fermes.map((ferme) {
          return ListTile(
            title: Text(ferme, style: const TextStyle(fontSize: 16)),
            trailing: ferme == _selectedFerme ? const Icon(Icons.check, color: Color(0xFF263238)) : null,
            onTap: () {
              setState(() => _selectedFerme = ferme);
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  void _handleSort() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: const Text('Par montant'),
            trailing: _sortMode == 'montant' ? const Icon(Icons.check) : null,
            onTap: () { setState(() => _sortMode = 'montant'); Navigator.pop(ctx); },
          ),
          ListTile(
            title: const Text('Par nom'),
            trailing: _sortMode == 'nom' ? const Icon(Icons.check) : null,
            onTap: () { setState(() => _sortMode = 'nom'); Navigator.pop(ctx); },
          ),
          ListTile(
            title: const Text('Par nombre'),
            trailing: _sortMode == 'count' ? const Icon(Icons.check) : null,
            onTap: () { setState(() => _sortMode = 'count'); Navigator.pop(ctx); },
          ),
        ],
      ),
    );
  }

  void _handleShare(List<_CatEntry> categories, double total) {
    final buf = StringBuffer();
    buf.writeln('Rapport $_selectedType — $_selectedPeriod');
    if (_selectedPeriod == 'Mensuel') buf.writeln('$_selectedMonth $_selectedYear');
    if (_selectedPeriod == 'Annuel') buf.writeln(_selectedYear);
    buf.writeln('Ferme: $_selectedFerme');
    buf.writeln('─────────────────────');
    for (final c in categories) {
      final pct = total > 0 ? (c.amount / total * 100).toStringAsFixed(1) : '0.0';
      buf.writeln('${c.name}: ${c.amount.toStringAsFixed(2)} MAD ($pct%) ×${c.count}');
    }
    buf.writeln('─────────────────────');
    buf.writeln('Total: ${total.toStringAsFixed(2)} MAD');
    Share.share(buf.toString());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final availYears = _availableYears(provider);
    final effectiveYear = availYears.contains(_selectedYear) ? _selectedYear : (availYears.isNotEmpty ? availYears.first : _selectedYear);
    final categories = _buildCategories(provider);
    final total = categories.fold(0.0, (s, c) => s + c.amount);
    final maxAmount = categories.isEmpty ? 1.0 : categories.map((c) => c.amount).reduce((a, b) => a > b ? a : b);
    final isExpense = _selectedType == 'Dépense';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        automaticallyImplyLeading: false,
        title: const Text(
          'Rapports par catégorie',
          style: TextStyle(
            color: Color(0xFF263238),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Sélecteur ferme ──────────────────────────────────────────────
          GestureDetector(
            onTap: _showFermePicker,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedFerme,
                    style: const TextStyle(color: Color(0xFF78909C), fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more, size: 16, color: Color(0xFF90A4AE)),
                ],
              ),
            ),
          ),

          // ── Filtres type + période ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilterDropdown(
                        value: _selectedType,
                        items: _types,
                        onChanged: (v) => setState(() => _selectedType = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilterDropdown(
                        value: _selectedPeriod,
                        items: _periods,
                        onChanged: (v) => setState(() => _selectedPeriod = v),
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ],
                ),
                if (_selectedPeriod == 'Mensuel' || _selectedPeriod == 'Annuel') ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (_selectedPeriod == 'Mensuel') ...[
                        Expanded(
                          child: FilterDropdown(
                            value: _selectedMonth,
                            items: _months,
                            onChanged: (v) => setState(() => _selectedMonth = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: FilterDropdown(
                          value: effectiveYear,
                          items: availYears.isEmpty ? [effectiveYear] : availYears,
                          onChanged: (v) => setState(() => _selectedYear = v),
                          alignment: Alignment.centerRight,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Liste catégories ─────────────────────────────────────────────
          Expanded(
            child: categories.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune donnée pour cette période',
                      style: TextStyle(color: Color(0xFF90A4AE), fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return CategoryListItem(
                        name: cat.name,
                        count: cat.count,
                        amount: cat.amount,
                        icon: _iconForCategory(cat.name),
                        color: _kCatColors[index % _kCatColors.length],
                        total: total,
                        maxAmount: maxAmount,
                        isExpense: isExpense,
                      );
                    },
                  ),
          ),

          // ── Barre bas ────────────────────────────────────────────────────
          BottomActionBar(
            total: total,
            currency: 'MAD',
            onChartTap: null,
            onShareTap: () => _handleShare(categories, total),
            onSortTap: _handleSort,
          ),
        ],
      ),
    );
  }
}

class _CatEntry {
  final String name;
  final double amount;
  final int count;
  const _CatEntry({required this.name, required this.amount, required this.count});
}
