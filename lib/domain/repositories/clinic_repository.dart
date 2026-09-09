import '../clinic.dart';

abstract interface class ClinicRepository {
  Future<ClinicPage> list(String country, {String? cursor});
  Future<void> save(String country, ClinicInput input, {Clinic? previous});
  Future<void> setActive(Clinic previous, bool active);
}
