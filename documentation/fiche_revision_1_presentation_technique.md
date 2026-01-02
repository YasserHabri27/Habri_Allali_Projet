# Fiche de Révision 1 : Présentation Technique du Projet Pegasus

Cette fiche résume les aspects techniques clés du projet Pegasus. Utilisez ces points pour présenter le projet de manière claire et précise.

## 1. Vue d'Ensemble & Architecture
Le projet suit strictement les principes de la **Clean Architecture** pour garantir la séparation des responsabilités, la testabilité et la maintenance.

### Structure en Couches (Layers)
Le code est organisé en trois couches principales à l'intérieur de chaque fonctionnalité (`feature`) :

1.  **Domain (Coeur)** :
    *   **Rôle** : Contient la logique métier pure et les règles de l'application. Elle est indépendante de tout framework externe (Flutter, HTTP, etc.).
    *   **Contenu** : `Entities` (Objets métier), `Use Cases` (Scénarios d'utilisation), `Repositories Interfaces` (Contrats).

2.  **Data (Données)** :
    *   **Rôle** : Gère la récupération et la persistance des données. Elle implémente les contrats du domaine.
    *   **Contenu** :
        *   `Models` : Adaptateurs des entités (pour JSON/Hive).
        *   `DataSources` : Sources de données (Remote pour API, Local pour Hive).
        *   `Repositories Impl` : Implémentation concrète des interfaces du repository.

3.  **Presentation (UI et État)** :
    *   **Rôle** : Affiche les données et gère les interactions utilisateur.
    *   **Contenu** : `Pages`, `Widgets`, et `BLoCs` (Business Logic Components) pour la gestion d'état.

## 2. Choix Technologiques

### Framework & Langage
*   **Flutter & Dart** : Pour un développement cross-platform performant et une UI fluide.

### Gestion d'État (State Management)
*   **BLoC (`flutter_bloc`)** :
    *   Pattern basé sur les événements (`Events`) et les états (`States`).
    *   Permet une séparation claire entre l'UI et la logique.
    *   Flux : UI -> envoie Event -> BLoC traite -> émet State -> UI se met à jour.

### Injection de Dépendances
*   **GetIt (`get_it`)** :
    *   Utilisé comme "Service Locator" pour accéder aux instances de classes (Repositories, Use Cases, BLoCs) n'importe où dans l'app sans couplage fort.
    *   Configuration centralisée dans `lib/config/injection/injection_container.dart`.

### Réseau & API
*   **Dio (`dio`)** : Client HTTP puissant préféré à `http` pour ses intercepteurs, sa gestion globale des erreurs et sa facilité de configuration.
*   **Pretty Dio Logger** : Pour des logs réseaux lisibles en développement.
*   **Connectivity Plus** : Pour vérifier l'état de la connexion internet.

### Stockage Local
*   **Hive (`hive`)** :
    *   Base de données NoSQL clé-valeur.
    *   Très rapide et légère, écrite en pur Dart.
    *   Utilisée pour le cache local et le mode hors-ligne.
*   **Shared Preferences** : Pour les données simples (thème, token auth).

## 3. Points Clés à Connaitre

*   **Flux de Données Typique** :
    1.  L'utilisateur clique sur un bouton (UI).
    2.  L'UI envoie un `Event` au `BLoC`.
    3.  Le `BLoC` appelle un `Use Case`.
    4.  Le `Use Case` appelle le `Repository` (Interface).
    5.  L'implémentation du `Repository` vérifie la connexion :
        *   *Si connecté* : Appelle `RemoteDataSource` (API), sauvegarde le résultat dans `LocalDataSource` (Cache), et retourne la donnée.
        *   *Si hors-ligne* : Retourne la donnée depuis `LocalDataSource`.
    6.  La donnée remonte jusqu'au `BLoC` qui émet un nouvel `State` (ex: `Loaded`).
    7.  L'UI se redessine avec les nouvelles données.

*   **Gestion des Erreurs** :
    *   Utilisation de `Failures` (côté Domaine) pour mapper les `Exceptions` (côté Data) en erreurs lisibles pour l'utilisateur.

*   **Routing** :
    *   **GoRouter** : Gestion de la navigation déclarative (basée sur les URL), simplifiant les deep links et la logique de redirection (ex: rediriger vers Login si non authentifié).

## 4. Organisation du Code (`lib/`)
*   `core/` : Éléments transversaux (Constantes, Gestion d'erreurs, Client API singleton, Thème).
*   `features/` : Découpage fonctionnel (Auth, Tasks, Projects...).
*   `config/` : Configuration globale (Routes, Injection).
*   `shared/` : Widgets réutilisables dans toute l'app.
