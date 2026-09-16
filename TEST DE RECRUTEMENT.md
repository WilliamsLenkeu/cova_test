## TEST DE RECRUTEMENT

## Objectif général du test

- Évaluer la capacité du candidat à concevoir, développer, déployer et documenter une application web et mobile complète, en intégrant un backend Java Spring Boot et un frontend React+Vite+TSX, avec une extension mobile Flutter.

## 🔹 Partie 1 : Description du projet à réaliser

Développer une mini application de gestion de tâches ("Task Manager") permettant à un utilisateur de :

- Créer un compte et se connecter.

- Ajouter, modifier et supprimer des tâches.

- Visualiser la liste de ses tâches (filtrage par statut et recherche).

- Synchroniser les tâches entre le web et mobile.

- Sauvegarder les données dans une API Spring Boot (CRUD complet).

- Déployer le projet sur GCP avec Docker et CI/CD automatisé. (Bonus)

## Sujet :

## 🔹 Partie 2 : Stack technique imposée

Domaine

Frontend Web

React + Vite + TypeScript (TSX) + Tailwind ou Shadcn UI

Backend API

Java Spring Boot + Spring Data JPA + MySQL

Mobile (bonus)

Flutter + Dart (consommation de la même API)

CI/CD & Déploiement

GitHub Actions / Jenkins + Docker + Google Cloud Platform (Cloud Run ou GCE)

Outils / Technologies attendues


## 🔹 Partie 3 : Détails du test

## 🧩 Étape 1 : Backend Spring Boot

Objectif : construire une API RESTful simple.

## Exigences :

## ● Créer les endpoints suivants :

- POST /api/auth/register : inscription d’un utilisateur.

- POST /api/auth/login : connexion (JWT).

- GET /api/tasks : liste des tâches de l’utilisateur connecté.

- POST /api/tasks : création d’une tâche.

- PUT /api/tasks/{id} : modification d’une tâche.

- DELETE /api/tasks/{id} : suppression d’une tâche.

- Entités : User, Task (avec title, description, status, createdAt, updatedAt).

- Base de données : MySQL (avec Docker Compose optionnel).

- Authentification : JWT (Spring Security).

## ⚛️ Étape 2 : Frontend React+Vite+TSX

Objectif : créer une interface utilisateur moderne consommant l’API du backend.

## Exigences :

- Formulaire d’inscription / connexion.

- Liste de tâches (affichage dynamique via fetch API).

- Ajout, édition, suppression des tâches.

- Filtrage par statut et champ de recherche.

- Gestion des erreurs API (alertes, toasts…).

- Stockage du token JWT dans cookies ou localStorage.


## 📱 Étape 3 (Bonus) : Application Mobile Flutter

Objectif : Reproduire l’interface principale (liste et création de tâches).

## Exigences :

- Connexion via l’API Spring Boot (même JWT).

- Affichage et gestion des tâches.

- Utilisation de dio ou http pour les appels API.

- Interface épurée avec ListView, TextField, ElevatedButton.

## ⚙️ Étape 4 (Bonus) : CI/CD & Déploiement

Objectif : montrer une compréhension des outils DevOps.

## Exigences :

- Créer un pipeline CI/CD avec :

- Build et test du backend et frontend.

- Build Docker images (backend + frontend).

- Déploiement sur GCP (Cloud Run ou VM Dockerisée).

- Fichier docker-compose.yml optionnel pour local.

## 🔹 Partie 5 : Modalités de rendu

- Fournir un lien GitHub public du projet (monorepo ou dossier frontend/, backend/, mobile/).

- Inclure un README.md clair avec :

- Instructions d’installation et d’exécution.

- Description technique rapide (architecture, choix techniques).

- Captures d’écran si possible.

- Bonus : un lien déployé (Cloud Run / Firebase Hosting).
