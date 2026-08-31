import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations_x.dart';

enum CourseTab { intro, videos, quiz, notes }

class CourseTabBar extends StatelessWidget {
  const CourseTabBar({
    required this.selected,
    required this.showQuiz,
    required this.showNotes,
    required this.onSelected,
    super.key,
  });

  final CourseTab selected;
  final bool showQuiz;
  final bool showNotes;
  final ValueChanged<CourseTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = <CourseTab>[
      CourseTab.intro,
      CourseTab.videos,
      if (showQuiz) CourseTab.quiz,
      if (showNotes) CourseTab.notes,
    ];

    String label(CourseTab tab) => switch (tab) {
          CourseTab.intro => l10n.intro,
          CourseTab.videos => l10n.videos,
          CourseTab.quiz => l10n.quiz,
          CourseTab.notes => l10n.notes,
        };

    return Row(
      children: [
        for (final tab in tabs)
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: TextButton(
              onPressed: () => onSelected(tab),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                foregroundColor: tab == selected
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                side: tab == selected
                    ? BorderSide(
                        color: Theme.of(context).colorScheme.error,
                        width: 0,
                      )
                    : BorderSide.none,
              ),
              child: Text(
                label(tab),
                style: TextStyle(
                  fontWeight:
                      tab == selected ? FontWeight.w700 : FontWeight.w600,
                  decoration:
                      tab == selected ? TextDecoration.underline : null,
                  decorationThickness: 2,
                  decorationColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
