import '../doctor_record.dart';

abstract interface class DoctorRepository {
  Future<DoctorPage> list(String country, {String? cursor});
  Future<void> save(
    String country,
    DoctorInput input, {
    DoctorRecord? previous,
  });
  Future<void> review(DoctorRecord previous, DoctorReview review);
}
