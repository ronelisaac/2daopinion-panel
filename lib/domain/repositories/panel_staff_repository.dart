import '../panel_staff.dart';
import '../doctor_account_preview.dart';

abstract interface class PanelStaffRepository {
  Future<StaffPage> list(String country, {String? cursor});
  Future<DoctorAccountPreview> previewDoctor(
    String country,
    String uid,
    String registry,
  );
  Future<bool> mutate(Map<String, Object?> command);
}
