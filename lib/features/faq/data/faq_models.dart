import '../../../core/text/html_plain_text.dart';

class FaqItem {
  const FaqItem({
    required this.id,
    required this.question,
    required this.answerHtml,
  });

  final int id;
  final String question;
  final String answerHtml;

  String get answerText => htmlToPlainText(answerHtml);

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: _asInt(json['id']),
      question: json['question']?.toString().trim() ?? '',
      answerHtml: json['answer']?.toString() ?? '',
    );
  }
}

class FaqCollection {
  const FaqCollection({
    required this.items,
    required this.contactNote,
  });

  final List<FaqItem> items;
  final String contactNote;

  factory FaqCollection.fromJson(Map<String, dynamic> json) {
    final rawItems = json['faqs'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map(
              (item) => FaqItem.fromJson(
                item.map((key, value) => MapEntry(key.toString(), value)),
              ),
            )
            .where((item) => item.question.isNotEmpty)
            .toList(growable: false)
        : const <FaqItem>[];

    return FaqCollection(
      items: items,
      contactNote: htmlToPlainText(json['contact_note']?.toString() ?? ''),
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
