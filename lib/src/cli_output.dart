part of 'cli.dart';

// -- Console output formatting --

void _printError(String message) {
  stderr.writeln(_style('[$_brand] $message', [31], isStderr: true));
}

void _printInfo(String message) {
  stdout.writeln(_style('[$_brand] $message', [36]));
}

void _printSuccess(String message) {
  stdout.writeln(_style('[$_brand] $message', [32]));
}

void _printWarn(String message) {
  stdout.writeln(_style('[$_brand] $message', [33]));
}

String _style(String text, List<int> codes, {bool isStderr = false}) {
  final useColor =
      isStderr ? stderr.supportsAnsiEscapes : stdout.supportsAnsiEscapes;
  if (!useColor) {
    return text;
  }
  final sequence = codes.join(';');
  return '\x1B[${sequence}m$text\x1B[0m';
}
