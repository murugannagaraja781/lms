import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  int totalReplacedOpacity = 0;
  int totalReplacedBackground = 0;

  for (final file in files) {
    String content = await file.readAsString();
    bool changed = false;

    // Replace .withOpacity(x) with .withValues(alpha: x)
    final RegExp opacityRegex = RegExp(r'\.withOpacity\(([^)]+)\)');
    if (opacityRegex.hasMatch(content)) {
      content = content.replaceAllMapped(opacityRegex, (match) {
        return '.withValues(alpha: ${match.group(1)})';
      });
      changed = true;
      totalReplacedOpacity++;
    }

    // Replace onBackground with onSurface
    if (content.contains('onBackground')) {
      content = content.replaceAll('onBackground', 'onSurface');
      changed = true;
      totalReplacedBackground++;
    }
    
    // Replace .background with .surface
    // Note: careful with generic words. Let's specifically target colorScheme.background
    if (content.contains('colorScheme.background')) {
      content = content.replaceAll('colorScheme.background', 'colorScheme.surface');
      changed = true;
    }
    
    // In theme definitions
    if (content.contains('background:')) {
       // Only if inside ColorScheme
    }

    if (changed) {
      await file.writeAsString(content);
      print('Fixed: ${file.path}');
    }
  }

  print('Done! Modified opacity in $totalReplacedOpacity files, background in $totalReplacedBackground files.');
}
