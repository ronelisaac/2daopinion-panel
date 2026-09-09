enum ClinicIssue { invalid, denied, duplicate, conflict, unavailable }

class ClinicFailure implements Exception {
  const ClinicFailure(this.issue);
  final ClinicIssue issue;
}

class ClinicInput {
  ClinicInput(
    String code,
    String name,
    String description, {
    required String city,
    required String address,
    String email = '',
    String phone = '',
  }) : code = code.trim().toLowerCase(),
       name = name.trim(),
       description = description.trim(),
       city = city.trim(),
       address = address.trim(),
       email = email.trim(),
       phone = phone.trim();
  final String code;
  final String name;
  final String description;
  final String city;
  final String address;
  final String email;
  final String phone;
  static bool validCity(String value) =>
      value.trim().runes.length >= 2 && value.trim().runes.length <= 100;
  static bool validAddress(String value) =>
      value.trim().runes.length >= 5 && value.trim().runes.length <= 200;
  static bool validEmail(String value) =>
      value.trim().isEmpty ||
      (value.trim().length <= 254 &&
          RegExp(
            r'^[A-Za-z0-9_%+\-]+(\.[A-Za-z0-9_%+\-]+)*@[A-Za-z0-9]([A-Za-z0-9\-]*[A-Za-z0-9])?(\.[A-Za-z0-9]([A-Za-z0-9\-]*[A-Za-z0-9])?)*\.[A-Za-z]{2,63}$',
          ).hasMatch(value.trim()));
  static bool validPhone(String value) =>
      value.trim().isEmpty ||
      RegExp(r'^\+[1-9][0-9]{7,14}$').hasMatch(value.trim());
  static bool validCode(String value) =>
      RegExp(r'^[a-z][a-z0-9_]{1,31}$').hasMatch(value.trim().toLowerCase());
  static bool validName(String value) =>
      value.trim().runes.length >= 2 && value.trim().runes.length <= 100;
  static bool validDescription(String value) =>
      value.trim().runes.length <= 500;
  bool get valid =>
      validCode(code) &&
      validName(name) &&
      validDescription(description) &&
      validCity(city) &&
      validAddress(address) &&
      validEmail(email) &&
      validPhone(phone);
}

class Clinic {
  const Clinic({
    required this.id,
    required this.country,
    required this.input,
    required this.active,
    required this.revision,
    required this.updatedAt,
  });
  final String id;
  final String country;
  final ClinicInput input;
  final bool active;
  final int revision;
  final DateTime updatedAt;
}

class ClinicPage {
  const ClinicPage(this.items, this.nextCursor);
  final List<Clinic> items;
  final String? nextCursor;
}
