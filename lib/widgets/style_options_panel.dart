import 'package:flutter/material.dart';
import '../models/style_options.dart';

// Helper function to get display names for BackgroundStyle
String _backgroundStyleDisplayName(BackgroundStyle style) {
  switch (style) {
    case BackgroundStyle.gradient:
      return 'Dégradé';
    case BackgroundStyle.solid:
      return 'Uni';
    case BackgroundStyle.pattern:
      return 'Motif';
    default:
      return style.toString().split('.').last; // Fallback
  }
}

// Helper function to get display names for FontStyle
String _fontStyleDisplayName(FontStyle style) {
  switch (style) {
    case FontStyle.classic:
      return 'Classique';
    case FontStyle.modern:
      return 'Moderne';
    case FontStyle.script:
      return 'Script';
    case FontStyle.bold:
      return 'Gras';
    default:
      return style.toString().split('.').last; // Fallback
  }
}

// Helper function to get display names for ColorSchemeOption
String _colorSchemeDisplayName(ColorSchemeOption scheme) {
  switch (scheme) {
    case ColorSchemeOption.blue:
      return 'Bleu';
    case ColorSchemeOption.green:
      return 'Vert';
    case ColorSchemeOption.purple:
      return 'Violet';
    case ColorSchemeOption.sunset:
      return 'Coucher de soleil';
    case ColorSchemeOption.grayscale:
      return 'Noir & Blanc';
    default:
      return scheme.toString().split('.').last; // Fallback
  }
}

// Helper function to get background colors for ColorSchemeOption chips
Color _colorSchemeChipBackgroundColor(ColorSchemeOption scheme) {
  switch (scheme) {
    case ColorSchemeOption.blue:
      return Colors.blue.shade100;
    case ColorSchemeOption.green:
      return Colors.green.shade100;
    case ColorSchemeOption.purple:
      return Colors.purple.shade100;
    case ColorSchemeOption.sunset:
      return Colors.orange.shade100;
    case ColorSchemeOption.grayscale:
      return Colors.grey.shade100;
    default:
      return Colors.grey.shade300; // Fallback
  }
}

class StyleOptionsPanel extends StatelessWidget {
  final BackgroundStyle selectedBackgroundStyle;
  final FontStyle selectedFontStyle;
  final ColorSchemeOption selectedColorScheme;
  final bool showFrame;
  final bool showAuthor;
  final double fontSize;

  final ValueChanged<BackgroundStyle> onBackgroundStyleChanged;
  final ValueChanged<FontStyle> onFontStyleChanged;
  final ValueChanged<ColorSchemeOption> onColorSchemeChanged;
  final ValueChanged<bool> onShowFrameChanged;
  final ValueChanged<bool> onShowAuthorChanged;
  final ValueChanged<double> onFontSizeChanged;

  const StyleOptionsPanel({
    super.key,
    required this.selectedBackgroundStyle,
    required this.selectedFontStyle,
    required this.selectedColorScheme,
    required this.showFrame,
    required this.showAuthor,
    required this.fontSize,
    required this.onBackgroundStyleChanged,
    required this.onFontStyleChanged,
    required this.onColorSchemeChanged,
    required this.onShowFrameChanged,
    required this.onShowAuthorChanged,
    required this.onFontSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                children: BackgroundStyle.values.map((style) {
                  return ChoiceChip(
                    label: Text(_backgroundStyleDisplayName(style)),
                    selected: selectedBackgroundStyle == style,
                    onSelected: (selected) {
                      if (selected) {
                        onBackgroundStyleChanged(style);
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Sélection du style de police
              const Text(
                'Style de police:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 10,
                children: FontStyle.values.map((style) {
                  return ChoiceChip(
                    label: Text(_fontStyleDisplayName(style)),
                    selected: selectedFontStyle == style,
                    onSelected: (selected) {
                      if (selected) {
                        onFontStyleChanged(style);
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Sélection du schéma de couleurs
              const Text(
                'Schéma de couleurs:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 10,
                children: ColorSchemeOption.values.map((scheme) {
                  return ChoiceChip(
                    label: Text(_colorSchemeDisplayName(scheme)),
                    selected: selectedColorScheme == scheme,
                    onSelected: (selected) {
                      if (selected) {
                        onColorSchemeChanged(scheme);
                      }
                    },
                    backgroundColor: _colorSchemeChipBackgroundColor(scheme),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Taille de police
              const Text(
                'Taille de police:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Slider(
                value: fontSize,
                min: 14.0,
                max: 36.0,
                divisions: 11,
                label: '${fontSize.round()}',
                onChanged: onFontSizeChanged,
              ),

              const SizedBox(height: 12),

              // Options supplémentaires
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Afficher le cadre'),
                      value: showFrame,
                      onChanged: (bool? value) {
                        onShowFrameChanged(value ?? true);
                      },
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Afficher l\'auteur'),
                      value: showAuthor,
                      onChanged: (bool? value) {
                        onShowAuthorChanged(value ?? true);
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
}