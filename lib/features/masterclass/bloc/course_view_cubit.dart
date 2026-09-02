import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/masterclass_models.dart';
import '../presentation/widgets/course_tab_bar.dart';

class CourseViewState {
  const CourseViewState({
    required this.chapterIndex,
    required this.tab,
  });

  final int chapterIndex;
  final CourseTab tab;

  CourseViewState copyWith({int? chapterIndex, CourseTab? tab}) =>
      CourseViewState(
        chapterIndex: chapterIndex ?? this.chapterIndex,
        tab: tab ?? this.tab,
      );
}

class CourseViewCubit extends Cubit<CourseViewState> {
  CourseViewCubit() : super(const CourseViewState(
          chapterIndex: -1,
          tab: CourseTab.intro,
        ));

  void selectCourseIntro() =>
      emit(const CourseViewState(chapterIndex: -1, tab: CourseTab.intro));

  void selectChapter(int index) =>
      emit(CourseViewState(chapterIndex: index, tab: CourseTab.intro));

  void selectTab(CourseTab tab) => emit(state.copyWith(tab: tab));

  List<CourseTab> availableTabs(CourseChapter chapter) => <CourseTab>[
        CourseTab.intro,
        if (chapter.videos.isNotEmpty) CourseTab.videos,
        if (chapter.quiz.available) CourseTab.quiz,
        if (chapter.notes.isNotEmpty) CourseTab.notes,
      ];

  bool canGoPreviousTab(CourseChapter chapter) {
    final tabs = availableTabs(chapter);
    final index = tabs.indexOf(state.tab);
    return index > 0;
  }

  bool canGoNextTab(CourseChapter chapter) {
    final tabs = availableTabs(chapter);
    final index = tabs.indexOf(state.tab);
    return index >= 0 && index < tabs.length - 1;
  }

  void previousTab(CourseChapter chapter) {
    final tabs = availableTabs(chapter);
    final index = tabs.indexOf(state.tab);
    if (index > 0) {
      selectTab(tabs[index - 1]);
    }
  }

  void nextTab(CourseChapter chapter) {
    final tabs = availableTabs(chapter);
    final index = tabs.indexOf(state.tab);
    if (index >= 0 && index < tabs.length - 1) {
      selectTab(tabs[index + 1]);
    }
  }
}
