import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Importation du module "modele" avec l'alias "modele"
import './modele.dart' as modele;
// Importation du module "grille_demineur" avec l'alias "grille_demineur"
import './grille_demineur.dart' as grille_demineur;

// Provider pour le nom du joueur avec une valeur initiale vide
final playerNameProvider = StateProvider<String>((ref) => "");
// Provider pour la difficulté avec une valeur initiale "facile"
// (même au démarrage de l'application, c'est un bug)
final difficultyProvider = StateProvider<String>((ref) => "facile");

class Accueil extends ConsumerStatefulWidget {
  // Classe Accueil qui étend ConsumerStatefulWidget
  const Accueil({Key? key}) : super(key: key);

  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends ConsumerState<Accueil> {
  // Classe _AccueilState qui étend ConsumerState<Accueil>
  final _formKey = GlobalKey<FormState>(); // Clé globale pour le formulaire

  @override
  Widget build(BuildContext context) {
    final _playerName = ref.watch(
        playerNameProvider); // Lecture du nom du joueur depuis le provider
    final _difficulty = ref.watch(
        difficultyProvider); // Lecture de la difficulté depuis le provider

    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  validator: (value) {
                    // Validation du champ de texte
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    // Sauvegarde du nom du joueur dans le provider
                    ref.read(playerNameProvider.notifier).state = value!;
                  },
                  decoration: InputDecoration(
                    labelText: _playerName != ""
                        ? "Nom actuel : $_playerName"
                        : "Entrez votre nom",
                  ),
                ),
              ),
            ),
            DropdownButton<String>(
              value: _difficulty, // Valeur actuelle de la difficulté
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? newValue) {
                // Gestionnaire de modification de la difficulté
                ref.read(difficultyProvider.notifier).state = newValue!;
              },
              items: <String>['facile', 'moyen', 'difficile']
                  .map<DropdownMenuItem<String>>((String value) {
                // Création des éléments de la liste déroulante
                return DropdownMenuItem<String>(
                  value: value,
                  child: value == _difficulty
                      ? Text('${value} (precedent)')
                      : Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!
                      .save(); // Validation et sauvegarde du formulaire
                  int gridSize;
                  if (_difficulty == 'facile') {
                    gridSize = 5;
                  } else if (_difficulty == 'moyen') {
                    gridSize = 10;
                  } else {
                    gridSize = 20;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => grille_demineur.GrilleDemineur(
                          gridSize, gridSize, _playerName, _difficulty),
                    ),
                  ); // Navigation vers la grille de démineur avec les paramètres nécessaires
                }
              },
              child: Text(
                'Commencer',
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
