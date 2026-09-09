import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

Iterable<File> sources(String directory) => Directory(directory)
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('.dart'));

void main() {
  test(
    'domain is pure Dart, views and controllers do not import infrastructure',
    () {
      for (final source in sources('lib/domain')) {
        expect(
          source.readAsStringSync().contains('package:'),
          isFalse,
          reason: source.path,
        );
      }
      for (final source in [
        ...sources('lib/views'),
        ...sources('lib/widgets'),
        ...sources('lib/controllers'),
      ]) {
        final content = source.readAsStringSync();
        for (final forbidden in [
          '../repositories/',
          'package:firebase_',
          'package:cloud_firestore',
          'dart:io',
          'package:http',
        ]) {
          expect(
            content.contains(forbidden),
            isFalse,
            reason: '${source.path}: $forbidden',
          );
        }
      }
    },
  );
  test(
    'panel has no public registration, role provisioning or remote clinical URLs',
    () {
      for (final source in sources('lib')) {
        final content = source.readAsStringSync();
        expect(
          content.contains('createUserWithEmailAndPassword'),
          isFalse,
          reason: source.path,
        );
        expect(
          content
              .replaceAll('https://rnpi.superdesalud.gob.cl/', '')
              .contains('https://'),
          isFalse,
          reason: source.path,
        );
        expect(
          content.contains('setCustomUserClaims'),
          isFalse,
          reason: source.path,
        );
      }
      expect(
        File('lib/main.dart').readAsStringSync(),
        isNot(contains('PreviewIntakeRepository()')),
      );
    },
  );
}
