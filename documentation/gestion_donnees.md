# Gestion et Architecture des Données - Projet Pegasus

Ce document technique détaille exclusivement la stratégie de gestion, de stockage et de flux des données au sein de l'application.

## 1. Philosophie "Offline-First"
L'application Pegasus est conçue pour fonctionner de manière fluide même sans connexion internet.
**Principe :** L'utilisateur interagit toujours avec des données disponibles localement (cache). Le réseau n'est qu'un moyen de synchroniser ce cache.

### Pourquoi ce choix ?
*   **Expérience Utilisateur (UX) :** Pas de chargement bloquant (spinners) en attendant le réseau.
*   **Fiabilité :** L'application reste utilisable en zone blanche ou instable.
*   **Performance :** La lecture disque locale est toujours plus rapide qu'une requête HTTP.

---

## 2. Architecture des Données

### A. Séparation Modèles vs Entités
Nous utilisons deux types d'objets pour représenter la même donnée :

1.  **Entities (Domaine) :** `Task`, `Project`
    *   Objets Dart purs (`Equatable`).
    *   Aucune dépendance à des librairies externes (comme Hive ou JSON).
    *   Utilisés par l'UI et le Business Logic (BLoC).
    *   *Pourquoi ?* Pour ne pas polluer le code métier avec des détails techniques de sérialisation.

2.  **Models (Data) :** `TaskModel`, `ProjectModel`
    *   Héritent ou convertissent les Entités.
    *   Contiennent les méthodes `fromJson`, `toJson`.
    *   Contiennent les annotations Hive (`@HiveType`, `@HiveField`).
    *   *Pourquoi ?* Pour gérer la conversion technique spécifique aux APIs et au stockage.

### B. Le Repository Pattern (Mediator)
Le `Repository` est le **seul point d'entrée** pour accéder aux données. Il masque la complexité de l'origine de la donnée.

**Fonctionnement type d'une lecture (`getTasks`) :**
1.  Vérification de la connectivité (`NetworkInfo`).
2.  **Si Internet OK :**
    *   Appel API (`RemoteDataSource`).
    *   Si succès : Sauvegarde immédiate des résultats dans le cache local (`LocalDataSource`).
    *   Retour des données fraîches.
3.  **Si Internet KO (ou erreur serveur) :**
    *   Lecture directe du cache local (`LocalDataSource`).
    *   Retour des données persistées.

---

## 3. Choix Technologiques de Stockage

### A. Hive (NoSQL Local)
Nous utilisons **Hive** pour stocker les objets métier "lourds" (Projets, Tâches).

*   **Pourquoi Hive ?**
    *   **Performance :** Beaucoup plus rapide que SQL (SQLite) pour la lecture/écriture simple.
    *   **Simplicité :** Stocke directement des objets Dart (NoSQL), pas besoin de mapping complexe relationnel.
    *   **Légèreté :** Librairie 100% Dart, pas de code natif lourd.
*   **Implémentation :**
    *   Chaque entité a sa "Box" (équivalent d'une table).
    *   `HiveService` gère l'ouverture des boîtes au démarrage.

### B. SharedPreferences (Clé-Valeur)
Nous utilisons **SharedPreferences** pour les données "légères" et de configuration.

*   **Usage :**
    *   Token d'authentification (JWT).
    *   Drapeau "Premier lancement" (Onboarding).
    *   Préférences de thème (Dark/Light).
*   **Pourquoi ?**
    *   API native simple pour des paires clé-valeur.
    *   Suffisant pour des données non structurées.

### C. Dio (Réseau)
Nous utilisons **Dio** pour les requêtes HTTP.

*   **Pourquoi ?**
    *   Intercepteurs (pour injecter le Token JWT automatiquement).
    *   Gestion fine des Timeouts et des erreurs.
    *   Facilité de test (Mocking).

---

## 4. Sécurité des Données
1.  **Token JWT :** Stocké localement pour maintenir la session. Injecté dans le header `Authorization` de chaque requête via `ApiClient`.
2.  **Encapsulation :** Les couches supérieures (UI) n'ont jamais accès direct à la base de données ou à l'API. Elles passent obligatoirement par les UseCases.

---

## 5. Résumé des Flux

| Action | Flux de Données |
| :--- | :--- |
| **Lecture** | Local <-- Repository --> Remote (Mise à jour du Local si succès Remote) |
| **Écriture** | App UI -> Repository -> Remote (API) -> (Si Succès) -> Update Local (Hive) |
| **Synchronisation** | Les données locales sont écrasées par les données distantes à chaque lecture réussie ("Last Write Wins" simplifié). |
