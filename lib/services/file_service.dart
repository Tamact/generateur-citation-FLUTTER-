import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart'; // For BuildContext, ScaffoldMessenger, etc.
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:logger/logger.dart';

final logger = Logger(); // Or pass logger instance

class FileService {
  // ÉTAPE 9: Fonction pour partager l'image générée
  static Future<void> shareImage(
      BuildContext context, Uint8List? imageBytes) async {
    if (imageBytes == null) {
      // Check for mounted if context is used across async gap potentially
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune image à partager')),
        );
      }
      return;
    }

    try {
      // Créer un fichier temporaire pour l'image
      final directory = await getTemporaryDirectory();
      final String fileName =
          'citation_${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = '${directory.path}/$fileName';

      // Écrire les données de l'image dans le fichier
      final File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      // Partager le fichier
      // final result = // No need to use result for now unless logging share status
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Voici une citation que j\'ai générée!', // Escaped apostrophe
        subject: 'Citation Inspirante',
      );
      // logger.d('Résultat du partage: ${result.status}'); // Optional logging
    } catch (e) {
      logger.e('Erreur lors du partage: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erreur lors du partage')));
      }
    }
  }

  // Fonction pour sauvegarder l'image sur l'appareil
  static Future<void> saveImageToGallery(
      BuildContext context, Uint8List? imageBytes) async {
    if (imageBytes == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune image à sauvegarder')),
        );
      }
      return;
    }

    try {
      // Demander la permission d'accès au stockage
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Permission refusée')));
        }
        return;
      }

      // Obtenir le répertoire de stockage
      // Using getApplicationDocumentsDirectory for broader compatibility
      // For saving to gallery, platform-specific solutions or plugins like 'image_gallery_saver' are often better.
      // This saves to app's documents directory.
      final directory = await getApplicationDocumentsDirectory();
      final String fileName =
          'citation_${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = '${directory.path}/$fileName';

      // Écrire les données de l'image dans un fichier
      final File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image sauvegardée: $filePath')));
      }
      logger.d('Image sauvegardée à: $filePath');
    } catch (e) {
      logger.e('Erreur lors de la sauvegarde: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la sauvegarde')),
        );
      }
    }
  }
}