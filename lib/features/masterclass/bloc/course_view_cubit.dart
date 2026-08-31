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

  void previous(CourseDetail course) {
    if (state.chapterIndex < 0) return;
    if (state.chapterIndex == 0) {
      selectCourseIntro();
    } else {
      selectChapter(state.chapterIndex - 1);
    }
  }

  void next(CourseDetail course) {
    if (course.chapters.isEmpty) return;
    if (state.chapterIndex < 0) {
      selectChapter(0);
    } else if (state.chapterIndex < course.chapters.length - 1) {
      selectChapter(state.chapterIndex + 1);
    }
  }
}
