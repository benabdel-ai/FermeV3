// AUTO-GENERATED — do not edit manually
// ignore_for_file: lines_longer_than_80_chars
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

const _u = Uuid();

Future<void> seedHistoricalData(Database db) async {
  // ── Cheptel stock initial ──────────────────────────────────────────────
  await db.insert('mouvements', {'id': _u.v4(), 'type': 'init_femelles', 'qte': 41, 'date': '2026-04-06', 'remarque': 'Brebis stock initial', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('mouvements', {'id': _u.v4(), 'type': 'init_males', 'qte': 28, 'date': '2026-04-06', 'remarque': 'Moutons stock initial (1 etalon + 27 Aid)', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('mouvements', {'id': _u.v4(), 'type': 'init_agf', 'qte': 27, 'date': '2026-04-06', 'remarque': 'Agnelles stock initial', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('mouvements', {'id': _u.v4(), 'type': 'init_agm', 'qte': 19, 'date': '2026-04-06', 'remarque': 'Agneaux stock initial', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);

  // ── Revenus Aid ───────────────────────────────────────────────────────
  await db.insert('revenus', {'id': _u.v4(), 'montant': 4500.0, 'date': '2026-03-13', 'categorie': 'Vente Aid', 'remarque': 'Vente 7awli Med', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);

  // ── Revenus Cheptel ──────────────────────────────────────────────────
  await db.insert('revenus', {'id': _u.v4(), 'montant': 1.0, 'date': '2024-07-15', 'categorie': 'Vente betail', 'remarque': 'Khroufa matet estomac', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 9700.0, 'date': '2024-10-06', 'categorie': 'Vente betail', 'remarque': '3 brebis et 2 moutons', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 5350.0, 'date': '2024-10-16', 'categorie': 'Vente betail', 'remarque': 'Khroufa et khrouf ki boite, khroufa satha', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 3250.0, 'date': '2024-11-25', 'categorie': 'Vente betail', 'remarque': 'Khrof Abdel3ati (pieds chkwadri)', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 22500.0, 'date': '2025-03-19', 'categorie': 'Vente betail', 'remarque': '8 moutons', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 1.0, 'date': '2025-04-10', 'categorie': 'Vente betail', 'remarque': '2 n3aj fcharfate matou (fidaoui)', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 7500.0, 'date': '2025-05-01', 'categorie': 'Vente betail', 'remarque': 'Vente 4 brebis charfat, 3 moutons petit (echange avec 2brebis et 2 kherfane)', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 1500.0, 'date': '2025-10-04', 'categorie': 'Vente betail', 'remarque': 'Vente chevres', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 2000.0, 'date': '2025-10-18', 'categorie': 'Vente betail', 'remarque': 'Moutons l si3li', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 12800.0, 'date': '2025-11-12', 'categorie': 'Vente betail', 'remarque': 'Da3ma ovins', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 1.0, 'date': '2025-12-01', 'categorie': 'Vente betail', 'remarque': 'Khroufa matet (naissance pied 3awja)', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);

  // ── Revenus Srahna ───────────────────────────────────────────────────
  await db.insert('revenus', {'id': _u.v4(), 'montant': 79035.0, 'date': '2024-10-01', 'categorie': 'Vente Olives/Huile', 'remarque': 'Olives et huile', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 4500.0, 'date': '2025-01-18', 'categorie': 'Vente Ferraille', 'remarque': 'La ferraille', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 2500.0, 'date': '2025-07-19', 'categorie': 'Vente Kharoub', 'remarque': 'Kharoub (800kg)', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 175507.0, 'date': '2025-10-31', 'categorie': 'Vente Olives/Huile', 'remarque': 'Jenyane 27064kg', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);

  // ── Revenus Rhamna ───────────────────────────────────────────────────
  await db.insert('revenus', {'id': _u.v4(), 'montant': 2000.0, 'date': '2024-01-08', 'categorie': 'Vente Fassa', 'remarque': 'Vente Fassa, orange et Drag', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 3000.0, 'date': '2024-02-17', 'categorie': 'Vente Fassa', 'remarque': 'Fassa', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 400.0, 'date': '2024-07-06', 'categorie': 'Vente Hendya', 'remarque': 'Hendya sando9', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 550.0, 'date': '2024-07-15', 'categorie': 'Vente Hendya', 'remarque': 'Hendya', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 1050.0, 'date': '2024-07-23', 'categorie': 'Vente Hendya', 'remarque': 'Hendya', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 250.0, 'date': '2024-08-17', 'categorie': 'Vente Fruits', 'remarque': 'Mechmach et slawi', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 4360.0, 'date': '2024-10-01', 'categorie': 'Vente Olives', 'remarque': 'Valeur olives dwirt', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 7200.0, 'date': '2024-11-17', 'categorie': 'Vente Fassa', 'remarque': 'Drag (jniwi, 3ammi, hammou)', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 2500.0, 'date': '2024-11-21', 'categorie': 'Vente Chemkar', 'remarque': 'Vente chemkar', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 250.0, 'date': '2025-04-11', 'categorie': 'Vente Divers', 'remarque': 'Lgssab', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 4000.0, 'date': '2025-06-02', 'categorie': 'Vente Chemkar', 'remarque': 'Vente chemkar', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 1500.0, 'date': '2025-06-02', 'categorie': 'Vente Divers', 'remarque': 'Bota lkhawi', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 800.0, 'date': '2025-07-02', 'categorie': 'Vente Divers', 'remarque': 'Vente parquet', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 600.0, 'date': '2025-07-02', 'categorie': 'Vente Divers', 'remarque': 'Vente ferraille 7did', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 2500.0, 'date': '2025-07-02', 'categorie': 'Location Tracteur', 'remarque': 'Revenu Tracteurs', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 100.0, 'date': '2025-07-14', 'categorie': 'Vente Hendya', 'remarque': 'Vente stal hendya', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 350.0, 'date': '2025-07-28', 'categorie': 'Vente Hendya', 'remarque': 'Hendya', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 5000.0, 'date': '2025-09-05', 'categorie': 'Location Tracteur', 'remarque': 'Frais tracteurs', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 700.0, 'date': '2025-10-01', 'categorie': 'Vente Fruits', 'remarque': 'Roumane vente', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 500.0, 'date': '2025-10-16', 'categorie': 'Vente Divers', 'remarque': 'Gssab', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 107460.0, 'date': '2025-10-31', 'categorie': 'Vente Olives', 'remarque': 'Olives rhamna 14717kg', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 454120.0, 'date': '2025-11-30', 'categorie': 'Vente Huile d\'olive', 'remarque': 'Ventes huile olive', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 4050.0, 'date': '2025-12-20', 'categorie': 'Location Tracteur', 'remarque': 'Tracteur 7art', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('revenus', {'id': _u.v4(), 'montant': 32400.0, 'date': '2025-12-31', 'categorie': 'Vente Fassa', 'remarque': 'Fassa (540 bala) année 2025', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);

  // ── Depenses Aid ─────────────────────────────────────────────────────
  await db.insert('depenses', {'id': _u.v4(), 'montant': 101950.0, 'date': '2026-02-17', 'categorie': 'Aid', 'remarque': 'Achat 34 moutons', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1230.0, 'date': '2026-02-18', 'categorie': 'Aid', 'remarque': 'Gazoil, et manger', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2245.0, 'date': '2026-02-18', 'categorie': 'Aid', 'remarque': 'Part 34 moutons pour 70 bala', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 800.0, 'date': '2026-02-18', 'categorie': 'Aid', 'remarque': 'Transport', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 370.0, 'date': '2026-02-18', 'categorie': 'Aid', 'remarque': 'Dwa quarantaine', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2903.0, 'date': '2026-02-18', 'categorie': 'Aid', 'remarque': 'Part Achat 3alf (1300kg) pour 34', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 320.0, 'date': '2026-02-25', 'categorie': 'Aid', 'remarque': 'Part Dwa vitamine pour 34', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 4485.0, 'date': '2026-03-09', 'categorie': 'Aid', 'remarque': 'Part Achat Aliments pour 34', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 4570.0, 'date': '2026-04-05', 'categorie': 'Aid', 'remarque': 'Part Achat 3alf pour 33', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);

  // ── Depenses Olivier Rhamna ──────────────────────────────────────────
  await db.insert('depenses', {'id': _u.v4(), 'montant': 468.0, 'date': '2023-11-01', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Bota', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 400.0, 'date': '2023-11-01', 'categorie': 'Carburant', 'remarque': 'Mazot', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 200.0, 'date': '2023-11-01', 'categorie': 'Autre', 'remarque': 'Motor réparation', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 400.0, 'date': '2023-11-01', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Jawad', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 3400.0, 'date': '2023-11-01', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Zebbara', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 800.0, 'date': '2023-11-01', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Jawad', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 350.0, 'date': '2023-11-01', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Jawad', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 300.0, 'date': '2023-11-01', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Jawad', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 400.0, 'date': '2023-11-19', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Jawad', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 8140.0, 'date': '2024-01-01', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Bota, jawad, tkerbil, mazir', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1800.0, 'date': '2024-01-03', 'categorie': 'Produits agricoles', 'remarque': 'Cuivre dwa', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 9215.0, 'date': '2024-02-17', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Drag 2200, bota w ouvrier', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 450.0, 'date': '2024-02-17', 'categorie': 'Produits agricoles', 'remarque': 'Bore', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 5250.0, 'date': '2024-04-04', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Bota, mchanter', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 5800.0, 'date': '2024-05-16', 'categorie': 'Autre', 'remarque': '', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 700.0, 'date': '2024-05-16', 'categorie': 'Autre', 'remarque': 'Croquis', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 3245.0, 'date': '2024-06-01', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Bota et ouvrier', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2025.0, 'date': '2024-06-18', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Ouvrier et bota', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2350.0, 'date': '2024-06-27', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Ouvrier et bota', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 3450.0, 'date': '2024-08-01', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Ouvrier, bota, chtab', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 4950.0, 'date': '2024-09-11', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Bota, mchanter (jusqu\'à 11 septembre)', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 6000.0, 'date': '2024-09-11', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Hafid (juillet et Août)', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2290.0, 'date': '2024-10-13', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Mchanter, bota', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2050.0, 'date': '2024-11-03', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Mchantar, bota, chambraire', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 5970.0, 'date': '2024-11-10', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Mchanter, bota, tracteurs (jusqu\'au 28 décembre)', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2530.0, 'date': '2025-01-22', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Mchanter et bota jusqu\'au 19 janvier', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1500.0, 'date': '2025-02-02', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Mchanter bota jusqu\'au 02 fevr 25', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2730.0, 'date': '2025-02-23', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Mchanter, bota jusqu\'au 23 février', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 800.0, 'date': '2025-04-05', 'categorie': 'Produits agricoles', 'remarque': 'Bore', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 3890.0, 'date': '2025-04-06', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Mchanter et bota jusqu\'au 06 avril', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2600.0, 'date': '2025-04-26', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Mchanter et bota jusqu\'au 27 avril', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 4050.0, 'date': '2025-06-08', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Mchanter et bota jusqu\'au 08 juin', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 540.0, 'date': '2025-06-20', 'categorie': 'Produits agricoles', 'remarque': 'Dwa mouche', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 3000.0, 'date': '2025-07-20', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Mchanter jusqu\'au 20/07', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 30000.0, 'date': '2025-07-20', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Hafid de septembre 24 à juillet 25', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 5000.0, 'date': '2025-10-01', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Mchanter jusqu\'au 28/09', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 44570.0, 'date': '2025-10-31', 'categorie': 'Zakat/Partage', 'remarque': 'Jenyane, part tante, oncle zakat', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 5550.0, 'date': '2025-11-23', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Mchanter jusqu\'au 23/11/25', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1500.0, 'date': '2026-02-17', 'categorie': 'Reparations', 'remarque': 'Scaphandre pompe', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 800.0, 'date': '2026-02-18', 'categorie': 'Produits agricoles', 'remarque': 'Dwa bore zinc', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 500.0, 'date': '2026-02-18', 'categorie': 'Autre', 'remarque': 'Réparation pompe', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 400.0, 'date': '2026-04-04', 'categorie': 'Produits agricoles', 'remarque': '7echane rbi3', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 800.0, 'date': '2026-04-30', 'categorie': 'Autre', 'remarque': 'Réparation pompe', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);

  // ── Depenses Cheptel ─────────────────────────────────────────────────
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1150.0, 'date': '2024-06-01', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Gardien et 7echane', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 4775.0, 'date': '2024-06-18', 'categorie': 'Alimentation betail', 'remarque': 'Dzaza, fassa, werradat,,ouvrier', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 70.0, 'date': '2024-06-20', 'categorie': 'Veterinaire', 'remarque': 'Dwa brebis', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 900.0, 'date': '2024-06-27', 'categorie': 'Autre', 'remarque': 'Tanga, pesticides brebis et minéraux brebis', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2150.0, 'date': '2024-06-27', 'categorie': 'Veterinaire', 'remarque': 'Ouvrier, dwa', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 10500.0, 'date': '2024-07-15', 'categorie': 'Autre', 'remarque': 'Achats brebis (5)', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1635.0, 'date': '2024-08-01', 'categorie': 'Veterinaire', 'remarque': 'L7ayl, dwa', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 6000.0, 'date': '2024-08-01', 'categorie': 'Alimentation betail', 'remarque': 'Rwiza', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 35500.0, 'date': '2024-08-21', 'categorie': 'Achat betail', 'remarque': 'Achat 10 moutons', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2000.0, 'date': '2024-09-08', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Zangat abdel3ati', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1200.0, 'date': '2024-09-08', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Wekkala', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 500.0, 'date': '2024-09-08', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Zangate kouri', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 500.0, 'date': '2024-09-08', 'categorie': 'Veterinaire', 'remarque': 'Jilali, dwa l7awli', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2520.0, 'date': '2024-09-11', 'categorie': 'Alimentation betail', 'remarque': 'L7ayl (120dh chmander) jusqu\'à 11 sept', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1000.0, 'date': '2024-09-22', 'categorie': 'Infrastructure', 'remarque': 'Zriba naturelle', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 5100.0, 'date': '2024-10-01', 'categorie': 'Alimentation betail', 'remarque': 'Fassa (68 bala moins 20 dial bovins)', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 370.0, 'date': '2024-10-10', 'categorie': 'Veterinaire', 'remarque': 'Dwa', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1855.0, 'date': '2024-10-13', 'categorie': 'Alimentation betail', 'remarque': 'L7ayl w (chmander (205dh)', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 80.0, 'date': '2024-10-13', 'categorie': 'Alimentation betail', 'remarque': 'Tben', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 306.0, 'date': '2024-10-24', 'categorie': 'Alimentation betail', 'remarque': 'Chamndar, noukhala', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1885.0, 'date': '2024-11-03', 'categorie': 'Alimentation betail', 'remarque': 'L7ayl, chmandar, nokhala', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 3825.0, 'date': '2024-11-10', 'categorie': 'Alimentation betail', 'remarque': 'L7ayl, noukhala, chamndar (Jusqu\'au 29 décembre)', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 5400.0, 'date': '2024-11-25', 'categorie': 'Alimentation betail', 'remarque': 'Fassa 60 bala', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 550.0, 'date': '2024-11-25', 'categorie': 'Veterinaire', 'remarque': 'Veto ne3ja tweled et trs', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 450.0, 'date': '2024-11-25', 'categorie': 'Veterinaire', 'remarque': 'Cesarienne ne3ja', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 250.0, 'date': '2024-12-01', 'categorie': 'Alimentation betail', 'remarque': 'Chmander noukhala', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 100.0, 'date': '2024-12-03', 'categorie': 'Veterinaire', 'remarque': 'Ferme r7am', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 440.0, 'date': '2024-12-06', 'categorie': 'Alimentation betail', 'remarque': 'Chamnder w noukhala', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 530.0, 'date': '2024-12-09', 'categorie': 'Autre', 'remarque': 'Chamnder noukhalla', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 300.0, 'date': '2024-12-12', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Transports jilali vétérinaire', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 100.0, 'date': '2024-12-12', 'categorie': 'Veterinaire', 'remarque': 'Fermer r7am', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 234.0, 'date': '2025-01-08', 'categorie': 'Veterinaire', 'remarque': 'Moutons pieds veto', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1705.0, 'date': '2025-01-18', 'categorie': 'Alimentation betail', 'remarque': 'Noukhala w chmandar', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2575.0, 'date': '2025-01-22', 'categorie': 'Main-d\'oeuvre', 'remarque': 'L7ayl w dra jusqu\'au 19 janvier', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 10000.0, 'date': '2025-01-24', 'categorie': 'Alimentation betail', 'remarque': 'Rwiza (60 khancha x 80kg)', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 5000.0, 'date': '2025-01-28', 'categorie': 'Alimentation betail', 'remarque': '60 bala Fassa (dr chawki)', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 70.0, 'date': '2025-01-29', 'categorie': 'Autre', 'remarque': 'Khrouf diarrhée', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 466.0, 'date': '2025-01-29', 'categorie': 'Alimentation betail', 'remarque': 'Chamnder w noukhala', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 800.0, 'date': '2025-02-02', 'categorie': 'Main-d\'oeuvre', 'remarque': 'L7ayl jusqu\'au 2 fevr 25', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1770.0, 'date': '2025-02-04', 'categorie': 'Alimentation betail', 'remarque': 'Noukhala et chmander', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1300.0, 'date': '2025-02-23', 'categorie': 'Main-d\'oeuvre', 'remarque': 'L7AYL jusqu\'au 23 février', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 6000.0, 'date': '2025-03-03', 'categorie': 'Achat betail', 'remarque': 'Achat 7awli anoc', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2350.0, 'date': '2025-04-06', 'categorie': 'Main-d\'oeuvre', 'remarque': 'L7ayl et bache jusqu\'au 06 avril', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1500.0, 'date': '2025-04-26', 'categorie': 'Main-d\'oeuvre', 'remarque': 'L7ayl jusqu\'au 27 avril', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1000.0, 'date': '2025-04-26', 'categorie': 'Achat betail', 'remarque': 'Achat chevres', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1750.0, 'date': '2025-05-01', 'categorie': 'Achat betail', 'remarque': 'Rajout pour achat 2 brebis avec 2 kerhfane petit', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2700.0, 'date': '2025-06-08', 'categorie': 'Main-d\'oeuvre', 'remarque': 'L7ayl jusqu\'au 08 juin', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2400.0, 'date': '2025-07-20', 'categorie': 'Main-d\'oeuvre', 'remarque': 'L7ayl jusqu\'au 20/07', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2500.0, 'date': '2025-10-01', 'categorie': 'Main-d\'oeuvre', 'remarque': 'L7ayl jusqu\'au 24/08', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 60.0, 'date': '2025-12-01', 'categorie': 'Veterinaire', 'remarque': 'Dwa khrouf', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 8760.0, 'date': '2025-12-01', 'categorie': 'Alimentation betail', 'remarque': 'Achat 3alf jusqu\'au', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 530.0, 'date': '2025-12-01', 'categorie': 'Veterinaire', 'remarque': 'Dwa', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1500.0, 'date': '2025-12-24', 'categorie': 'Location', 'remarque': 'Location terrain', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 8000.0, 'date': '2025-12-31', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Salaire l7ayl', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 32400.0, 'date': '2025-12-31', 'categorie': 'Alimentation betail', 'remarque': '540 bala fassa depuis fevrier 2025', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 3200.0, 'date': '2026-01-01', 'categorie': 'Main-d\'oeuvre', 'remarque': 'L7ayl jusqu\'au 01/03', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 300.0, 'date': '2026-02-02', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Nettoyage zriba', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 3200.0, 'date': '2026-02-18', 'categorie': 'Alimentation betail', 'remarque': 'Fassa, 3alf, dwa pour 19 moutons', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 87.0, 'date': '2026-02-25', 'categorie': 'Veterinaire', 'remarque': 'Dwa ssrohma kherfane', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2500.0, 'date': '2026-04-05', 'categorie': 'Main-d\'oeuvre', 'remarque': 'L7ayl jusqu\'au 05/04/26', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 5185.0, 'date': '2026-04-05', 'categorie': 'Alimentation betail', 'remarque': '3alf 19 moutons', 'fermeId': 'rhamna'}, conflictAlgorithm: ConflictAlgorithm.ignore);

  // ── Depenses Srahna ──────────────────────────────────────────────────
  await db.insert('depenses', {'id': _u.v4(), 'montant': 2100.0, 'date': '2024-07-15', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Ouvriers clotures et assistant irrigation', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 400.0, 'date': '2024-07-17', 'categorie': 'Transport', 'remarque': 'Transports Jilali', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 6810.0, 'date': '2024-07-17', 'categorie': 'Equipement', 'remarque': 'Cameras et installation', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 820.0, 'date': '2024-07-17', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Déjeuner et petit dej ouvriers', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 800.0, 'date': '2024-07-17', 'categorie': 'Carburant', 'remarque': 'Jawaz et gazoil adil et moi', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 750.0, 'date': '2024-07-21', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Ouvrier semaine1', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 500.0, 'date': '2024-07-27', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Mustapha srahna assistance', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 750.0, 'date': '2024-07-28', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Ouvrier semaine 2', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1450.0, 'date': '2024-08-08', 'categorie': 'Location Tracteur', 'remarque': 'Traks', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 750.0, 'date': '2024-08-11', 'categorie': 'Main-d\'oeuvre', 'remarque': '3aychour', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 750.0, 'date': '2024-08-25', 'categorie': 'Main-d\'oeuvre', 'remarque': '3aychour', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 4500.0, 'date': '2024-09-08', 'categorie': 'Main-d\'oeuvre', 'remarque': '3aychour jusqu\'au 08 Août', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 10165.0, 'date': '2024-10-01', 'categorie': 'Recolte Jenyane', 'remarque': 'Frais jenyane et extra', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 4500.0, 'date': '2024-10-13', 'categorie': 'Main-d\'oeuvre', 'remarque': '3aychour jusqu\'à 13 octobre', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 9818.0, 'date': '2024-11-01', 'categorie': 'Travaux agricoles', 'remarque': 'Tkerbil (2091 7ofra)', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 3750.0, 'date': '2024-11-17', 'categorie': 'Main-d\'oeuvre', 'remarque': '3aychour jusqu\'au 17 novembre', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 3000.0, 'date': '2024-12-15', 'categorie': 'Main-d\'oeuvre', 'remarque': '3aychour jusqu\'au 15 decembre', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 7740.0, 'date': '2025-01-18', 'categorie': 'Travaux agricoles', 'remarque': 'Tkerbil (1935 oliviers)', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 3750.0, 'date': '2025-01-19', 'categorie': 'Main-d\'oeuvre', 'remarque': '3aychour jusqu\'au 19 janvier 25', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 3750.0, 'date': '2025-02-23', 'categorie': 'Main-d\'oeuvre', 'remarque': '3aychour jusqu\'au 23 février', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 4400.0, 'date': '2025-04-05', 'categorie': 'Transport', 'remarque': 'Bore et transport et tracteur', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 15750.0, 'date': '2025-07-20', 'categorie': 'Main-d\'oeuvre', 'remarque': '3aychour jusqu\'au 20/07', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 8250.0, 'date': '2025-10-05', 'categorie': 'Main-d\'oeuvre', 'remarque': '3aychour jusqu\'au 05/10/2025', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 83497.0, 'date': '2025-10-31', 'categorie': 'Recolte Jenyane', 'remarque': 'Jenyane, trans, part fidaoui, zakat', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 4800.0, 'date': '2025-12-31', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Brahim serhani jusqu\'au 0401/26', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 7000.0, 'date': '2025-12-31', 'categorie': 'Main-d\'oeuvre', 'remarque': '3aychour jusqu\'au 04/01/26', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 1200.0, 'date': '2026-02-18', 'categorie': 'Produits agricoles', 'remarque': 'Dwa zitoune', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 5200.0, 'date': '2026-04-05', 'categorie': 'Main-d\'oeuvre', 'remarque': 'Brahim serhani jusqu\'au 05/04/26', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('depenses', {'id': _u.v4(), 'montant': 6500.0, 'date': '2026-04-05', 'categorie': 'Main-d\'oeuvre', 'remarque': '3aychour jusqu\'au 05/04/26', 'fermeId': 'srahna'}, conflictAlgorithm: ConflictAlgorithm.ignore);

  // ── Salariés fixes hebdomadaires (récurrents) ─────────────────────────
  await db.insert('recurring_expenses', {'id': _u.v4(), 'label': 'L\'7ayl — Gardien Rhamna', 'montant': 500.0, 'fermeId': 'rhamna', 'actif': 1, 'createdAt': '2026-04-06', 'lastPaidAt': null}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('recurring_expenses', {'id': _u.v4(), 'label': 'Hafid — Olivier Rhamna', 'montant': 800.0, 'fermeId': 'rhamna', 'actif': 1, 'createdAt': '2026-04-06', 'lastPaidAt': null}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('recurring_expenses', {'id': _u.v4(), 'label': '3aychour — Srahna', 'montant': 500.0, 'fermeId': 'srahna', 'actif': 1, 'createdAt': '2026-04-06', 'lastPaidAt': null}, conflictAlgorithm: ConflictAlgorithm.ignore);
  await db.insert('recurring_expenses', {'id': _u.v4(), 'label': 'Brahim Serhani — Srahna', 'montant': 400.0, 'fermeId': 'srahna', 'actif': 1, 'createdAt': '2026-04-06', 'lastPaidAt': null}, conflictAlgorithm: ConflictAlgorithm.ignore);

}