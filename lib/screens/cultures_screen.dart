import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ferme_models.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/form_sheet.dart';
import '../widgets/widgets.dart';

class CulturesScreen extends StatelessWidget {
  const CulturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        FermeFilterBar(),
        Expanded(child: _RecolteTab()),
      ],
    );
  }
}

// ─── Récolte Tab ──────────────────────────────────────────────────────────────

class _RecolteTab extends StatelessWidget {
  const _RecolteTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final recoltes = provider.recoltesFiltrees;

    // KPI aggregation by culture
    final byCulture = <String, _CultureStats>{};
    for (final r in recoltes) {
      byCulture.update(
        r.culture,
        (s) => _CultureStats(
          quantite: s.quantite + r.quantite,
          huile: s.huile + r.litresHuile,
          bilan: s.bilan + r.bilanRecolte,
          count: s.count + 1,
        ),
        ifAbsent: () => _CultureStats(
          quantite: r.quantite,
          huile: r.litresHuile,
          bilan: r.bilanRecolte,
          count: 1,
        ),
      );
    }

    // Totals
    final totalBilan = recoltes.fold(0.0, (s, r) => s + r.bilanRecolte);
    final totalCout = recoltes.fold(0.0, (s, r) => s + r.coutTotal);
    final totalRevenu = recoltes.fold(0.0, (s, r) => s + r.revenuHuile + r.revenuOlive);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionTitle('🌾 Cultures & Récoltes', sub: 'Production, trituration et bilan par culture'),

          // Summary hero card
          if (recoltes.isNotEmpty) ...<Widget>[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFF2E7D32), Color(0xFF43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: <BoxShadow>[
                  BoxShadow(color: AppColors.green2.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('📊 Bilan global récoltes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white70)),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      _HeroStat(label: 'Revenus', value: fmtMAD(totalRevenu), color: Colors.white),
                      _HeroStat(label: 'Charges', value: fmtMAD(totalCout), color: const Color(0xFFFFCC80)),
                      _HeroStat(
                        label: 'Bilan net',
                        value: fmtMAD(totalBilan),
                        color: totalBilan >= 0 ? const Color(0xFFA5D6A7) : const Color(0xFFEF9A9A),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Culture KPIs
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: byCulture.entries.map((e) {
                final emoji = cultureEmojis[e.key] ?? '🌱';
                final unite = cultureUnites[e.key] ?? 'kg';
                return _CultureKpi(
                  emoji: emoji,
                  culture: e.key,
                  stats: e.value,
                  unite: unite,
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          AddButton(
            label: '+ Enregistrer une récolte',
            onTap: () => showRecolteForm(context),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('📋 HISTORIQUE RÉCOLTES'),
                if (recoltes.isEmpty)
                  const EmptyState(emoji: '🌾', text: 'Aucune récolte enregistrée')
                else
                  ...recoltes.map((r) => _RecolteItem(r: r)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data helpers ──────────────────────────────────────────────────────────────

class _CultureStats {
  const _CultureStats({
    required this.quantite,
    required this.huile,
    required this.bilan,
    required this.count,
  });
  final double quantite;
  final double huile;
  final double bilan;
  final int count;
}

// ─── Hero stat (inside hero card) ─────────────────────────────────────────────

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: <Widget>[
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white60)),
          ],
        ),
      );
}

// ─── Culture KPI card ─────────────────────────────────────────────────────────

class _CultureKpi extends StatelessWidget {
  const _CultureKpi({
    required this.emoji,
    required this.culture,
    required this.stats,
    required this.unite,
  });

  final String emoji;
  final String culture;
  final _CultureStats stats;
  final String unite;

  @override
  Widget build(BuildContext context) {
    final qteStr = stats.quantite % 1 == 0
        ? '${stats.quantite.toInt()} $unite'
        : '${stats.quantite.toStringAsFixed(1)} $unite';
    final bilanColor = stats.bilan >= 0 ? AppColors.green2 : AppColors.red;

    return Container(
      width: 155,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            qteStr,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.green2),
          ),
          Text(culture, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.text2)),
          if (stats.huile > 0) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              '🫙 ${stats.huile.toStringAsFixed(1)} L huile',
              style: const TextStyle(fontSize: 11, color: AppColors.text3),
            ),
          ],
          if (stats.bilan != 0) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              '${stats.bilan >= 0 ? '+' : ''}${fmtMAD(stats.bilan)}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: bilanColor),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Récolte list item ─────────────────────────────────────────────────────────

class _RecolteItem extends StatelessWidget {
  const _RecolteItem({required this.r});
  final Recolte r;

  @override
  Widget build(BuildContext context) {
    final emoji = cultureEmojis[r.culture] ?? '🌱';
    final qteStr = r.quantite % 1 == 0
        ? '${r.quantite.toInt()} ${r.unite}'
        : '${r.quantite.toStringAsFixed(1)} ${r.unite}';
    final bilanColor = r.bilanRecolte >= 0 ? AppColors.green2 : AppColors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header row
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            leading: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.greenBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
            ),
            title: Text(r.culture, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Saison ${r.saison} · ${fmtDate(r.date)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.text3),
                ),
                const SizedBox(height: 4),
                FermeBadge(r.fermeId),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  qteStr,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.green2),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    InkWell(
                      onTap: () => showRecolteForm(context, initial: r),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.edit_outlined, size: 18, color: AppColors.text3),
                      ),
                    ),
                    InkWell(
                      onTap: () => _confirmDelete(
                        context,
                        () => context.read<AppProvider>().deleteRecolte(r.id),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.delete_outline, size: 18, color: AppColors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
          ),

          // Details section
          if (_hasDetails(r))
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: <Widget>[
                  if (r.litresHuile > 0)
                    _chip('🫙 ${r.litresHuile.toStringAsFixed(1)} L', AppColors.greenBg, AppColors.green2),
                  if (r.litresHuile > 0 && r.quantite > 0)
                    _chip('📊 ${r.rendementPct.toStringAsFixed(1)}%', AppColors.greenBg, AppColors.green3),
                  if (r.nbCaissons > 0)
                    _chip('📦 ${r.nbCaissons.toStringAsFixed(0)} caisses', const Color(0xFFFFF5E7), AppColors.orange),
                  if (r.coutTotal > 0)
                    _chip('💸 −${fmtMAD(r.coutTotal)}', const Color(0xFFFFF0F0), AppColors.red),
                  if (r.bilanRecolte != 0)
                    _chip(
                      '${r.bilanRecolte >= 0 ? '+' : ''}${fmtMAD(r.bilanRecolte)}',
                      r.bilanRecolte >= 0 ? AppColors.greenBg : const Color(0xFFFFF0F0),
                      bilanColor,
                    ),
                ],
              ),
            ),

          if (r.remarque.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Text(r.remarque, style: const TextStyle(fontSize: 11, color: AppColors.text3)),
            ),
        ],
      ),
    );
  }

  bool _hasDetails(Recolte r) =>
      r.litresHuile > 0 || r.nbCaissons > 0 || r.coutTotal > 0 || r.bilanRecolte != 0;

  Widget _chip(String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
      );
}

// ─── Shared helpers ────────────────────────────────────────────────────────────

void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.bg2,
      title: const Text('Confirmer'),
      content: const Text('Supprimer cet enregistrement ?'),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirm();
          },
          child: const Text('Supprimer', style: TextStyle(color: AppColors.red)),
        ),
      ],
    ),
  );
}
