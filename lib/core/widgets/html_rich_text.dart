import 'package:flutter/material.dart';

class HtmlRichText extends StatelessWidget {
  const HtmlRichText(
    this.html, {
    super.key,
    this.style,
  });

  final String html;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: _parseHtml(html, baseStyle),
      ),
    );
  }
}

List<InlineSpan> _parseHtml(String html, TextStyle? baseStyle) {
  final spans = <InlineSpan>[];
  final styles = <TextStyle?>[baseStyle];
  final tokenPattern = RegExp(r'(<[^>]+>|[^<]+)', multiLine: true);

  for (final match in tokenPattern.allMatches(html)) {
    final token = match.group(0) ?? '';
    if (!token.startsWith('<')) {
      final text = _decodeEntities(token);
      if (text.isNotEmpty) {
        spans.add(TextSpan(text: text, style: styles.last));
      }
      continue;
    }

    final normalized = token
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();

    if (RegExp(r'^<br\s*/?>$').hasMatch(normalized)) {
      spans.add(TextSpan(text: '\n', style: styles.last));
    } else if (RegExp(r'^</?(p|div)(\s[^>]*)?>$').hasMatch(normalized)) {
      if (normalized.startsWith('</')) {
        spans.add(TextSpan(text: '\n\n', style: styles.last));
      }
    } else if (RegExp(r'^<li(\s[^>]*)?>$').hasMatch(normalized)) {
      spans.add(TextSpan(text: '• ', style: styles.last));
    } else if (normalized == '</li>') {
      spans.add(TextSpan(text: '\n', style: styles.last));
    } else if (RegExp(r'^<(strong|b)(\s[^>]*)?>$').hasMatch(normalized)) {
      styles.add(styles.last?.copyWith(fontWeight: FontWeight.w700));
    } else if (normalized == '</strong>' || normalized == '</b>') {
      if (styles.length > 1) styles.removeLast();
    } else if (RegExp(r'^<(em|i)(\s[^>]*)?>$').hasMatch(normalized)) {
      styles.add(styles.last?.copyWith(fontStyle: FontStyle.italic));
    } else if (normalized == '</em>' || normalized == '</i>') {
      if (styles.length > 1) styles.removeLast();
    } else if (RegExp(r'^<u(\s[^>]*)?>$').hasMatch(normalized)) {
      styles.add(styles.last?.copyWith(decoration: TextDecoration.underline));
    } else if (normalized == '</u>') {
      if (styles.length > 1) styles.removeLast();
    }
  }

  return _trimTrailingBreaks(spans);
}

List<InlineSpan> _trimTrailingBreaks(List<InlineSpan> spans) {
  while (spans.isNotEmpty) {
    final last = spans.last;
    if (last is TextSpan && (last.text ?? '').trim().isEmpty) {
      spans.removeLast();
      continue;
    }
    break;
  }
  return spans;
}

String _decodeEntities(String value) {
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

  var result = value;
  for (final entry in entities.entries) {
    result = result.replaceAll(entry.key, entry.value);
  }

  return result.replaceAllMapped(
    RegExp(r'&#(\d+);'),
    (match) {
      final codePoint = int.tryParse(match.group(1) ?? '');
      return codePoint == null ? match.group(0)! : String.fromCharCode(codePoint);
    },
  );
}
