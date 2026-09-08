enum IntakeStatus { received, reviewing, needsDocuments }

enum ServiceMode { documentary, consultation }

enum DocumentCategory { report, examination, prescription }

class IntakeDocument {
  const IntakeDocument({
    required this.id,
    required this.category,
    required this.extension,
  });
  final String id;
  final DocumentCategory category;
  final String extension;
}

class IntakeRequest {
  IntakeRequest({
    required this.id,
    required this.reference,
    required this.countryCode,
    required this.status,
    required this.mode,
    required this.createdAt,
    required List<IntakeDocument> documents,
    this.hasVideo = false,
  }) : documents = List.unmodifiable(documents);
  final String id;
  final String reference;
  final String countryCode;
  final IntakeStatus status;
  final ServiceMode mode;
  final DateTime createdAt;
  final List<IntakeDocument> documents;
  final bool hasVideo;
}

class IntakeQuery {
  const IntakeQuery({this.search = '', this.status, this.page = 0});
  static const pageSize = 8;
  final String search;
  final IntakeStatus? status;
  final int page;
}

class IntakePage {
  IntakePage({required List<IntakeRequest> items, required this.total})
    : items = List.unmodifiable(items);
  final List<IntakeRequest> items;
  final int total;
}

enum IntakeIssue { unavailable, notFound }

class IntakeFailure implements Exception {
  const IntakeFailure(this.issue);
  final IntakeIssue issue;
}
