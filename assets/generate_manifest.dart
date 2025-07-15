import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

/// This script scans the assets/rive/ directory for all .riv files
/// and generates a manifest.json file with their names and sizes.
///
/// Usage:
///   dart assets/generate_manifest.dart

void main() async {
  final riveDir = Directory('assets/rive');
  if (!riveDir.existsSync()) {
    print('Directory assets/rive/ does not exist.');
    return;
  }

  final files = riveDir
      .listSync()
      .whereType<File>()
      .where((f) => p.extension(f.path) == '.riv')
      .toList();

  final manifest = files.map((file) {
    final stat = file.statSync();
    return {
      'file': p.basename(file.path),
      'size': stat.size, // in bytes
    };
  }).toList();

  final manifestFile = File('assets/manifest.json');
  manifestFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert(manifest));
  print('Generated manifest.json with ${manifest.length} files.');
} 