import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:rive/rive.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const DelightInSynapseApp());
}

class DelightInSynapseApp extends StatelessWidget {
  const DelightInSynapseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delight in Synapse',
      theme: ThemeData(
        fontFamily: 'Geist',
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF163224),
          onPrimary: Colors.white,
          secondary: Colors.white,
          onSecondary: Color(0xFF163224),
          error: Color(0xFF163224),
          onError: Colors.white,
          background: Color(0xFFFAFAFA),
          onBackground: Color(0xFF163224),
          surface: Color(0xFFFAFAFA),
          onSurface: Color(0xFF163224),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Color(0xFFFAFAFA),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: Color(0xFFE4E4E4), width: 1),
          ),
          shadowColor: const Color.fromRGBO(19, 52, 59, 0.02),
          surfaceTintColor: Colors.white,
          margin: EdgeInsets.zero,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF163224),
          foregroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF163224)),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF163224)),
          bodyMedium: TextStyle(color: Color(0xFF163224)),
          bodySmall: TextStyle(color: Color(0xFF163224)),
          titleLarge: TextStyle(color: Color(0xFF163224)),
          titleMedium: TextStyle(color: Color(0xFF163224)),
          titleSmall: TextStyle(color: Color(0xFF163224)),
        ),
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

  /// Loads the manifest.json and parses the list of Rive files, sorted by latest modified
  Future<List<RiveFileEntry>> _loadManifest() async {
    final manifestStr = await rootBundle.loadString('assets/manifest.json');
    final List<dynamic> manifest = json.decode(manifestStr);
    final files = manifest.map((e) => RiveFileEntry.fromJson(e)).toList();
    files.sort((a, b) => b.modified.compareTo(a.modified)); // latest first
    return files;
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delight in Synapse', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<RiveFileEntry>>(
        future: _riveFilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF163224)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Black and white empty state
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.insert_drive_file_rounded, size: 64, color: Color(0xFF163224).withOpacity(0.2)),
                  const SizedBox(height: 16),
                  const Text(
                    'No Rive files found.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF163224)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add .riv files to assets/rive/ and update the manifest.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF163224).withOpacity(0.54)),
                  ),
                ],
              ),
            );
          }
          final files = snapshot.data!;
          // Group files by date (date only, not time)
          final Map<DateTime, List<RiveFileEntry>> grouped = {};
          for (final entry in files) {
            final dateOnly = DateTime(entry.modified.year, entry.modified.month, entry.modified.day);
            grouped.putIfAbsent(dateOnly, () => []).add(entry);
          }
          // Sort dates descending (latest first)
          final sortedDates = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));
          final children = <Widget>[];
          // Add top padding below the app bar and above the first date section
          children.add(const SizedBox(height: 24));
          for (int i = 0; i < sortedDates.length; i++) {
            final date = sortedDates[i];
            // Add extra space before each date section except the first
            if (i > 0) {
              children.add(const SizedBox(height: 32));
            }
            children.add(Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Text(
                _formatDateSection(date),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF163224),
                ),
              ),
            ));
            final entries = grouped[date]!;
            for (int j = 0; j < entries.length; j++) {
              final entry = entries[j];
              children.add(Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  margin: EdgeInsets.only(
                    top: j == 0 ? 0 : 18, // 18px between list items, none above first item
                    bottom: 0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE4E4E4), width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(19, 52, 59, 0.02),
                        offset: Offset(0, 4),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      borderRadius: BorderRadius.circular(4),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RivePreviewPage(entry: entry),
                        ),
                      ),
                      splashColor: Color(0xFF163224).withOpacity(0.08),
                      highlightColor: Color(0xFF163224).withOpacity(0.04),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 44,
                              height: 44,
                              child: SvgPicture.asset(
                                'assets/rive_logo.svg',
                                fit: BoxFit.contain,
                              ),
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
                                      color: Color(0xFF163224),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.sizeFormatted,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF163224).withOpacity(0.54),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Color(0xFF163224).withOpacity(0.7)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ));
            }
          }
          final content = ListView(
            padding: EdgeInsets.only(top: 0, bottom: 24),
            children: children,
          );
          return isWeb
              ? Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: content,
                  ),
                )
              : content;
        },
      ),
    );
  }

  String _formatDateSection(DateTime date) {
    // Format as 'Month Day, Year' (e.g., July 15, 2025)
    final months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return "${months[date.month]} ${date.day}, ${date.year}";
  }
}

/// Data class for a Rive file entry
class RiveFileEntry {

  final String file;
  final int size;
  final DateTime modified;

  RiveFileEntry({required this.file, required this.size, required this.modified});

  String get displayName {
    // Remove extension
    String name = p.basenameWithoutExtension(file);
    // Replace underscores, hyphens, and non-alphanumeric with space
    name = name.replaceAll(RegExp(r'[_\-]+'), ' ');
    name = name.replaceAll(RegExp(r'[^A-Za-z0-9 ]'), '');
    // Insert space before capital letters (except the first)
    name = name.replaceAllMapped(
      RegExp(r'(?<!^)([A-Z])'),
      (Match m) => ' ${m.group(0)}',
    );
    // Collapse multiple spaces
    name = name.replaceAll(RegExp(r' +'), ' ');
    // Capitalize first letter of each word
    String titleCase = name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
    return titleCase;
  }

  String get sizeFormatted => _formatBytes(size);
  // Get the actual file name in assets/rive/ (use the manifest file name as-is)
  String get assetFileName => file;

  factory RiveFileEntry.fromJson(Map<String, dynamic> json) {
    return RiveFileEntry(
      file: json['file'] as String,
      size: json['size'] as int,
      modified: DateTime.tryParse(json['modified'] ?? '') ?? DateTime(1970),
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
    return _RivePreviewPageWithRefresh(entry: entry);
  }
}

class _RivePreviewPageWithRefresh extends StatefulWidget {
  final RiveFileEntry entry;
  const _RivePreviewPageWithRefresh({super.key, required this.entry});

  @override
  State<_RivePreviewPageWithRefresh> createState() => _RivePreviewPageWithRefreshState();
}

class _RivePreviewPageWithRefreshState extends State<_RivePreviewPageWithRefresh> {
  int _reloadKey = 0;

  void _replay() {
    setState(() {
      _reloadKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry.displayName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                child: Icon(Icons.arrow_back_rounded, size: 28, color: Colors.white),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: _replay,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.refresh_rounded, size: 28, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: Color(0xFF163224),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Material(
              color: Colors.white,
              elevation: 2,
              shadowColor: const Color(0xFF163224),
              child: RiveAnimation.asset(
                'assets/rive/${widget.entry.file}',
                key: ValueKey(_reloadKey),
                fit: BoxFit.none, // Render at true size, no scaling
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}