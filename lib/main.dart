// Contenu complet pour lib/main.dart à la fin de l'Étape 2

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data'; // Pour Uint8List
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

// Créer une instance de logger pour l'application
final logger = Logger();

// Fonction principale qui lance l'application Flutter
void main() {
  // runApp prend le widget racine de l'application et l'attache à l'écran
  runApp(const MyApp());
}

// Le widget racine de l'application.
// StatelessWidget signifie qu'il n'a pas d'état interne qui change.
class MyApp extends StatelessWidget {
  // Constructeur standard pour un widget sans état
  const MyApp({super.key});

  // La méthode build décrit comment construire ce widget
  @override
  Widget build(BuildContext context) {
    // MaterialApp est un widget de base qui configure l'application
    // pour utiliser le design Material (style Android/Google).
    return MaterialApp(
      // Titre utilisé par le système d'exploitation (ex: gestionnaire de tâches)
      title: 'Générateur de Citations',

      // Thème visuel de l'application
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
          primary: Colors.teal,
          secondary: Colors.amber,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),

      // L'écran (ou "route") qui sera affiché au démarrage de l'application
      home: const HomeScreen(), // Notre écran principal
      // Optionnel: Cache la petite bannière "DEBUG" en haut à droite
      debugShowCheckedModeBanner: false,
    );
  }
}

// ÉTAPE 7.1: Définir les énumérations pour les options de style
enum BackgroundStyle { gradient, solid, pattern }

enum FontStyle { classic, modern, script, bold }

enum ColorSchemeOption { blue, green, purple, sunset, grayscale }

// Notre écran principal pour l'application.
// DOIT être un StatefulWidget car son état (le texte des champs) peut changer.
class HomeScreen extends StatefulWidget {
  // Constructeur standard pour un StatefulWidget
  const HomeScreen({super.key});

  // La méthode createState est requise pour un StatefulWidget.
  // Elle crée l'objet State mutable associé à ce widget.
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// La classe State associée à HomeScreen.
// C'est ici que l'on stocke les données qui changent (l'état)
// et que l'on construit l'interface utilisateur (dans la méthode build).
class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // TextEditingController est utilisé pour lire et contrôler le texte d'un TextField.
  // 'final' signifie que la référence au contrôleur ne changera pas,
  // mais le contenu du contrôleur (le texte) peut changer.
  final _quoteController = TextEditingController();
  final _authorController = TextEditingController();

  // Variable pour stocker les bytes de l'image générée
  Uint8List? _generatedImageBytes;
  bool _isLoading = false;

  // ÉTAPE 7.2: Ajouter des variables pour les options de style
  BackgroundStyle _selectedBackgroundStyle = BackgroundStyle.gradient;
  FontStyle _selectedFontStyle = FontStyle.classic;
  ColorSchemeOption _selectedColorScheme = ColorSchemeOption.blue;
  bool _showFrame = true;
  bool _showAuthor = true;
  double _fontSize = 24.0; // Taille de police par défaut

  // Animation controller pour les effets visuels
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // La méthode initState est appelée lorsque l'objet State est créé.
  @override
  void initState() {
    super.initState();

    // Initialisation des animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  // La méthode dispose est appelée lorsque l'objet State est définitivement retiré
  // de l'arbre des widgets. C'est l'endroit idéal pour nettoyer les ressources.
  @override
  void dispose() {
    // Il est crucial de 'dispose' les contrôleurs pour éviter les fuites de mémoire.
    _quoteController.dispose();
    _authorController.dispose();
    _animationController.dispose();
    // Toujours appeler super.dispose() à la fin de votre propre méthode dispose.
    super.dispose();
  }

  // ÉTAPE 8: Mise à jour de la fonction pour utiliser les options de style
  Future<Uint8List?> generateStyledImage(
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
      final List<int>? pngBytes = img.encodePng(image);

      if (pngBytes != null) {
        return Uint8List.fromList(pngBytes);
      } else {
        logger.e("Erreur: L'encodage PNG a échoué.");
        return null;
      }
    } catch (e) {
      logger.e("Erreur pendant la génération d'image: $e");
      return null;
    }
  }

  // ÉTAPE 8.5: Fonction pour appliquer le fond selon le style choisi
  void _applyBackground(
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
  void _applyFrame(img.Image image, ColorSchemeOption colorScheme) {
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
  void _drawQuote(
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
        font = img.arial24;
    }

    // Dessiner les guillemets avant la citation
    img.drawString(
      image,
      '"',
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
      '"',
      font: font,
      x: 60 + (quoteText.length * 10).clamp(0, image.width - 100),
      y: image.height ~/ 3 - 10,
      color: textColor,
    );
  }

  // ÉTAPE 8.8: Fonction pour dessiner l'auteur
  void _drawAuthor(
    img.Image image,
    String authorText,
    FontStyle fontStyle,
    ColorSchemeOption colorScheme,
  ) {
    final List<img.ColorRgb8> colors = _getColorsForScheme(colorScheme);
    final textColor =
        colors.length > 3 ? colors[3] : img.ColorRgb8(255, 255, 255);

    img.drawString(
      image,
      '- $authorText',
      font: img.arial14,
      x: image.width - 150,
      y: image.height - 50,
      color: textColor,
    );
  }

  // ÉTAPE 8.9: Fonction pour obtenir les couleurs selon le schéma choisi
  List<img.ColorRgb8> _getColorsForScheme(ColorSchemeOption scheme) {
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
        return [
          img.ColorRgb8(220, 220, 220), // Gris clair
          img.ColorRgb8(80, 80, 80), // Gris foncé
          img.ColorRgb8(255, 255, 255), // Blanc pour le cadre
          img.ColorRgb8(255, 255, 255), // Blanc pour le texte
        ];
    }
  }

  // ÉTAPE 9: Fonction pour partager l'image générée
  Future<void> _shareImage() async {
    if (_generatedImageBytes == null) {
      if (mounted) {
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
      await file.writeAsBytes(_generatedImageBytes!);

      // Partager le fichier
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Voici une citation que j\'ai générée!',
        subject: 'Citation Inspirante',
      );

      logger.d('Résultat du partage: ${result.status}');
    } catch (e) {
      logger.e('Erreur lors du partage: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erreur lors du partage')));
      }
    }
  }

  // Fonction pour sauvegarder l'image sur l'appareil
  Future<void> _saveImageToGallery() async {
    if (_generatedImageBytes == null) {
      if (mounted) {
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
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Permission refusée')));
        }
        return;
      }

      // Obtenir le répertoire de stockage
      final directory = await getApplicationDocumentsDirectory();
      final String fileName =
          'citation_${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = '${directory.path}/$fileName';

      // Écrire les données de l'image dans un fichier
      final File file = File(filePath);
      await file.writeAsBytes(_generatedImageBytes!);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Image sauvegardée: $filePath')));
      }
      logger.d('Image sauvegardée à: $filePath');
    } catch (e) {
      logger.e('Erreur lors de la sauvegarde: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la sauvegarde')),
        );
      }
    }
  }

  // ÉTAPE 7.3: Construire le panneau d'options de style
  Widget _buildStyleOptionsPanel() {
    return ExpansionTile(
      title: const Text(
        'Options de style',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('Personnalisez l\'apparence de votre citation'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sélection du style de fond
              const Text(
                'Style d\'arrière-plan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text('Dégradé'),
                    selected:
                        _selectedBackgroundStyle == BackgroundStyle.gradient,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedBackgroundStyle = BackgroundStyle.gradient;
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Uni'),
                    selected: _selectedBackgroundStyle == BackgroundStyle.solid,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedBackgroundStyle = BackgroundStyle.solid;
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Motif'),
                    selected:
                        _selectedBackgroundStyle == BackgroundStyle.pattern,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedBackgroundStyle = BackgroundStyle.pattern;
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Sélection du style de police
              const Text(
                'Style de police:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text('Classique'),
                    selected: _selectedFontStyle == FontStyle.classic,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFontStyle = FontStyle.classic;
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Moderne'),
                    selected: _selectedFontStyle == FontStyle.modern,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFontStyle = FontStyle.modern;
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Script'),
                    selected: _selectedFontStyle == FontStyle.script,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFontStyle = FontStyle.script;
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Gras'),
                    selected: _selectedFontStyle == FontStyle.bold,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFontStyle = FontStyle.bold;
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Sélection du schéma de couleurs
              const Text(
                'Schéma de couleurs:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text('Bleu'),
                    selected: _selectedColorScheme == ColorSchemeOption.blue,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedColorScheme = ColorSchemeOption.blue;
                        });
                      }
                    },
                    backgroundColor: Colors.blue.shade100,
                  ),
                  ChoiceChip(
                    label: const Text('Vert'),
                    selected: _selectedColorScheme == ColorSchemeOption.green,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedColorScheme = ColorSchemeOption.green;
                        });
                      }
                    },
                    backgroundColor: Colors.green.shade100,
                  ),
                  ChoiceChip(
                    label: const Text('Violet'),
                    selected: _selectedColorScheme == ColorSchemeOption.purple,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedColorScheme = ColorSchemeOption.purple;
                        });
                      }
                    },
                    backgroundColor: Colors.purple.shade100,
                  ),
                  ChoiceChip(
                    label: const Text('Coucher de soleil'),
                    selected: _selectedColorScheme == ColorSchemeOption.sunset,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedColorScheme = ColorSchemeOption.sunset;
                        });
                      }
                    },
                    backgroundColor: Colors.orange.shade100,
                  ),
                  ChoiceChip(
                    label: const Text('Noir & Blanc'),
                    selected:
                        _selectedColorScheme == ColorSchemeOption.grayscale,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedColorScheme = ColorSchemeOption.grayscale;
                        });
                      }
                    },
                    backgroundColor: Colors.grey.shade100,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Taille de police
              const Text(
                'Taille de police:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _fontSize,
                min: 14.0,
                max: 36.0,
                divisions: 11,
                label: '${_fontSize.round()}',
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                },
              ),

              const SizedBox(height: 12),

              // Options supplémentaires
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Afficher le cadre'),
                      value: _showFrame,
                      onChanged: (bool? value) {
                        setState(() {
                          _showFrame = value ?? true;
                        });
                      },
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Afficher l\'auteur'),
                      value: _showAuthor,
                      onChanged: (bool? value) {
                        setState(() {
                          _showAuthor = value ?? true;
                        });
                      },
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // La méthode build est appelée pour construire (ou reconstruire) l'interface
  // visuelle de cet état. Elle est appelée initialement et chaque fois que
  // l'état change (par exemple, via setState(), que nous verrons plus tard).
  @override
  Widget build(BuildContext context) {
    // Scaffold fournit la structure de base de l'écran.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générateur de Citations'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête
                const Text(
                  'Créez une belle image avec votre citation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Champ de texte pour la citation
                TextField(
                  controller: _quoteController,
                  decoration: const InputDecoration(
                    labelText: 'Citation',
                    hintText: 'Entrez la citation ici...',
                    prefixIcon: Icon(Icons.format_quote),
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 16),

                // Champ de texte pour l'auteur
                TextField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                    labelText: 'Auteur',
                    hintText: 'Nom de l\'auteur (optionnel)',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                const SizedBox(height: 16),

                // ÉTAPE 7.4: Intégrer le panneau d'options de style dans l'interface
                _buildStyleOptionsPanel(),

                const SizedBox(height: 20),

                // Boutons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Bouton pour générer l'image
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _isLoading
                                ? null
                                : () async {
                                  final String currentQuote =
                                      _quoteController.text;
                                  final String currentAuthor =
                                      _authorController.text;

                                  if (currentQuote.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Veuillez entrer une citation',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    _isLoading = true;
                                  });

                                  logger.d(
                                    'Génération de l\'image pour: "$currentQuote"',
                                  );

                                  // ÉTAPE 8.10: Utiliser la fonction générique avec les options de style
                                  final Uint8List? imageBytes =
                                      await generateStyledImage(
                                        currentQuote,
                                        currentAuthor,
                                        _selectedBackgroundStyle,
                                        _selectedFontStyle,
                                        _selectedColorScheme,
                                        _showFrame,
                                        _showAuthor,
                                        _fontSize,
                                      );

                                  if (!mounted) return;

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  if (imageBytes != null) {
                                    logger.d(
                                      'Image générée avec succès! (${imageBytes.lengthInBytes} bytes)',
                                    );
                                    setState(() {
                                      _generatedImageBytes = imageBytes;
                                    });

                                    // Déclencher l'animation
                                    _animationController.reset();
                                    _animationController.forward();
                                  } else {
                                    logger.e(
                                      'La génération de l\'image a échoué.',
                                    );
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Erreur lors de la génération de l\'image',
                                          ),
                                        ),
                                      );
                                    }
                                    setState(() {
                                      _generatedImageBytes = null;
                                    });
                                  }
                                },
                        icon:
                            _isLoading
                                ? Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.all(2.0),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                                : const Icon(Icons.image),
                        label: Text(
                          _isLoading ? 'Génération...' : 'Générer l\'image',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ÉTAPE 9.2: Boutons pour le partage et téléchargement
                Row(
                  children: [
                    // Bouton pour partager l'image
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _generatedImageBytes == null ? null : _shareImage,
                        icon: const Icon(Icons.share),
                        label: const Text('Partager'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Bouton pour télécharger l'image
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _generatedImageBytes == null
                                ? null
                                : _saveImageToGallery,
                        icon: const Icon(Icons.download),
                        label: const Text('Télécharger'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Aperçu de l'image
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator()
                            : (_generatedImageBytes == null
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'L\'image générée apparaîtra ici',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                )
                                : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    _generatedImageBytes!,
                                    fit: BoxFit.contain,
                                  ),
                                )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } // Fin de la méthode build.
} // Fin de la classe _HomeScreenState.
