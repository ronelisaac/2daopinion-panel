enum SpecialtyIssue { invalid, denied, duplicate, conflict, unavailable }

class SpecialtyFailure implements Exception {
  const SpecialtyFailure(this.issue);
  final SpecialtyIssue issue;
}

class SpecialtyInput {
  SpecialtyInput(String code, String name, String description)
    : code = code.trim().toLowerCase(),
      name = name.trim(),
      description = description.trim();
  final String code;
  final String name;
  final String description;
  static bool validCode(String value) =>
      RegExp(r'^[a-z][a-z0-9_]{1,31}$').hasMatch(value.trim().toLowerCase());
  static bool validName(String value) =>
      value.trim().runes.length >= 2 && value.trim().runes.length <= 100;
  static bool validDescription(String value) =>
      value.trim().runes.length <= 500;
  bool get valid =>
      validCode(code) && validName(name) && validDescription(description);
}

class Specialty {
  const Specialty({
    required this.id,
    required this.country,
    required this.input,
    required this.active,
    required this.revision,
    required this.updatedAt,
  });
  final String id;
  final String country;
  final SpecialtyInput input;
  final bool active;
  final int revision;
  final DateTime updatedAt;
}

class SpecialtyPage {
  const SpecialtyPage(this.items, this.nextCursor);
  final List<Specialty> items;
  final String? nextCursor;
}
