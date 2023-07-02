import 'dart:math';

// Les coordonnées d'une case de la grille
class Coordonnees {
  int ligne;
  int colonne;

  Coordonnees(this.ligne, this.colonne);
}

// Une case de la grille
class Case {
  bool minee; // La case comporte-t-elle une mine ?
  bool decouverte = false; // La case a-t-elle été découverte ?
  bool marquee = false; // La case a-t-elle été marquée ?
  int nbMinesAutour = 0; // Nombre de mines autour de la case

  Case(this.minee);
}

// Type d'action qu'un joueur peut réaliser sur une case
enum Action { decouvrir, marquer }

// Coup réalisé par le joueur
class Coup {
  Coordonnees coordonnees;
  Action action;

  Coup(int ligne, int colonne, this.action)
      : coordonnees = Coordonnees(ligne, colonne);
}

// Grille du démineur
class Grille {
  int taille; // dimensions de la grille carrée : taille*taille
  int nbMines; // nombre de mines dans la grille
  final List<List<Case>> _grille =
      []; // grille qui comportera taille*taille cases
  // Constructeur
  Grille(this.taille, this.nbMines) {
    int nbCasesACreer =
        taille * taille; // Le nombre de cases qu'il reste à créer
    int nbMinesAPoser = nbMines; // Le nombre de mines qu'il reste à poser
    Random generateur = Random(); // Générateur de nombres aléatoires
    // Pour chaque ligne de la grille
    for (int ligne = 0; ligne < taille; ligne++) {
      // On va ajouter à la grille une nouvelle Ligne (liste de 'cases')
      List<Case> uneLigne = [];
      for (int colonne = 0; colonne < taille; colonne++) {
        // S'il reste nBMinesAPoser dans nbCasesACreer, la probabilité de miner est nbMinesAPoser/nbCasesACreer
        // Donc on tire un nombre aléatoire a dans [1..nbCasesACreer] et on pose une mine si a <= nbMinesAposer
        bool isMinee = generateur.nextInt(nbCasesACreer) < nbMinesAPoser;
        if (isMinee) nbMinesAPoser--; // une mine de moins à poser
        uneLigne.add(Case(isMinee)); // On ajoute une nouvelle case à la ligne
        nbCasesACreer--; // Une case de moins à créer
      }
      // On ajoute la nouvelle ligne à la grille
      _grille.add(uneLigne);
    }
    // Les cases étant créées et les mines posées, on calcule pour chaque case le 'nombre de mines autour'
    calculeNbMinesAutour();
  }

  // Consulter une case
  Case getCase(Coordonnees coordonnees) {
    return _grille[coordonnees.ligne][coordonnees.colonne];
  }

  // Liste des coordonnées des cases voisines d'une case
  List<Coordonnees> getVoisines(Coordonnees coordonnees) {
    List<Coordonnees> listeVoisines = [];

    // On se positionne sur la case en haut à gauche des coordonnées choisis
    // puis on vérifie pour chaque colone et chaque ligne autour des coordonnées (3*3)
    // si la case a des coordonnées comprise dans la grille ou non
    for (int ligne = coordonnees.ligne - 1;
        ligne <= coordonnees.ligne + 1;
        ligne++) {
      for (int colonne = coordonnees.colonne - 1;
          colonne <= coordonnees.colonne + 1;
          colonne++) {
        if (ligne >= 0 &&
            ligne < taille &&
            colonne >= 0 &&
            colonne < taille &&
            (ligne != coordonnees.ligne || colonne != coordonnees.colonne)) {
          listeVoisines.add(Coordonnees(ligne, colonne));
        }
      }
    }

    return listeVoisines;
  }

  // Calcule pour chaque case le nombre de mines présentes dans ses voisines
  void calculeNbMinesAutour() {
    // Pour chaque case on regarde s'il y a une mine dans une de ses cases voisines
    for (int ligne = 0; ligne < taille; ligne++) {
      for (int colonne = 0; colonne < taille; colonne++) {
        List<Coordonnees> listeVoisines =
            getVoisines(Coordonnees(ligne, colonne));
        int nbMinesAutour = 0;
        for (Coordonnees coordonnees in listeVoisines) {
          if (getCase(coordonnees).minee) {
            nbMinesAutour++;
          }
        }

        getCase(Coordonnees(ligne, colonne)).nbMinesAutour = nbMinesAutour;
      }
    }
  }

  // Découvre récursivement toutes les voisines d'une case qui vient d'être découverte
  void decouvrirVoisines(Coordonnees coordonnees) {
    for (final voisine in getVoisines(coordonnees)) {
      Case caseVoisine = getCase(voisine);
      if (!caseVoisine.decouverte &&
          !caseVoisine.minee &&
          !caseVoisine.marquee) {
        caseVoisine.decouverte = true;
        if (caseVoisine.nbMinesAutour == 0) {
          decouvrirVoisines(voisine);
        }
      }
    }
  }

  // Met à jour la grille en fonction du coup joué
  void mettreAJour(Coup coup) {
    Case laCase = getCase(coup.coordonnees);
    if (coup.action == Action.marquer && !laCase.decouverte) {
      laCase.marquee = !laCase.marquee;
    } else if (coup.action == Action.decouvrir && !laCase.decouverte) {
      laCase.decouverte = true;
      if (!laCase.minee && laCase.nbMinesAutour == 0) {
        decouvrirVoisines(coup.coordonnees);
      }
    }
  }

  // Renvoie vrai si la grille a été complètement déminée
  bool isGagnee() {
    bool gagnee = true;
    for (int ligne = 0; ligne < taille && gagnee; ligne++) {
      for (int colonne = 0; colonne < taille && gagnee; colonne++) {
        // Ici on code un OU exclusif en C++ : A XOR B devient A != B
        gagnee =
            _grille[ligne][colonne].minee != _grille[ligne][colonne].decouverte;
      }
    }
    return gagnee;
  }

  // Renvoie vrai si une case minée a été découverte
  bool isPerdue() {
    bool perdue = false;
    for (int ligne = 0; ligne < taille && !perdue; ligne++) {
      for (int colonne = 0; colonne < taille && !perdue; colonne++) {
        // Ici on code un OU exclusif en C++ : A XOR B devient A != B
        perdue =
            _grille[ligne][colonne].minee && _grille[ligne][colonne].decouverte;
      }
    }
    return perdue;
  }

  // Renvoie vrai si la partie est finie
  bool isFinie() {
    return isGagnee() || isPerdue();
  }
}
