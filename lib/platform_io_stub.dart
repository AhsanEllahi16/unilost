// lib/platform_io_stub.dart
// Minimal stub for web build so references to File compile.
// The stub does nothing functional — it prevents compile errors on web.
// When running on web we avoid calling methods that rely on real files.

class File {
  final String path;
  File(this.path);
  // For our usage we only need existsSync() check; return false on web.
  bool existsSync() => false;
// Add any other members used by code if necessary (readAsBytes, etc.)
}