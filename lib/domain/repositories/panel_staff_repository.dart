import '../panel_staff.dart';

abstract interface class PanelStaffRepository {
  Future<StaffPage> list(String country, {String? cursor});
  Future<bool> mutate(Map<String, Object?> command);
}
