# Générateur de Citations

Une application Flutter permettant de créer de belles images avec vos citations préférées.

## Fonctionnalités

- Création d'images avec vos citations personnalisées
- Personnalisation complète de l'apparence:
  - Différents styles d'arrière-plan (dégradé, uni, motif)
  - Plusieurs styles de polices
  - Différents schémas de couleurs
  - Contrôle de la taille de police
  - Options pour afficher ou masquer le cadre et l'auteur
- Sauvegarde des images sur l'appareil
- Partage des images via les applications installées

## Installation

### Prérequis

- Flutter SDK (version récente)
- Android Studio/VS Code/autre éditeur
- Émulateur ou appareil physique pour le test

### Installation

1. Clonez le dépôt
   ```
   git clone [url_du_dépôt]
   cd generateur_citation
   ```

2. Installez les dépendances
   ```
   flutter pub get
   ```

3. Exécutez l'application
   ```
   flutter run
   ```

## Utilisation

1. Entrez votre citation dans le champ prévu
2. Ajoutez l'auteur (optionnel)
3. Personnalisez l'apparence en utilisant le panneau d'options
4. Cliquez sur "Générer l'image" pour créer votre image
5. Utilisez les boutons "Partager" ou "Télécharger" pour sauvegarder ou partager votre création

## Permissions

Cette application nécessite les permissions suivantes:
- Stockage: pour sauvegarder les images générées
- Internet (facultatif): si vous ajoutez des fonctionnalités en ligne

Pour Android 10+, ajoutez dans `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

## Technologies utilisées

- Flutter
- Dart
- Package image pour la génération d'images
- Package share_plus pour le partage d'images
- Package path_provider pour l'accès au système de fichiers
- Package permission_handler pour la gestion des permissions
- Package logger pour le logging

## Contribution

Les contributions sont les bienvenues! N'hésitez pas à soumettre des pull requests.

## Licence

Ce projet est sous licence [à spécifier].
