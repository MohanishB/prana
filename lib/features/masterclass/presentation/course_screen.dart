import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/errors/app_error_localization.dart';
import '../../../core/files/downloadable_file.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/services/dependencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/downloadable_file_tile.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/course_detail_cubit.dart';
import '../bloc/course_quiz_cubit.dart';
import '../bloc/course_view_cubit.dart';
import '../data/masterclass_models.dart';
import 'widgets/course_navigation_buttons.dart';
import 'widgets/course_tab_bar.dart';

class CourseScreen extends StatelessWidget {
  const CourseScreen({required this.courseId, super.key});
  final int courseId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (_) => CourseViewCubit(),
      child: BlocBuilder<CourseDetailCubit, CourseDetailState>(
        builder: (context, state) => Scaffold(
          appBar: PranaAppBar(
            title: state is CourseDetailLoaded
                ? state.course.title
                : l10n.masterclass,
            showBack: true,
            onBack: () {
              final viewCubit = context.read<CourseViewCubit>();
              if (viewCubit.state.chapterIndex >= 0) {
                viewCubit.selectCourseIntro();
              } else {
                context.pop();
              }
            },
          ),
          body: switch (state) {
            CourseDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            CourseDetailFailure(:final error) => AppErrorView(
                message: error.userMessage(context),
                retryLabel: l10n.retry,
                onRetry: context.read<CourseDetailCubit>().load,
              ),
            CourseDetailLoaded(:final course) => _CourseContent(course: course),
          },
        ),
      ),
    );
  }
}


class _CourseContent extends StatefulWidget {
  const _CourseContent({required this.course});

  final CourseDetail course;

  @override
  State<_CourseContent> createState() => _CourseContentState();
}

class _CourseContentState extends State<_CourseContent> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _chaptersKey = GlobalKey();

  CourseDetail get course => widget.course;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToChapters() {
    final chaptersContext = _chaptersKey.currentContext;
    if (chaptersContext == null) return;

    Scrollable.ensureVisible(
      chaptersContext,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }

  void _scrollToTopAfterChapterChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _selectChapter(BuildContext context, int index) {
    context.read<CourseViewCubit>().selectChapter(index);
  }

  void _previousTab(BuildContext context, CourseChapter chapter) {
    context.read<CourseViewCubit>().previousTab(chapter);
    _scrollToTopAfterChapterChange();
  }

  void _nextTab(BuildContext context, CourseChapter chapter) {
    context.read<CourseViewCubit>().nextTab(chapter);
    _scrollToTopAfterChapterChange();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CourseViewCubit, CourseViewState>(
      listenWhen: (previous, current) =>
          previous.chapterIndex != current.chapterIndex,
      listener: (_, __) => _scrollToTopAfterChapterChange(),
      builder: (context, view) {
        final chapter = view.chapterIndex >= 0 &&
                view.chapterIndex < course.chapters.length
            ? course.chapters[view.chapterIndex]
            : null;

        return SingleChildScrollView(
          controller: _scrollController,
          child: ResponsiveContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (chapter == null)
                  _CourseIntro(
                    course: course,
                    onViewChapters:
                        course.chapters.isEmpty ? null : _scrollToChapters,
                  )
                else ...[
                  Text(
                    context.l10n.chapterNumber(chapter.position),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.brick,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    chapter.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CourseTabBar(
                    selected: view.tab,
                    showVideos: chapter.videos.isNotEmpty,
                    showQuiz: chapter.quiz.available,
                    showNotes: chapter.notes.isNotEmpty,
                    onSelected: context.read<CourseViewCubit>().selectTab,
                  ),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  _ChapterTabContent(chapter: chapter, tab: view.tab),
                ],
                const SizedBox(height: AppSpacing.md),
                CourseNavigationButtons(
                  onPrevious: chapter != null &&
                          context
                              .read<CourseViewCubit>()
                              .canGoPreviousTab(chapter)
                      ? () => _previousTab(context, chapter)
                      : null,
                  onNext: chapter != null &&
                          context.read<CourseViewCubit>().canGoNextTab(chapter)
                      ? () => _nextTab(context, chapter)
                      : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (chapter == null) ...[
                  KeyedSubtree(
                    key: _chaptersKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.l10n.chapters,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (var i = 0; i < course.chapters.length; i++) ...[
                          _ChapterCard(
                            chapter: course.chapters[i],
                            onTap: () => _selectChapter(context, i),
                          ),
                          if (i != course.chapters.length - 1)
                            const SizedBox(height: AppSpacing.sm),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _CertificateSection(
                    courseId: course.courseId,
                    courseTitle: course.title,
                    certificate: course.certificate,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}


class _CourseIntro extends StatelessWidget {
  const _CourseIntro({
    required this.course,
    required this.onViewChapters,
  });

  final CourseDetail course;
  final VoidCallback? onViewChapters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          course.intro.tabTitle.isEmpty
              ? context.l10n.courseIntro
              : course.intro.tabTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (onViewChapters != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onViewChapters,
              icon: const Icon(Icons.menu_book_outlined),
              label: Text(context.l10n.viewChapters),
            ),
          ),
        ],
        if (course.intro.imageUrl.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                course.intro.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _MediaFallback(),
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        _HtmlLikeText(course.intro.descriptionHtml),
      ],
    );
  }
}

class _ChapterTabContent extends StatelessWidget {
  const _ChapterTabContent({required this.chapter, required this.tab});
  final CourseChapter chapter;
  final CourseTab tab;

  @override
  Widget build(BuildContext context) => switch (tab) {
        CourseTab.intro => _IntroTab(chapter: chapter),
        CourseTab.videos => _VideosTab(videos: chapter.videos),
        CourseTab.quiz => _QuizTab(chapter: chapter),
        CourseTab.notes => _NotesTab(notes: chapter.notes),
      };
}

class _IntroTab extends StatelessWidget {
  const _IntroTab({required this.chapter});
  final CourseChapter chapter;

  @override
  Widget build(BuildContext context) {
    final text = chapter.fullDescription.isNotEmpty
        ? chapter.fullDescription
        : chapter.introDescription;
    return _HtmlLikeText(text);
  }
}

class _VideosTab extends StatelessWidget {
  const _VideosTab({required this.videos});
  final List<CourseVideo> videos;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return Text(context.l10n.noVideos);
    return Column(
      children: [
        for (var i = 0; i < videos.length; i++) ...[
          _VideoCard(video: videos[i]),
          if (i != videos.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video});
  final CourseVideo video;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: !video.canPlay
            ? null
            : () => context.pushNamed(
                  RouteNames.courseVideo,
                  pathParameters: {
                    'courseId': '${context.read<CourseDetailCubit>().courseId}',
                    'videoId': '${video.id}',
                  },
                  extra: video,
                ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: AppSizes.thumbnailWidth,
                height: AppSizes.thumbnailHeight,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.forest, AppColors.forest2],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.play_arrow, color: AppColors.white),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${video.position}. ${video.title}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizTab extends StatelessWidget {
  const _QuizTab({required this.chapter});

  final CourseChapter chapter;

  @override
  Widget build(BuildContext context) {
    if (!chapter.quiz.available) return Text(context.l10n.quizUnavailable);

    final dependencies = context.read<AppDependencies>();
    final courseId = context.read<CourseDetailCubit>().courseId;

    return BlocProvider(
      key: ValueKey('quiz_${courseId}_${chapter.id}_${chapter.quiz.completed}'),
      create: (_) => CourseQuizCubit(
        repository: dependencies.masterclassRepository,
        courseId: courseId,
        chapterId: chapter.id,
        quiz: chapter.quiz,
      ),
      child: _QuizContent(chapterId: chapter.id),
    );
  }
}

class _QuizContent extends StatelessWidget {
  const _QuizContent({required this.chapterId});

  final int chapterId;

  Future<void> _submit(BuildContext context, CourseQuizReady state) async {
    if (!state.allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.answerEveryQuestion)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.confirmQuizSubmission),
        content: Text(dialogContext.l10n.quizSubmitWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.l10n.confirmSubmit),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final result = await context.read<CourseQuizCubit>().submit();
    if (!context.mounted || result == null) return;

    context.read<CourseDetailCubit>().updateChapterQuiz(
          chapterId: chapterId,
          quiz: result,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.quizSubmitted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseQuizCubit, CourseQuizState>(
      builder: (context, state) {
        final ready = state as CourseQuizReady;
        final quiz = ready.quiz;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (quiz.completed) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        child: Icon(Icons.emoji_events_outlined),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.quizResult,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              context.l10n.quizScore(
                                quiz.correct,
                                quiz.total,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ] else ...[
              Text(
                context.l10n.quizQuestions(quiz.questionCount),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.quizSubmitWarning,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            for (final question in quiz.questions) ...[
              _QuizQuestionCard(
                question: question,
                selectedOptionNo: ready.answers[question.id],
                readOnly: quiz.completed || ready.isSubmitting,
                onSelected: (optionNo) =>
                    context.read<CourseQuizCubit>().selectAnswer(
                          quizId: question.id,
                          optionNo: optionNo,
                        ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (!quiz.completed) ...[
              if (ready.error != null) ...[
                Text(
                  ready.error!.userMessage(context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      ready.isSubmitting ? null : () => _submit(context, ready),
                  child: ready.isSubmitting
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: AppSizes.loadingIndicatorSmall,
                              height: AppSizes.loadingIndicatorSmall,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(context.l10n.submittingQuiz),
                          ],
                        )
                      : Text(context.l10n.submitQuiz),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _QuizQuestionCard extends StatelessWidget {
  const _QuizQuestionCard({
    required this.question,
    required this.selectedOptionNo,
    required this.readOnly,
    required this.onSelected,
  });

  final CourseQuizQuestion question;
  final int? selectedOptionNo;
  final bool readOnly;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final result = question.isCorrect;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${context.l10n.questionShort}${question.position} '
                    '${question.question.trim()}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (result != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    result
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: result ? AppColors.success : colorScheme.error,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final option
                in question.options.where((item) => item.text.trim().isNotEmpty))
              RadioListTile<int>(
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: option.optionNo,
                groupValue: selectedOptionNo,
                onChanged: readOnly
                    ? null
                    : (value) {
                        if (value != null) onSelected(value);
                      },
                title: Text(option.text.trim()),
              ),
            if (result != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                result ? context.l10n.quizCorrect : context.l10n.quizIncorrect,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: result ? AppColors.success : colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.notes});
  final List<CourseNote> notes;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return Text(context.l10n.noNotes);

    final service = context.read<AppDependencies>().fileDownloadService;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            for (var i = 0; i < notes.length; i++) ...[
              DownloadableFileTile(
                service: service,
                file: DownloadableFile(
                  id: 'note_${notes[i].id}',
                  title: notes[i].title,
                  remoteUrl: notes[i].url,
                  folder: 'notes',
                ),
                leading: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: AppColors.brick,
                ),
              ),
              if (i != notes.length - 1) const Divider(),
            ],
          ],
        ),
      ),
    );
  }
}



class _CertificateSection extends StatelessWidget {
  const _CertificateSection({
    required this.courseId,
    required this.courseTitle,
    required this.certificate,
  });

  final int courseId;
  final String courseTitle;
  final CourseCertificate certificate;

  @override
  Widget build(BuildContext context) {
    final detailState = context.watch<CourseDetailCubit>().state;
    final loadedState =
        detailState is CourseDetailLoaded ? detailState : null;

    if (certificate.canDownload) {
      return _CourseCertificateCard(
        courseId: courseId,
        courseTitle: courseTitle,
        certificate: certificate,
      );
    }

    final isGenerating = loadedState?.isGeneratingCertificate ?? false;
    final generationError = loadedState?.certificateGenerationError;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.workspace_premium_outlined,
                  color: AppColors.gold,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.certificate,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              certificate.generated
                  ? context.l10n.certificateApiUnavailable
                  : context.l10n.certificateNotGenerated,
            ),
            if (generationError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                generationError.userMessage(context),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
            if (!certificate.generated) ...[
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: isGenerating
                    ? null
                    : context.read<CourseDetailCubit>().generateCertificate,
                icon: isGenerating
                    ? const SizedBox.square(
                        dimension: AppSizes.loadingIndicatorSmall,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.workspace_premium_outlined),
                label: Text(
                  isGenerating
                      ? context.l10n.generatingCertificate
                      : context.l10n.getCertificate,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CourseCertificateCard extends StatelessWidget {
  const _CourseCertificateCard({
    required this.courseId,
    required this.courseTitle,
    required this.certificate,
  });

  final int courseId;
  final String courseTitle;
  final CourseCertificate certificate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.workspace_premium_outlined,
          color: AppColors.gold,
        ),
        title: Text(context.l10n.certificateReady),
        subtitle: certificate.generatedOn.isEmpty
            ? Text(context.l10n.tapToViewCertificate)
            : Text(
                context.l10n.certificateGeneratedOn(
                  certificate.generatedOn,
                ),
              ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.pushNamed(
          RouteNames.certificate,
          pathParameters: {'certificateId': '$courseId'},
          queryParameters: {
            'title': courseTitle,
            'url': certificate.downloadUrl,
            if (certificate.generatedOn.isNotEmpty)
              'generatedOn': certificate.generatedOn,
          },
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({required this.chapter, required this.onTap});
  final CourseChapter chapter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final completed = chapter.quiz.available && chapter.quiz.completed;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chapter.position.toString().padLeft(2, '0'),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chapter.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      context.l10n.chapterContents(
                        chapter.videos.length,
                        chapter.quiz.available ? 1 : 0,
                        chapter.notes.length,
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (completed)
                const Icon(Icons.check_circle_outline, color: AppColors.success)
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _HtmlLikeText extends StatelessWidget {
  const _HtmlLikeText(this.html);
  final String html;

  @override
  Widget build(BuildContext context) {
    final plain = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<li>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
    return Text(plain, style: Theme.of(context).textTheme.bodyMedium);
  }
}

class _MediaFallback extends StatelessWidget {
  const _MediaFallback();

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.image_outlined)),
      );
}

