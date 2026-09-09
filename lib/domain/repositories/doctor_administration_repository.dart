import '../doctor_administration.dart';

abstract interface class DoctorAdministrationRepository {
  Future<List<DoctorAdministration>> list(String country, List<String> ids);
  Future<void> setActive(
    String country,
    DoctorAdministration previous,
    bool active,
    String reason,
    String requestId,
  );
}
