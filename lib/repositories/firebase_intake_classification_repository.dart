import 'package:cloud_functions/cloud_functions.dart';
import '../domain/intake_classification.dart';
import '../domain/repositories/intake_classification_repository.dart';

class FirebaseIntakeClassificationRepository
    implements IntakeClassificationRepository {
  FirebaseIntakeClassificationRepository({
    required this.functions,
    required this.initialize,
  });
  final FirebaseFunctions Function() functions;
  final Future<void> Function() initialize;
  Future<Map<String, dynamic>> _call(Map<String, Object?> input) async {
    try {
      await initialize();
      return (await functions()
              .httpsCallable(
                'managePanelUsers',
                options: HttpsCallableOptions(
                  timeout: const Duration(seconds: 70),
                ),
              )
              .call<Map<String, dynamic>>(input))
          .data;
    } on FirebaseFunctionsException catch (error) {
      throw ClassificationFailure(switch (error.code) {
        'permission-denied' || 'unauthenticated' => ClassificationIssue.denied,
        'aborted' ||
        'already-exists' ||
        'failed-precondition' => ClassificationIssue.conflict,
        'resource-exhausted' => ClassificationIssue.limit,
        'invalid-argument' => ClassificationIssue.invalid,
        _ => ClassificationIssue.unavailable,
      });
    } catch (_) {
      throw const ClassificationFailure(ClassificationIssue.unavailable);
    }
  }

  @override
  Future<IntakeClassification> get(String country, String id) async {
    final data = await _call({
      'action': 'intakeClassificationGet',
      'country': country,
      'id': id,
    });
    return IntakeClassification(
      id: data['id'] as String,
      revision: data['revision'] as int,
      source: ClassificationSource.values.byName(data['source'] as String),
      specialtyId: data['specialtyId'] as String?,
      specialtyName: data['specialtyName'] as String?,
      editable: data['editable'] == true,
      specialtyActive: data['specialtyActive'] == true,
      updatedAt: data['updatedAt'] == null
          ? null
          : DateTime.parse(data['updatedAt'] as String).toUtc(),
    );
  }

  @override
  Future<void> save(
    String country,
    IntakeClassification previous,
    ClassificationInput input,
    String requestId,
  ) async {
    await _call({
      'action': 'intakeClassificationSet',
      'country': country,
      'id': previous.id,
      'revision': previous.revision,
      'specialtyId': input.specialtyId,
      'source': input.source.name,
      'confirmed': input.confirmed,
      'requestId': requestId,
    });
  }
}
