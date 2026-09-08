import '../domain/intake_request.dart';
import '../domain/repositories/intake_repository.dart';

class PreviewIntakeRepository implements IntakeRepository {
  final List<IntakeRequest> _items = List.generate(
    18,
    (index) => IntakeRequest(
      id: 'example-${index + 1}',
      reference: 'DEMO-${(index + 1).toString().padLeft(4, '0')}',
      countryCode: 'CL',
      status: IntakeStatus.values[index % IntakeStatus.values.length],
      mode: ServiceMode.values[index % ServiceMode.values.length],
      createdAt: DateTime.utc(2026, 9, 8, 12).subtract(Duration(hours: index)),
      hasVideo: index % 4 == 0,
      documents: List.generate(
        index % 5 + 1,
        (documentIndex) => IntakeDocument(
          id: 'example-document-${index + 1}-${documentIndex + 1}',
          category: DocumentCategory
              .values[documentIndex % DocumentCategory.values.length],
          extension: documentIndex % 2 == 0 ? 'PDF' : 'JPG',
        ),
      ),
    ),
  );

  @override
  Future<IntakePage> list(IntakeQuery query) async {
    if (query.page < 0 || query.search.length > 64) {
      throw const IntakeFailure(IntakeIssue.unavailable);
    }
    final search = query.search.trim().toLowerCase();
    final matching = _items
        .where(
          (item) =>
              item.countryCode == query.countryCode &&
              (query.status == null || query.status == item.status) &&
              item.reference.toLowerCase().contains(search),
        )
        .toList();
    return IntakePage(
      items: matching
          .skip(query.page * IntakeQuery.pageSize)
          .take(IntakeQuery.pageSize)
          .toList(),
      total: matching.length,
    );
  }

  @override
  Future<IntakeRequest> get(String id) async {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    throw const IntakeFailure(IntakeIssue.notFound);
  }
}
