import 'dart:typed_data';
import 'package:image/image.dart' as img;
// For Color and other UI elements if needed by functions
import 'package:logger/logger.dart';

// Assuming style_options.dart is in ../models/style_options.dart relative to this file
// Adjust the import path if your final structure is different.
// If style_options.dart is in lib/models/style_options.dart
// and this file is in lib/services/image_service.dart,
// then the import should be:
import '../models/style_options.dart';

final logger = Logger(); // Or pass logger instance if preferred

class ImageService {
  // ÉTAPE 8: Mise à jour de la fonction pour utiliser les options de style
  static Future<Uint8List?> generateStyledImage(
    String quoteText,
    String authorText,
    BackgroundStyle backgroundStyle,
    FontStyle fontStyle,
    ColorSchemeOption colorScheme,
    bool showFrame,
    bool showAuthor,
    double fontSize,
  ) async {
    try {
      // Dimensions de l'image
      const int width = 800;
      const int height = 400;

      // Créer une image vierge
      final image = img.Image(width: width, height: height);

      // ÉTAPE 8.1: Appliquer le style de fond sélectionné
      _applyBackground(image, backgroundStyle, colorScheme);

      // ÉTAPE 8.2: Ajouter un cadre si demandé
      if (showFrame) {
        _applyFrame(image, colorScheme);
      }

      // ÉTAPE 8.3: Dessiner la citation avec le style de police sélectionné
      _drawQuote(image, quoteText, fontStyle, colorScheme, fontSize);

      // ÉTAPE 8.4: Dessiner l'auteur si demandé
      if (showAuthor && authorText.isNotEmpty) {
        _drawAuthor(image, authorText, fontStyle, colorScheme);
      }

      // Encoder l'image en PNG
      final List<int> pngBytes = img.encodePng(image);

      return Uint8List.fromList(pngBytes);
        } catch (e) {
      logger.e("Erreur pendant la génération d'image: $e");
      return null;
    }
  }

  // ÉTAPE 8.5: Fonction pour appliquer le fond selon le style choisi
  static void _applyBackground(
    img.Image image,
    BackgroundStyle style,
    ColorSchemeOption colorScheme,
  ) {
    // Obtenir les couleurs en fonction du schéma de couleurs
    final List<img.ColorRgb8> colors = _getColorsForScheme(colorScheme);

    switch (style) {
      case BackgroundStyle.solid:
        // Remplir avec une couleur unie
        img.fill(image, color: colors[0]);
        break;

      case BackgroundStyle.gradient:
        // Créer un dégradé du haut vers le bas
        for (int y = 0; y < image.height; y++) {
          for (int x = 0; x < image.width; x++) {
            final double ratio = y / image.height;
            final color1 = colors[0];
            final color2 = colors[1];

            final int r = (color1.r * (1 - ratio) + color2.r * ratio).round();
            final int g = (color1.g * (1 - ratio) + color2.g * ratio).round();
            final int b = (color1.b * (1 - ratio) + color2.b * ratio).round();

            image.setPixel(x, y, img.ColorRgb8(r, g, b));
          }
        }
        break;

      case BackgroundStyle.pattern:
        // Un motif simple (rayures)
        img.fill(image, color: colors[0]);
        final patternColor = colors[1];

        for (int y = 0; y < image.height; y += 20) {
          for (int x = 0; x < image.width; x++) {
            // Dessiner une ligne horizontale toutes les 20 pixels
            if (y < image.height) {
              image.setPixel(x, y, patternColor);
            }
          }
        }
        break;
    }
  }

  // ÉTAPE 8.6: Fonction pour dessiner un cadre
  static void _applyFrame(img.Image image, ColorSchemeOption colorScheme) {
    final List<img.ColorRgb8> colors = _getColorsForScheme(colorScheme);
    final frameColor =
        colors.length > 2 ? colors[2] : img.ColorRgb8(255, 255, 255);

    // Dessiner un rectangle avec la couleur du cadre
    img.drawRect(
      image,
      x1: 10,
      y1: 10,
      x2: image.width - 10,
      y2: image.height - 10,
      color: frameColor,
      thickness: 3,
    );
  }

  // ÉTAPE 8.7: Fonction pour dessiner la citation
  static void _drawQuote(
    img.Image image,
    String quoteText,
    FontStyle fontStyle,
    ColorSchemeOption colorScheme,
    double fontSize,
  ) {
    final List<img.ColorRgb8> colors = _getColorsForScheme(colorScheme);
    final textColor =
        colors.length > 3 ? colors[3] : img.ColorRgb8(255, 255, 255);

    // Sélectionner la police selon le style
    img.BitmapFont font;
    switch (fontStyle) {
      case FontStyle.modern:
        font = img.arial24; // Utiliser une police disponible
        break;
      case FontStyle.script:
        font = img.arial24; // Remplacer par une police script si disponible
        break;
      case FontStyle.bold:
        font = img.arial24; // Remplacer par une police bold si disponible
        break;
      case FontStyle.classic:
      default: // Added default for safety
        font = img.arial24;
    }

    // Dessiner les guillemets avant la citation
    img.drawString(
      image,
      '"', // Escaped quote
      font: font,
      x: 30,
      y: image.height ~/ 3 - 10,
      color: textColor,
    );

    // Dessiner la citation
    img.drawString(
      image,
      quoteText,
      font: font,
      x: 50,
      y: image.height ~/ 3,
      color: textColor,
    );

    // Dessiner les guillemets après la citation
    img.drawString(
      image,
      '"', // Escaped quote
      font: font,
      x: 60 + (quoteText.length * 10).clamp(0, image.width - 100),
      y: image.height ~/ 3 - 10,
      color: textColor,
    );
  }

  // ÉTAPE 8.8: Fonction pour dessiner l'auteur
  static void _drawAuthor(
    img.Image image,
    String authorText,
    FontStyle fontStyle, // fontStyle might not be used here, consider removing if not needed
    ColorSchemeOption colorScheme,
  ) {
    final List<img.ColorRgb8> colors = _getColorsForScheme(colorScheme);
    final textColor =
        colors.length > 3 ? colors[3] : img.ColorRgb8(255, 255, 255);

    // Consider using a font based on fontStyle if desired, like in _drawQuote
    img.drawString(
      image,
      '- $authorText',
      font: img.arial14, // Using a fixed font for author currently
      x: image.width - 150,
      y: image.height - 50,
      color: textColor,
    );
  }

  // ÉTAPE 8.9: Fonction pour obtenir les couleurs selon le schéma choisi
  static List<img.ColorRgb8> _getColorsForScheme(ColorSchemeOption scheme) {
    switch (scheme) {
      case ColorSchemeOption.blue:
        return [
          img.ColorRgb8(150, 200, 255), // Bleu clair
          img.ColorRgb8(100, 150, 200), // Bleu foncé
          img.ColorRgb8(255, 255, 255), // Blanc pour le cadre
          img.ColorRgb8(255, 255, 255), // Blanc pour le texte
        ];
      case ColorSchemeOption.green:
        return [
          img.ColorRgb8(150, 220, 150), // Vert clair
          img.ColorRgb8(70, 150, 70), // Vert foncé
          img.ColorRgb8(255, 255, 255), // Blanc pour le cadre
          img.ColorRgb8(255, 255, 255), // Blanc pour le texte
        ];
      case ColorSchemeOption.purple:
        return [
          img.ColorRgb8(200, 150, 220), // Violet clair
          img.ColorRgb8(130, 80, 170), // Violet foncé
          img.ColorRgb8(255, 255, 255), // Blanc pour le cadre
          img.ColorRgb8(255, 255, 255), // Blanc pour le texte
        ];
      case ColorSchemeOption.sunset:
        return [
          img.ColorRgb8(255, 200, 130), // Orange clair
          img.ColorRgb8(220, 100, 90), // Rouge-orange
          img.ColorRgb8(255, 255, 255), // Blanc pour le cadre
          img.ColorRgb8(255, 255, 255), // Blanc pour le texte
        ];
      case ColorSchemeOption.grayscale:
      default: // Added default for safety
        return [
          img.ColorRgb8(220, 220, 220), // Gris clair
          img.ColorRgb8(80, 80, 80), // Gris foncé
          img.ColorRgb8(255, 255, 255), // Blanc pour le cadre
          img.ColorRgb8(255, 255, 255), // Blanc pour le texte
        ];
    }
  }
} 