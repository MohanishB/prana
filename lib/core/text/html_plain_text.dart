/// Server text sometimes arrives HTML-escaped ("&lt;p&gt;Hello&lt;/p&gt;"), which
/// would show up as raw tags. This turns escaped tags back into real tags so both
/// the plain-text and the rich-text renderers see normal HTML.
String decodeEscapedHtml(String value) {
  var result = value;
  final escapedTag = RegExp(r'&(?:amp;)*lt;\s*/?\s*[a-zA-Z!]', caseSensitive: false);
  for (var i = 0; i < 3 && escapedTag.hasMatch(result); i++) {
    result = result
        .replaceAll(RegExp(r'&(?:amp;)+', caseSensitive: false), '&')
        .replaceAll(RegExp(r'&lt;', caseSensitive: false), '<')
        .replaceAll(RegExp(r'&gt;', caseSensitive: false), '>');
  }
  return result;
}

const Map<String, String> _namedEntities = <String, String>{
  '&nbsp;': ' ',
  '&quot;': '"',
  '&#39;': "'",
  '&apos;': "'",
  '&lt;': '<',
  '&gt;': '>',
  '&ndash;': '–',
  '&mdash;': '—',
  '&hellip;': '…',
  '&rsquo;': '’',
  '&lsquo;': '‘',
  '&rdquo;': '”',
  '&ldquo;': '“',
  '&bull;': '•',
  '&copy;': '©',
  '&reg;': '®',
  '&trade;': '™',
  '&amp;': '&',
};

/// Decodes named and numeric (&#123; / &#x1F;) entities.
String decodeHtmlEntities(String value) {
  var result = value;
  for (final entry in _namedEntities.entries) {
    result = result.replaceAll(entry.key, entry.value);
  }
  result = result.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
    final codePoint = int.tryParse(match.group(1) ?? '');
    return codePoint == null ? match.group(0)! : String.fromCharCode(codePoint);
  });
  return result.replaceAllMapped(RegExp(r'&#[xX]([0-9a-fA-F]+);'), (match) {
    final codePoint = int.tryParse(match.group(1) ?? '', radix: 16);
    return codePoint == null ? match.group(0)! : String.fromCharCode(codePoint);
  });
}

String htmlToPlainText(String html) {
  if (html.trim().isEmpty) return '';

  final value = decodeEscapedHtml(html)
      .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</\s*(p|h[1-6])\s*>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'</\s*div\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<\s*li[^>]*>', caseSensitive: false), '• ')
      .replaceAll(RegExp(r'</\s*li\s*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]+>'), '');

  return decodeHtmlEntities(value)
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}

/// One line of plain text for list cards: no tags, no line breaks.
String htmlToSingleLine(String html) =>
    htmlToPlainText(html).replaceAll(RegExp(r'\s+'), ' ').trim();
