import 'dart:html' as html;

class UrlLauncher {
  /// Ouvrir une URL dans un nouvel onglet (Flutter Web)
  static void openUrl(String url) {
    try {
      if (url.isNotEmpty) {
        // Ouvrir l'URL dans un nouvel onglet
        html.window.open(url, '_blank');
        print('URL ouverte dans un nouvel onglet: $url');
      }
    } catch (e) {
      print('Erreur lors de l\'ouverture de l\'URL: $e');
      // Fallback: copier l'URL dans le presse-papiers
      _copyToClipboard(url);
    }
  }
  
  /// Copier l'URL dans le presse-papiers (fallback)
  static void _copyToClipboard(String url) {
    try {
      html.window.navigator.clipboard?.writeText(url);
      print('URL copiée dans le presse-papiers: $url');
    } catch (e) {
      print('Impossible de copier l\'URL: $e');
    }
  }
  
  /// Ouvrir l'URL Barapay spécifiquement
  static void openBarapayUrl(String barapayUrl) {
    if (barapayUrl.startsWith('https://barapay.net/')) {
      openUrl(barapayUrl);
    } else {
      print('URL Barapay invalide: $barapayUrl');
    }
  }
}
