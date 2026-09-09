import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/specialty.dart';
import '../domain/repositories/specialty_repository.dart';

class FirebaseSpecialtyRepository implements SpecialtyRepository {
  FirebaseSpecialtyRepository({
    required this.database,
    required this.auth,
    required this.initialize,
  });
  final FirebaseFirestore Function() database;
  final FirebaseAuth Function() auth;
  final Future<void> Function() initialize;

  String _actor() {
    final user = auth().currentUser;
    if (user == null || !user.emailVerified) {
      throw const SpecialtyFailure(SpecialtyIssue.denied);
    }
    return user.uid;
  }

  Future<Result> _guard<Result>(Future<Result> Function() action) async {
    try {
      await initialize();
      return await action();
    } on FirebaseException catch (error) {
      throw SpecialtyFailure(switch (error.code) {
        'permission-denied' || 'unauthenticated' => SpecialtyIssue.denied,
        'aborted' => SpecialtyIssue.conflict,
        _ => SpecialtyIssue.unavailable,
      });
    }
  }

  Specialty _decode(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Specialty(
      id: snapshot.id,
      country: data['countryCode'] as String,
      input: SpecialtyInput(
        data['code'] as String,
        data['name'] as String,
        data['description'] as String,
      ),
      active: data['active'] as bool,
      revision: data['revision'] as int,
      updatedAt: (data['updatedAt'] as Timestamp).toDate().toUtc(),
    );
  }

  @override
  Future<SpecialtyPage> list(String country, {String? cursor}) =>
      _guard(() async {
        final actor = _actor();
        Query<Map<String, dynamic>> query = database()
            .collection('specialties')
            .where('countryCode', isEqualTo: country)
            .orderBy(FieldPath.documentId);
        if (cursor != null) query = query.startAfter([cursor]);
        final result = await query
            .limit(21)
            .get(const GetOptions(source: Source.server));
        if (_actor() != actor) {
          throw const SpecialtyFailure(SpecialtyIssue.denied);
        }
        final visible = result.docs.take(20).toList();
        return SpecialtyPage(
          visible.map(_decode).toList(),
          result.docs.length > 20 ? visible.last.id : null,
        );
      });

  @override
  Future<void> save(
    String country,
    SpecialtyInput input, {
    Specialty? previous,
  }) => _write(country, input, previous: previous);

  @override
  Future<void> setActive(Specialty previous, bool active) => _write(
    previous.country,
    previous.input,
    previous: previous,
    active: active,
  );

  Future<void> _write(
    String country,
    SpecialtyInput input, {
    Specialty? previous,
    bool? active,
  }) => _guard(() async {
    if (country != 'CL' ||
        !input.valid ||
        (previous != null &&
            (previous.country != country ||
                previous.input.code != input.code)) ||
        (active != null && (previous == null || previous.active == active))) {
      throw const SpecialtyFailure(SpecialtyIssue.invalid);
    }
    final actor = _actor();
    final reference = database()
        .collection('specialties')
        .doc('${country}_${input.code}');
    final issue = await database().runTransaction<SpecialtyIssue?>((
      transaction,
    ) async {
      final current = await transaction.get(reference);
      if (auth().currentUser?.uid != actor ||
          auth().currentUser?.emailVerified != true) {
        return SpecialtyIssue.denied;
      }
      if (previous == null && current.exists) return SpecialtyIssue.duplicate;
      if (previous != null &&
          (!current.exists ||
              current.data()!['revision'] != previous.revision ||
              previous.id != reference.id)) {
        return SpecialtyIssue.conflict;
      }
      final data = <String, dynamic>{
        'id': reference.id,
        'countryCode': country,
        'schemaVersion': 1,
        'environment': 'development',
        'code': input.code,
        'name': input.name,
        'description': input.description,
        'active': active ?? previous?.active ?? true,
        'revision': (previous?.revision ?? 0) + 1,
        'createdBy': current.data()?['createdBy'] ?? actor,
        'createdAt':
            current.data()?['createdAt'] ?? FieldValue.serverTimestamp(),
        'updatedBy': actor,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      transaction.set(reference, data);
      transaction
          .set(reference.collection('events').doc('${data['revision']}'), {
            'revision': data['revision'],
            'actorId': actor,
            'countryCode': country,
            'action': previous == null
                ? 'create'
                : active == null
                ? 'edit'
                : active
                ? 'reactivate'
                : 'deactivate',
            'recordedAt': FieldValue.serverTimestamp(),
            'snapshot': data,
          });
      return null;
    });
    if (issue != null) throw SpecialtyFailure(issue);
    if (_actor() != actor) throw const SpecialtyFailure(SpecialtyIssue.denied);
  });
}
