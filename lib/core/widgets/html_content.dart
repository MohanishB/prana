import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../text/html_plain_text.dart';
import '../theme/app_spacing.dart';
import '../utils/external_link.dart';

/// Shows admin-written formatted text: paragraphs, headings (h1-h4), bold, italic,
/// underline, bullet and numbered lists, and tappable links (web, email, phone).
/// Anything else in the html is ignored, its text is kept.
class HtmlContent extends StatefulWidget {
  const HtmlContent(this.html, {super.key});

  final String html;

  @override
  State<HtmlContent> createState() => _HtmlContentState();
}

class _HtmlContentState extends State<HtmlContent> {
  final List<TapGestureRecognizer> _recognizers = [];
  late List<_Block> _blocks;

  @override
  void initState() {
    super.initState();
    _blocks = _parse();
  }

  @override
  void didUpdateWidget(HtmlContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.html != widget.html) {
      _disposeRecognizers();
      _blocks = _parse();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  TapGestureRecognizer _recognizerFor(String url) {
    final recognizer = TapGestureRecognizer()
      ..onTap = () {
        if (mounted) openExternalLink(context, url);
      };
    _recognizers.add(recognizer);
    return recognizer;
  }

  List<_Block> _parse() {
    final blocks = <_Block>[];
    var runs = <_Run>[];
    var bold = 0;
    var italic = 0;
    var underline = 0;
    var heading = 0;
    var indent = 0;
    String? prefix;
    final links = <TapGestureRecognizer?>[];
    final lists = <_ListState>[];

    void flush() {
      final trimmed = _trimRuns(runs);
      if (trimmed.isNotEmpty) {
        blocks.add(_Block(
          heading: heading,
          indent: indent,
          prefix: prefix,
          runs: trimmed,
        ));
      }
      runs = <_Run>[];
      prefix = null;
      indent = 0;
    }

    final tokens = RegExp(r'<[^>]+>|[^<]+')
        .allMatches(decodeEscapedHtml(widget.html))
        .map((m) => m.group(0) ?? '');

    for (final token in tokens) {
      if (!token.startsWith('<')) {
        final text = decodeHtmlEntities(token).replaceAll(RegExp(r'\s+'), ' ');
        if (text.isNotEmpty) {
          runs.add(_Run(
            text: text,
            bold: bold > 0,
            italic: italic > 0,
            underline: underline > 0,
            link: links.isEmpty ? null : links.last,
          ));
        }
        continue;
      }

      final match = RegExp(r'^<\s*(/?)\s*([a-zA-Z0-9]+)').firstMatch(token);
      if (match == null) continue;
      final closing = match.group(1) == '/';
      final name = match.group(2)!.toLowerCase();

      switch (name) {
        case 'br':
          runs.add(const _Run(text: '\n'));
        case 'p' || 'div':
          flush();
        case 'h1' || 'h2' || 'h3' || 'h4':
          flush();
          heading = closing ? 0 : int.parse(name.substring(1));
        case 'ul' || 'ol':
          flush();
          if (closing) {
            if (lists.isNotEmpty) lists.removeLast();
          } else {
            lists.add(_ListState(ordered: name == 'ol'));
          }
        case 'li':
          flush();
          if (!closing) {
            final list = lists.isEmpty ? null : lists.last;
            indent = lists.isEmpty ? 1 : lists.length;
            if (list != null && list.ordered) {
              list.counter += 1;
              prefix = '${list.counter}. ';
            } else {
              prefix = '• ';
            }
          }
        case 'b' || 'strong':
          bold = closing ? (bold > 0 ? bold - 1 : 0) : bold + 1;
        case 'i' || 'em':
          italic = closing ? (italic > 0 ? italic - 1 : 0) : italic + 1;
        case 'u':
          underline = closing ? (underline > 0 ? underline - 1 : 0) : underline + 1;
        case 'a':
          if (closing) {
            if (links.isNotEmpty) links.removeLast();
          } else {
            final href = RegExp(r'''href\s*=\s*(?:"([^"]*)"|'([^']*)')''')
                .firstMatch(token);
            final url = decodeHtmlEntities(
              (href?.group(1) ?? href?.group(2) ?? '').trim(),
            );
            final allowed = RegExp(r'^(https?://|mailto:|tel:)', caseSensitive: false)
                .hasMatch(url);
            links.add(allowed ? _recognizerFor(url) : null);
          }
      }
    }
    flush();
    return blocks;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.bodyMedium;
    final linkColor = theme.colorScheme.primary;

    TextStyle? headingStyle(int level) {
      final style = switch (level) {
        1 => theme.textTheme.titleLarge,
        2 => theme.textTheme.titleMedium,
        _ => theme.textTheme.titleSmall,
      };
      return style?.copyWith(fontWeight: FontWeight.w700);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final block in _blocks)
          Padding(
            padding: EdgeInsets.only(
              left: block.indent * AppSpacing.md,
              top: block.heading > 0 ? AppSpacing.xs : AppSpacing.none,
              bottom: block.prefix != null ? AppSpacing.xxs : AppSpacing.sm,
            ),
            child: Text.rich(
              TextSpan(
                style: block.heading > 0 ? headingStyle(block.heading) : base,
                children: [
                  if (block.prefix != null) TextSpan(text: block.prefix),
                  for (final run in block.runs)
                    TextSpan(
                      text: run.text,
                      recognizer: run.link,
                      style: TextStyle(
                        fontWeight: run.bold ? FontWeight.w700 : null,
                        fontStyle: run.italic ? FontStyle.italic : null,
                        decoration: run.underline || run.link != null
                            ? TextDecoration.underline
                            : null,
                        color: run.link != null ? linkColor : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Run {
  const _Run({
    required this.text,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.link,
  });

  final String text;
  final bool bold;
  final bool italic;
  final bool underline;
  final TapGestureRecognizer? link;

  _Run withText(String value) => _Run(
        text: value,
        bold: bold,
        italic: italic,
        underline: underline,
        link: link,
      );
}

class _Block {
  const _Block({
    required this.heading,
    required this.indent,
    required this.prefix,
    required this.runs,
  });

  /// 0 for normal text, 1-4 for a heading.
  final int heading;
  final int indent;
  final String? prefix;
  final List<_Run> runs;
}

class _ListState {
  _ListState({required this.ordered});

  final bool ordered;
  int counter = 0;
}

/// Removes blank space at the start and the end of a block (spaces, line breaks).
List<_Run> _trimRuns(List<_Run> runs) {
  final result = List<_Run>.of(runs);
  while (result.isNotEmpty) {
    final trimmed = result.first.text.trimLeft();
    if (trimmed.isEmpty) {
      result.removeAt(0);
    } else {
      result[0] = result.first.withText(trimmed);
      break;
    }
  }
  while (result.isNotEmpty) {
    final trimmed = result.last.text.trimRight();
    if (trimmed.isEmpty) {
      result.removeLast();
    } else {
      result[result.length - 1] = result.last.withText(trimmed);
      break;
    }
  }
  return result;
}
