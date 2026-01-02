# Documentation Technique de l'Architecture - Projet Pegasus

## 1. Introduction & Philosophie
Ce document détaille l'architecture technique de l'application mobile Pegasus. Le projet est construit sur les principes de la **Clean Architecture** (proposée par Robert C. Martin), couplée au pattern **BLoC** (Business Logic Component) pour la gestion d'état.

Cette approche garantit :
*   **L'indépendance du Framework :** La logique métier ne dépend pas de l'interface utilisateur (Flutter).
*   **La Testabilité :** Chaque couche peut être testée isolément.
*   **La Maintenabilité :** Une séparation claire des responsabilités facilite les évolutions futures.

## 2. Structure Globale des Couches
L'application est divisée en trois couches principales pour chaque fonctionnalité (*Feature*) :

### A. Domain Layer (Couche Domaine)
*C'est le cœur de l'application. Elle ne dépend d'aucune autre couche.*
*   **Entities :** Objets métier purs (ex: `User`, `Project`, `Task`).
*   **Repositories (Interfaces) :** Contrats définissant les opérations possibles sur les données, sans se soucier de leur provenance (API, Cache...).
*   **Use Cases :** Règles métier spécifiques. Chaque classe encapsule une action unique (ex: `LoginUseCase`, `CreateProjectUseCase`).

### B. Data Layer (Couche Données)
*Cette couche implémente les contrats du Domaine.*
*   **Models :** Extensions des entités avec des méthodes de sérialisation/désérialisation (JSON, Hive).
*   **Data Sources :**
    *   *Remote :* Appels API (via Dio).
    *   *Local :* Persistance des données (via Hive et SharedPreferences).
*   **Repositories (Implémentations) :** Orchestrent la récupération des données (décision entre local ou distant) et gèrent les erreurs.

### C. Presentation Layer (Couche Présentation)
*Interface utilisateur et gestion d'état.*
*   **BLoC :** Reçoit des événements (Events), exécute des Use Cases, et émet des états (States).
*   **Pages :** Écrans complets (`Scaffold`).
*   **Widgets :** Composants réutilisables.

---

## 3. Analyse Détaillée de l'Arborescence

Voici le rôle précis de chaque dossier et fichier clé dans `lib/` :

### 📂 `lib/config/`
Contient la configuration globale de l'application.
*   **`routes/router.dart` :** Configuration de **GoRouter**. Définit toutes les routes, les redirections et les gardes (auth guards).
*   **`theme/app_theme.dart` :** Définition des thèmes clair et sombre (couleurs, typographie).
*   **`injection/injection_container.dart` :** Configuration de **GetIt**. C'est ici que nous enregistrons toutes nos dépendances (DataSources, Repositories, UseCases, BLoCs) pour l'injection de dépendances.

### 📂 `lib/core/`
Contient les éléments transversaux et partagés.
*   **`errors/`** :
    *   `failures.dart` : Classes d'erreurs métier utilisées par le Domaine.
    *   `exceptions.dart` : Classes d'exceptions techniques utilisées par la couche Data.
*   **`usecases/usecase.dart`** : Interface générique pour tous les Use Cases.
*   **`network/`** :
    *   `network_info.dart` : Gestion de la connectivité (Internet).
    *   `api_client.dart` : Configuration du client HTTP (Dio).
*   **`storage/`** :
    *   `hive_service.dart` : Initialisation et gestion de la base de données locale Hive.
    *   `preferences_service.dart` : Gestion des préférences simples (SharedPreferences).

### 📂 `lib/features/`
Regroupe les modules fonctionnels. Chaque dossier (Auth, Projects, Tasks, Dashboard) suit strictement la structure : `data`, `domain`, `presentation`.

#### Exemple détaillé avec le module `Projects` :

**`features/projects/domain/`**
*   `entities/project.dart` : Classe définissant ce qu'est un projet (id, titre, description...).pou
*   `repositories/project_repository.dart` : Interface `abstract class` listant les méthodes requises (`getProjects`, `createProject`...).
*   `usecases/` :
    *   `create_project_usecase.dart` : Logique de création.
    *   `calculate_project_progress_usecase.dart` : Logique complexe de calcul de progression.

**`features/projects/data/`**
*   `models/project_model.dart` : Hérite de `Project`. Contient `fromJson`, `toJson`, et les annotations Hive.
*   `datasources/` :
    *   `project_remote_datasource.dart` : Appels API REST.
    *   `project_local_datasource.dart` : Opérations CRUD sur la box Hive locale.
*   `repositories/project_repository_impl.dart` : Implémente l'interface du domaine. Gère la logique "Offline-First" (essaie le réseau, sinon le cache, ou met en cache après le réseau).

**`features/projects/presentation/`**
*   `bloc/` :
    *   `project_event.dart` : Actions utilisateur (`LoadProjects`, `AddProject`).
    *   `project_state.dart` : États de l'écran (`ProjectLoading`, `ProjectsLoaded`, `ProjectError`).
    *   `project_bloc.dart` : Logique de mapping Event -> State.
*   `pages/project_list_page.dart` : Écran principal affichant la liste.
*   `widgets/project_card.dart` : Composant visuel unitaire.

### 📂 Fichiers Racine

*   **`lib/main.dart` :** Point d'entrée. 
    *   Initialise Flutter binding.
    *   Appelle `di.init()` pour l'injection de dépendances.
    *   Configure `MaterialApp` avec le `routerConfig` et le `BlocProvider` global (Auth).

---

## 4. Flux de Données Type
Pour illustrer le fonctionnement, voici le cheminement d'une action "Charger le Dashboard" :

1.  **UI :** `DashboardPage` est construite. Elle demande le `DashboardBloc`.
2.  **BLoC :** `DashboardPage` ajoute l'événement `LoadDashboardData` au BLoC.
3.  **BLoC :** Le `DashboardBloc` reçoit l'événement. Il appelle plusieurs **Use Cases** en parallèle (`GetProjects`, `GetTasks`).
4.  **Use Case :** `GetProjectsUseCase` appelle `projectRepository.getProjects()`.
5.  **Repository :** `ProjectRepositoryImpl` vérifie la connexion internet via `NetworkInfo`.
    *   *Si connecté :* Appelle `RemoteDataSource` (API), sauvegarde le résultat dans `LocalDataSource` (Hive), et retourne les données.
    *   *Si hors ligne :* Récupère les données depuis `LocalDataSource`.
6.  **BLoC :** Reçoit les données (ou une erreur `Failure`), calcule les statistiques finales, et émet l'état `DashboardLoaded`.
7.  **UI :** `BlocBuilder` écoute le changement d'état et reconstruit l'interface avec les nouvelles données.

## 5. Choix Techniques Clés
*   **Injection de dépendances (`get_it`) :** Permet de découpler les classes. Si nous voulons changer la base de données locale, nous changeons juste l'implémentation injectée dans `injection_container.dart` sans toucher au reste du code.
*   **Programmation Fonctionnelle (`dartz`) :** Utilisation du type `Either<Failure, Type>` pour forcer la gestion explicite des erreurs et éviter les blocs `try-catch` éparpillés.
*   **Mode Hors-Ligne :** Priorité donnée à la continuité de service grâce à la stratégie de mise en cache systématique.
