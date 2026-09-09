import '../intake_classification.dart';

abstract interface class IntakeClassificationRepository {
  Future<IntakeClassification> get(String country, String id);
  Future<void> save(
    String country,
    IntakeClassification previous,
    ClassificationInput input,
    String requestId,
  );
}
