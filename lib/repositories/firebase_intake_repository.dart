import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/intake_request.dart';
import '../domain/repositories/intake_repository.dart';

class FirebaseIntakeRepository implements IntakeRepository {
  FirebaseIntakeRepository({
    required FirebaseFirestore Function() database,
    required FirebaseAuth Function() auth,
    required this.initialize,
  }) : _database = database,
       _auth = auth;
  final FirebaseFirestore Function() _database;
  final FirebaseAuth Function() _auth;
  final Future<void> Function() initialize;
  String? _key;
  final Map<int, DocumentSnapshot<Map<String, dynamic>>> _cursors = {};
  static final _idPattern = RegExp(r'^[a-zA-Z0-9]{20}$');

  String _owner() {
    final user = _auth().currentUser;
    if (user == null || !user.emailVerified) {
      throw const IntakeFailure(IntakeIssue.unavailable);
    }
    return user.uid;
  }

  IntakeRequest _decode(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return IntakeRequest(
      id: snapshot.id,
      reference: 'SO-${snapshot.id}',
      countryCode: data['countryCode'] as String,
      status: IntakeStatus.values.byName(data['status'] as String),
      mode: data['mode'] == 'document_review'
          ? ServiceMode.documentary
          : ServiceMode.consultation,
      createdAt: (data['createdAt'] as Timestamp).toDate().toUtc(),
      documents: const [],
      declaredDocumentCount: data['documentCount'] as int? ?? 0,
      hasVideo: data['hasVideo'] == true,
    );
  }

  @override
  Future<IntakePage> list(IntakeQuery query) async {
    try {
      await initialize();
      final owner = _owner();
      if (query.page < 0 || query.search.length > 64) {
        throw const IntakeFailure(IntakeIssue.unavailable);
      }
      final search = query.search.trim();
      final key = '$owner|${query.countryCode}|${query.status}|$search';
      if (_key != key || query.page == 0) {
        _cursors.clear();
        _key = key;
      }
      Query<Map<String, dynamic>> request = _database()
          .collection('intakeRequests')
          .where('countryCode', isEqualTo: query.countryCode);
      if (query.status != null) {
        request = request.where('status', isEqualTo: query.status!.name);
      }
      if (search.isNotEmpty) {
        final id = search.startsWith('SO-') ? search.substring(3) : search;
        if (!_idPattern.hasMatch(id)) return IntakePage(items: [], total: 0);
        request = request.where(FieldPath.documentId, isEqualTo: id);
      } else {
        request = request
            .orderBy('createdAt', descending: true)
            .orderBy(FieldPath.documentId);
        if (query.page > 0) {
          final cursor = _cursors[query.page];
          if (cursor == null) {
            throw const IntakeFailure(IntakeIssue.unavailable);
          }
          request = request.startAfterDocument(cursor);
        }
      }
      final snapshot = await request
          .limit(IntakeQuery.pageSize + 1)
          .get(const GetOptions(source: Source.server));
      if (_owner() != owner) throw const IntakeFailure(IntakeIssue.unavailable);
      final visible = snapshot.docs.take(IntakeQuery.pageSize).toList();
      if (_key == key && visible.isNotEmpty) {
        _cursors[query.page + 1] = visible.last;
      }
      return IntakePage(
        items: visible.map(_decode).toList(),
        hasMore: snapshot.docs.length > IntakeQuery.pageSize,
      );
    } catch (_) {
      throw const IntakeFailure(IntakeIssue.unavailable);
    }
  }

  @override
  Future<IntakeRequest> get(String id) async {
    if (!_idPattern.hasMatch(id)) {
      throw const IntakeFailure(IntakeIssue.notFound);
    }
    try {
      await initialize();
      final owner = _owner();
      final snapshot = await _database()
          .collection('intakeRequests')
          .doc(id)
          .get(const GetOptions(source: Source.server));
      if (_owner() != owner) throw const IntakeFailure(IntakeIssue.unavailable);
      if (!snapshot.exists) throw const IntakeFailure(IntakeIssue.notFound);
      return _decode(snapshot);
    } on IntakeFailure {
      rethrow;
    } catch (_) {
      throw const IntakeFailure(IntakeIssue.unavailable);
    }
  }
}
