import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Importation du module "grille_demineur" avec l'alias "grille_demineur"
import './grille_demineur.dart' as grille_demineur;
// Importation du module "accueil" avec l'alias "accueil"
import './accueil.dart' as accueil;

class Resultat extends ConsumerStatefulWidget {
  // Classe Resultat qui étend ConsumerStatefulWidget
  final Duration duree;
  String resultat;

  Resultat(this.duree, this.resultat, String playerName, String difficulte,
      {Key? key})
      : super(key: key);

  @override
  _ResultatState createState() => _ResultatState();
}

class _ResultatState extends ConsumerState<Resultat> {
  // Classe _ResultatState qui étend ConsumerState<Resultat>
  @override
  Widget build(BuildContext context) {
    final playerName = ref.read(accueil
        .playerNameProvider); // Lecture du nom du joueur depuis le provider de l'accueil
    final difficulte = ref.read(accueil
        .difficultyProvider); // Lecture de la difficulté depuis le provider de l'accueil

    return Scaffold(
      appBar: AppBar(
        title: Text('Résultat'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${playerName} a ${widget.resultat} !', // Affichage du résultat avec le nom du joueur et le résultat fourni
              style: const TextStyle(
                fontSize: 30,
              ),
            ),
            Text(
              'Temps écoulé : ${widget.duree.inSeconds} secondes', // Affichage du temps écoulé en secondes
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            Text('Difficulté : $difficulte', // Affichage de la difficulté
                style: const TextStyle(
                  fontSize: 20,
                )),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        accueil.Accueil(), // Navigation vers la page d'accueil
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                "Revenir a l'accueil", // Bouton pour revenir à l'accueil
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
