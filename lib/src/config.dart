import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'constants.dart';

class FladConfig {
  final String targetDir;

  /// Creates a config instance with the provided target directory.
  const FladConfig({required this.targetDir});

  /// Serializes this config to JSON.
  Map<String, dynamic> toJson() => {
        'targetDir': targetDir,
      };

  /// Builds a config from JSON.
  static FladConfig fromJson(Map<String, dynamic> json) {
    final targetDir = json['targetDir'];
    if (targetDir is! String || targetDir.trim().isEmpty) {
      throw const FormatException('Invalid targetDir in config.');
    }
    return FladConfig(targetDir: targetDir.trim());
  }
}

/// Returns the absolute path to the config file.
String configPath([String? root]) {
  final base = root ?? Directory.current.path;
  return p.join(base, configFileName);
}

/// Reads the config file if it exists; returns null if missing or empty.
Future<FladConfig?> readConfig([String? root]) async {
  final file = File(configPath(root));
  if (!await file.exists()) {
    return null;
  }
  final contents = await file.readAsString();
  if (contents.trim().isEmpty) {
    return null;
  }
  final json = jsonDecode(contents);
  if (json is! Map<String, dynamic>) {
    throw const FormatException('Config file is not a JSON object.');
  }
  return FladConfig.fromJson(json);
}

/// Writes the config file with the provided values.
Future<void> writeConfig(FladConfig config, [String? root]) async {
  final file = File(configPath(root));
  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString('${encoder.convert(config.toJson())}\n');
}

/// Returns the default config used when no file exists.
FladConfig defaultConfig() {
  return const FladConfig(targetDir: defaultTargetDir);
}
