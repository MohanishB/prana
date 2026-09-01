String htmlToPlainText(String html) {
  if (html.trim().isEmpty) return '';

  var value = html
      .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</\s*p\s*>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'</\s*div\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<\s*li[^>]*>', caseSensitive: false), '• ')
      .replaceAll(RegExp(r'</\s*li\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]+>'), '');

  const entities = <String, String>{
    '&nbsp;': ' ',
    '&amp;': '&',
    '&quot;': '"',
    '&#39;': "'",
    '&apos;': "'",
    '&lt;': '<',
    '&gt;': '>',
    '&ndash;': '–',
    '&mdash;': '—',
    '&hellip;': '…',
  };

  for (final entry in entities.entries) {
    value = value.replaceAll(entry.key, entry.value);
  }

  value = value.replaceAllMapped(
    RegExp(r'&#(\d+);'),
    (match) {
      final codePoint = int.tryParse(match.group(1) ?? '');
      return codePoint == null ? match.group(0)! : String.fromCharCode(codePoint);
    },
  );

  return value
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}
