import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/ferme_models.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

// ═════════════════════════════════════════════════════════════════════════════
// RAPPORTS SCREEN — Version améliorée
// 4 onglets : Dépenses · Revenus · Bilan · Exploitation
// ═════════════════════════════════════════════════════════════════════════════

class RapportsScreen extends StatefulWidget {
  const RapportsScreen({super.key});

  @override
  State<RapportsScreen> createState() => _RapportsScreenState();
}

class _RapportsScreenState extends State<RapportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // ── Filtres partagés ────────────────────────────────────────────────────────
  String _periode = 'mensuel';
  int _mois = DateTime.now().month;
  int _annee = DateTime.now().year;
  DateTime _dateJour = DateTime.now();
  DateTime _dateDebut = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _dateFin = DateTime.now();

  static const List<String> _moisLabels = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];
  static const List<String> _moisCourts = [
    'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
    'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── Années disponibles ──────────────────────────────────────────────────────
  List<int> _availableYears(AppProvider p) {
    final years = <int>{DateTime.now().year};
    for (final d in p.depensesFiltrees) {
      years.add(d.date.year);
    }
    for (final r in p.revenusFiltres) {
      years.add(r.date.year);
    }
    return years.toList()..sort();
  }

  // ── Filtrage par période ───────────────────────────────────────────────────
  List<T> _filterByPeriod<T>(List<T> items, DateTime Function(T) getDate) {
    final now = DateTime.now();
    DateTime? start, end;

    switch (_periode) {
      case 'par_jour':
        start = DateTime(_dateJour.year, _dateJour.month, _dateJour.day);
        end = start.add(const Duration(hours: 23, minutes: 59, seconds: 59));
        break;
      case 'hebdomadaire':
        final today = DateTime(now.year, now.month, now.day);
        start = today.subtract(const Duration(days: 6));
        end = today.add(const Duration(hours: 23, minutes: 59, seconds: 59));
        break;
      case 'bihebdomadaire':
        final today = DateTime(now.year, now.month, now.day);
        start = today.subtract(const Duration(days: 13));
        end = today.add(const Duration(hours: 23, minutes: 59, seconds: 59));
        break;
      case 'mensuel':
        start = DateTime(_annee, _mois, 1);
        end = DateTime(_annee, _mois + 1, 0, 23, 59, 59);
        break;
      case 'annuel':
        start = DateTime(_annee, 1, 1);
        end = DateTime(_annee, 12, 31, 23, 59, 59);
        break;
      case 'periode':
        start = DateTime(_dateDebut.year, _dateDebut.month, _dateDebut.day);
        end = DateTime(
            _dateFin.year, _dateFin.month, _dateFin.day, 23, 59, 59);
        break;
    }

    if (start != null && end != null) {
      return items
          .where((i) =>
              !getDate(i).isBefore(start!) && !getDate(i).isAfter(end!))
          .toList();
    }
    return items;
  }

  String _periodLabel() {
    switch (_periode) {
      case 'mensuel':
        return '${_moisLabels[_mois - 1]} $_annee';
      case 'annuel':
        return 'Année $_annee';
      case 'hebdomadaire':
        return '7 derniers jours';
      case 'bihebdomadaire':
        return '14 derniers jours';
      case 'par_jour':
        return DateFormat('dd/MM/yyyy').format(_dateJour);
      case 'periode':
        return '${DateFormat('dd/MM').format(_dateDebut)} → ${DateFormat('dd/MM/yy').format(_dateFin)}';
      default:
        return '';
    }
  }

  Future<void> _pickDate(
      DateTime initial, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) onPicked(picked);
  }

  // ── Grouper par catégorie ──────────────────────────────────────────────────
  Map<String, ({int count, double total})> _groupByCategory(
      List<({String categorie, double montant})> items) {
    final result = <String, ({int count, double total})>{};
    for (final item in items) {
      final existing = result[item.categorie];
      result[item.categorie] = (
        count: (existing?.count ?? 0) + 1,
        total: (existing?.total ?? 0.0) + item.montant,
      );
    }
    return Map.fromEntries(
      result.entries.toList()
        ..sort((a, b) => b.value.total.compareTo(a.value.total)),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final years = _availableYears(provider);
    if (!years.contains(_annee)) _annee = years.last;

    return Column(
      children: <Widget>[
        // ── Titre ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SectionTitle(
            '📊 Rapports',
            sub: _periodLabel(),
          ),
        ),

        // ── Tab bar ────────────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.bg3,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: TabBar(
            controller: _tabCtrl,
            onTap: (_) => setState(() {}),
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.text2,
            labelStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w900),
            unselectedLabelStyle: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700),
            indicator: BoxDecoration(
              color: AppColors.green2,
              borderRadius: BorderRadius.circular(14),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            splashBorderRadius: BorderRadius.circular(14),
            padding: const EdgeInsets.all(4),
            tabs: const <Tab>[
              Tab(text: '💸 Dép.'),
              Tab(text: '💰 Rev.'),
              Tab(text: '📊 Bilan'),
              Tab(text: '🐑 Expl.'),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Contenu ────────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: <Widget>[
              _buildDepensesTab(provider, years),
              _buildRevenusTab(provider, years),
              _buildBilanTab(provider, years),
              _buildExploitationTab(provider),
            ],
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // FILTRES (partagés entre les 3 premiers onglets)
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildFilters(List<int> years) {
    return Column(
      children: <Widget>[
        // ── Period chips ─────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              _periodeChip('mensuel', 'Mensuel'),
              _periodeChip('annuel', 'Annuel'),
              _periodeChip('hebdomadaire', 'Hebdo'),
              _periodeChip('bihebdomadaire', 'Bihebdo'),
              _periodeChip('par_jour', 'Par jour'),
              _periodeChip('periode', 'Période libre'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Date selectors ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildDateSelectors(years),
        ),
      ],
    );
  }

  Widget _buildDateSelectors(List<int> years) {
    if (_periode == 'mensuel') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _DropdownField<int>(
                value: _mois,
                items: List<DropdownMenuItem<int>>.generate(
                  12,
                  (i) => DropdownMenuItem<int>(
                      value: i + 1, child: Text(_moisCourts[i])),
                ),
                onChanged: (v) => setState(() => _mois = v!),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DropdownField<int>(
                value: _annee,
                items: years
                    .map((y) =>
                        DropdownMenuItem<int>(value: y, child: Text('$y')))
                    .toList(),
                onChanged: (v) => setState(() => _annee = v!),
              ),
            ),
          ],
        ),
      );
    }

    if (_periode == 'annuel') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _DropdownField<int>(
          value: _annee,
          items: years
              .map(
                  (y) => DropdownMenuItem<int>(value: y, child: Text('$y')))
              .toList(),
          onChanged: (v) => setState(() => _annee = v!),
        ),
      );
    }

    if (_periode == 'par_jour') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () =>
              _pickDate(_dateJour, (d) => setState(() => _dateJour = d)),
          child: _DateBtn(label: 'Date', date: _dateJour),
        ),
      );
    }

    if (_periode == 'periode') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () => _pickDate(
                    _dateDebut, (d) => setState(() => _dateDebut = d)),
                child: _DateBtn(label: 'Début', date: _dateDebut),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _pickDate(
                    _dateFin, (d) => setState(() => _dateFin = d)),
                child: _DateBtn(label: 'Fin', date: _dateFin),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox(height: 12);
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // ONGLET 1 — DÉPENSES PAR CATÉGORIE
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildDepensesTab(AppProvider provider, List<int> years) {
    final filtered = _filterByPeriod<Depense>(
        provider.depensesFiltrees, (d) => d.date);
    final items = filtered
        .map((d) => (categorie: d.categorie, montant: d.montant))
        .toList();
    final grouped = _groupByCategory(items);
    final grandTotal = grouped.values.fold(0.0, (sum, v) => sum + v.total);

    // Détails main-d'œuvre
    final filteredSessions = _filterByPeriod<TravailleurSession>(
        provider.sessionsFiltrees, (s) => s.date);
    final sessionsByName = <String, ({double jours, double total})>{};
    for (final s in filteredSessions) {
      final existing = sessionsByName[s.nom];
      sessionsByName[s.nom] = (
        jours: (existing?.jours ?? 0) + s.nbJours,
        total: (existing?.total ?? 0) + s.total,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: <Widget>[
          _buildFilters(years),

          // ── Résultats ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const CardTitle('PAR CATÉGORIE'),
                      if (grandTotal > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(
                            fmtMAD(grandTotal),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (grouped.isEmpty)
                    const EmptyState(
                        emoji: '📊',
                        text: 'Aucune dépense pour cette période')
                  else
                    ...grouped.entries.map((entry) {
                      final pct = grandTotal > 0
                          ? entry.value.total / grandTotal
                          : 0.0;
                      return _CategoryTile(
                        label: entry.key,
                        count: entry.value.count,
                        amount: entry.value.total,
                        pct: pct,
                        color: AppColors.red,
                        // Afficher détails travailleurs si Main-d'œuvre
                        details: entry.key.toLowerCase().contains('main')
                            ? sessionsByName.entries
                                .map((e) => _DetailLine(
                                      label: e.key,
                                      value: fmtMAD(e.value.total),
                                      sub:
                                          '${e.value.jours.toStringAsFixed(0)}j × ${(e.value.total / e.value.jours).toStringAsFixed(0)} MAD/j',
                                    ))
                                .toList()
                            : null,
                      );
                    }),
                ],
              ),
            ),
          ),

          // ── Footer résumé ─────────────────────────────────────────────
          if (grouped.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SummaryFooter(
                opCount: filtered.length,
                catCount: grouped.length,
                total: grandTotal,
                color: AppColors.red,
                bgColor: AppColors.redBg,
              ),
            ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // ONGLET 2 — REVENUS PAR CATÉGORIE
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildRevenusTab(AppProvider provider, List<int> years) {
    final filtered = _filterByPeriod<Revenu>(
        provider.revenusFiltres, (r) => r.date);
    final items = filtered
        .map((r) => (categorie: r.categorie, montant: r.montant))
        .toList();
    final grouped = _groupByCategory(items);
    final grandTotal = grouped.values.fold(0.0, (sum, v) => sum + v.total);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: <Widget>[
          _buildFilters(years),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const CardTitle('PAR CATÉGORIE'),
                      if (grandTotal > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(
                            fmtMAD(grandTotal),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.green2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (grouped.isEmpty)
                    const EmptyState(
                        emoji: '📭',
                        text: 'Aucun revenu pour cette période')
                  else
                    ...grouped.entries.map((entry) {
                      final pct = grandTotal > 0
                          ? entry.value.total / grandTotal
                          : 0.0;
                      return _CategoryTile(
                        label: entry.key,
                        count: entry.value.count,
                        amount: entry.value.total,
                        pct: pct,
                        color: AppColors.green2,
                      );
                    }),
                ],
              ),
            ),
          ),

          if (grouped.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SummaryFooter(
                opCount: filtered.length,
                catCount: grouped.length,
                total: grandTotal,
                color: AppColors.green2,
                bgColor: AppColors.greenBg,
              ),
            ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // ONGLET 3 — BILAN (REVENUS vs DÉPENSES)
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildBilanTab(AppProvider provider, List<int> years) {
    final filteredDep = _filterByPeriod<Depense>(
        provider.depensesFiltrees, (d) => d.date);
    final filteredRev = _filterByPeriod<Revenu>(
        provider.revenusFiltres, (r) => r.date);
    final totalDep = filteredDep.fold(0.0, (sum, d) => sum + d.montant);
    final totalRev = filteredRev.fold(0.0, (sum, r) => sum + r.montant);
    final solde = totalRev - totalDep;
    final maxVal = totalRev > totalDep ? totalRev : totalDep;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: <Widget>[
          _buildFilters(years),

          // ── Cards Revenus / Dépenses ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _BilanCard(
                    label: 'Revenus',
                    emoji: '💰',
                    amount: totalRev,
                    gradient: const [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BilanCard(
                    label: 'Dépenses',
                    emoji: '💸',
                    amount: totalDep,
                    gradient: const [Color(0xFFB71C1C), Color(0xFFC62828)],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Solde ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppCard(
              child: Column(
                children: <Widget>[
                  Text(
                    solde >= 0 ? '📈 Bénéfice net' : '📉 Perte nette',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${solde >= 0 ? '+' : ''}${_moneyFmt.format(solde)} MAD',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: solde >= 0 ? AppColors.green2 : AppColors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Barres comparatives ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const CardTitle('COMPARAISON'),
                  const SizedBox(height: 4),
                  _CompareBar(
                    label: 'Revenus',
                    amount: totalRev,
                    maxVal: maxVal,
                    color: AppColors.green2,
                  ),
                  const SizedBox(height: 14),
                  _CompareBar(
                    label: 'Dépenses',
                    amount: totalDep,
                    maxVal: maxVal,
                    color: AppColors.red,
                  ),
                ],
              ),
            ),
          ),

          // ── Top 3 catégories chaque côté ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: _TopCategoriesCard(
                    title: 'TOP DÉPENSES',
                    items: filteredDep
                        .map((d) =>
                            (categorie: d.categorie, montant: d.montant))
                        .toList(),
                    color: AppColors.red,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TopCategoriesCard(
                    title: 'TOP REVENUS',
                    items: filteredRev
                        .map((r) =>
                            (categorie: r.categorie, montant: r.montant))
                        .toList(),
                    color: AppColors.green2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // ONGLET 4 — EXPLOITATION (CHEPTEL + CULTURES)
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildExploitationTab(AppProvider provider) {
    final stock = provider.stock;
    final now = DateTime.now();

    // Mouvements du mois
    final mvtsMois = provider.mouvements.where((m) =>
        m.date.year == now.year && m.date.month == now.month);
    int naissances = 0, ventes = 0, deces = 0, achats = 0;
    for (final m in mvtsMois) {
      if (m.type.startsWith('naissance')) naissances += m.qte;
      if (m.type.startsWith('vente')) ventes += m.qte;
      if (m.type.startsWith('deces')) deces += m.qte;
      if (m.type.startsWith('achat')) achats += m.qte;
    }

    // Coûts cheptel
    final depMois = provider.depensesFiltrees
        .where((d) => d.date.year == now.year && d.date.month == now.month)
        .fold(0.0, (sum, d) => sum + d.montant);
    final coutParTete = stock.total > 0 ? depMois / stock.total : 0.0;

    // Cultures — agréger par type
    final cultureStats = <String, ({double production, double revenu, double depense})>{};
    for (final r in provider.recoltesFiltrees) {
      final ex = cultureStats[r.culture];
      cultureStats[r.culture] = (
        production: (ex?.production ?? 0) + r.quantite,
        revenu: ex?.revenu ?? 0,
        depense: ex?.depense ?? 0,
      );
    }
    // Associer revenus de vente aux cultures
    for (final rev in provider.revenusFiltres) {
      final catLower = rev.categorie.toLowerCase();
      String? matchCulture;
      if (catLower.contains('olive') || catLower.contains('huile')) {
        matchCulture = 'Olives';
        if (!cultureStats.containsKey(matchCulture)) {
          matchCulture = "Huile d'olive";
        }
      }
      if (matchCulture != null && cultureStats.containsKey(matchCulture)) {
        final ex = cultureStats[matchCulture]!;
        cultureStats[matchCulture] = (
          production: ex.production,
          revenu: ex.revenu + rev.montant,
          depense: ex.depense,
        );
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── CHEPTEL ───────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '🐑 CHEPTEL',
              style: TextStyle(
                fontSize: 13,
                letterSpacing: .7,
                fontWeight: FontWeight.w900,
                color: AppColors.text2,
              ),
            ),
          ),

          // État actuel - grille 2x2
          Row(
            children: <Widget>[
              Expanded(
                child: _StockTile(
                    count: stock.femelles, label: 'Femelles', emoji: '🐑'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StockTile(
                    count: stock.males, label: 'Mâles', emoji: '🐏'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _StockTile(
                    count: stock.agneauxF,
                    label: 'Agneaux ♀',
                    emoji: '🍼'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StockTile(
                    count: stock.agneauxM,
                    label: 'Agneaux ♂',
                    emoji: '🐣'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Total cheptel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: <Widget>[
                const Text(
                  'Total cheptel',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  '${stock.total}',
                  style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
                const Text(
                  'têtes',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mouvements du mois
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'MOUVEMENTS DU MOIS',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: .7,
                fontWeight: FontWeight.w900,
                color: AppColors.text2,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: _MvtMiniCard(
                      emoji: '🐣', count: naissances, label: 'Naissances')),
              const SizedBox(width: 8),
              Expanded(
                  child: _MvtMiniCard(
                      emoji: '🤝', count: ventes, label: 'Ventes')),
              const SizedBox(width: 8),
              Expanded(
                  child: _MvtMiniCard(
                      emoji: '💀', count: deces, label: 'Décès')),
              const SizedBox(width: 8),
              Expanded(
                  child: _MvtMiniCard(
                      emoji: '🛒', count: achats, label: 'Achats')),
            ],
          ),
          const SizedBox(height: 12),

          // Coût par tête
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    const Text(
                      'Coût/tête (mois)',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fmtMAD(coutParTete),
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.red),
                    ),
                  ],
                ),
                Container(width: 1, height: 40, color: AppColors.border),
                Column(
                  children: <Widget>[
                    const Text(
                      'Dépenses mois',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fmtMAD(depMois),
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── CULTURES ──────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '🌾 CULTURES & RÉCOLTES',
              style: TextStyle(
                fontSize: 13,
                letterSpacing: .7,
                fontWeight: FontWeight.w900,
                color: AppColors.text2,
              ),
            ),
          ),

          if (cultureStats.isEmpty)
            const EmptyState(
                emoji: '🌱',
                text: 'Aucune récolte enregistrée')
          else
            ...cultureStats.entries.map((entry) {
              final emoji = cultureEmojis[entry.key] ?? '🌱';
              final unite = cultureUnites[entry.key] ?? 'kg';
              final marge = entry.value.revenu - entry.value.depense;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(emoji, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.text,
                                  ),
                                ),
                                Text(
                                  '${entry.value.production.toStringAsFixed(0)} $unite',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (entry.value.revenu > 0) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _MiniStatBox(
                                label: 'Revenu',
                                value: fmtMAD(entry.value.revenu),
                                color: AppColors.green2,
                                bg: AppColors.greenBg,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MiniStatBox(
                                label: 'Marge',
                                value:
                                    '${marge >= 0 ? '+' : ''}${_moneyFmt.format(marge)} MAD',
                                color: marge >= 0
                                    ? AppColors.green2
                                    : AppColors.red,
                                bg: marge >= 0
                                    ? AppColors.greenBg
                                    : AppColors.redBg,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // SHARED WIDGETS
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _periodeChip(String value, String label) {
    final selected = _periode == value;
    return GestureDetector(
      onTap: () => setState(() => _periode = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.green2 : AppColors.bg2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.green2 : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : AppColors.text2,
          ),
        ),
      ),
    );
  }
}

final NumberFormat _moneyFmt = NumberFormat('#,##0', 'fr_FR');

// ═════════════════════════════════════════════════════════════════════════════
// SOUS-WIDGETS PRIVÉS
// ═════════════════════════════════════════════════════════════════════════════

// ─── Catégorie expandable ────────────────────────────────────────────────────

class _CategoryTile extends StatefulWidget {
  const _CategoryTile({
    required this.label,
    required this.count,
    required this.amount,
    required this.pct,
    required this.color,
    this.details,
  });

  final String label;
  final int count;
  final double amount;
  final double pct;
  final Color color;
  final List<_DetailLine>? details;

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasDetails =
        widget.details != null && widget.details!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: hasDetails
                ? () => setState(() => _expanded = !_expanded)
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  widget.label,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                              if (hasDetails)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: AnimatedRotation(
                                    turns: _expanded ? 0.25 : 0,
                                    duration:
                                        const Duration(milliseconds: 200),
                                    child: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 10,
                                      color: AppColors.text3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            '${widget.count} opération${widget.count > 1 ? 's' : ''}',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.text3),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          fmtMAD(widget.amount),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: widget.color,
                          ),
                        ),
                        Text(
                          '${(widget.pct * 100).toStringAsFixed(1)} %',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.text3),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: widget.pct,
                    minHeight: 8,
                    backgroundColor: AppColors.bg4,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(widget.color),
                  ),
                ),
              ],
            ),
          ),

          // ── Détails expandés ────────────────────────────────────────────
          if (_expanded && hasDetails)
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: Container(
                margin: const EdgeInsets.only(top: 10, left: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bg3,
                  borderRadius: BorderRadius.circular(14),
                  border: Border(
                    left: BorderSide(color: widget.color, width: 3),
                  ),
                ),
                child: Column(
                  children: widget.details!
                      .map((d) => Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        d.label,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.text,
                                        ),
                                      ),
                                      if (d.sub != null)
                                        Text(
                                          d.sub!,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.text3,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  d.value,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: widget.color,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailLine {
  final String label;
  final String value;
  final String? sub;
  const _DetailLine({required this.label, required this.value, this.sub});
}

// ─── Summary footer ──────────────────────────────────────────────────────────

class _SummaryFooter extends StatelessWidget {
  const _SummaryFooter({
    required this.opCount,
    required this.catCount,
    required this.total,
    required this.color,
    required this.bgColor,
  });

  final int opCount;
  final int catCount;
  final double total;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$opCount opération${opCount > 1 ? 's' : ''}',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800, color: color),
              ),
              Text(
                '$catCount catégorie${catCount > 1 ? 's' : ''}',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.text3,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Text(
            fmtMAD(total),
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }
}

// ─── Bilan Card ──────────────────────────────────────────────────────────────

class _BilanCard extends StatelessWidget {
  const _BilanCard({
    required this.label,
    required this.emoji,
    required this.amount,
    required this.gradient,
  });

  final String label;
  final String emoji;
  final double amount;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$emoji $label',
            style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              fmtMAD(amount),
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Compare Bar ─────────────────────────────────────────────────────────────

class _CompareBar extends StatelessWidget {
  const _CompareBar({
    required this.label,
    required this.amount,
    required this.maxVal,
    required this.color,
  });

  final String label;
  final double amount;
  final double maxVal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = maxVal > 0 ? amount / maxVal : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text)),
            Text('${(pct * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 14,
            backgroundColor: AppColors.bg4,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ─── Top Categories Card ─────────────────────────────────────────────────────

class _TopCategoriesCard extends StatelessWidget {
  const _TopCategoriesCard({
    required this.title,
    required this.items,
    required this.color,
  });

  final String title;
  final List<({String categorie, double montant})> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, double>{};
    for (final item in items) {
      grouped[item.categorie] = (grouped[item.categorie] ?? 0) + item.montant;
    }
    final sorted = grouped.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sorted.take(3);

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: .5,
              fontWeight: FontWeight.w900,
              color: AppColors.text3,
            ),
          ),
          const SizedBox(height: 10),
          if (top3.isEmpty)
            const Text('—',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.text3,
                    fontWeight: FontWeight.w700)),
          ...top3.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      e.key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text),
                    ),
                    Text(
                      fmtMAD(e.value),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: color),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ─── Stock Tile ──────────────────────────────────────────────────────────────

class _StockTile extends StatelessWidget {
  const _StockTile({
    required this.count,
    required this.label,
    required this.emoji,
  });

  final int count;
  final String label;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$count',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green2),
              ),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text2),
              ),
            ],
          ),
          Text(emoji, style: const TextStyle(fontSize: 28)),
        ],
      ),
    );
  }
}

// ─── Mvt Mini Card ───────────────────────────────────────────────────────────

class _MvtMiniCard extends StatelessWidget {
  const _MvtMiniCard({
    required this.emoji,
    required this.count,
    required this.label,
  });

  final String emoji;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.text),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.text3),
          ),
        ],
      ),
    );
  }
}

// ─── Mini Stat Box ───────────────────────────────────────────────────────────

class _MiniStatBox extends StatelessWidget {
  const _MiniStatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  final String label;
  final String value;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.text3),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w900, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dropdown Field (réutilisé) ──────────────────────────────────────────────

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.text),
          isExpanded: true,
          dropdownColor: AppColors.bg2,
        ),
      ),
    );
  }
}

// ─── Date Picker Button ──────────────────────────────────────────────────────

class _DateBtn extends StatelessWidget {
  const _DateBtn({required this.label, required this.date});
  final String label;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.calendar_today_rounded,
              size: 16, color: AppColors.green2),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.text3,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(date),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: AppColors.text3),
        ],
      ),
    );
  }
}
