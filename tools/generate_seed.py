import xlrd, os
from datetime import date

BASE = r'C:/Users/Bentaleb/Downloads/'
OUT  = r'C:/Users/Bentaleb/Desktop/ma_ferme/lib/services/seed_data.dart'

def xls_date(val):
    try:
        t = xlrd.xldate_as_datetime(val, 0)
        return t.strftime('%Y-%m-%d')
    except:
        return date.today().isoformat()

def get_rows(fname):
    wb = xlrd.open_workbook(BASE + fname)
    sh = wb.sheets()[0]
    result = []
    for r in range(5, sh.nrows):
        row = [sh.cell_value(r, c) for c in range(sh.ncols)]
        if not row[1]: continue
        result.append(row)
    return result

def cat_rev_rhamna(desc):
    d = desc.lower()
    if 'fassa' in d or ('drag' in d and 'olives' not in d): return 'Vente Fassa'
    if 'hendya' in d: return 'Vente Hendya'
    if 'huile' in d: return "Vente Huile d'olive"
    if 'olives' in d or 'olive' in d: return 'Vente Olives'
    if 'tracteur' in d: return 'Location Tracteur'
    if 'chemkar' in d: return 'Vente Chemkar'
    if 'roumane' in d or 'mechmach' in d or 'slawi' in d: return 'Vente Fruits'
    return 'Vente Divers'

def cat_rev_srahna(desc):
    d = desc.lower()
    if 'huile' in d or 'olive' in d or 'jenyane' in d: return "Vente Olives/Huile"
    if 'ferraille' in d: return 'Vente Ferraille'
    if 'kharoub' in d: return 'Vente Kharoub'
    return 'Ventes Srahna'

def cat_dep_cheptel(desc):
    d = desc.lower()
    if any(x in d for x in ['achat brebis','achat 10','achat 7awli','achat chevres','rajout pour achat']):
        return 'Achat betail'
    if any(x in d for x in ['fassa','3alf','noukhala','chamndar','chmander','tben','dzaza','werradat','khancha','nokhala','rwiza','aliments']):
        return 'Alimentation betail'
    if any(x in d for x in ['dwa','veto','cesarienne','r7am','ssrohma','pieds veto']):
        return 'Veterinaire'
    if any(x in d for x in ['l7ayl','gardien','ouvrier','wekkala','zangat','jilali','nettoyage','salaire']):
        return "Main-d'oeuvre"
    if 'transport' in d: return 'Transport'
    if 'location' in d: return 'Location'
    if 'zriba' in d: return 'Infrastructure'
    return 'Autre'

def cat_dep_olivier(desc):
    d = desc.lower()
    if any(x in d for x in ['mchanter','bota','jawad','zebbara','hafid','ouvrier','drag']):
        return "Main-d'oeuvre"
    if any(x in d for x in ['tkerbil','mazir']): return 'Travaux agricoles'
    if any(x in d for x in ['mazot','gazoil']): return 'Carburant'
    if any(x in d for x in ['reparation','scaphandre']): return 'Reparations'
    if any(x in d for x in ['dwa','cuivre','bore','zinc','mouche','7echane']): return 'Produits agricoles'
    if 'jenyane' in d and ('tante' in d or 'oncle' in d or 'zakat' in d): return 'Zakat/Partage'
    return 'Autre'

def cat_dep_srahna(desc):
    d = desc.lower()
    if any(x in d for x in ['ouvrier','3aychour','brahim','mustapha','assistant','manger','dejeuner','clotures','semaine']):
        return "Main-d'oeuvre"
    if 'transport' in d: return 'Transport'
    if 'camera' in d: return 'Equipement'
    if 'gazoil' in d or 'jawaz' in d: return 'Carburant'
    if 'traks' in d: return 'Location Tracteur'
    if 'tkerbil' in d: return 'Travaux agricoles'
    if 'jenyane' in d: return 'Recolte Jenyane'
    if 'bore' in d: return 'Produits agricoles'
    if 'zakat' in d: return 'Zakat/Partage'
    if 'dwa' in d: return 'Produits agricoles'
    return 'Autre'

def esc(s):
    return str(s).replace("\\", "\\\\").replace("'", "\\'").replace('"', '\\"').replace('\n','').strip()

today = date.today().isoformat()
L = []

L.append("// AUTO-GENERATED — do not edit manually")
L.append("// ignore_for_file: lines_longer_than_80_chars")
L.append("import 'package:sqflite/sqflite.dart';")
L.append("import 'package:uuid/uuid.dart';")
L.append("")
L.append("const _u = Uuid();")
L.append("")
L.append("Future<void> seedHistoricalData(Database db) async {")

def ins_rev(montant, dt, cat, rem, ferme):
    r = esc(rem)
    c = esc(cat)
    L.append(f"  await db.insert('revenus', {{'id': _u.v4(), 'montant': {montant}, 'date': '{dt}', 'categorie': '{c}', 'remarque': '{r}', 'fermeId': '{ferme}'}}, conflictAlgorithm: ConflictAlgorithm.ignore);")

def ins_dep(montant, dt, cat, rem, ferme):
    r = esc(rem)
    c = esc(cat)
    L.append(f"  await db.insert('depenses', {{'id': _u.v4(), 'montant': {montant}, 'date': '{dt}', 'categorie': '{c}', 'remarque': '{r}', 'fermeId': '{ferme}'}}, conflictAlgorithm: ConflictAlgorithm.ignore);")

def ins_mvt(typ, qte, rem, ferme):
    r = esc(rem)
    L.append(f"  await db.insert('mouvements', {{'id': _u.v4(), 'type': '{typ}', 'qte': {qte}, 'date': '{today}', 'remarque': '{r}', 'fermeId': '{ferme}'}}, conflictAlgorithm: ConflictAlgorithm.ignore);")

L.append("  // ── Cheptel stock initial ──────────────────────────────────────────────")
ins_mvt('init_femelles', 41, 'Brebis stock initial', 'rhamna')
ins_mvt('init_males',    28, 'Moutons stock initial (1 etalon + 27 Aid)', 'rhamna')
ins_mvt('init_agf',      27, 'Agnelles stock initial', 'rhamna')
ins_mvt('init_agm',      19, 'Agneaux stock initial', 'rhamna')

L.append("")
L.append("  // ── Revenus Aid ───────────────────────────────────────────────────────")
for row in get_rows('Revenus Aid.xls'):
    m = row[5]
    if m <= 0: continue
    ins_rev(m, xls_date(row[1]), 'Vente Aid', str(row[7]), 'rhamna')

L.append("")
L.append("  // ── Revenus Cheptel ──────────────────────────────────────────────────")
for row in get_rows('Revenus Cheptel.xls'):
    m = row[5]
    if m <= 0: continue
    ins_rev(m, xls_date(row[1]), 'Vente betail', str(row[7]), 'rhamna')

L.append("")
L.append("  // ── Revenus Srahna ───────────────────────────────────────────────────")
for row in get_rows('Revenus oliviers Srahna.xls'):
    m = row[5]
    if m <= 0: continue
    ins_rev(m, xls_date(row[1]), cat_rev_srahna(str(row[7])), str(row[7]), 'srahna')

L.append("")
L.append("  // ── Revenus Rhamna ───────────────────────────────────────────────────")
for row in get_rows('Revenus Rhamna.xls'):
    m = row[5]
    if m <= 0: continue
    ins_rev(m, xls_date(row[1]), cat_rev_rhamna(str(row[7])), str(row[7]), 'rhamna')

L.append("")
L.append("  // ── Depenses Aid ─────────────────────────────────────────────────────")
for row in get_rows('Achat et depenses Aid.xls'):
    m = row[6]
    if m <= 0: continue
    ins_dep(m, xls_date(row[1]), 'Aid', str(row[7]), 'rhamna')

L.append("")
L.append("  // ── Depenses Olivier Rhamna ──────────────────────────────────────────")
for row in get_rows('Depenses Olivier Rhamna.xls'):
    m = row[6]
    if m <= 0: continue
    ins_dep(m, xls_date(row[1]), cat_dep_olivier(str(row[7])), str(row[7]), 'rhamna')

L.append("")
L.append("  // ── Depenses Cheptel ─────────────────────────────────────────────────")
for row in get_rows('Depenses Cheptel.xls'):
    m = row[6]
    if m <= 0: continue
    ins_dep(m, xls_date(row[1]), cat_dep_cheptel(str(row[7])), str(row[7]), 'rhamna')

L.append("")
L.append("  // ── Depenses Srahna ──────────────────────────────────────────────────")
for row in get_rows('Depenses_Srahna.xls'):
    m = row[6]
    if m <= 0: continue
    ins_dep(m, xls_date(row[1]), cat_dep_srahna(str(row[7])), str(row[7]), 'srahna')

L.append("}")

content = '\n'.join(L)
with open(OUT, 'w', encoding='utf-8') as f:
    f.write(content)

print(f"Genere : {OUT}")
print(f"Lignes Dart : {len(L)}")
