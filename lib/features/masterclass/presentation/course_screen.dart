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
    return BlocBuilder<CourseDetailCubit, CourseDetailState>(
      builder: (context, state) => Scaffold(
        appBar: PranaAppBar(
          title: state is CourseDetailLoaded ? state.course.title : l10n.masterclass,
          showBack: true,
        ),
        body: switch (state) {
          CourseDetailLoading() => const Center(child: CircularProgressIndicator()),
          CourseDetailFailure(:final error) => AppErrorView(
              message: error.userMessage(context),
              retryLabel: l10n.retry,
              onRetry: context.read<CourseDetailCubit>().load,
            ),
          CourseDetailLoaded(:final course) => BlocProvider(
              create: (_) => CourseViewCubit(),
              child: _CourseContent(course: course),
            ),
        },
      ),
    );
  }
}

class _CourseContent extends StatelessWidget {
  const _CourseContent({required this.course});
  final CourseDetail course;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseViewCubit, CourseViewState>(
      builder: (context, view) {
        final chapter = view.chapterIndex >= 0 &&
                view.chapterIndex < course.chapters.length
            ? course.chapters[view.chapterIndex]
            : null;

        return SingleChildScrollView(
          child: ResponsiveContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (chapter == null)
                  _CourseIntro(course: course)
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
                  Text(chapter.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  CourseTabBar(
                    selected: view.tab,
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
                  onPrevious: view.chapterIndex >= 0
                      ? () => context.read<CourseViewCubit>().previous(course)
                      : null,
                  onNext: view.chapterIndex < course.chapters.length - 1
                      ? () => context.read<CourseViewCubit>().next(course)
                      : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (chapter == null) ...[
                  Text(
                    context.l10n.chapters,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (var i = 0; i < course.chapters.length; i++) ...[
                    _ChapterCard(
                      chapter: course.chapters[i],
                      onTap: () =>
                          context.read<CourseViewCubit>().selectChapter(i),
                    ),
                    if (i != course.chapters.length - 1)
                      const SizedBox(height: AppSpacing.sm),
                  ],
                  if (course.certificate.canDownload) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _CourseCertificateCard(
                      courseId: course.courseId,
                      courseTitle: course.title,
                      certificate: course.certificate,
                    ),
                  ],
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
  const _CourseIntro({required this.course});
  final CourseDetail course;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(course.intro.tabTitle.isEmpty ? context.l10n.courseIntro : course.intro.tabTitle,
            style: Theme.of(context).textTheme.titleLarge),
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
        CourseTab.quiz => _QuizTab(quiz: chapter.quiz),
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
  const _QuizTab({required this.quiz});
  final CourseQuiz quiz;

  @override
  Widget build(BuildContext context) {
    if (!quiz.available) return Text(context.l10n.quizUnavailable);
    if (!quiz.completed) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const CircleAvatar(child: Icon(Icons.quiz_outlined)),
              const SizedBox(height: AppSpacing.sm),
              Text(context.l10n.chapterQuiz,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(context.l10n.quizQuestions(quiz.questionCount)),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: null,
                  child: Text(context.l10n.startQuiz),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.quizSubmissionComingSoon,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.quizScore(quiz.correct, quiz.total),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final question in quiz.questions) ...[
          _QuizQuestionCard(question: question),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _QuizQuestionCard extends StatelessWidget {
  const _QuizQuestionCard({required this.question});
  final CourseQuizQuestion question;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${context.l10n.questionShort}${question.position} ${question.question}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final option in question.options)
              RadioListTile<int>(
                dense: true,
                value: option.optionNo,
                groupValue: question.studentAnswer?.optionNo,
                onChanged: null,
                title: Text(option.text),
              ),
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

