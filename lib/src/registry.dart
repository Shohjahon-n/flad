import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Default remote registry base URL (GitHub raw content).
const defaultRegistryUrl =
    'https://raw.githubusercontent.com/Shohjahon-n/flad-registry/main';

const _registryRequestTimeout = Duration(seconds: 8);
const _registryAttempts = 2;
const _defaultRegistryCacheRoot = '.flad/cache/registry';

/// Fetches the component index from the remote registry.
///
/// The index is a JSON file at `<registryUrl>/index.json` containing:
/// ```json
/// {
///   "components": {
///     "button": { "description": "...", "file": "button.dart", "dependencies": [] },
///     ...
///   }
/// }
/// ```
///
/// Returns `null` on network or parse errors.
Future<RegistryIndex?> fetchRegistryIndex({
  String? registryUrl,
  Directory? cacheRoot,
  bool offline = false,
}) async {
  final base = registryUrl ?? defaultRegistryUrl;
  final root = cacheRoot ?? Directory(_defaultRegistryCacheRoot);

  if (offline) {
    return _readCachedRegistryIndex(base, root);
  }

  final url = Uri.parse('$base/index.json');
  try {
    final body = await _fetchText(
      url,
      timeout: _registryRequestTimeout,
      attempts: _registryAttempts,
    );
    if (body != null) {
      final parsed = _parseRegistryIndex(body, base);
      if (parsed != null) {
        await _writeCacheFile(_indexCacheFile(base, root), body);
        return parsed;
      }
    }

    // Fall back to cache when network fetch/parsing fails.
    return _readCachedRegistryIndex(base, root);
  } on Exception {
    return _readCachedRegistryIndex(base, root);
  }
}

/// Fetches a single component source from the remote registry.
///
/// Returns the Dart source string or `null` on failure.
Future<String?> fetchComponent(
  String fileUrl, {
  Directory? cacheRoot,
  String? registryUrl,
  String? componentName,
  bool offline = false,
}) async {
  final base = registryUrl ?? _baseUrlForFile(fileUrl);
  final key = _componentCacheKey(fileUrl, componentName: componentName);
  final root = cacheRoot ?? Directory(_defaultRegistryCacheRoot);
  final cacheFile = _componentCacheFile(base, key, root);

  if (offline) {
    return _readCachedText(cacheFile);
  }

  final url = Uri.parse(fileUrl);
  final body = await _fetchText(
    url,
    timeout: _registryRequestTimeout,
    attempts: _registryAttempts,
  );
  if (body != null) {
    await _writeCacheFile(cacheFile, body);
    return body;
  }
  return _readCachedText(cacheFile);
}

Future<String?> _fetchText(
  Uri url, {
  required Duration timeout,
  required int attempts,
}) async {
  for (var attempt = 1; attempt <= attempts; attempt++) {
    final client = HttpClient();
    try {
      final request = await client.getUrl(url).timeout(timeout);
      final response = await request.close().timeout(timeout);
      if (response.statusCode != 200) {
        if (!_isRetryableStatus(response.statusCode) || attempt >= attempts) {
          return null;
        }
        continue;
      }
      return response.transform(utf8.decoder).join().timeout(timeout);
    } on TimeoutException {
      if (attempt >= attempts) {
        return null;
      }
    } on Exception {
      if (attempt >= attempts) {
        return null;
      }
    } finally {
      client.close(force: true);
    }
  }
  return null;
}

bool _isRetryableStatus(int statusCode) {
  return statusCode == 408 || statusCode == 429 || statusCode >= 500;
}

RegistryIndex? _parseRegistryIndex(String body, String base) {
  final json = jsonDecode(body);
  if (json is! Map<String, dynamic>) {
    return null;
  }
  return RegistryIndex.fromJson(json, base);
}

Future<RegistryIndex?> _readCachedRegistryIndex(
  String base,
  Directory cacheRoot,
) async {
  final file = _indexCacheFile(base, cacheRoot);
  final body = await _readCachedText(file);
  if (body == null) {
    return null;
  }
  try {
    return _parseRegistryIndex(body, base);
  } on Exception {
    return null;
  }
}

Future<String?> _readCachedText(File file) async {
  try {
    if (!await file.exists()) {
      return null;
    }
    return file.readAsString();
  } on Exception {
    return null;
  }
}

Future<void> _writeCacheFile(File file, String body) async {
  try {
    await file.parent.create(recursive: true);
    await file.writeAsString(body);
  } on Exception {
    // Best-effort cache writes should not fail registry fetches.
  }
}

String _baseUrlForFile(String fileUrl) {
  const marker = '/components/';
  final index = fileUrl.indexOf(marker);
  if (index != -1) {
    return fileUrl.substring(0, index);
  }
  final lastSlash = fileUrl.lastIndexOf('/');
  if (lastSlash == -1) {
    return fileUrl;
  }
  return fileUrl.substring(0, lastSlash);
}

String _componentCacheKey(String fileUrl, {String? componentName}) {
  if (componentName != null && componentName.trim().isNotEmpty) {
    return componentName.trim();
  }
  final parsed = Uri.tryParse(fileUrl);
  final path = parsed?.path ?? fileUrl;
  final basename = p.basename(path);
  if (basename.endsWith('.dart')) {
    return basename.substring(0, basename.length - 5);
  }
  return basename;
}

String _cacheNamespace(String base) => Uri.encodeComponent(base);

File _indexCacheFile(String base, Directory root) {
  return File(p.join(root.path, _cacheNamespace(base), 'index.json'));
}

File _componentCacheFile(String base, String key, Directory root) {
  return File(
    p.join(root.path, _cacheNamespace(base), 'components', '$key.dart'),
  );
}

/// Parsed remote registry index.
class RegistryIndex {
  final Map<String, RegistryComponent> components;
  final String baseUrl;

  const RegistryIndex({required this.components, required this.baseUrl});

  static RegistryIndex fromJson(Map<String, dynamic> json, String baseUrl) {
    final components = <String, RegistryComponent>{};
    final comps = json['components'];
    if (comps is Map<String, dynamic>) {
      for (final entry in comps.entries) {
        if (entry.value is Map<String, dynamic>) {
          components[entry.key] = RegistryComponent.fromJson(
              entry.value as Map<String, dynamic>, baseUrl);
        }
      }
    }
    return RegistryIndex(components: components, baseUrl: baseUrl);
  }
}

/// A single component entry in the registry.
class RegistryComponent {
  final String description;
  final String fileUrl;
  final List<String> dependencies;

  const RegistryComponent({
    required this.description,
    required this.fileUrl,
    required this.dependencies,
  });

  static RegistryComponent fromJson(Map<String, dynamic> json, String baseUrl) {
    final file = json['file'] as String? ?? '';
    final deps = json['dependencies'];
    return RegistryComponent(
      description: json['description'] as String? ?? '',
      fileUrl: file.startsWith('http') ? file : '$baseUrl/components/$file',
      dependencies: deps is List ? deps.cast<String>() : const [],
    );
  }
}
