import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ferme_models.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme.dart';

Future<void> showMvtForm(BuildContext context, {String? initialType}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _MvtForm(initialType: initialType),
  );
}

class _MvtForm extends StatefulWidget {
  const _MvtForm({this.initialType});

  final String? initialType;

  @override
  State<_MvtForm> createState() => _MvtFormState();
}

class _MvtFormState extends State<_MvtForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _type;
  int _qte = 1;
  DateTime _date = DateTime.now();
  String _rem = '';
  String _fermeId = 'rhamna';

  // Extra fields by type
  double _prixUnitaire = 0;
  double _poids = 0;
  String _acheteur = '';
  String _fournisseur = '';
  String _cause = '';
  String _mere = '';

  static const List<(String, String)> _types = <(String, String)>[
    ('naissance_agf', '🍼 Naissance Agneau ♀'),
    ('naissance_agm', '🐣 Naissance Agneau ♂'),
    ('achat_femelle', '🛒 Achat Femelle'),
    ('achat_male', '🛒 Achat Mâle'),
    ('vente_femelle', '🤝 Vente Femelle'),
    ('vente_male', '🤝 Vente Mâle'),
    ('deces_femelle', '💀 Décès Femelle'),
    ('deces_male', '💀 Décès Mâle'),
    ('passage_agf', '🔄 Passage Agneau ♀ → Femelle'),
    ('passage_agm', '🔄 Passage Agneau ♂ → Mâle'),
    ('init_femelles', '⚙️ Stock initial Femelles'),
    ('init_males', '⚙️ Stock initial Mâles'),
    ('init_agf', '⚙️ Stock initial Agneaux ♀'),
    ('init_agm', '⚙️ Stock initial Agneaux ♂'),
  ];

  bool get _isVente => _type.startsWith('vente');
  bool get _isAchat => _type.startsWith('achat');
  bool get _isDeces => _type.startsWith('deces');
  bool get _isNaissance => _type.startsWith('naissance');

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? 'naissance_agf';
    final filter = context.read<AppProvider>().fermeFilter;
    _fermeId = filter == 'all' ? 'rhamna' : filter;
  }

  double _parseD(String? v) => double.tryParse((v ?? '').replaceAll(',', '.')) ?? 0;

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      title: '🐑 Mouvement troupeau',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _label('Ferme'),
            _FermeSelector(value: _fermeId, onChanged: (v) => setState(() => _fermeId = v)),
            const SizedBox(height: 14),
            _label('Type de mouvement'),
            _dropdown<String>(
              _types
                  .map((entry) => DropdownMenuItem<String>(value: entry.$1, child: Text(entry.$2)))
                  .toList(),
              _type,
              (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Quantité (têtes)'),
                      TextFormField(
                        initialValue: '1',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(prefixText: '× '),
                        validator: (value) {
                          final parsed = int.tryParse(value ?? '');
                          if (parsed == null || parsed < 1) return 'Invalide';
                          return null;
                        },
                        onSaved: (value) => _qte = int.tryParse(value ?? '') ?? 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(label: 'Date', value: _date, onChanged: (d) => setState(() => _date = d)),
                ),
              ],
            ),

            // ── Vente fields ──
            if (_isVente) ...<Widget>[
              const _SectionHeader('🤝 Détails de la vente'),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _label('Prix unitaire (MAD)'),
                        TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(suffixText: 'MAD'),
                          onChanged: (v) => setState(() => _prixUnitaire = _parseD(v)),
                          onSaved: (v) => _prixUnitaire = _parseD(v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _label('Poids total (kg)'),
                        TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(suffixText: 'kg'),
                          onSaved: (v) => _poids = _parseD(v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _label('Acheteur'),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Nom de l\'acheteur (opt.)'),
                onSaved: (v) => _acheteur = v?.trim() ?? '',
              ),
              if (_prixUnitaire > 0 && _qte > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '💰 Total vente : ${(_prixUnitaire * _qte).toStringAsFixed(0)} MAD',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.green2),
                  ),
                ),
            ],

            // ── Achat fields ──
            if (_isAchat) ...<Widget>[
              const _SectionHeader('🛒 Détails de l\'achat'),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _label('Prix unitaire (MAD)'),
                        TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(suffixText: 'MAD'),
                          onChanged: (v) => setState(() => _prixUnitaire = _parseD(v)),
                          onSaved: (v) => _prixUnitaire = _parseD(v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _label('Poids total (kg)'),
                        TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(suffixText: 'kg'),
                          onSaved: (v) => _poids = _parseD(v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _label('Fournisseur'),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Nom du fournisseur (opt.)'),
                onSaved: (v) => _fournisseur = v?.trim() ?? '',
              ),
              if (_prixUnitaire > 0 && _qte > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '💸 Total achat : ${(_prixUnitaire * _qte).toStringAsFixed(0)} MAD',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.orange),
                  ),
                ),
            ],

            // ── Décès fields ──
            if (_isDeces) ...<Widget>[
              const _SectionHeader('💀 Cause du décès'),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Maladie, accident, autre...'),
                onSaved: (v) => _cause = v?.trim() ?? '',
              ),
            ],

            // ── Naissance fields ──
            if (_isNaissance) ...<Widget>[
              const _SectionHeader('🍼 Détails naissance'),
              _label('Mère (opt.)'),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Identification ou nom de la mère'),
                onSaved: (v) => _mere = v?.trim() ?? '',
              ),
            ],

            const SizedBox(height: 14),
            _label('Remarque'),
            TextFormField(
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Observation optionnelle'),
              onSaved: (value) => _rem = value ?? '',
            ),
            const SizedBox(height: 20),
            _submitBtn(
              label: 'Enregistrer le mouvement',
              color: AppColors.green2,
              onTap: _save,
            ),
            const SizedBox(height: 8),
            _cancelBtn(context),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    await context.read<AppProvider>().addMouvement(
          Mouvement(
            type: _type,
            qte: _qte,
            date: _date,
            remarque: _rem,
            fermeId: _fermeId,
            prixUnitaire: _prixUnitaire,
            poids: _poids,
            acheteur: _acheteur,
            fournisseur: _fournisseur,
            cause: _cause,
            mere: _mere,
          ),
        );

    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mouvement enregistré'),
        backgroundColor: AppColors.green2,
      ),
    );
  }
}

Future<void> showDepForm(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _DepForm(),
  );
}

class _DepForm extends StatefulWidget {
  const _DepForm();

  @override
  State<_DepForm> createState() => _DepFormState();
}

class _DepFormState extends State<_DepForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double _montant = 0;
  DateTime _date = DateTime.now();
  String _categorie = '';
  String _rem = '';
  String _fermeId = 'rhamna';

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    final filter = provider.fermeFilter;
    _fermeId = filter == 'all' ? 'rhamna' : filter;
    final cats = provider.depCatLabels;
    if (cats.isNotEmpty) _categorie = cats.first;
  }

  @override
  Widget build(BuildContext context) {
    final cats = context.watch<AppProvider>().depCatLabels;
    if (_categorie.isEmpty && cats.isNotEmpty) _categorie = cats.first;
    return _Sheet(
      title: '💸 Ajouter une dépense',
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _label('Ferme'),
            _FermeSelector(
              value: _fermeId,
              onChanged: (v) => setState(() => _fermeId = v),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Montant (MAD)'),
                      TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(suffixText: 'MAD'),
                        validator: (value) {
                          final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
                          if (parsed == null || parsed <= 0) {
                            return 'Montant invalide';
                          }
                          return null;
                        },
                        onSaved: (value) => _montant =
                            double.tryParse((value ?? '').replaceAll(',', '.')) ?? 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Date',
                    value: _date,
                    onChanged: (date) => setState(() => _date = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _label('Catégorie'),
            _dropdown<String>(
              cats.map((cat) => DropdownMenuItem<String>(value: cat, child: Text(cat))).toList(),
              cats.contains(_categorie) ? _categorie : (cats.isNotEmpty ? cats.first : _categorie),
              (value) => setState(() => _categorie = value ?? _categorie),
            ),
            const SizedBox(height: 14),
            _label('Remarque'),
            TextFormField(
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Détail optionnel'),
              onSaved: (value) => _rem = value ?? '',
            ),
            const SizedBox(height: 20),
            _submitBtn(
              label: 'Enregistrer la dépense',
              color: AppColors.red2,
              onTap: _save,
            ),
            const SizedBox(height: 8),
            _cancelBtn(context),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    await context.read<AppProvider>().addDepense(
          Depense(
            montant: _montant,
            date: _date,
            categorie: _categorie,
            remarque: _rem,
            fermeId: _fermeId,
          ),
        );

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dépense enregistrée'),
        backgroundColor: AppColors.green2,
      ),
    );
  }
}

Future<void> showRevForm(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RevForm(),
  );
}

class _RevForm extends StatefulWidget {
  const _RevForm();

  @override
  State<_RevForm> createState() => _RevFormState();
}

class _RevFormState extends State<_RevForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double _montant = 0;
  DateTime _date = DateTime.now();
  String _categorie = '';
  String _rem = '';
  String _fermeId = 'rhamna';

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    final filter = provider.fermeFilter;
    _fermeId = filter == 'all' ? 'rhamna' : filter;
    final cats = provider.revCatLabels;
    if (cats.isNotEmpty) _categorie = cats.first;
  }

  @override
  Widget build(BuildContext context) {
    final cats = context.watch<AppProvider>().revCatLabels;
    if (_categorie.isEmpty && cats.isNotEmpty) _categorie = cats.first;
    return _Sheet(
      title: '💰 Ajouter un revenu',
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _label('Ferme'),
            _FermeSelector(
              value: _fermeId,
              onChanged: (v) => setState(() => _fermeId = v),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Montant (MAD)'),
                      TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(suffixText: 'MAD'),
                        validator: (value) {
                          final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
                          if (parsed == null || parsed <= 0) {
                            return 'Montant invalide';
                          }
                          return null;
                        },
                        onSaved: (value) => _montant =
                            double.tryParse((value ?? '').replaceAll(',', '.')) ?? 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Date',
                    value: _date,
                    onChanged: (date) => setState(() => _date = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _label('Catégorie'),
            _dropdown<String>(
              cats.map((cat) => DropdownMenuItem<String>(value: cat, child: Text(cat))).toList(),
              cats.contains(_categorie) ? _categorie : (cats.isNotEmpty ? cats.first : _categorie),
              (value) => setState(() => _categorie = value ?? _categorie),
            ),
            const SizedBox(height: 14),
            _label('Remarque'),
            TextFormField(
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Détail optionnel'),
              onSaved: (value) => _rem = value ?? '',
            ),
            const SizedBox(height: 20),
            _submitBtn(
              label: 'Enregistrer le revenu',
              color: AppColors.green2,
              onTap: _save,
            ),
            const SizedBox(height: 8),
            _cancelBtn(context),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    await context.read<AppProvider>().addRevenu(
          Revenu(
            montant: _montant,
            date: _date,
            categorie: _categorie,
            remarque: _rem,
            fermeId: _fermeId,
          ),
        );

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Revenu enregistré'),
        backgroundColor: AppColors.green2,
      ),
    );
  }
}

// ─── Activity Picker ──────────────────────────────────────────────────────────

Future<void> showActivityPicker(BuildContext context, String actionType) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _ActivityPicker(actionType: actionType, parentContext: context),
  );
}

class _ActivityPicker extends StatelessWidget {
  const _ActivityPicker({required this.actionType, required this.parentContext});
  final String actionType;
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    final isDepense = actionType == 'depense';
    final title = isDepense ? '💸 Ajouter une dépense' : '💰 Ajouter un revenu';
    final items = isDepense ? _depenseItems(parentContext) : _revenuItems(parentContext);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(20)),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.green2)),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.8,
              children: items,
            ),
            const SizedBox(height: 8),
            _cancelBtn(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _depenseItems(BuildContext ctx) => [
        _actBtn(ctx, '🫒', 'Récolte', () => showRecolteForm(ctx)),
        _actBtn(ctx, '🐑', 'Élevage', () => showMvtForm(ctx)),
        _actBtn(ctx, '🌿', 'Cultures', () => showDepForm(ctx)),
        _actBtn(ctx, '👷', 'Équipe', () => showTravailleurForm(ctx)),
        _actBtn(ctx, '💼', 'Autre', () => showDepForm(ctx)),
      ];

  List<Widget> _revenuItems(BuildContext ctx) => [
        _actBtn(ctx, '🫒', 'Récolte', () => showRecolteForm(ctx)),
        _actBtn(ctx, '🐑', 'Vente bétail', () => showMvtForm(ctx, initialType: 'vente_femelle')),
        _actBtn(ctx, '🌿', 'Cultures', () => showRevForm(ctx)),
        _actBtn(ctx, '💼', 'Autre', () => showRevForm(ctx)),
      ];

  Widget _actBtn(BuildContext ctx, String emoji, String label, VoidCallback action) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        action();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bg3,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
          ],
        ),
      ),
    );
  }
}

// ─── Récolte Form ─────────────────────────────────────────────────────────────

Future<void> showRecolteForm(BuildContext context, {Recolte? initial}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RecolteForm(initial: initial),
  );
}

class _RecolteForm extends StatefulWidget {
  const _RecolteForm({this.initial});
  final Recolte? initial;

  @override
  State<_RecolteForm> createState() => _RecolteFormState();
}

class _RecolteFormState extends State<_RecolteForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _fermeId = 'rhamna';
  String _culture = cultureTypes.first;
  int _saison = DateTime.now().year;
  DateTime _date = DateTime.now();

  // Récolte fields
  double _quantite = 0;
  double _quantiteVente = 0;
  double _prixVenteKg = 0;

  // Trituration fields
  double _litresHuile = 0;
  double _litresVente = 0;
  double _litresFamille = 0;
  double _litresHeritiers = 0;
  double _prixVenteLitre = 0;
  double _coutMoulin = 0;

  // Coûts fields
  double _coutOuvriers = 0;
  double _coutTransport = 0;
  double _diversMontant = 0;
  String _diversRemarque = '';

  // Caissons fields
  double _nbCaissons = 0;
  double _prixCaisson = 0;

  String _remarque = '';

  bool get _showTrituration => _culture == 'Olives' || _culture == "Huile d'olive";

  double get _rendement => _quantite > 0 ? (_litresHuile / _quantite * 100) : 0;
  double get _coutCaissons => _nbCaissons * _prixCaisson;
  double get _coutTotal => _coutOuvriers + _coutTransport + _coutMoulin + _diversMontant + _coutCaissons;
  double get _revenuHuile => _litresVente * _prixVenteLitre;
  double get _revenuOlive => _quantiteVente * _prixVenteKg;
  double get _bilan => _revenuHuile + _revenuOlive - _coutTotal;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    final filter = provider.fermeFilter;
    _fermeId = filter == 'all' ? 'rhamna' : filter;
    if (widget.initial != null) {
      final r = widget.initial!;
      _fermeId = r.fermeId;
      _culture = r.culture;
      _saison = r.saison;
      _date = r.date;
      _quantite = r.quantite;
      _quantiteVente = r.quantiteVente;
      _prixVenteKg = r.prixVenteKg;
      _litresHuile = r.litresHuile;
      _litresVente = r.litresVente;
      _litresFamille = r.litresFamille;
      _litresHeritiers = r.litresHeritiers;
      _prixVenteLitre = r.prixVenteLitre;
      _coutMoulin = r.coutMoulin;
      _coutOuvriers = r.coutOuvriers;
      _coutTransport = r.coutTransport;
      _diversMontant = r.diversMontant;
      _diversRemarque = r.diversRemarque;
      _nbCaissons = r.nbCaissons;
      _prixCaisson = r.prixCaisson;
      _remarque = r.remarque;
    }
  }

  double _parseField(String? v) => double.tryParse((v ?? '').replaceAll(',', '.')) ?? 0;

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      title: '🫒 Récolte',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _label('Ferme'),
            _FermeSelector(value: _fermeId, onChanged: (v) => setState(() => _fermeId = v)),
            const SizedBox(height: 14),
            _label('Culture'),
            _dropdown<String>(
              cultureTypes.map((c) => DropdownMenuItem<String>(value: c, child: Text('${cultureEmojis[c] ?? ''} $c'))).toList(),
              _culture,
              (v) => setState(() => _culture = v ?? _culture),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Saison'),
                      TextFormField(
                        initialValue: _saison.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Année'),
                        onChanged: (v) => setState(() => _saison = int.tryParse(v) ?? _saison),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Date',
                    value: _date,
                    onChanged: (d) => setState(() => _date = d),
                  ),
                ),
              ],
            ),

            // Section Récolte
            const _SectionHeader('📦 Récolte'),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Quantité (kg)'),
                      TextFormField(
                        initialValue: _quantite > 0 ? _quantite.toString() : '',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(suffixText: 'kg'),
                        validator: (v) {
                          if (_parseField(v) <= 0) return 'Requis';
                          return null;
                        },
                        onChanged: (v) => setState(() => _quantite = _parseField(v)),
                        onSaved: (v) => _quantite = _parseField(v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Qté vendue (kg)'),
                      TextFormField(
                        initialValue: _quantiteVente > 0 ? _quantiteVente.toString() : '',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(suffixText: 'kg'),
                        onChanged: (v) => setState(() => _quantiteVente = _parseField(v)),
                        onSaved: (v) => _quantiteVente = _parseField(v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _label('Prix vente kg (MAD)'),
            TextFormField(
              initialValue: _prixVenteKg > 0 ? _prixVenteKg.toString() : '',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(suffixText: 'MAD/kg'),
              onChanged: (v) => setState(() => _prixVenteKg = _parseField(v)),
              onSaved: (v) => _prixVenteKg = _parseField(v),
            ),

            // Section Trituration (conditionnelle)
            if (_showTrituration) ...<Widget>[
              const _SectionHeader('🫙 Trituration / Moulin'),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _label('Litres huile'),
                        TextFormField(
                          initialValue: _litresHuile > 0 ? _litresHuile.toString() : '',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(suffixText: 'L'),
                          onChanged: (v) => setState(() => _litresHuile = _parseField(v)),
                          onSaved: (v) => _litresHuile = _parseField(v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _label('Litres vendus'),
                        TextFormField(
                          initialValue: _litresVente > 0 ? _litresVente.toString() : '',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(suffixText: 'L'),
                          onChanged: (v) => setState(() => _litresVente = _parseField(v)),
                          onSaved: (v) => _litresVente = _parseField(v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _label('Litres famille'),
                        TextFormField(
                          initialValue: _litresFamille > 0 ? _litresFamille.toString() : '',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(suffixText: 'L'),
                          onChanged: (v) => setState(() => _litresFamille = _parseField(v)),
                          onSaved: (v) => _litresFamille = _parseField(v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _label('Litres héritiers'),
                        TextFormField(
                          initialValue: _litresHeritiers > 0 ? _litresHeritiers.toString() : '',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(suffixText: 'L'),
                          onChanged: (v) => setState(() => _litresHeritiers = _parseField(v)),
                          onSaved: (v) => _litresHeritiers = _parseField(v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _label('Prix vente litre (MAD)'),
                        TextFormField(
                          initialValue: _prixVenteLitre > 0 ? _prixVenteLitre.toString() : '',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(suffixText: 'MAD/L'),
                          onChanged: (v) => setState(() => _prixVenteLitre = _parseField(v)),
                          onSaved: (v) => _prixVenteLitre = _parseField(v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _label('Coût moulin (MAD)'),
                        TextFormField(
                          initialValue: _coutMoulin > 0 ? _coutMoulin.toString() : '',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(suffixText: 'MAD'),
                          onChanged: (v) => setState(() => _coutMoulin = _parseField(v)),
                          onSaved: (v) => _coutMoulin = _parseField(v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_litresHuile > 0 && _quantite > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Rendement: ${_rendement.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text2),
                  ),
                ),
            ],

            // Section Coûts
            const _SectionHeader('💰 Coûts'),
            // Caissons row
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Nb caissons'),
                      TextFormField(
                        initialValue: _nbCaissons > 0 ? _nbCaissons.toStringAsFixed(0) : '',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(suffixText: 'caisses'),
                        onChanged: (v) => setState(() => _nbCaissons = _parseField(v)),
                        onSaved: (v) => _nbCaissons = _parseField(v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Prix / caisson (MAD)'),
                      TextFormField(
                        initialValue: _prixCaisson > 0 ? _prixCaisson.toString() : '',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(suffixText: 'MAD'),
                        onChanged: (v) => setState(() => _prixCaisson = _parseField(v)),
                        onSaved: (v) => _prixCaisson = _parseField(v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_coutCaissons > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 4),
                child: Text(
                  '📦 Total caissons : ${_coutCaissons.toStringAsFixed(0)} MAD',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text2),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Coût ouvriers (MAD)'),
                      TextFormField(
                        initialValue: _coutOuvriers > 0 ? _coutOuvriers.toString() : '',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(suffixText: 'MAD'),
                        onChanged: (v) => setState(() => _coutOuvriers = _parseField(v)),
                        onSaved: (v) => _coutOuvriers = _parseField(v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Coût transport (MAD)'),
                      TextFormField(
                        initialValue: _coutTransport > 0 ? _coutTransport.toString() : '',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(suffixText: 'MAD'),
                        onChanged: (v) => setState(() => _coutTransport = _parseField(v)),
                        onSaved: (v) => _coutTransport = _parseField(v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Divers (MAD)'),
                      TextFormField(
                        initialValue: _diversMontant > 0 ? _diversMontant.toString() : '',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(suffixText: 'MAD'),
                        onChanged: (v) => setState(() => _diversMontant = _parseField(v)),
                        onSaved: (v) => _diversMontant = _parseField(v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Remarque divers'),
                      TextFormField(
                        initialValue: _diversRemarque,
                        decoration: const InputDecoration(hintText: 'Optionnel'),
                        onSaved: (v) => _diversRemarque = v ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Section Résumé
            const _SectionHeader('📊 Résumé'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bg3,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: <Widget>[
                  if (_revenuHuile > 0) _resumeLine('Revenu huile', _revenuHuile, AppColors.green2),
                  if (_revenuOlive > 0) _resumeLine('Revenu olive', _revenuOlive, AppColors.green2),
                  if (_coutCaissons > 0) _resumeLine('Caissons', -_coutCaissons, AppColors.orange),
                  if (_coutOuvriers > 0) _resumeLine('Ouvriers', -_coutOuvriers, AppColors.orange),
                  if (_coutTransport > 0) _resumeLine('Transport', -_coutTransport, AppColors.orange),
                  if (_coutMoulin > 0) _resumeLine('Moulin', -_coutMoulin, AppColors.orange),
                  if (_diversMontant > 0) _resumeLine('Divers', -_diversMontant, AppColors.orange),
                  const Divider(color: AppColors.border),
                  _resumeLine('Bilan', _bilan, _bilan >= 0 ? AppColors.green2 : AppColors.red, bold: true),
                ],
              ),
            ),

            const SizedBox(height: 14),
            _label('Remarque'),
            TextFormField(
              initialValue: _remarque,
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Observation optionnelle'),
              onSaved: (v) => _remarque = v ?? '',
            ),
            const SizedBox(height: 20),
            _submitBtn(
              label: 'Enregistrer la récolte',
              color: AppColors.green2,
              onTap: _save,
            ),
            const SizedBox(height: 8),
            _cancelBtn(context),
          ],
        ),
      ),
    );
  }

  Widget _resumeLine(String label, double value, Color color, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w500, color: AppColors.text2)),
          Text(
            '${value >= 0 ? '+' : ''}${value.toStringAsFixed(0)} MAD',
            style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final recolte = Recolte(
      id: widget.initial?.id,
      fermeId: _fermeId,
      culture: _culture,
      saison: _saison,
      quantite: _quantite,
      unite: cultureUnites[_culture] ?? 'kg',
      quantiteVente: _quantiteVente,
      date: _date,
      remarque: _remarque,
      coutOuvriers: _coutOuvriers,
      coutTransport: _coutTransport,
      coutMoulin: _coutMoulin,
      litresHuile: _litresHuile,
      litresVente: _litresVente,
      litresFamille: _litresFamille,
      litresHeritiers: _litresHeritiers,
      prixVenteLitre: _prixVenteLitre,
      prixVenteKg: _prixVenteKg,
      diversMontant: _diversMontant,
      diversRemarque: _diversRemarque,
      nbCaissons: _nbCaissons,
      prixCaisson: _prixCaisson,
    );

    if (widget.initial != null) {
      await context.read<AppProvider>().updateRecolte(recolte);
    } else {
      await context.read<AppProvider>().addRecolte(recolte);
    }

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Récolte enregistrée'), backgroundColor: AppColors.green2),
    );
  }
}

// ─── Travailleur Form ─────────────────────────────────────────────────────────

Future<void> showTravailleurForm(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _TravailleurForm(),
  );
}

class _TravailleurForm extends StatefulWidget {
  const _TravailleurForm();

  @override
  State<_TravailleurForm> createState() => _TravailleurFormState();
}

class _TravailleurFormState extends State<_TravailleurForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _nom = '';
  double _nbJours = 0;
  double _salaire = 0;
  String _activite = 'general';
  DateTime _date = DateTime.now();
  String _remarque = '';
  String _fermeId = 'rhamna';

  static const List<(String, String)> _activites = <(String, String)>[
    ('general', 'Général'),
    ('recolte', 'Récolte'),
    ('elevage', 'Élevage'),
    ('cultures', 'Cultures'),
    ('entretien', 'Entretien'),
  ];

  @override
  void initState() {
    super.initState();
    final filter = context.read<AppProvider>().fermeFilter;
    _fermeId = filter == 'all' ? 'rhamna' : filter;
  }

  @override
  Widget build(BuildContext context) {
    return _Sheet(
      title: '👷 Session de travail',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _label('Ferme'),
            _FermeSelector(value: _fermeId, onChanged: (v) => setState(() => _fermeId = v)),
            const SizedBox(height: 14),
            _label('Nom du travailleur'),
            TextFormField(
              decoration: const InputDecoration(hintText: 'Prénom et nom'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              onSaved: (v) => _nom = v?.trim() ?? '',
            ),
            const SizedBox(height: 14),
            _label('Activité'),
            _dropdown<String>(
              _activites.map((a) => DropdownMenuItem<String>(value: a.$1, child: Text(a.$2))).toList(),
              _activite,
              (v) => setState(() => _activite = v ?? _activite),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Nombre de jours'),
                      TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(suffixText: 'j'),
                        validator: (v) {
                          final p = double.tryParse((v ?? '').replaceAll(',', '.'));
                          if (p == null || p <= 0) return 'Requis';
                          return null;
                        },
                        onSaved: (v) => _nbJours = double.tryParse((v ?? '').replaceAll(',', '.')) ?? 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _label('Salaire/jour (MAD)'),
                      TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(suffixText: 'MAD'),
                        validator: (v) {
                          final p = double.tryParse((v ?? '').replaceAll(',', '.'));
                          if (p == null || p <= 0) return 'Requis';
                          return null;
                        },
                        onSaved: (v) => _salaire = double.tryParse((v ?? '').replaceAll(',', '.')) ?? 0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _DateField(label: 'Date', value: _date, onChanged: (d) => setState(() => _date = d)),
            const SizedBox(height: 14),
            _label('Remarque'),
            TextFormField(
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Observation optionnelle'),
              onSaved: (v) => _remarque = v ?? '',
            ),
            const SizedBox(height: 20),
            _submitBtn(
              label: 'Enregistrer la session',
              color: AppColors.green2,
              onTap: _save,
            ),
            const SizedBox(height: 8),
            _cancelBtn(context),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    await context.read<AppProvider>().addTravailleurSession(
          TravailleurSession(
            fermeId: _fermeId,
            nom: _nom,
            nbJours: _nbJours,
            salaireJournalier: _salaire,
            date: _date,
            remarque: _remarque,
            activite: _activite,
          ),
        );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session enregistrée'), backgroundColor: AppColors.green2),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.text3,
            letterSpacing: .5,
          ),
        ),
      );
}

// ─── Sheet ────────────────────────────────────────────────────────────────────

class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green2,
                  ),
                ),
                const SizedBox(height: 20),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _label(label),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.bg3,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _label(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: .5,
        fontWeight: FontWeight.w800,
        color: AppColors.text3,
      ),
    ),
  );
}

Widget _dropdown<T>(
  List<DropdownMenuItem<T>> items,
  T value,
  ValueChanged<T?> onChanged,
) {
  return DropdownButtonFormField<T>(
    initialValue: value,
    items: items,
    onChanged: onChanged,
    dropdownColor: AppColors.bg2,
    decoration: const InputDecoration(),
  );
}

Widget _submitBtn({
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size.fromHeight(60),
      ),
      child: Text(label),
    ),
  );
}

Widget _cancelBtn(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        'Annuler',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.text3,
        ),
      ),
    ),
  );
}

class _FermeSelector extends StatelessWidget {
  const _FermeSelector({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _btn('rhamna', '🐑 Rhamna'),
        const SizedBox(width: 10),
        _btn('srahna', '🫒 Srahna'),
      ],
    );
  }

  Widget _btn(String v, String label) {
    final selected = value == v;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.green2 : AppColors.bg3,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.green2 : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : AppColors.text2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
