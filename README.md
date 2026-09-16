# Task Manager

Gestion de tâches avec un compte. Tu crées / modifies / supprimes tes tâches, tu filtres par statut et tu cherches dans le titre.

Stack : Spring Boot 4, MySQL, JWT, React (Vite + Tailwind).

## Lancer

Il faut Docker.

```bash
docker compose up --build
```

Ensuite : [http://localhost](http://localhost). L’API passe par nginx (`/api`) ; le backend écoute aussi sur le port 8080.

Pour tout stopper : `docker compose down`.

```
backend/     API Java
frontend/    UI React
docker-compose.yml
```

## API

```
POST   /api/auth/register     { name, email, password }
POST   /api/auth/login        { email, password }
GET    /api/tasks             ?status=&q=
POST   /api/tasks
PUT    /api/tasks/{id}
DELETE /api/tasks/{id}
```

Statuts : `TODO`, `IN_PROGRESS`, `DONE`. Une tâche appartient à l’utilisateur du JWT (stocké en `localStorage`). Filtre et recherche côté serveur.

CI sur GitHub Actions : tests Maven, build Vite, build des deux images.

## Captures

![Connexion](screenshots/login.png)

![Inscription](screenshots/register.png)

![Liste des tâches](screenshots/tasks.png)
