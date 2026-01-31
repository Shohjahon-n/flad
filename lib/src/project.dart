import 'dart:io';

/// Returns true if the current directory looks like a Flutter project.
Future<bool> ensureFlutterProject(
    {void Function(String message)? onError}) async {
  final libDir = Directory('lib');
  if (!await libDir.exists()) {
    onError?.call('Not a Flutter project: lib/ directory not found.');
    return false;
  }
  return true;
}
