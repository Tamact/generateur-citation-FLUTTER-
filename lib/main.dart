// Contenu complet pour lib/main.dart à la fin de l'Étape 2

import 'package:flutter/material.dart';
import 'dart:typed_data'; // Pour Uint8List
import 'package:logger/logger.dart';
import 'models/style_options.dart'; // Import for the new style options file
import 'services/image_service.dart'; // Import for the new image service
import 'services/file_service.dart'; // Import for the new file service
import 'widgets/style_options_panel.dart'; // Import the new widget

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
// enum BackgroundStyle { gradient, solid, pattern }

// enum FontStyle { classic, modern, script, bold }

// enum ColorSchemeOption { blue, green, purple, sunset, grayscale }

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
                StyleOptionsPanel(
                  selectedBackgroundStyle: _selectedBackgroundStyle,
                  selectedFontStyle: _selectedFontStyle,
                  selectedColorScheme: _selectedColorScheme,
                  showFrame: _showFrame,
                  showAuthor: _showAuthor,
                  fontSize: _fontSize,
                  onBackgroundStyleChanged: (value) {
                    setState(() => _selectedBackgroundStyle = value);
                  },
                  onFontStyleChanged: (value) {
                    setState(() => _selectedFontStyle = value);
                  },
                  onColorSchemeChanged: (value) {
                    setState(() => _selectedColorScheme = value);
                  },
                  onShowFrameChanged: (value) {
                    setState(() => _showFrame = value);
                  },
                  onShowAuthorChanged: (value) {
                    setState(() => _showAuthor = value);
                  },
                  onFontSizeChanged: (value) {
                    setState(() => _fontSize = value);
                  },
                ),

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
                                      await ImageService.generateStyledImage(
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
                                      setState(() {
                                        _generatedImageBytes = null;
                                      });
                                    }
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
                            _generatedImageBytes == null ? null : () => FileService.shareImage(context, _generatedImageBytes),
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
                                : () => FileService.saveImageToGallery(context, _generatedImageBytes),
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
