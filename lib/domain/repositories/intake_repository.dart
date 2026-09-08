import '../intake_request.dart';

abstract interface class IntakeRepository {
  Future<IntakePage> list(IntakeQuery query);
  Future<IntakeRequest> get(String id);
}
