import 'dart:io';

import 'package:test/test.dart';

import 'package:flad_cli/src/registry.dart';

void main() {
  test('fetchRegistryIndex parses valid registry index', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));

    server.listen((request) async {
      if (request.uri.path == '/index.json') {
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.json
          ..write('''
{"components":{"button":{"description":"Button","file":"button.dart","dependencies":[]}}}
''');
      } else {
        request.response.statusCode = 404;
      }
      await request.response.close();
    });

    final baseUrl = 'http://${server.address.address}:${server.port}';
    final index = await fetchRegistryIndex(registryUrl: baseUrl);

    expect(index, isNotNull);
    expect(index!.components.containsKey('button'), isTrue);
    expect(
      index.components['button']!.fileUrl,
      '$baseUrl/components/button.dart',
    );
  });

  test('fetchRegistryIndex retries once on server error', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));

    var attempts = 0;
    server.listen((request) async {
      if (request.uri.path == '/index.json') {
        attempts++;
        if (attempts == 1) {
          request.response.statusCode = 500;
        } else {
          request.response
            ..statusCode = 200
            ..headers.contentType = ContentType.json
            ..write('{"components":{}}');
        }
      } else {
        request.response.statusCode = 404;
      }
      await request.response.close();
    });

    final baseUrl = 'http://${server.address.address}:${server.port}';
    final index = await fetchRegistryIndex(registryUrl: baseUrl);

    expect(index, isNotNull);
    expect(attempts, 2);
  });

  test('fetchComponent returns component source', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));

    server.listen((request) async {
      if (request.uri.path == '/components/button.dart') {
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.text
          ..write('class FladButton {}');
      } else {
        request.response.statusCode = 404;
      }
      await request.response.close();
    });

    final fileUrl =
        'http://${server.address.address}:${server.port}/components/button.dart';
    final source = await fetchComponent(fileUrl);

    expect(source, isNotNull);
    expect(source, contains('FladButton'));
  });

  test('registry index and components are served from cache in offline mode',
      () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final cacheRoot =
        await Directory.systemTemp.createTemp('flad_registry_cache');
    addTearDown(() => cacheRoot.delete(recursive: true));

    server.listen((request) async {
      if (request.uri.path == '/index.json') {
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.json
          ..write('''
{"components":{"button":{"description":"Button","file":"button.dart","dependencies":[]}}}
''');
      } else if (request.uri.path == '/components/button.dart') {
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.text
          ..write('class FladButton {}');
      } else {
        request.response.statusCode = 404;
      }
      await request.response.close();
    });

    final baseUrl = 'http://${server.address.address}:${server.port}';
    final onlineIndex = await fetchRegistryIndex(
      registryUrl: baseUrl,
      cacheRoot: cacheRoot,
    );
    expect(onlineIndex, isNotNull);

    final onlineSource = await fetchComponent(
      '$baseUrl/components/button.dart',
      registryUrl: baseUrl,
      componentName: 'button',
      cacheRoot: cacheRoot,
    );
    expect(onlineSource, contains('FladButton'));

    await server.close(force: true);

    final offlineIndex = await fetchRegistryIndex(
      registryUrl: baseUrl,
      cacheRoot: cacheRoot,
      offline: true,
    );
    expect(offlineIndex, isNotNull);
    expect(offlineIndex!.components.containsKey('button'), isTrue);

    final offlineSource = await fetchComponent(
      '$baseUrl/components/button.dart',
      registryUrl: baseUrl,
      componentName: 'button',
      cacheRoot: cacheRoot,
      offline: true,
    );
    expect(offlineSource, contains('FladButton'));
  });

  test('fetchComponent falls back to cache when network is unavailable',
      () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final cacheRoot =
        await Directory.systemTemp.createTemp('flad_registry_cache');
    addTearDown(() => cacheRoot.delete(recursive: true));

    server.listen((request) async {
      if (request.uri.path == '/components/button.dart') {
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.text
          ..write('class FladButton {}');
      } else {
        request.response.statusCode = 404;
      }
      await request.response.close();
    });

    final baseUrl = 'http://${server.address.address}:${server.port}';
    final url = '$baseUrl/components/button.dart';
    final firstFetch = await fetchComponent(
      url,
      registryUrl: baseUrl,
      componentName: 'button',
      cacheRoot: cacheRoot,
    );
    expect(firstFetch, contains('FladButton'));

    await server.close(force: true);

    final fallbackFetch = await fetchComponent(
      url,
      registryUrl: baseUrl,
      componentName: 'button',
      cacheRoot: cacheRoot,
    );
    expect(fallbackFetch, contains('FladButton'));
  });
}
