import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Importation du module "modele" avec l'alias "modele"
import './modele.dart' as modele;
// Importation du module "resultat" avec l'alias "resultat"
import './resultat.dart' as resultat;
// Importation du module "accueil" avec l'alias "accueil"
import './accueil.dart' as accueil;

class GrilleDemineur extends ConsumerStatefulWidget {
  // Classe GrilleDemineur qui étend ConsumerStatefulWidget
  final int taille;
  final int nbMines;

  GrilleDemineur(
      this.taille, this.nbMines, String playerName, String difficulty,
      {Key? key})
      : super(key: key);

  @override
  _GrilleDemineur createState() => _GrilleDemineur();
}

class _GrilleDemineur extends ConsumerState<GrilleDemineur> {
  // Classe _GrilleDemineur qui étend ConsumerState<GrilleDemineur>
  late modele.Grille _grille; // Grille de démineur
  Stopwatch _stopwatch =
      Stopwatch(); // Chronomètre pour mesurer le temps écoulé
  Timer? _timer;

  @override
  void initState() {
    _grille = modele.Grille(
        widget.taille,
        widget
            .nbMines); // Initialisation de la grille avec la taille et le nombre de mines
    _timer = Timer.periodic(
        Duration(seconds: 1),
        (Timer t) =>
            setState(() {})); // Mise à jour de l'interface toutes les secondes
    _stopwatch.start(); // Démarrage du chronomètre
    super.initState();
  }

  void reset() {
    setState(() {
      _grille = modele.Grille(
          widget.taille, widget.nbMines); // Réinitialisation de la grille
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 400,
        width: 400,
        child: GridView.builder(
          padding: EdgeInsets.zero,
          itemCount: _grille.taille * _grille.taille,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _grille.taille,
            mainAxisSpacing: 4.0, // Ajout d'espace verticalement
            crossAxisSpacing: 4.0, // Ajout d'espace horizontalement
          ),
          itemBuilder: (BuildContext context, int index) {
            int ligne = index ~/ _grille.taille;
            int colonne = index % _grille.taille;
            return Padding(
              padding: const EdgeInsets.all(
                  2.0), // Ajuster le padding selon les besoins
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _grille.mettreAJour(modele.Coup(
                        ligne,
                        colonne,
                        modele.Action
                            .decouvrir)); // Mettre à jour la grille avec un coup de découverte
                    bool perdue = _grille.isPerdue();
                    if (perdue) {
                      final playerName = ref.read(accueil.playerNameProvider);
                      final difficulte = ref.read(accueil.difficultyProvider);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => resultat.Resultat(
                              _stopwatch.elapsed,
                              "Perdu",
                              playerName,
                              difficulte),
                        ),
                      ); // Navigation vers l'écran de résultat en cas de défaite
                    } else {
                      if (_grille.isGagnee()) {
                        final playerName = ref.read(accueil.playerNameProvider);
                        final difficulte = ref.read(accueil.difficultyProvider);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => resultat.Resultat(
                                _stopwatch.elapsed,
                                "Gagné",
                                playerName,
                                difficulte),
                          ),
                        ); // Navigation vers l'écran de résultat en cas de victoire
                      }
                    }
                  });
                },
                onLongPress: () {
                  setState(() {
                    _grille.mettreAJour(modele.Coup(
                        ligne,
                        colonne,
                        modele.Action
                            .marquer)); // Mettre à jour la grille avec un coup de marquage
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: caseToColor(_grille.getCase(modele.Coordonnees(
                      ligne,
                      colonne))), // Couleur du bouton en fonction de l'état de la case
                ),
                child: Text(
                  caseToText(
                    _grille.getCase(modele.Coordonnees(ligne,
                        colonne)), // Texte à afficher sur le bouton en fonction de l'état de la case
                    _grille.isFinie(),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
              ),
            );
          },
        ));
  }

  String caseToText(modele.Case laCase, bool isFini) {
    if (laCase.marquee) {
      return 'M'; // Marque 'M' pour les cases marquées
    } else if (laCase.decouverte) {
      if (laCase.nbMinesAutour != 0 && !isFini) {
        return laCase.nbMinesAutour
            .toString(); // Nombre de mines adjacentes pour les cases découvertes
      } else {
        return ''; // Case vide pour les cases découvertes sans mines adjacentes
      }
    } else if (isFini && laCase.minee) {
      return 'X'; // Marque 'X' pour les cases avec une mine en cas de fin de partie
    } else {
      return ''; // Case vide pour les cases non découvertes
    }
  }

  Color caseToColor(modele.Case laCase) {
    if (laCase.marquee) {
      return Colors.orange; // Couleur orange pour les cases marquées
    } else if (laCase.decouverte) {
      if (laCase.minee) {
        return Colors.red; // Couleur rouge pour les cases avec une mine
      } else if (laCase.nbMinesAutour != 0) {
        return Colors
            .grey; // Couleur grise pour les cases avec des mines adjacentes
      } else {
        return Colors
            .blue; // Couleur bleue pour les cases sans mines adjacentes
      }
    } else {
      return Colors.grey; // Couleur grise pour les cases non découvertes
    }
  }

  String messageEtat(modele.Grille grille) {
    if (grille.isFinie()) {
      if (grille.isGagnee()) {
        return "Partie Gagné !"; // Message de victoire si la partie est terminée et gagnée
      } else {
        return "Partie Perdu !"; // Message de défaite si la partie est terminée et perdue
      }
    } else {
      return "En cours de déminage..."; // Message en cours de partie
    }
  }
}
