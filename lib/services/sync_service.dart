import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ferme_models.dart';
import '../models/models.dart';
import 'database_service.dart';

class SyncResult {
  final bool success;
  final String message;
  final int pushed;
  final int pulled;

  const SyncResult({
    required this.success,
    required this.message,
    this.pushed = 0,
    this.pulled = 0,
  });
}

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  final SupabaseClient _sb = Supabase.instance.client;
  final DatabaseService _db = DatabaseService.instance;

  bool _syncing = false;
  bool get isSyncing => _syncing;

  // ── Push all local data to Supabase (upsert) ────────────────────────────────

  Future<SyncResult> pushAll() async {
    if (_syncing) {
      return const SyncResult(success: false, message: 'Synchronisation déjà en cours');
    }
    _syncing = true;
    int pushed = 0;

    try {
      // Mouvements
      final mouvements = await _db.getMouvements();
      if (mouvements.isNotEmpty) {
        await _sb.from('mouvements').upsert(
          mouvements.map(_mvtToRow).toList(),
          onConflict: 'id',
        );
        pushed += mouvements.length;
      }

      // Dépenses
      final depenses = await _db.getDepenses();
      if (depenses.isNotEmpty) {
        await _sb.from('depenses').upsert(
          depenses.map(_depToRow).toList(),
          onConflict: 'id',
        );
        pushed += depenses.length;
      }

      // Revenus
      final revenus = await _db.getRevenus();
      if (revenus.isNotEmpty) {
        await _sb.from('revenus').upsert(
          revenus.map(_revToRow).toList(),
          onConflict: 'id',
        );
        pushed += revenus.length;
      }

      // Récoltes
      final recoltes = await _db.getRecoltes();
      if (recoltes.isNotEmpty) {
        await _sb.from('recoltes').upsert(
          recoltes.map(_recolteToRow).toList(),
          onConflict: 'id',
        );
        pushed += recoltes.length;
      }

      // Triturations
      final triturations = await _db.getTriturations();
      if (triturations.isNotEmpty) {
        await _sb.from('triturations').upsert(
          triturations.map(_tritToRow).toList(),
          onConflict: 'id',
        );
        pushed += triturations.length;
      }

      // Travailleurs
      final sessions = await _db.getTravailleurSessions();
      if (sessions.isNotEmpty) {
        await _sb.from('travailleur_sessions').upsert(
          sessions.map(_sessionToRow).toList(),
          onConflict: 'id',
        );
        pushed += sessions.length;
      }

      // Récurrents
      final recurrents = await _db.getRecurringExpenses();
      if (recurrents.isNotEmpty) {
        await _sb.from('recurring_expenses').upsert(
          recurrents.map(_recurToRow).toList(),
          onConflict: 'id',
        );
        pushed += recurrents.length;
      }

      // Catégories
      final cats = await _db.getAllCategories();
      if (cats.isNotEmpty) {
        await _sb.from('categories').upsert(
          cats.map(_catToRow).toList(),
          onConflict: 'id',
        );
        pushed += cats.length;
      }

      return SyncResult(
        success: true,
        message: '$pushed enregistrements envoyés vers Supabase',
        pushed: pushed,
      );
    } catch (e) {
      return SyncResult(success: false, message: 'Erreur upload: $e');
    } finally {
      _syncing = false;
    }
  }

  // ── Pull all data from Supabase → local SQLite ───────────────────────────────

  Future<SyncResult> pullAll() async {
    if (_syncing) {
      return const SyncResult(success: false, message: 'Synchronisation déjà en cours');
    }
    _syncing = true;
    int pulled = 0;

    try {
      // Mouvements
      final mvtRows = await _sb.from('mouvements').select();
      for (final row in mvtRows) {
        await _db.upsertMouvement(Mouvement.fromMap(_rowToMvt(row)));
        pulled++;
      }

      // Dépenses
      final depRows = await _sb.from('depenses').select();
      for (final row in depRows) {
        await _db.upsertDepense(Depense.fromMap(_rowToDep(row)));
        pulled++;
      }

      // Revenus
      final revRows = await _sb.from('revenus').select();
      for (final row in revRows) {
        await _db.upsertRevenu(Revenu.fromMap(_rowToRev(row)));
        pulled++;
      }

      // Récoltes
      final recolteRows = await _sb.from('recoltes').select();
      for (final row in recolteRows) {
        await _db.upsertRecolte(Recolte.fromMap(_rowToRecolte(row)));
        pulled++;
      }

      // Triturations
      final tritRows = await _sb.from('triturations').select();
      for (final row in tritRows) {
        await _db.upsertTrituration(Trituration.fromMap(_rowToTrit(row)));
        pulled++;
      }

      // Travailleurs
      final sessionRows = await _sb.from('travailleur_sessions').select();
      for (final row in sessionRows) {
        await _db.upsertTravailleurSession(TravailleurSession.fromMap(_rowToSession(row)));
        pulled++;
      }

      // Récurrents
      final recurRows = await _sb.from('recurring_expenses').select();
      for (final row in recurRows) {
        await _db.upsertRecurringExpense(RecurringExpense.fromMap(_rowToRecur(row)));
        pulled++;
      }

      // Catégories
      final catRows = await _sb.from('categories').select();
      for (final row in catRows) {
        await _db.upsertCategory(AppCategory.fromMap(_rowToCat(row)));
        pulled++;
      }

      return SyncResult(
        success: true,
        message: '$pulled enregistrements récupérés depuis Supabase',
        pulled: pulled,
      );
    } catch (e) {
      return SyncResult(success: false, message: 'Erreur download: $e');
    } finally {
      _syncing = false;
    }
  }

  // ── Full sync: push then pull ────────────────────────────────────────────────

  Future<SyncResult> syncAll() async {
    final push = await pushAll();
    if (!push.success) return push;
    return SyncResult(
      success: true,
      message: 'Sync terminée · ${push.pushed} envoyés',
      pushed: push.pushed,
    );
  }

  // ── Row mappers: local → Supabase ────────────────────────────────────────────

  Map<String, dynamic> _mvtToRow(Mouvement m) => {
        'id': m.id,
        'type': m.type,
        'qte': m.qte,
        'date': m.date.toIso8601String().split('T').first,
        'remarque': m.remarque,
        'ferme_id': m.fermeId,
        'updated_at': DateTime.now().toIso8601String(),
      };

  Map<String, dynamic> _depToRow(Depense d) => {
        'id': d.id,
        'montant': d.montant,
        'date': d.date.toIso8601String().split('T').first,
        'categorie': d.categorie,
        'remarque': d.remarque,
        'ferme_id': d.fermeId,
        'updated_at': DateTime.now().toIso8601String(),
      };

  Map<String, dynamic> _revToRow(Revenu r) => {
        'id': r.id,
        'montant': r.montant,
        'date': r.date.toIso8601String().split('T').first,
        'categorie': r.categorie,
        'remarque': r.remarque,
        'ferme_id': r.fermeId,
        'updated_at': DateTime.now().toIso8601String(),
      };

  Map<String, dynamic> _recolteToRow(Recolte r) => {
        'id': r.id,
        'ferme_id': r.fermeId,
        'culture': r.culture,
        'saison': r.saison,
        'quantite': r.quantite,
        'unite': r.unite,
        'quantite_vente': r.quantiteVente,
        'quantite_interne': r.quantiteInterne,
        'date': r.date.toIso8601String().split('T').first,
        'remarque': r.remarque,
        'updated_at': DateTime.now().toIso8601String(),
      };

  Map<String, dynamic> _tritToRow(Trituration t) => {
        'id': t.id,
        'ferme_id': t.fermeId,
        'saison': t.saison,
        'kg_olives': t.kgOlives,
        'litres_huile': t.litresHuile,
        'cout_trituration': t.coutTrituration,
        'litres_vente': t.litresVente,
        'litres_famille': t.litresFamille,
        'litres_heritiers': t.litresHeritiers,
        'prix_vente_litre': t.prixVenteLitre,
        'date': t.date.toIso8601String().split('T').first,
        'remarque': t.remarque,
        'updated_at': DateTime.now().toIso8601String(),
      };

  Map<String, dynamic> _sessionToRow(TravailleurSession s) => {
        'id': s.id,
        'ferme_id': s.fermeId,
        'nom': s.nom,
        'nb_jours': s.nbJours,
        'salaire_journalier': s.salaireJournalier,
        'date': s.date.toIso8601String().split('T').first,
        'remarque': s.remarque,
        'updated_at': DateTime.now().toIso8601String(),
      };

  Map<String, dynamic> _recurToRow(RecurringExpense r) => {
        'id': r.id,
        'label': r.label,
        'montant': r.montant,
        'ferme_id': r.fermeId,
        'actif': r.actif ? 1 : 0,
        'created_at': r.createdAt.toIso8601String(),
        'last_paid_at': r.lastPaidAt?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

  Map<String, dynamic> _catToRow(AppCategory c) => {
        'id': c.id,
        'type': c.type,
        'label': c.label,
        'ordre': c.ordre,
        'updated_at': DateTime.now().toIso8601String(),
      };

  // ── Row mappers: Supabase → local ────────────────────────────────────────────

  Map<String, dynamic> _rowToMvt(Map<String, dynamic> r) => {
        'id': r['id'],
        'type': r['type'],
        'qte': r['qte'],
        'date': r['date'],
        'remarque': r['remarque'] ?? '',
        'fermeId': r['ferme_id'] ?? 'rhamna',
      };

  Map<String, dynamic> _rowToDep(Map<String, dynamic> r) => {
        'id': r['id'],
        'montant': r['montant'],
        'date': r['date'],
        'categorie': r['categorie'] ?? '',
        'remarque': r['remarque'] ?? '',
        'fermeId': r['ferme_id'] ?? 'rhamna',
      };

  Map<String, dynamic> _rowToRev(Map<String, dynamic> r) => {
        'id': r['id'],
        'montant': r['montant'],
        'date': r['date'],
        'categorie': r['categorie'] ?? '',
        'remarque': r['remarque'] ?? '',
        'fermeId': r['ferme_id'] ?? 'rhamna',
      };

  Map<String, dynamic> _rowToRecolte(Map<String, dynamic> r) => {
        'id': r['id'],
        'fermeId': r['ferme_id'] ?? 'rhamna',
        'culture': r['culture'],
        'saison': r['saison'],
        'quantite': r['quantite'],
        'unite': r['unite'] ?? 'kg',
        'quantiteVente': r['quantite_vente'] ?? 0,
        'quantiteInterne': r['quantite_interne'] ?? 0,
        'date': r['date'],
        'remarque': r['remarque'] ?? '',
      };

  Map<String, dynamic> _rowToTrit(Map<String, dynamic> r) => {
        'id': r['id'],
        'fermeId': r['ferme_id'] ?? 'rhamna',
        'saison': r['saison'],
        'kgOlives': r['kg_olives'],
        'litresHuile': r['litres_huile'],
        'coutTrituration': r['cout_trituration'] ?? 0,
        'litresVente': r['litres_vente'] ?? 0,
        'litresFamille': r['litres_famille'] ?? 0,
        'litresHeritiers': r['litres_heritiers'] ?? 0,
        'prixVenteLitre': r['prix_vente_litre'] ?? 0,
        'date': r['date'],
        'remarque': r['remarque'] ?? '',
      };

  Map<String, dynamic> _rowToSession(Map<String, dynamic> r) => {
        'id': r['id'],
        'fermeId': r['ferme_id'] ?? 'rhamna',
        'nom': r['nom'],
        'nbJours': r['nb_jours'],
        'salaireJournalier': r['salaire_journalier'],
        'date': r['date'],
        'remarque': r['remarque'] ?? '',
      };

  Map<String, dynamic> _rowToRecur(Map<String, dynamic> r) => {
        'id': r['id'],
        'label': r['label'],
        'montant': r['montant'],
        'fermeId': r['ferme_id'] ?? 'rhamna',
        'actif': r['actif'] ?? 1,
        'createdAt': r['created_at'] ?? DateTime.now().toIso8601String(),
        'lastPaidAt': r['last_paid_at'],
      };

  Map<String, dynamic> _rowToCat(Map<String, dynamic> r) => {
        'id': r['id'],
        'type': r['type'],
        'label': r['label'],
        'ordre': r['ordre'] ?? 0,
      };
}
