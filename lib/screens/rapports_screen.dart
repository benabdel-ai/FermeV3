import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class RapportsScreen extends StatefulWidget {
  const RapportsScreen({super.key});

  @override
  State<RapportsScreen> createState() => _RapportsScreenState();
}

class _RapportsScreenState extends State<RapportsScreen> {
  String _type = 'depense';
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

  List<int> _availableYears(AppProvider provider) {
    final years = <int>{DateTime.now().year};
    for (final d in provider.depensesFiltrees) {
      years.add(d.date.year);
    }
    for (final r in provider.revenusFiltres) {
      years.add(r.date.year);
    }
    return years.toList()..sort();
  }

  List<({String categorie, double montant, DateTime date})> _filterItems(
      AppProvider provider) {
    final items = _type == 'depense'
        ? provider.depensesFiltrees
            .map((d) =>
                (categorie: d.categorie, montant: d.montant, date: d.date))
            .toList()
        : provider.revenusFiltres
            .map((r) =>
                (categorie: r.categorie, montant: r.montant, date: r.date))
            .toList();

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
          .where((i) => !i.date.isBefore(start!) && !i.date.isAfter(end!))
          .toList();
    }
    return items;
  }

  Map<String, ({int count, double total})> _groupByCategory(
      List<({String categorie, double montant, DateTime date})> items) {
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final years = _availableYears(provider);
    final safeAnnee = years.contains(_annee) ? _annee : years.last;
    final filtered = _filterItems(provider);
    final grouped = _groupByCategory(filtered);
    final grandTotal = grouped.values.fold(0.0, (sum, v) => sum + v.total);
    final isRev = _type == 'revenu';
    final color = isRev ? AppColors.green2 : AppColors.red;
    final bgColor = isRev ? AppColors.greenBg : AppColors.redBg;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionTitle(
            'Rapports',
            sub: '${isRev ? 'Revenus' : 'Dépenses'} · ${_periodLabel()}',
          ),

          // ── Type toggle ──────────────────────────────────────────────────
          Row(
            children: <Widget>[
              Expanded(
                child: _TypeToggleBtn(
                  label: 'Dépenses',
                  emoji: '💸',
                  selected: _type == 'depense',
                  color: AppColors.red,
                  onTap: () => setState(() => _type = 'depense'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TypeToggleBtn(
                  label: 'Revenus',
                  emoji: '💰',
                  selected: _type == 'revenu',
                  color: AppColors.green2,
                  onTap: () => setState(() => _type = 'revenu'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Period chips ─────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
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

          // ── Date selectors ───────────────────────────────────────────────
          if (_periode == 'mensuel') ...<Widget>[
            Row(
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
                    value: safeAnnee,
                    items: years
                        .map((y) => DropdownMenuItem<int>(
                            value: y, child: Text('$y')))
                        .toList(),
                    onChanged: (v) => setState(() => _annee = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          if (_periode == 'annuel') ...<Widget>[
            _DropdownField<int>(
              value: safeAnnee,
              items: years
                  .map((y) =>
                      DropdownMenuItem<int>(value: y, child: Text('$y')))
                  .toList(),
              onChanged: (v) => setState(() => _annee = v!),
            ),
            const SizedBox(height: 12),
          ],

          if (_periode == 'par_jour') ...<Widget>[
            GestureDetector(
              onTap: () =>
                  _pickDate(_dateJour, (d) => setState(() => _dateJour = d)),
              child: _DateBtn(label: 'Date', date: _dateJour),
            ),
            const SizedBox(height: 12),
          ],

          if (_periode == 'periode') ...<Widget>[
            Row(
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
            const SizedBox(height: 12),
          ],

          // ── Results ──────────────────────────────────────────────────────
          AppCard(
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
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: color),
                        ),
                      ),
                  ],
                ),
                if (grouped.isEmpty)
                  const EmptyState(
                      emoji: '📊', text: 'Aucune donnée pour cette période')
                else
                  ...grouped.entries.map((entry) {
                    final pct =
                        grandTotal > 0 ? entry.value.total / grandTotal : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    Text(
                                      '${entry.value.count} opération${entry.value.count > 1 ? 's' : ''}',
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
                                    fmtMAD(entry.value.total),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: color,
                                    ),
                                  ),
                                  Text(
                                    '${(pct * 100).toStringAsFixed(1)} %',
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
                              value: pct,
                              minHeight: 8,
                              backgroundColor: AppColors.bg4,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),

          // ── Summary footer ───────────────────────────────────────────────
          if (grouped.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                        '${filtered.length} opération${filtered.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                      Text(
                        '${grouped.length} catégorie${grouped.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.text3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    fmtMAD(grandTotal),
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900, color: color),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

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

// ─── Type Toggle Button ───────────────────────────────────────────────────────

class _TypeToggleBtn extends StatelessWidget {
  const _TypeToggleBtn({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : AppColors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? color : AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppColors.text2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Dropdown Field ───────────────────────────────────────────────────────────

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

// ─── Date Picker Button ───────────────────────────────────────────────────────

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
