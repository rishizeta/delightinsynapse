import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:rive/rive.dart';

void main() {
  runApp(const DelightInSynapseApp());
}

class DelightInSynapseApp extends StatelessWidget {
  const DelightInSynapseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DelightInSynapse',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F6FB),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
          elevation: 0.5,
          centerTitle: true,
        ),
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      home: const RiveListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Home page: lists all Rive files from manifest.json
class RiveListPage extends StatefulWidget {
  const RiveListPage({super.key});

  @override
  State<RiveListPage> createState() => _RiveListPageState();
}

class _RiveListPageState extends State<RiveListPage> {
  late Future<List<RiveFileEntry>> _riveFilesFuture;

  @override
  void initState() {
    super.initState();
    _riveFilesFuture = _loadManifest();
  }

  /// Loads the manifest.json and parses the list of Rive files
  Future<List<RiveFileEntry>> _loadManifest() async {
    final manifestStr = await rootBundle.loadString('assets/rive/manifest.json');
    final List<dynamic> manifest = json.decode(manifestStr);
    return manifest.map((e) => RiveFileEntry.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rive Preview', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<RiveFileEntry>>(
        future: _riveFilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Beautiful empty state
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.insert_drive_file_rounded, size: 64, color: Colors.deepPurple.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  const Text(
                    'No Rive files found.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add .riv files to assets/rive/ and update the manifest.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            );
          }
          final files = snapshot.data!;
          final list = ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            itemCount: files.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, i) {
              final entry = files[i];
              return Card(
                elevation: 3,
                margin: EdgeInsets.zero,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RivePreviewPage(entry: entry),
                    ),
                  ),
                  splashColor: Colors.deepPurple.withOpacity(0.08),
                  highlightColor: Colors.deepPurple.withOpacity(0.04),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    child: Row(
                      children: [
                        // Placeholder for Rive icon/thumbnail
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.animation_rounded, size: 28, color: Colors.deepPurple),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.displayName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.sizeFormatted,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.deepPurple.withOpacity(0.7)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
          // Center on web, mobile-first otherwise
          return isWeb
              ? Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: list,
                  ),
                )
              : list;
        },
      ),
    );
  }
}

/// Data class for a Rive file entry
class RiveFileEntry {
  final String file;
  final int size;

  RiveFileEntry({required this.file, required this.size});

  String get displayName => p.basenameWithoutExtension(file);
  String get sizeFormatted => _formatBytes(size);

  factory RiveFileEntry.fromJson(Map<String, dynamic> json) {
    return RiveFileEntry(
      file: json['file'] as String,
      size: json['size'] as int,
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

/// Preview page: plays the selected Rive animation
class RivePreviewPage extends StatelessWidget {
  final RiveFileEntry entry;
  const RivePreviewPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () => Navigator.pop(context),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.arrow_back_rounded, size: 28, color: Colors.deepPurple),
              ),
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0.5,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Material(
                color: Colors.white,
                elevation: 2,
                child: RiveAnimation.asset(
                  'assets/rive/${entry.file}',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 