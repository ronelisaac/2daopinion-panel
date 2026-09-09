import '../specialty.dart';

abstract interface class SpecialtyRepository {
  Future<SpecialtyPage> list(String country, {String? cursor});
  Future<void> save(
    String country,
    SpecialtyInput input, {
    Specialty? previous,
  });
  Future<void> setActive(Specialty previous, bool active);
}
