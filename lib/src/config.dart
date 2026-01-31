import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'constants.dart';

class FladConfig {
  final String targetDir;

  const FladConfig({required this.targetDir});

  Map<String, dynamic> toJson() => {
        'targetDir': targetDir,
      };

  static FladConfig fromJson(Map<String, dynamic> json) {
    final targetDir = json['targetDir'];
    if (targetDir is! String || targetDir.trim().isEmpty) {
      throw const FormatException('Invalid targetDir in config.');
    }
    return FladConfig(targetDir: targetDir.trim());
  }
}

String configPath([String? root]) {
  final base = root ?? Directory.current.path;
  return p.join(base, configFileName);
}

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

Future<void> writeConfig(FladConfig config, [String? root]) async {
  final file = File(configPath(root));
  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString('${encoder.convert(config.toJson())}\n');
}

FladConfig defaultConfig() {
  return const FladConfig(targetDir: defaultTargetDir);
}
