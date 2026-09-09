import '../doctor_workspace.dart';

abstract interface class DoctorWorkspaceRepository {
  Future<DoctorWorkspace> read(String country);
  Future<void> save(
    String country,
    DoctorWorkspace previous,
    bool accepting,
    String requestId,
  );
}
