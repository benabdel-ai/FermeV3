import 'package:uuid/uuid.dart';

const _uuid = Uuid();

const Map<String, String> fermeNames = {
  'rhamna': 'Ferme Rhamna',
  'srahna': 'Ferme Srahna',
};

const List<String> cultureTypes = [
  'Olives',
  "Huile d'olive",
  'Citrons',
  'Figues',
  'Fruits divers',
  'Luzerne',
  'Autre',
];

const Map<String, String> cultureEmojis = {
  'Olives': '🫒',
  "Huile d'olive": '🫙',
  'Citrons': '🍋',
  'Figues': '🍑',
  'Fruits divers': '🍎',
  'Luzerne': '🌿',
  'Autre': '🌱',
};

const Map<String, String> cultureUnites = {
  'Olives': 'kg',
  "Huile d'olive": 'litres',
  'Citrons': 'kg',
  'Figues': 'kg',
  'Fruits divers': 'kg',
  'Luzerne': 'kg',
  'Autre': 'kg',
};

// ─── Récolte ─────────────────────────────────────────────────────────────────

class Recolte {
  final String id;
  final String fermeId;
  final String culture;
  final int saison;
  final double quantite;
  final String unite;
  final double quantiteVente;
  final double quantiteInterne;
  final DateTime date;
  final String remarque;

  // Trituration / moulin fields (merged)
  final double coutOuvriers;
  final double coutTransport;
  final double coutMoulin;
  final double litresHuile;
  final double litresVente;
  final double litresFamille;
  final double litresHeritiers;
  final double prixVenteLitre;
  final double prixVenteKg;
  final double diversMontant;
  final String diversRemarque;

  // Caissons fields
  final double nbCaissons;
  final double prixCaisson;

  Recolte({
    String? id,
    required this.fermeId,
    required this.culture,
    required this.saison,
    required this.quantite,
    this.unite = 'kg',
    this.quantiteVente = 0,
    this.quantiteInterne = 0,
    required this.date,
    this.remarque = '',
    this.coutOuvriers = 0,
    this.coutTransport = 0,
    this.coutMoulin = 0,
    this.litresHuile = 0,
    this.litresVente = 0,
    this.litresFamille = 0,
    this.litresHeritiers = 0,
    this.prixVenteLitre = 0,
    this.prixVenteKg = 0,
    this.diversMontant = 0,
    this.diversRemarque = '',
    this.nbCaissons = 0,
    this.prixCaisson = 0,
  }) : id = id ?? _uuid.v4();

  // Computed getters
  double get rendementPct => quantite > 0 ? (litresHuile / quantite * 100) : 0;
  double get coutCaissons => nbCaissons * prixCaisson;
  double get coutTotal => coutOuvriers + coutTransport + coutMoulin + diversMontant + coutCaissons;
  double get revenuHuile => litresVente * prixVenteLitre;
  double get revenuOlive => quantiteVente * prixVenteKg;
  double get bilanRecolte => revenuHuile + revenuOlive - coutTotal;

  Map<String, dynamic> toMap() => {
        'id': id,
        'fermeId': fermeId,
        'culture': culture,
        'saison': saison,
        'quantite': quantite,
        'unite': unite,
        'quantiteVente': quantiteVente,
        'quantiteInterne': quantiteInterne,
        'date': date.toIso8601String().split('T').first,
        'remarque': remarque,
        'coutOuvriers': coutOuvriers,
        'coutTransport': coutTransport,
        'coutMoulin': coutMoulin,
        'litresHuile': litresHuile,
        'litresVente': litresVente,
        'litresFamille': litresFamille,
        'litresHeritiers': litresHeritiers,
        'prixVenteLitre': prixVenteLitre,
        'prixVenteKg': prixVenteKg,
        'diversMontant': diversMontant,
        'diversRemarque': diversRemarque,
        'nbCaissons': nbCaissons,
        'prixCaisson': prixCaisson,
      };

  factory Recolte.fromMap(Map<String, dynamic> map) => Recolte(
        id: map['id'] as String,
        fermeId: (map['fermeId'] ?? 'rhamna') as String,
        culture: map['culture'] as String,
        saison: map['saison'] as int,
        quantite: (map['quantite'] as num).toDouble(),
        unite: (map['unite'] ?? 'kg') as String,
        quantiteVente: (map['quantiteVente'] as num? ?? 0).toDouble(),
        quantiteInterne: (map['quantiteInterne'] as num? ?? 0).toDouble(),
        date: DateTime.parse(map['date'] as String),
        remarque: (map['remarque'] ?? '') as String,
        coutOuvriers: (map['coutOuvriers'] as num? ?? 0).toDouble(),
        coutTransport: (map['coutTransport'] as num? ?? 0).toDouble(),
        coutMoulin: (map['coutMoulin'] as num? ?? 0).toDouble(),
        litresHuile: (map['litresHuile'] as num? ?? 0).toDouble(),
        litresVente: (map['litresVente'] as num? ?? 0).toDouble(),
        litresFamille: (map['litresFamille'] as num? ?? 0).toDouble(),
        litresHeritiers: (map['litresHeritiers'] as num? ?? 0).toDouble(),
        prixVenteLitre: (map['prixVenteLitre'] as num? ?? 0).toDouble(),
        prixVenteKg: (map['prixVenteKg'] as num? ?? 0).toDouble(),
        diversMontant: (map['diversMontant'] as num? ?? 0).toDouble(),
        diversRemarque: (map['diversRemarque'] ?? '') as String,
        nbCaissons: (map['nbCaissons'] as num? ?? 0).toDouble(),
        prixCaisson: (map['prixCaisson'] as num? ?? 0).toDouble(),
      );

  Recolte copyWith({
    String? fermeId,
    String? culture,
    int? saison,
    double? quantite,
    String? unite,
    double? quantiteVente,
    double? quantiteInterne,
    DateTime? date,
    String? remarque,
    double? coutOuvriers,
    double? coutTransport,
    double? coutMoulin,
    double? litresHuile,
    double? litresVente,
    double? litresFamille,
    double? litresHeritiers,
    double? prixVenteLitre,
    double? prixVenteKg,
    double? diversMontant,
    String? diversRemarque,
    double? nbCaissons,
    double? prixCaisson,
  }) =>
      Recolte(
        id: id,
        fermeId: fermeId ?? this.fermeId,
        culture: culture ?? this.culture,
        saison: saison ?? this.saison,
        quantite: quantite ?? this.quantite,
        unite: unite ?? this.unite,
        quantiteVente: quantiteVente ?? this.quantiteVente,
        quantiteInterne: quantiteInterne ?? this.quantiteInterne,
        date: date ?? this.date,
        remarque: remarque ?? this.remarque,
        coutOuvriers: coutOuvriers ?? this.coutOuvriers,
        coutTransport: coutTransport ?? this.coutTransport,
        coutMoulin: coutMoulin ?? this.coutMoulin,
        litresHuile: litresHuile ?? this.litresHuile,
        litresVente: litresVente ?? this.litresVente,
        litresFamille: litresFamille ?? this.litresFamille,
        litresHeritiers: litresHeritiers ?? this.litresHeritiers,
        prixVenteLitre: prixVenteLitre ?? this.prixVenteLitre,
        prixVenteKg: prixVenteKg ?? this.prixVenteKg,
        diversMontant: diversMontant ?? this.diversMontant,
        diversRemarque: diversRemarque ?? this.diversRemarque,
        nbCaissons: nbCaissons ?? this.nbCaissons,
        prixCaisson: prixCaisson ?? this.prixCaisson,
      );
}

// ─── Trituration ─────────────────────────────────────────────────────────────

class Trituration {
  final String id;
  final String fermeId;
  final int saison;
  final double kgOlives;
  final double litresHuile;
  final double coutTrituration;
  final double litresVente;
  final double litresFamille;
  final double litresHeritiers;
  final double prixVenteLitre;
  final DateTime date;
  final String remarque;

  Trituration({
    String? id,
    required this.fermeId,
    required this.saison,
    required this.kgOlives,
    required this.litresHuile,
    this.coutTrituration = 0,
    this.litresVente = 0,
    this.litresFamille = 0,
    this.litresHeritiers = 0,
    this.prixVenteLitre = 0,
    required this.date,
    this.remarque = '',
  }) : id = id ?? _uuid.v4();

  double get rendementPct => kgOlives > 0 ? (litresHuile / kgOlives * 100) : 0;
  double get revenusVente => litresVente * prixVenteLitre;
  double get litresTotal => litresVente + litresFamille + litresHeritiers;

  Map<String, dynamic> toMap() => {
        'id': id,
        'fermeId': fermeId,
        'saison': saison,
        'kgOlives': kgOlives,
        'litresHuile': litresHuile,
        'coutTrituration': coutTrituration,
        'litresVente': litresVente,
        'litresFamille': litresFamille,
        'litresHeritiers': litresHeritiers,
        'prixVenteLitre': prixVenteLitre,
        'date': date.toIso8601String().split('T').first,
        'remarque': remarque,
      };

  factory Trituration.fromMap(Map<String, dynamic> map) => Trituration(
        id: map['id'] as String,
        fermeId: (map['fermeId'] ?? 'rhamna') as String,
        saison: map['saison'] as int,
        kgOlives: (map['kgOlives'] as num).toDouble(),
        litresHuile: (map['litresHuile'] as num).toDouble(),
        coutTrituration: (map['coutTrituration'] as num? ?? 0).toDouble(),
        litresVente: (map['litresVente'] as num? ?? 0).toDouble(),
        litresFamille: (map['litresFamille'] as num? ?? 0).toDouble(),
        litresHeritiers: (map['litresHeritiers'] as num? ?? 0).toDouble(),
        prixVenteLitre: (map['prixVenteLitre'] as num? ?? 0).toDouble(),
        date: DateTime.parse(map['date'] as String),
        remarque: (map['remarque'] ?? '') as String,
      );

  Trituration copyWith({String? fermeId, int? saison, double? kgOlives, double? litresHuile, double? coutTrituration, double? litresVente, double? litresFamille, double? litresHeritiers, double? prixVenteLitre, DateTime? date, String? remarque}) =>
      Trituration(id: id, fermeId: fermeId ?? this.fermeId, saison: saison ?? this.saison, kgOlives: kgOlives ?? this.kgOlives, litresHuile: litresHuile ?? this.litresHuile, coutTrituration: coutTrituration ?? this.coutTrituration, litresVente: litresVente ?? this.litresVente, litresFamille: litresFamille ?? this.litresFamille, litresHeritiers: litresHeritiers ?? this.litresHeritiers, prixVenteLitre: prixVenteLitre ?? this.prixVenteLitre, date: date ?? this.date, remarque: remarque ?? this.remarque);
}

// ─── TravailleurSession ───────────────────────────────────────────────────────

class TravailleurSession {
  final String id;
  final String fermeId;
  final String nom;
  final double nbJours;
  final double salaireJournalier;
  final DateTime date;
  final String remarque;
  final String activite;

  TravailleurSession({
    String? id,
    required this.fermeId,
    required this.nom,
    required this.nbJours,
    required this.salaireJournalier,
    required this.date,
    this.remarque = '',
    this.activite = 'general',
  }) : id = id ?? _uuid.v4();

  double get total => nbJours * salaireJournalier;

  Map<String, dynamic> toMap() => {
        'id': id,
        'fermeId': fermeId,
        'nom': nom,
        'nbJours': nbJours,
        'salaireJournalier': salaireJournalier,
        'date': date.toIso8601String().split('T').first,
        'remarque': remarque,
        'activite': activite,
      };

  factory TravailleurSession.fromMap(Map<String, dynamic> map) =>
      TravailleurSession(
        id: map['id'] as String,
        fermeId: (map['fermeId'] ?? 'rhamna') as String,
        nom: map['nom'] as String,
        nbJours: (map['nbJours'] as num).toDouble(),
        salaireJournalier: (map['salaireJournalier'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        remarque: (map['remarque'] ?? '') as String,
        activite: (map['activite'] ?? 'general') as String,
      );

  TravailleurSession copyWith({
    String? fermeId,
    String? nom,
    double? nbJours,
    double? salaireJournalier,
    DateTime? date,
    String? remarque,
    String? activite,
  }) =>
      TravailleurSession(
        id: id,
        fermeId: fermeId ?? this.fermeId,
        nom: nom ?? this.nom,
        nbJours: nbJours ?? this.nbJours,
        salaireJournalier: salaireJournalier ?? this.salaireJournalier,
        date: date ?? this.date,
        remarque: remarque ?? this.remarque,
        activite: activite ?? this.activite,
      );
}

// ─── CheptelDepense ───────────────────────────────────────────────────────────

class CheptelDepense {
  final String id;
  final String fermeId;
  /// 'alimentation' | 'veterinaire' | 'berger' | 'materiel' | 'autre'
  final String categorie;
  final String sousCategorie;
  final double montant;
  final double quantite; // pour alimentation
  final String unite;    // kg, bottes, sacs...
  final DateTime date;
  final String remarque;

  CheptelDepense({
    String? id,
    required this.fermeId,
    required this.categorie,
    required this.sousCategorie,
    required this.montant,
    this.quantite = 0,
    this.unite = '',
    required this.date,
    this.remarque = '',
  }) : id = id ?? _uuid.v4();

  double get prixUnitaire => quantite > 0 ? montant / quantite : 0;

  Map<String, dynamic> toMap() => {
        'id': id,
        'fermeId': fermeId,
        'categorie': categorie,
        'sousCategorie': sousCategorie,
        'montant': montant,
        'quantite': quantite,
        'unite': unite,
        'date': date.toIso8601String().split('T').first,
        'remarque': remarque,
      };

  factory CheptelDepense.fromMap(Map<String, dynamic> map) => CheptelDepense(
        id: map['id'] as String,
        fermeId: (map['fermeId'] ?? 'rhamna') as String,
        categorie: map['categorie'] as String,
        sousCategorie: (map['sousCategorie'] ?? '') as String,
        montant: (map['montant'] as num).toDouble(),
        quantite: (map['quantite'] as num? ?? 0).toDouble(),
        unite: (map['unite'] ?? '') as String,
        date: DateTime.parse(map['date'] as String),
        remarque: (map['remarque'] ?? '') as String,
      );
}

// ─── RecurringExpense ─────────────────────────────────────────────────────────

class RecurringExpense {
  final String id;
  final String label;
  final double montant;
  final String fermeId;
  final bool actif;
  final DateTime createdAt;
  final DateTime? lastPaidAt;

  RecurringExpense({
    String? id,
    required this.label,
    required this.montant,
    required this.fermeId,
    this.actif = true,
    DateTime? createdAt,
    this.lastPaidAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  bool get isDueThisWeek {
    if (!actif) return false;
    if (lastPaidAt == null) return true;
    return DateTime.now().difference(lastPaidAt!).inDays >= 7;
  }

  RecurringExpense copyWith({
    String? label,
    double? montant,
    String? fermeId,
    bool? actif,
    DateTime? lastPaidAt,
  }) =>
      RecurringExpense(
        id: id,
        label: label ?? this.label,
        montant: montant ?? this.montant,
        fermeId: fermeId ?? this.fermeId,
        actif: actif ?? this.actif,
        createdAt: createdAt,
        lastPaidAt: lastPaidAt ?? this.lastPaidAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'montant': montant,
        'fermeId': fermeId,
        'actif': actif ? 1 : 0,
        'createdAt': createdAt.toIso8601String(),
        'lastPaidAt': lastPaidAt?.toIso8601String(),
      };

  factory RecurringExpense.fromMap(Map<String, dynamic> map) => RecurringExpense(
        id: map['id'] as String,
        label: map['label'] as String,
        montant: (map['montant'] as num).toDouble(),
        fermeId: (map['fermeId'] ?? 'rhamna') as String,
        actif: (map['actif'] as int? ?? 1) == 1,
        createdAt: DateTime.parse(map['createdAt'] as String),
        lastPaidAt: map['lastPaidAt'] != null &&
                (map['lastPaidAt'] as String).isNotEmpty
            ? DateTime.parse(map['lastPaidAt'] as String)
            : null,
      );
}

// ─── AppCategory ──────────────────────────────────────────────────────────────

class AppCategory {
  final String id;
  final String type; // 'depense' | 'revenu' | 'culture'
  final String label;
  final int ordre;

  AppCategory({String? id, required this.type, required this.label, this.ordre = 0}) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => {'id': id, 'type': type, 'label': label, 'ordre': ordre};

  factory AppCategory.fromMap(Map<String, dynamic> map) => AppCategory(
        id: map['id'] as String,
        type: map['type'] as String,
        label: map['label'] as String,
        ordre: (map['ordre'] as int? ?? 0),
      );
}
