import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/ferme_models.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/form_sheet.dart';
import '../widgets/widgets.dart';
import 'rapports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _reportType = 'depenses';
  String _periode = 'mensuel';
  int _mois = DateTime.now().month;
  int _annee = DateTime.now().year;

  List<dynamic> _filterItems(List<dynamic> items) {
    final now = DateTime.now();
    switch (_periode) {
      case 'mensuel':
        return items.where((item) => (item.date as DateTime).year == _annee && (item.date as DateTime).month == _mois).toList();
      case 'annuel':
        return items.where((item) => (item.date as DateTime).year == _annee).toList();
      case 'hebdo':
        final startOfWeek = DateTime(now.year, now.month, now.day - (now.weekday - 1));
        return items.where((item) => !(item.date as DateTime).isBefore(startOfWeek)).toList();
      default:
        return items;
    }
  }

  Map<String, double> _groupByCategorie(List<dynamic> items) {
    final result = <String, double>{};
    for (final item in items) {
      final cat = item.categorie as String;
      final montant = (item.montant as num).toDouble();
      result[cat] = (result[cat] ?? 0) + montant;
    }
    return Map.fromEntries(result.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final stock = provider.stock;
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy', 'fr_FR').format(now);

    // Finance totals — always global (all farms)
    final allDep = provider.depenses;
    final allRev = provider.revenus;
    final depMois = allDep.where((d) => d.date.year == now.year && d.date.month == now.month).fold(0.0, (s, d) => s + d.montant);
    final revMois = allRev.where((r) => r.date.year == now.year && r.date.month == now.month).fold(0.0, (s, r) => s + r.montant);
    final soldeMois = revMois - depMois;
    final bilanTotal = allRev.fold(0.0, (s, r) => s + r.montant) - allDep.fold(0.0, (s, d) => s + d.montant);

    // Report data — always global
    final reportSource = _reportType == 'depenses' ? allDep : allRev;
    final reportFiltered = _filterItems(reportSource);
    final reportTotal = reportFiltered.fold(0.0, (s, item) => s + (item.montant as num).toDouble());
    final reportByCategorie = _groupByCategorie(reportFiltered);
    final reportColor = _reportType == 'depenses' ? AppColors.red : AppColors.green2;

    // Available years for dropdowns
    final yearSet = <int>{now.year};
    for (final d in allDep) yearSet.add(d.date.year);
    for (final r in allRev) yearSet.add(r.date.year);
    final years = yearSet.toList()..sort();

    // Recent items
    final recentMouvements = provider.mouvements.reversed.take(4).toList();
    final recentDepenses = provider.depensesFiltrees.take(2).toList();
    final recentRevenus = provider.revenusFiltres.take(2).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const FermeFilterBar(),
          const SizedBox(height: 4),
          // ── Action buttons ─────────────────────────────────────────────
          Row(
            children: <Widget>[
              Expanded(
                child: _ActionBtn(
                  label: 'Revenus',
                  emoji: '💰',
                  color: const Color(0xFF1B7A46),
                  splashColor: const Color(0xFF27A260),
                  onTap: () => showRevForm(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionBtn(
                  label: 'Dépenses',
                  emoji: '💸',
                  color: const Color(0xFFB5192E),
                  splashColor: const Color(0xFFE02040),
                  onTap: () => showDepForm(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Finance hero card ──────────────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF1A3A5C), Color(0xFF2562A0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  monthName.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white54, letterSpacing: 1),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _DashHeroCol(
                        label: 'Revenus',
                        value: fmtMAD(revMois),
                        color: const Color(0xFF52D789),
                      ),
                    ),
                    Container(width: 1, height: 44, color: Colors.white24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _DashHeroCol(
                        label: 'Dépenses',
                        value: fmtMAD(depMois),
                        color: const Color(0xFFFF7070),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: Colors.white24),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _DashHeroStat(
                        label: 'Solde du mois',
                        value: fmtMAD(soldeMois.abs()),
                        positive: soldeMois >= 0,
                      ),
                    ),
                    Expanded(
                      child: _DashHeroStat(
                        label: 'Bilan cumulé',
                        value: fmtMAD(bilanTotal.abs()),
                        positive: bilanTotal >= 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Compact cheptel row ────────────────────────────────────────
          GestureDetector(
            onTap: () => _showCheptelDetail(context, 'femelles'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.bg4,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.greenBg),
              ),
              child: Row(
                children: <Widget>[
                  const Text('🐑', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('Cheptel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
                        Text(
                          '${stock.femelles} brebis · ${stock.males} béliers · ${stock.agneauxF + stock.agneauxM} agneaux',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text2),
                        ),
                      ],
                    ),
                  ),
                  Text('${stock.total}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.green2)),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.text3),
                ],
              ),
            ),
          ),

          // ── Inline Rapports ────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('RAPPORTS'),
                // Type toggle
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _DashToggleBtn(
                        label: 'Dépenses',
                        active: _reportType == 'depenses',
                        color: AppColors.red,
                        onTap: () => setState(() => _reportType = 'depenses'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DashToggleBtn(
                        label: 'Revenus',
                        active: _reportType == 'revenus',
                        color: AppColors.green2,
                        onTap: () => setState(() => _reportType = 'revenus'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Period chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      _DashPeriodChip(label: 'Ce mois', selected: _periode == 'mensuel', onTap: () => setState(() => _periode = 'mensuel')),
                      const SizedBox(width: 8),
                      _DashPeriodChip(label: 'Cette année', selected: _periode == 'annuel', onTap: () => setState(() => _periode = 'annuel')),
                      const SizedBox(width: 8),
                      _DashPeriodChip(label: 'Cette semaine', selected: _periode == 'hebdo', onTap: () => setState(() => _periode = 'hebdo')),
                      const SizedBox(width: 8),
                      _DashPeriodChip(label: 'Tout', selected: _periode == 'tout', onTap: () => setState(() => _periode = 'tout')),
                    ],
                  ),
                ),
                // Date selectors
                if (_periode == 'mensuel') ...<Widget>[
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _DashDropdown<int>(
                          value: _mois,
                          items: List<int>.generate(12, (i) => i + 1),
                          label: (m) => DateFormat('MMMM', 'fr_FR').format(DateTime(2000, m)),
                          onChanged: (v) => setState(() => _mois = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DashDropdown<int>(
                          value: _annee,
                          items: years,
                          label: (y) => '$y',
                          onChanged: (v) => setState(() => _annee = v),
                        ),
                      ),
                    ],
                  ),
                ] else if (_periode == 'annuel') ...<Widget>[
                  const SizedBox(height: 10),
                  _DashDropdown<int>(
                    value: _annee,
                    items: years,
                    label: (y) => '$y',
                    onChanged: (v) => setState(() => _annee = v),
                  ),
                ],
                const SizedBox(height: 14),
                // Category bars
                if (reportByCategorie.isEmpty)
                  const EmptyState(emoji: '📊', text: 'Aucune donnée pour cette période')
                else ...<Widget>[
                  ...reportByCategorie.entries.map(
                    (entry) => CatRow(cat: entry.key, amount: entry.value, total: reportTotal, color: reportColor),
                  ),
                  Container(height: 1, color: AppColors.bg4, margin: const EdgeInsets.symmetric(vertical: 8)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text('Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
                      Text(fmtMAD(reportTotal), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: reportColor)),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Récent ────────────────────────────────────────────────────
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('RÉCENT'),
                if (recentMouvements.isEmpty && recentDepenses.isEmpty && recentRevenus.isEmpty)
                  const EmptyState(emoji: '📭', text: 'Aucune donnée récente')
                else ...<Widget>[
                  ...recentMouvements.map(
                    (m) => RecentItem(
                      emoji: m.emoji,
                      title: m.label,
                      subtitle: fmtDate(m.date),
                      value: '×${m.qte}',
                      valueColor: mvtFgColor(m.color),
                      bgColor: mvtBgColor(m.color),
                    ),
                  ),
                  ...recentDepenses.map(
                    (d) => RecentItem(
                      emoji: '💸',
                      title: d.categorie,
                      subtitle: fmtDate(d.date),
                      value: '-${fmtMAD(d.montant)}',
                      valueColor: AppColors.red,
                      bgColor: AppColors.redBg,
                    ),
                  ),
                  ...recentRevenus.map(
                    (r) => RecentItem(
                      emoji: '💰',
                      title: r.categorie,
                      subtitle: fmtDate(r.date),
                      value: '+${fmtMAD(r.montant)}',
                      valueColor: AppColors.green2,
                      bgColor: AppColors.greenBg,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dashboard sub-widgets ──────────────────────────────────────────────────────

class _DashHeroCol extends StatelessWidget {
  const _DashHeroCol({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white60)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}

class _DashHeroStat extends StatelessWidget {
  const _DashHeroStat({required this.label, required this.value, required this.positive});
  final String label;
  final String value;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive ? const Color(0xFF52D789) : const Color(0xFFFF7070);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white60)),
        const SizedBox(height: 3),
        Row(
          children: <Widget>[
            Icon(
              positive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              size: 15,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ],
    );
  }
}

class _DashToggleBtn extends StatelessWidget {
  const _DashToggleBtn({required this.label, required this.active, required this.color, required this.onTap});
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.12) : AppColors.bg4,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? color : Colors.transparent, width: 1.5),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: active ? color : AppColors.text2),
        ),
      ),
    );
  }
}

class _DashPeriodChip extends StatelessWidget {
  const _DashPeriodChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.green2 : AppColors.bg4,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : AppColors.text2,
          ),
        ),
      ),
    );
  }
}

class _DashDropdown<T> extends StatelessWidget {
  const _DashDropdown({required this.value, required this.items, required this.label, required this.onChanged});
  final T value;
  final List<T> items;
  final String Function(T) label;
  final void Function(T) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(color: AppColors.bg4, borderRadius: BorderRadius.circular(12)),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
        items: items.map((item) => DropdownMenuItem<T>(value: item, child: Text(label(item)))).toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.emoji,
    required this.color,
    required this.splashColor,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final Color color;
  final Color splashColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: splashColor.withOpacity(.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: .2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheptelScreen extends StatelessWidget {
  const CheptelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final stock = provider.stock;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionTitle('Cheptel', sub: 'Suivi des entrées, sorties et état actuel'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('ÉTAT ACTUEL'),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.22,
                  children: <Widget>[
                    KpiCard(emoji: '🐑', value: '${stock.femelles}', label: 'Femelles', onTap: () => _showCheptelDetail(context, 'femelles')),
                    KpiCard(emoji: '🐏', value: '${stock.males}', label: 'Mâles', onTap: () => _showCheptelDetail(context, 'males')),
                    KpiCard(emoji: '🐣', value: '${stock.agneauxF}', label: 'Agneaux femelles', onTap: () => _showCheptelDetail(context, 'agf')),
                    KpiCard(emoji: '🐥', value: '${stock.agneauxM}', label: 'Agneaux mâles', onTap: () => _showCheptelDetail(context, 'agm')),
                  ],
                ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('AJOUTER UN MOUVEMENT'),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.25,
                  children: <Widget>[
                    MvtBtn(emoji: '🐣', label: 'Naissance femelle', onTap: () => showMvtForm(context, initialType: 'naissance_agf')),
                    MvtBtn(emoji: '🐥', label: 'Naissance mâle', onTap: () => showMvtForm(context, initialType: 'naissance_agm')),
                    MvtBtn(emoji: '🛒', label: 'Achat', onTap: () => showMvtForm(context, initialType: 'achat_femelle')),
                    MvtBtn(emoji: '🤝', label: 'Vente', onTap: () => showMvtForm(context, initialType: 'vente_femelle')),
                    MvtBtn(emoji: '💀', label: 'Décès', onTap: () => showMvtForm(context, initialType: 'deces_femelle')),
                    MvtBtn(emoji: '⚙️', label: 'Stock initial', onTap: () => showMvtForm(context, initialType: 'init_femelles')),
                  ],
                ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('DERNIERS MOUVEMENTS'),
                if (provider.mouvements.isEmpty)
                  const EmptyState(emoji: '🐑', text: 'Aucun mouvement enregistré')
                else
                  ...provider.mouvements.reversed.take(20).map(
                        (m) => HistoryItem(
                          emoji: m.emoji,
                          title: m.label,
                          subtitle: '${fmtDate(m.date)}${m.remarque.isNotEmpty ? ' · ${m.remarque}' : ''}',
                          value: '×${m.qte}',
                          valueColor: mvtFgColor(m.color),
                          bgColor: mvtBgColor(m.color),
                          onDelete: () => _confirmDelete(context, () => context.read<AppProvider>().deleteMouvement(m.id)),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DepensesScreen extends StatelessWidget {
  const DepensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final now = DateTime.now();
    final categories = provider.depensesByCategorie();
    final total = provider.totalDepenses;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const FermeFilterBar(),
          const SectionTitle('Dépenses', sub: 'Vue synthèse et journal des sorties'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FinSumCard(value: fmtMAD(provider.depensesMois(now)), label: 'Ce mois', color: AppColors.red),
              FinSumCard(value: fmtMAD(total), label: 'Total', color: AppColors.red),
            ],
          ),
          const SizedBox(height: 14),
          AddButton(label: 'Ajouter une dépense', onTap: () => showDepForm(context), color: AppColors.red2),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('PAR CATÉGORIE'),
                if (categories.isEmpty)
                  const EmptyState(emoji: '📊', text: 'Aucune dépense')
                else
                  ...categories.entries.map(
                    (entry) => CatRow(cat: entry.key, amount: entry.value, total: total, color: AppColors.red),
                  ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('TOUTES LES DÉPENSES'),
                if (provider.depensesFiltrees.isEmpty)
                  const EmptyState(emoji: '💸', text: 'Aucune dépense enregistrée')
                else
                  ...provider.depensesFiltrees.map(
                    (d) => HistoryItem(
                      emoji: '💸',
                      title: d.categorie,
                      subtitle: '${fmtDate(d.date)}${d.remarque.isNotEmpty ? ' · ${d.remarque}' : ''}',
                      value: '-${fmtMAD(d.montant)}',
                      valueColor: AppColors.red,
                      bgColor: AppColors.redBg,
                      onDelete: () => _confirmDelete(context, () => context.read<AppProvider>().deleteDepense(d.id)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RevenusScreen extends StatelessWidget {
  const RevenusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final now = DateTime.now();
    final categories = provider.revenusByCategorie();
    final total = provider.totalRevenus;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const FermeFilterBar(),
          const SectionTitle('Revenus', sub: 'Vue synthèse et journal des encaissements'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FinSumCard(value: fmtMAD(provider.revenusMois(now)), label: 'Ce mois', color: AppColors.green2),
              FinSumCard(value: fmtMAD(total), label: 'Total', color: AppColors.green2),
            ],
          ),
          const SizedBox(height: 14),
          AddButton(label: 'Ajouter un revenu', onTap: () => showRevForm(context)),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('PAR CATÉGORIE'),
                if (categories.isEmpty)
                  const EmptyState(emoji: '📊', text: 'Aucun revenu')
                else
                  ...categories.entries.map(
                    (entry) => CatRow(cat: entry.key, amount: entry.value, total: total, color: AppColors.green2),
                  ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('TOUS LES REVENUS'),
                if (provider.revenusFiltres.isEmpty)
                  const EmptyState(emoji: '💰', text: 'Aucun revenu enregistré')
                else
                  ...provider.revenusFiltres.map(
                    (r) => HistoryItem(
                      emoji: '💰',
                      title: r.categorie,
                      subtitle: '${fmtDate(r.date)}${r.remarque.isNotEmpty ? ' · ${r.remarque}' : ''}',
                      value: '+${fmtMAD(r.montant)}',
                      valueColor: AppColors.green2,
                      bgColor: AppColors.greenBg,
                      onDelete: () => _confirmDelete(context, () => context.read<AppProvider>().deleteRevenu(r.id)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    final items = <({DateTime date, String type, dynamic item})>[
      if (_filter == 'all' || _filter == 'mvt') ...provider.mouvements.map((m) => (date: m.date, type: 'mvt', item: m)),
      if (_filter == 'all' || _filter == 'dep') ...provider.depensesFiltrees.map((d) => (date: d.date, type: 'dep', item: d)),
      if (_filter == 'all' || _filter == 'rev') ...provider.revenusFiltres.map((r) => (date: r.date, type: 'rev', item: r)),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionTitle('Historique', sub: 'Toutes les opérations récentes'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    _chip('Tout', 'all'),
                    _chip('Troupeau', 'mvt'),
                    _chip('Dépenses', 'dep'),
                    _chip('Revenus', 'rev'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const EmptyState(emoji: '📭', text: 'Aucune donnée')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final entry = items[index];

                    if (entry.type == 'mvt') {
                      final m = entry.item as Mouvement;
                      return HistoryItem(
                        emoji: m.emoji,
                        title: m.label,
                        subtitle: '${fmtDate(m.date)}${m.remarque.isNotEmpty ? ' · ${m.remarque}' : ''}',
                        value: '×${m.qte}',
                        valueColor: mvtFgColor(m.color),
                        bgColor: mvtBgColor(m.color),
                      );
                    }

                    if (entry.type == 'dep') {
                      final d = entry.item as Depense;
                      return HistoryItem(
                        emoji: '💸',
                        title: d.categorie,
                        subtitle: '${fmtDate(d.date)}${d.remarque.isNotEmpty ? ' · ${d.remarque}' : ''}',
                        value: '-${fmtMAD(d.montant)}',
                        valueColor: AppColors.red,
                        bgColor: AppColors.redBg,
                      );
                    }

                    final r = entry.item as Revenu;
                    return HistoryItem(
                      emoji: '💰',
                      title: r.categorie,
                      subtitle: '${fmtDate(r.date)}${r.remarque.isNotEmpty ? ' · ${r.remarque}' : ''}',
                      value: '+${fmtMAD(r.montant)}',
                      valueColor: AppColors.green2,
                      bgColor: AppColors.greenBg,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final selected = _filter == value;

    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.green2 : AppColors.bg2,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? AppColors.green2 : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.text2),
        ),
      ),
    );
  }
}

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TabBar(
          controller: _tab,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const <Tab>[
            Tab(text: 'Dépenses'),
            Tab(text: 'Revenus'),
            Tab(text: 'Historique'),
            Tab(text: '📊 Rapports'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: const <Widget>[
              DepensesScreen(),
              RevenusScreen(),
              HistoriqueScreen(),
              RapportsScreen(),
            ],
          ),
        ),
      ],
    );
  }
}

class ManagementHubScreen extends StatefulWidget {
  const ManagementHubScreen({super.key});
  @override
  State<ManagementHubScreen> createState() => _ManagementHubScreenState();
}

class _ManagementHubScreenState extends State<ManagementHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilotage & Paramètres'),
        bottom: TabBar(
          controller: _tab,
          tabs: const <Tab>[
            Tab(text: '💸 Dépenses'),
            Tab(text: '💰 Revenus'),
            Tab(text: '🌾 Cultures'),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          // ── Fermes info ──────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: <Widget>[
                Expanded(child: _FermeInfo(emoji: '🐑', name: 'Ferme Rhamna', desc: 'Moutons · Oliviers · Fassa')),
                Container(width: 1, height: 44, color: AppColors.border),
                Expanded(child: _FermeInfo(emoji: '🫒', name: 'Ferme Srahna', desc: 'Oliviers · Luzerne')),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // ── Export + Clear ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _ToolBtn(
                    emoji: '💾',
                    label: 'Exporter sauvegarde',
                    color: AppColors.green2,
                    onTap: () async {
                      try {
                        await context.read<AppProvider>().exportDatabase();
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur export: $e'), backgroundColor: AppColors.red),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ToolBtn(
                    emoji: '🗑️',
                    label: 'Vider les données',
                    color: AppColors.red2,
                    onTap: () => _confirmDelete(context, () => context.read<AppProvider>().clearAll()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // ── Supabase Sync ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _ToolBtn(
                    emoji: '☁️',
                    label: 'Sync → Supabase',
                    color: AppColors.blue2,
                    onTap: () async {
                      final provider = context.read<AppProvider>();
                      if (provider.syncInProgress) return;
                      final result = await provider.syncToSupabase();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result.message),
                          backgroundColor: result.success ? AppColors.green2 : AppColors.red,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ToolBtn(
                    emoji: '📥',
                    label: 'Restaurer depuis cloud',
                    color: AppColors.orange2,
                    onTap: () => _confirmDelete(
                      context,
                      () async {
                        final provider = context.read<AppProvider>();
                        final result = await provider.restoreFromSupabase();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.message),
                            backgroundColor: result.success ? AppColors.green2 : AppColors.red,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // ── Category tabs ────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: const <Widget>[
                _CatList(type: 'depense'),
                _CatList(type: 'revenu'),
                _CatList(type: 'culture'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FermeInfo extends StatelessWidget {
  const _FermeInfo({required this.emoji, required this.name, required this.desc});
  final String emoji;
  final String name;
  final String desc;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.text)),
        Text(desc, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text3), textAlign: TextAlign.center),
      ],
    );
  }
}

class _ToolBtn extends StatelessWidget {
  const _ToolBtn({required this.emoji, required this.label, required this.color, required this.onTap});
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatList extends StatelessWidget {
  const _CatList({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final cats = type == 'depense'
        ? provider.depCategories
        : type == 'revenu'
            ? provider.revCategories
            : provider.cultureCategories;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCatForm(context, type),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter une catégorie'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green2,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
        ),
        Expanded(
          child: cats.isEmpty
              ? const Center(child: Text('Aucune catégorie', style: TextStyle(color: AppColors.text3)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: cats.length,
                  itemBuilder: (ctx, i) {
                    final cat = cats[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.bg2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: AppColors.greenBg, borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(
                              type == 'depense' ? '💸' : type == 'revenu' ? '💰' : '🌾',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        title: Text(cat.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.green2),
                              onPressed: () => _showCatForm(context, type, existing: cat),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.red),
                              onPressed: () => _confirmDelete(context, () => context.read<AppProvider>().deleteCategory(cat.id)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showCatForm(BuildContext context, String type, {AppCategory? existing}) {
    final ctrl = TextEditingController(text: existing?.label ?? '');
    final emoji = type == 'depense' ? '💸' : type == 'revenu' ? '💰' : '🌾';
    final title = existing == null ? 'Ajouter catégorie $emoji' : 'Modifier catégorie $emoji';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bg2,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.green2)),
                const SizedBox(height: 20),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Nom de la catégorie',
                    hintText: 'Ex: Vente Fassa',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final label = ctrl.text.trim();
                      if (label.isEmpty) return;
                      final provider = context.read<AppProvider>();
                      if (existing == null) {
                        final cats = type == 'depense' ? provider.depCategories : type == 'revenu' ? provider.revCategories : provider.cultureCategories;
                        await provider.addCategory(AppCategory(type: type, label: label, ordre: cats.length));
                      } else {
                        await provider.updateCategory(AppCategory(id: existing.id, type: type, label: label, ordre: existing.ordre));
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.green2, minimumSize: const Size.fromHeight(54)),
                    child: Text(existing == null ? 'Ajouter' : 'Enregistrer'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler', style: TextStyle(color: AppColors.text3, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.bg2,
      title: const Text('Confirmer'),
      content: const Text('Supprimer cet enregistrement ?'),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Annuler')),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            onConfirm();
          },
          child: const Text('Supprimer', style: TextStyle(color: AppColors.red)),
        ),
      ],
    ),
  );
}

// ─── Cheptel Detail ───────────────────────────────────────────────────────────

void _showCheptelDetail(BuildContext context, String category) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CheptelDetailSheet(category: category),
  );
}

class _CheptelDetailSheet extends StatelessWidget {
  const _CheptelDetailSheet({required this.category});
  final String category;

  static const Map<String, Set<String>> _categoryTypes = <String, Set<String>>{
    'femelles': {'init_femelles', 'achat_femelle', 'vente_femelle', 'deces_femelle', 'passage_agf'},
    'males': {'init_males', 'achat_male', 'vente_male', 'deces_male', 'passage_agm'},
    'agf': {'init_agf', 'naissance_agf', 'passage_agf'},
    'agm': {'init_agm', 'naissance_agm', 'passage_agm'},
  };

  static const Map<String, String> _titles = <String, String>{
    'femelles': 'Femelles',
    'males': 'Mâles',
    'agf': 'Agneaux femelles',
    'agm': 'Agneaux mâles',
  };

  static const Map<String, String> _emojis = <String, String>{
    'femelles': '🐑',
    'males': '🐏',
    'agf': '🐣',
    'agm': '🐥',
  };

  static const Map<String, String> _addTypes = <String, String>{
    'femelles': 'achat_femelle',
    'males': 'achat_male',
    'agf': 'naissance_agf',
    'agm': 'naissance_agm',
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final stock = provider.stock;
    final types = _categoryTypes[category]!;
    final mouvements = provider.mouvements
        .where((m) => types.contains(m.type))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final currentValue = switch (category) {
      'femelles' => stock.femelles,
      'males' => stock.males,
      'agf' => stock.agneauxF,
      'agm' => stock.agneauxM,
      _ => 0,
    };

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: const BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: <Widget>[
            // ── Handle + Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.greenBg,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            _emojis[category]!,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _titles[category]!,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.green2,
                              ),
                            ),
                            Text(
                              '$currentValue tête${currentValue > 1 ? 's' : ''} actuellement',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.text3,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () =>
                            showMvtForm(context, initialType: _addTypes[category]!),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Ajouter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green2,
                          minimumSize: const Size(0, 38),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                  Text(
                    'HISTORIQUE DES MOUVEMENTS',
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: .6,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text3,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            // ── Movements list ───────────────────────────────────────────
            Expanded(
              child: mouvements.isEmpty
                  ? const EmptyState(
                      emoji: '📭',
                      text: 'Aucun mouvement enregistré dans cette catégorie',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: mouvements.length,
                      itemBuilder: (ctx, i) {
                        final m = mouvements[i];
                        return HistoryItem(
                          emoji: m.emoji,
                          title: m.label,
                          subtitle:
                              '${fmtDate(m.date)}${m.remarque.isNotEmpty ? ' · ${m.remarque}' : ''}',
                          value: '×${m.qte}',
                          valueColor: mvtFgColor(m.color),
                          bgColor: mvtBgColor(m.color),
                          onDelete: () => _confirmDelete(
                            context,
                            () => context
                                .read<AppProvider>()
                                .deleteMouvement(m.id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
