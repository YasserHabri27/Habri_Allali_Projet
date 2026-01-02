# Pegasus - Smart Workflow Manager

## Présentation du Projet
Pegasus est une application mobile de gestion de flux de travail intelligente, développée avec le framework Flutter. Elle permet aux utilisateurs de gérer efficacement leurs projets et tâches, avec une synchronisation automatique de la progression et un tableau de bord analytique complet. L'application respecte rigoureusement les principes de la Clean Architecture pour garantir maintenabilité, testabilité et évolutivité.

Ce projet a été réalisé dans le cadre de l'évaluation du module de développement mobile Flutter.

## Informations Académiques
**Contexte :** Contrôle Flutter
**Binôme :**
*   Yasser Habri
*   Doha Allali

**Professeur encadrant :**
*   M. Abdoul Nasser Hamidou Soumana

## Architecture et Technologies
Ce projet met en œuvre une architecture logicielle robuste et des technologies modernes.

### Architecture
*   **Clean Architecture :** Séparation stricte des responsabilités en trois couches (Domain, Data, Presentation).
*   **Pattern BLoC (Business Logic Component) :** Gestion d'état prédictible et séparation de la logique métier de l'interface utilisateur.
*   **Repository Pattern :** Abstraction de la couche de données permettant une gestion transparente des sources locales et distantes.

### Technologies et Bibliothèques
*   **Flutter & Dart :** Framework et langage de développement.
*   **flutter_bloc :** Gestion d'état.
*   **go_router :** Gestion de la navigation et du routage profond.
*   **get_it :** Injection de dépendances (Service Locator).
*   **dio :** Client HTTP performant pour les appels réseaux.
*   **hive :** Base de données locale NoSQL légère et rapide pour le cache et le mode hors ligne.
*   **dartz :** Programmation fonctionnelle (gestion des erreurs avec Either).
*   **equatable :** Simplification de la comparaison d'objets.

## Fonctionnalités Principales
1.  **Authentification Sécurisée :**
    *   Système complet de connexion et d'inscription.
    *   Gestion de la persistance de session.
    *   Contrôle d'accès et protection des routes.

2.  **Gestion de Projets :**
    *   Création, lecture, mise à jour et suppression (CRUD) de projets.
    *   Suivi visuel de l'avancement avec calcul automatique.
    *   Stockage local pour un accès hors ligne.

3.  **Gestion de Tâches :**
    *   Association de tâches par projet.
    *   États de tâches (À faire, En cours, Terminé) influençant directement la progression du projet parent.
    *   Synchronisation intelligente entre les entités.

4.  **Tableau de Bord (Dashboard) :**
    *   Vue d'ensemble analytique.
    *   Statistiques en temps réel (taux de complétion, tâches en retard).
    *   Visualisation interactive du flux de travail.

## Installation et Exécution

1.  **Prérequis :**
    *   Flutter SDK installé.
    *   Un émulateur Android/iOS ou un appareil physique connecté.

2.  **Installation des dépendances :**
    ```bash
    flutter pub get
    ```

3.  **Génération de code (pour Hive et les adaptateurs) :**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Lancement de l'application :**
    ```bash
    flutter run
    ```
