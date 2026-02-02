import 'dart:convert';
import 'dart:io';

/// Default remote registry base URL (GitHub raw content).
const defaultRegistryUrl =
    'https://raw.githubusercontent.com/Shohjahon-n/flad-registry/main';

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
Future<RegistryIndex?> fetchRegistryIndex({String? registryUrl}) async {
  final base = registryUrl ?? defaultRegistryUrl;
  final url = Uri.parse('$base/index.json');
  try {
    final client = HttpClient();
    final request = await client.getUrl(url);
    final response = await request.close();
    if (response.statusCode != 200) {
      client.close();
      return null;
    }
    final body = await response.transform(utf8.decoder).join();
    client.close();
    final json = jsonDecode(body);
    if (json is! Map<String, dynamic>) return null;
    return RegistryIndex.fromJson(json, base);
  } on Exception {
    return null;
  }
}

/// Fetches a single component source from the remote registry.
///
/// Returns the Dart source string or `null` on failure.
Future<String?> fetchComponent(String fileUrl) async {
  final url = Uri.parse(fileUrl);
  try {
    final client = HttpClient();
    final request = await client.getUrl(url);
    final response = await request.close();
    if (response.statusCode != 200) {
      client.close();
      return null;
    }
    final body = await response.transform(utf8.decoder).join();
    client.close();
    return body;
  } on Exception {
    return null;
  }
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
