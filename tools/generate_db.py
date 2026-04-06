import xlrd, sqlite3, uuid, os
from datetime import datetime, date

BASE = r'C:/Users/Bentaleb/Downloads/'
OUT  = r'C:/Users/Bentaleb/Desktop/troupeau_ovins.db'

def xls_date(val):
    try:
        t = xlrd.xldate_as_datetime(val, 0)
        return t.strftime('%Y-%m-%d')
    except:
        return date.today().isoformat()

def rows(fname):
    wb = xlrd.open_workbook(BASE + fname)
    sh = wb.sheets()[0]
    result = []
    for r in range(5, sh.nrows):
        row = [sh.cell_value(r, c) for c in range(sh.ncols)]
        if not row[1]:
            continue
        result.append(row)
    return result

def cat_rev_rhamna(desc):
    d = desc.lower()
    if 'fassa' in d or ('drag' in d and 'olives' not in d): return 'Vente Fassa'
    if 'hendya' in d:                   return 'Vente Hendya'
    if 'huile' in d:                    return "Vente Huile d'olive"
    if 'olives' in d or 'olive' in d:   return 'Vente Olives'
    if 'tracteur' in d:                 return 'Location Tracteur'
    if 'chemkar' in d:                  return 'Vente Chemkar'
    if 'roumane' in d or 'mechmach' in d or 'slawi' in d: return 'Vente Fruits'
    if 'ferraille' in d or 'parquet' in d: return 'Vente Divers'
    return 'Vente Divers'

def cat_rev_srahna(desc):
    d = desc.lower()
    if 'huile' in d or 'olive' in d or 'jenyane' in d: return 'Vente Olives/Huile'
    if 'ferraille' in d:   return 'Vente Ferraille'
    if 'kharoub' in d:     return 'Vente Kharoub'
    return 'Ventes Srahna'

def cat_dep_cheptel(desc):
    d = desc.lower()
    if any(x in d for x in ['achat brebis','achat 10 moutons','achat 7awli','achat chevres','rajout pour achat']):
        return 'Achat bétail'
    if any(x in d for x in ['fassa','3alf','noukhala','chamndar','chmander','tben','dzaza','werradat','khancha','dra','nokhala','rwiza','aliments']):
        return 'Alimentation bétail'
    if any(x in d for x in ['dwa','veto','cesarienne','r7am','ssrohma','diarrhee','pieds veto']):
        return 'Vétérinaire'
    if any(x in d for x in ['l7ayl','gardien','ouvrier','wekkala','zangat','jilali','nettoyage','salaire']):
        return "Main-d'oeuvre"
    if 'transport' in d:    return 'Transport'
    if 'location' in d:     return 'Location'
    if 'zriba' in d:        return 'Infrastructure'
    if 'bache' in d:        return 'Materiel'
    return 'Autre'

def cat_dep_olivier_rhamna(desc):
    d = desc.lower()
    if any(x in d for x in ['mchanter','bota','jawad','zebbara','hafid','ouvrier']):
        return "Main-d'oeuvre"
    if any(x in d for x in ['tkerbil','mazir']):
        return 'Travaux agricoles'
    if any(x in d for x in ['mazot','gazoil']):
        return 'Carburant'
    if any(x in d for x in ['reparation','scaphandre']):
        return 'Reparations'
    if any(x in d for x in ['dwa','cuivre','bore','zinc','mouche','7echane']):
        return 'Produits agricoles'
    if 'jenyane' in d and ('tante' in d or 'oncle' in d or 'zakat' in d):
        return 'Zakat/Partage'
    if 'drag' in d:
        return "Main-d'oeuvre"
    return 'Autre'

def cat_dep_srahna(desc):
    d = desc.lower()
    if any(x in d for x in ['ouvrier','3aychour','brahim','mustapha','assistant','manger','dejeuner','clotures','semaine']):
        return "Main-d'oeuvre"
    if 'transport' in d:        return 'Transport'
    if 'camera' in d:           return 'Equipement'
    if 'gazoil' in d or 'jawaz' in d: return 'Carburant'
    if 'traks' in d:            return 'Location Tracteur'
    if 'tkerbil' in d:          return 'Travaux agricoles'
    if 'jenyane' in d:          return 'Recolte Jenyane'
    if 'bore' in d:             return 'Produits agricoles'
    if 'zakat' in d:            return 'Zakat/Partage'
    if 'dwa' in d:              return 'Produits agricoles'
    return 'Autre'

if os.path.exists(OUT):
    os.remove(OUT)

conn = sqlite3.connect(OUT)
c = conn.cursor()

c.executescript("""
CREATE TABLE mouvements (
  id TEXT PRIMARY KEY, type TEXT NOT NULL, qte INTEGER NOT NULL,
  date TEXT NOT NULL, remarque TEXT DEFAULT '', fermeId TEXT NOT NULL DEFAULT 'rhamna'
);
CREATE TABLE depenses (
  id TEXT PRIMARY KEY, montant REAL NOT NULL, date TEXT NOT NULL,
  categorie TEXT NOT NULL, remarque TEXT DEFAULT '', fermeId TEXT NOT NULL DEFAULT 'rhamna'
);
CREATE TABLE revenus (
  id TEXT PRIMARY KEY, montant REAL NOT NULL, date TEXT NOT NULL,
  categorie TEXT NOT NULL, remarque TEXT DEFAULT '', fermeId TEXT NOT NULL DEFAULT 'rhamna'
);
CREATE TABLE IF NOT EXISTS aid_moutons (
  id TEXT PRIMARY KEY, numero TEXT NOT NULL UNIQUE, race TEXT NOT NULL,
  prixAchat REAL NOT NULL, coutRevient REAL NOT NULL DEFAULT 0,
  sold INTEGER NOT NULL DEFAULT 0, reserved INTEGER NOT NULL DEFAULT 0,
  prixVente REAL NOT NULL DEFAULT 0, acheteur TEXT DEFAULT '',
  createdAt TEXT NOT NULL, reservedAt TEXT, soldAt TEXT
);
CREATE TABLE IF NOT EXISTS recoltes (
  id TEXT PRIMARY KEY, fermeId TEXT NOT NULL, culture TEXT NOT NULL,
  saison INTEGER NOT NULL, quantite REAL NOT NULL, unite TEXT NOT NULL DEFAULT 'kg',
  quantiteVente REAL NOT NULL DEFAULT 0, quantiteInterne REAL NOT NULL DEFAULT 0,
  date TEXT NOT NULL, remarque TEXT DEFAULT ''
);
CREATE TABLE IF NOT EXISTS triturations (
  id TEXT PRIMARY KEY, fermeId TEXT NOT NULL, saison INTEGER NOT NULL,
  kgOlives REAL NOT NULL, litresHuile REAL NOT NULL, coutTrituration REAL NOT NULL DEFAULT 0,
  litresVente REAL NOT NULL DEFAULT 0, litresFamille REAL NOT NULL DEFAULT 0,
  litresHeritiers REAL NOT NULL DEFAULT 0, prixVenteLitre REAL NOT NULL DEFAULT 0,
  date TEXT NOT NULL, remarque TEXT DEFAULT ''
);
CREATE TABLE IF NOT EXISTS travailleur_sessions (
  id TEXT PRIMARY KEY, fermeId TEXT NOT NULL, nom TEXT NOT NULL,
  nbJours REAL NOT NULL, salaireJournalier REAL NOT NULL,
  date TEXT NOT NULL, remarque TEXT DEFAULT ''
);
CREATE TABLE IF NOT EXISTS recurring_expenses (
  id TEXT PRIMARY KEY, label TEXT NOT NULL, montant REAL NOT NULL,
  fermeId TEXT NOT NULL, actif INTEGER NOT NULL DEFAULT 1,
  createdAt TEXT NOT NULL, lastPaidAt TEXT
);
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY, type TEXT NOT NULL, label TEXT NOT NULL,
  ordre INTEGER NOT NULL DEFAULT 0
);
""")

dep_cats = [
    "Alimentation betail","Veterinaire","Transport","Achat betail","Main-d'oeuvre",
    "Equipement","Eau / Electricite","Trituration","Engrais / Produits",
    "Aid","Carburant","Location","Infrastructure","Materiel",
    "Produits agricoles","Travaux agricoles","Reparations","Zakat/Partage",
    "Location Tracteur","Recolte Jenyane","Autre"
]
rev_cats = [
    "Vente betail","Vente Aid","Vente Fassa","Vente Hendya","Vente Chemkar",
    "Vente Huile d'olive","Vente Olives","Vente Olives/Huile","Vente Kharoub",
    "Vente Ferraille","Vente Fruits","Vente Divers","Ventes Srahna",
    "Location Tracteur","Autre"
]
cult_cats = ["Olives","Huile d'olive","Citrons","Figues","Fruits divers","Luzerne","Autre"]

for i, lb in enumerate(dep_cats):
    c.execute("INSERT INTO categories VALUES (?,?,?,?)", (str(uuid.uuid4()),'depense',lb,i))
for i, lb in enumerate(rev_cats):
    c.execute("INSERT INTO categories VALUES (?,?,?,?)", (str(uuid.uuid4()),'revenu',lb,i))
for i, lb in enumerate(cult_cats):
    c.execute("INSERT INTO categories VALUES (?,?,?,?)", (str(uuid.uuid4()),'culture',lb,i))

today = date.today().isoformat()
mvts = [
    ('init_femelles', 41,  'Brebis stock initial'),
    ('init_males',    28,  'Moutons stock initial (1 etalon + 27 Aid)'),
    ('init_agf',      27,  'Agnelles stock initial'),
    ('init_agm',      19,  'Agneaux stock initial'),
]
for typ, qte, rem in mvts:
    c.execute("INSERT INTO mouvements VALUES (?,?,?,?,?,?)",
              (str(uuid.uuid4()), typ, qte, today, rem, 'rhamna'))

for row in rows('Revenus Aid.xls'):
    montant = row[5]
    if montant <= 0: continue
    c.execute("INSERT INTO revenus VALUES (?,?,?,?,?,?)",
              (str(uuid.uuid4()), montant, xls_date(row[1]), 'Vente Aid', str(row[7]), 'rhamna'))

for row in rows('Revenus Cheptel.xls'):
    montant = row[5]
    if montant <= 0: continue
    c.execute("INSERT INTO revenus VALUES (?,?,?,?,?,?)",
              (str(uuid.uuid4()), montant, xls_date(row[1]), 'Vente betail', str(row[7]), 'rhamna'))

for row in rows('Revenus oliviers Srahna.xls'):
    montant = row[5]
    if montant <= 0: continue
    c.execute("INSERT INTO revenus VALUES (?,?,?,?,?,?)",
              (str(uuid.uuid4()), montant, xls_date(row[1]), cat_rev_srahna(str(row[7])), str(row[7]), 'srahna'))

for row in rows('Revenus Rhamna.xls'):
    montant = row[5]
    if montant <= 0: continue
    c.execute("INSERT INTO revenus VALUES (?,?,?,?,?,?)",
              (str(uuid.uuid4()), montant, xls_date(row[1]), cat_rev_rhamna(str(row[7])), str(row[7]), 'rhamna'))

for row in rows('Achat et depenses Aid.xls'):
    montant = row[6]
    if montant <= 0: continue
    c.execute("INSERT INTO depenses VALUES (?,?,?,?,?,?)",
              (str(uuid.uuid4()), montant, xls_date(row[1]), 'Aid', str(row[7]), 'rhamna'))

for row in rows('Depenses Olivier Rhamna.xls'):
    montant = row[6]
    if montant <= 0: continue
    c.execute("INSERT INTO depenses VALUES (?,?,?,?,?,?)",
              (str(uuid.uuid4()), montant, xls_date(row[1]), cat_dep_olivier_rhamna(str(row[7])), str(row[7]), 'rhamna'))

for row in rows('Depenses Cheptel.xls'):
    montant = row[6]
    if montant <= 0: continue
    c.execute("INSERT INTO depenses VALUES (?,?,?,?,?,?)",
              (str(uuid.uuid4()), montant, xls_date(row[1]), cat_dep_cheptel(str(row[7])), str(row[7]), 'rhamna'))

for row in rows('Depenses_Srahna.xls'):
    montant = row[6]
    if montant <= 0: continue
    c.execute("INSERT INTO depenses VALUES (?,?,?,?,?,?)",
              (str(uuid.uuid4()), montant, xls_date(row[1]), cat_dep_srahna(str(row[7])), str(row[7]), 'srahna'))

conn.commit()

for tbl in ['mouvements','revenus','depenses','categories']:
    c.execute(f'SELECT COUNT(*) FROM {tbl}')
    print(f'  {tbl}: {c.fetchone()[0]} lignes')

total_rev = c.execute('SELECT SUM(montant) FROM revenus').fetchone()[0]
total_dep = c.execute('SELECT SUM(montant) FROM depenses').fetchone()[0]
print(f'\n  Total revenus  : {total_rev:,.0f} MAD')
print(f'  Total depenses : {total_dep:,.0f} MAD')
print(f'  Bilan          : {(total_rev - total_dep):,.0f} MAD')
print(f'\nBase creee : {OUT}')
conn.close()
