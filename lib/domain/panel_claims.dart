import 'panel_access.dart';

PanelPrincipal principalFromClaims(
  String uid,
  bool verified,
  Map<String, dynamic>? claims,
) {
  if (!verified) {
    throw const PanelAccessFailure(PanelAccessIssue.emailNotVerified);
  }
  final access = claims?['panelAccess'];
  if (access is! Map || access['version'] != 1 || access['active'] != true) {
    throw const PanelAccessFailure(PanelAccessIssue.denied);
  }
  final membership = access['memberships'];
  if (membership is! Map || membership.isEmpty || membership.length > 30) {
    throw const PanelAccessFailure(PanelAccessIssue.denied);
  }
  final scopes = <String, Set<PanelRole>>{};
  for (final entry in membership.entries) {
    final country = entry.key;
    final values = entry.value;
    if (country is! String ||
        !RegExp(r'^[A-Z]{2}$').hasMatch(country) ||
        values is! List ||
        values.isEmpty ||
        values.length > PanelRole.values.length) {
      throw const PanelAccessFailure(PanelAccessIssue.denied);
    }
    final roles = <PanelRole>{};
    for (final value in values) {
      final matches = PanelRole.values.where((role) => role.name == value);
      if (matches.isEmpty) {
        throw const PanelAccessFailure(PanelAccessIssue.denied);
      }
      roles.add(matches.single);
    }
    scopes[country] = roles;
  }
  return PanelPrincipal(
    id: uid,
    roles: scopes.values.expand((roles) => roles).toSet(),
    countries: scopes.keys.toSet(),
    countryRoles: scopes,
  );
}
