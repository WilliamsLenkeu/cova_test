# Mobile (Flutter)

Client Android du Task Manager (même API JWT).

```bash
# API déjà lancée (docker compose ou Spring sur :8080)
flutter run
# téléphone physique :
flutter run --dart-define=API_URL=http://<IP-LAN>:8080
```

Émulateur : `http://10.0.2.2:8080` par défaut.
