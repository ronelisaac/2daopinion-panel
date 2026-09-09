import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/doctor_record.dart';
import '../domain/repositories/doctor_repository.dart';

class FirebaseDoctorRepository implements DoctorRepository {
  FirebaseDoctorRepository({
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
      throw const DoctorFailure(DoctorIssue.denied);
    }
    return user.uid;
  }

  Future<Result> _guard<Result>(Future<Result> Function() action) async {
    try {
      await initialize();
      return await action();
    } on FirebaseException catch (error) {
      throw DoctorFailure(switch (error.code) {
        'permission-denied' || 'unauthenticated' => DoctorIssue.denied,
        'aborted' => DoctorIssue.conflict,
        _ => DoctorIssue.unavailable,
      });
    }
  }

  DoctorRecord _decode(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final review = data['review'] as Map<String, dynamic>;
    final status = DoctorStatus.values.byName(data['status'] as String);
    return DoctorRecord(
      id: snapshot.id,
      country: data['countryCode'] as String,
      input: DoctorInput(
        data['name'] as String,
        data['registryNumber'] as String,
        data['specialty'] as String,
        specialtyId: data['specialtyId'] as String?,
      ),
      status: status,
      revision: data['revision'] as int,
      createdBy: data['createdBy'] as String,
      updatedAt: (data['updatedAt'] as Timestamp).toDate().toUtc(),
      reviewedBy: review['actorId'] as String?,
      reviewedAt: (review['at'] as Timestamp?)?.toDate().toUtc(),
      review: review.isEmpty
          ? null
          : DoctorReview(
              status: status,
              evidence: review['evidence'] as String,
              note: review['note'] as String,
              identityChecked: review['identityChecked'] as bool,
              titleChecked: review['titleChecked'] as bool,
              specialtyChecked: review['specialtyChecked'] as bool,
            ),
    );
  }

  @override
  Future<DoctorPage> list(String country, {String? cursor}) => _guard(() async {
    final actor = _actor();
    Query<Map<String, dynamic>> query = database()
        .collection('doctorRecords')
        .where('countryCode', isEqualTo: country)
        .orderBy(FieldPath.documentId);
    if (cursor != null) query = query.startAfter([cursor]);
    final result = await query
        .limit(21)
        .get(const GetOptions(source: Source.server));
    if (_actor() != actor) throw const DoctorFailure(DoctorIssue.denied);
    final visible = result.docs.take(20).toList();
    return DoctorPage(
      visible.map(_decode).toList(),
      result.docs.length > 20 ? visible.last.id : null,
    );
  });

  @override
  Future<void> save(
    String country,
    DoctorInput input, {
    DoctorRecord? previous,
  }) => _guard(() async {
    if (country != 'CL' ||
        !input.valid ||
        !input.linked ||
        (previous != null &&
            (!previous.editable ||
                previous.country != country ||
                input.registry != previous.input.registry))) {
      throw const DoctorFailure(DoctorIssue.invalid);
    }
    final reference = database()
        .collection('doctorRecords')
        .doc('${country}_${input.registry}');
    final actor = _actor();
    final issue = await database().runTransaction<DoctorIssue?>((
      transaction,
    ) async {
      final current = await transaction.get(reference);
      if (auth().currentUser?.uid != actor ||
          auth().currentUser?.emailVerified != true) {
        return DoctorIssue.denied;
      }
      if (previous == null && current.exists) {
        return DoctorIssue.duplicate;
      }
      if (previous != null &&
          (!current.exists ||
              current.data()!['revision'] != previous.revision ||
              previous.id != reference.id)) {
        return DoctorIssue.conflict;
      }
      final specialty = await transaction.get(
        database().collection('specialties').doc(input.specialtyId!),
      );
      if (!specialty.exists ||
          specialty.data()!['active'] != true ||
          specialty.data()!['countryCode'] != country ||
          specialty.data()!['name'] != input.specialty) {
        return DoctorIssue.specialtyUnavailable;
      }
      final data = <String, dynamic>{
        'id': reference.id,
        'countryCode': country,
        'schemaVersion': 2,
        'environment': 'development',
        'name': input.name,
        'registryNumber': input.registry,
        'specialty': input.specialty,
        'specialtyId': input.specialtyId,
        'status': 'pending',
        'review': <String, dynamic>{},
        'revision': (previous?.revision ?? 0) + 1,
        'createdBy': current.data()?['createdBy'] ?? actor,
        'createdAt':
            current.data()?['createdAt'] ?? FieldValue.serverTimestamp(),
        'updatedBy': actor,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      _write(
        transaction,
        reference,
        data,
        previous == null ? 'create' : 'edit',
        actor,
      );
      return null;
    });
    if (issue != null) throw DoctorFailure(issue);
    if (_actor() != actor) throw const DoctorFailure(DoctorIssue.denied);
  });

  @override
  Future<void> review(
    DoctorRecord previous,
    DoctorReview review,
  ) => _guard(() async {
    final actor = _actor();
    if (!review.valid ||
        !previous.permits(review.status) ||
        actor == previous.createdBy) {
      throw const DoctorFailure(DoctorIssue.invalid);
    }
    final reference = database().collection('doctorRecords').doc(previous.id);
    final issue = await database().runTransaction<DoctorIssue?>((
      transaction,
    ) async {
      final current = await transaction.get(reference);
      if (auth().currentUser?.uid != actor ||
          auth().currentUser?.emailVerified != true) {
        return DoctorIssue.denied;
      }
      if (!current.exists || current.data()!['revision'] != previous.revision) {
        return DoctorIssue.conflict;
      }
      if (review.status == DoctorStatus.verified) {
        final specialtyId = current.data()!['specialtyId'];
        if (specialtyId is! String || !previous.input.linked) {
          return DoctorIssue.specialtyUnavailable;
        }
        final specialty = await transaction.get(
          database().collection('specialties').doc(specialtyId),
        );
        if (!specialty.exists ||
            specialty.data()!['active'] != true ||
            specialty.data()!['countryCode'] != previous.country) {
          return DoctorIssue.specialtyUnavailable;
        }
      }
      final data = <String, dynamic>{
        ...current.data()!,
        'status': review.status.name,
        'revision': previous.revision + 1,
        'updatedBy': actor,
        'updatedAt': FieldValue.serverTimestamp(),
        'review': {
          'actorId': actor,
          'at': FieldValue.serverTimestamp(),
          'source': 'CL_RNPI',
          'evidence': review.evidence,
          'note': review.note,
          'identityChecked': review.identityChecked,
          'titleChecked': review.titleChecked,
          'specialtyChecked': review.specialtyChecked,
        },
      };
      _write(transaction, reference, data, 'review', actor);
      return null;
    });
    if (issue != null) throw DoctorFailure(issue);
    if (_actor() != actor) throw const DoctorFailure(DoctorIssue.denied);
  });

  void _write(
    Transaction transaction,
    DocumentReference<Map<String, dynamic>> reference,
    Map<String, dynamic> data,
    String action,
    String actor,
  ) {
    transaction.set(reference, data);
    transaction.set(reference.collection('events').doc('${data['revision']}'), {
      'revision': data['revision'],
      'actorId': actor,
      'countryCode': data['countryCode'],
      'action': action,
      'recordedAt': FieldValue.serverTimestamp(),
      'snapshot': data,
    });
  }
}
