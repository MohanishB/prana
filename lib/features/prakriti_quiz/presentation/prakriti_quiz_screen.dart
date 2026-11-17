import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/services/dependencies.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/prakriti_quiz_cubit.dart';
import 'prakriti_result_view.dart';

/// The Prakriti (body type) quiz, for signed-in students. A student who already
/// has a result sees it first, with a Retake button. A visitor who is not
/// signed in sees a short message and a Log in button.
class PrakritiQuizScreen extends StatelessWidget {
  const PrakritiQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.watch<AuthBloc>().state is AuthGuest) {
      return const _LoginRequired();
    }
    final deps = context.read<AppDependencies>();
    return BlocProvider(
      create: (_) => PrakritiQuizCubit(
        deps.prakritiRepository,
        deps.prakritiProgressStore,
      )..load(),
      child: const _QuizBody(),
    );
  }
}

class _LoginRequired extends StatelessWidget {
  const _LoginRequired();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PranaAppBar(
        title: l10n.doshaQuiz,
        showBack: true,
        onBack: () => context.goNamed(RouteNames.account),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.prakritiLoginRequired,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(const AuthLoginRequested()),
                child: Text(l10n.signIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizBody extends StatefulWidget {
  const _QuizBody();

  @override
  State<_QuizBody> createState() => _QuizBodyState();
}

class _QuizBodyState extends State<_QuizBody> {
  /// Back goes one step inside the quiz; from the instructions or the result
  /// it leaves the quiz for My account.
  void _onBack() {
    if (!context.read<PrakritiQuizCubit>().back()) {
      context.goNamed(RouteNames.account);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<PrakritiQuizCubit, PrakritiQuizState>(
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _onBack();
            },
            child: Scaffold(
              appBar: PranaAppBar(
                title: l10n.doshaQuiz,
                showBack: true,
                onBack: _onBack,
              ),
              body: _content(context, state),
              bottomNavigationBar: _footer(context, state),
            ),
          );
        },
    );
  }

  Widget _content(BuildContext context, PrakritiQuizState state) {
    final l10n = context.l10n;
    switch (state.phase) {
      case PrakritiPhase.loading:
        return const Center(child: CircularProgressIndicator());
      case PrakritiPhase.failed:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.error?.userMessage(context) ?? l10n.errorGeneric,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => context.read<PrakritiQuizCubit>().load(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        );
      case PrakritiPhase.welcome:
        return _scroll(_welcome(context, state));
      case PrakritiPhase.question:
        return Column(
          children: [
            LinearProgressIndicator(
              value: state.total == 0 ? 0 : state.index / state.total,
              minHeight: 4,
            ),
            Expanded(child: _scroll(_question(context, state))),
          ],
        );
      case PrakritiPhase.closing:
        return _scroll(_closing(context, state));
      case PrakritiPhase.result:
        return SingleChildScrollView(
          child: ResponsiveContent(
            child: PrakritiResultView(
              result: state.result!,
              onRetake: () => context.read<PrakritiQuizCubit>().retake(),
            ),
          ),
        );
    }
  }

  Widget _scroll(Widget child) => SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: ResponsiveContent(child: child),
      );

  Widget _welcome(BuildContext context, PrakritiQuizState state) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final quiz = state.quiz!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.versionChanged) ...[
          Text(
            l10n.prakritiVersionChanged,
            style: TextStyle(color: theme.colorScheme.error),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Text(l10n.doshaQuiz, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(quiz.introText, style: theme.textTheme.bodyLarge),
      ],
    );
  }

  Widget _question(BuildContext context, PrakritiQuizState state) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final quiz = state.quiz!;
    final q = state.question;
    if (q == null) return const SizedBox.shrink();
    final chosen = state.chosen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.prakritiProgress(
              q.partNo, quiz.partCount, state.index + 1, state.total),
          style: theme.textTheme.labelLarge
              ?.copyWith(color: theme.colorScheme.primary),
        ),
        if (q.firstInPart) ...[
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q.partTitle, style: theme.textTheme.titleSmall),
                  if (q.partIntro.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(q.partIntro, style: theme.textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Text(q.text, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.lg),
        for (final option in q.options) ...[
          _OptionTile(
            label: option.text,
            selected: chosen == option.id,
            onTap: () => context.read<PrakritiQuizCubit>().select(option.id),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (quiz.notSureTip.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            quiz.notSureTip,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ],
    );
  }

  Widget _closing(BuildContext context, PrakritiQuizState state) {
    final theme = Theme.of(context);
    final quiz = state.quiz!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(
          quiz.finalScreenText,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          quiz.disclaimerText,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        if (state.submitError != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            state.submitError!.userMessage(context),
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ],
      ],
    );
  }

  Widget _busy() => const SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );

  /// Questions move on as soon as an answer is tapped, so only the other
  /// screens have a button.
  Widget? _footer(BuildContext context, PrakritiQuizState state) {
    final l10n = context.l10n;
    final cubit = context.read<PrakritiQuizCubit>();
    final Widget? button;
    switch (state.phase) {
      case PrakritiPhase.welcome:
        button = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.canResume) ...[
              FilledButton(
                onPressed: cubit.resume,
                child: Text(l10n.prakritiResume),
              ),
              const SizedBox(height: AppSpacing.xs),
              OutlinedButton(
                onPressed: cubit.start,
                child: Text(l10n.prakritiStartOver),
              ),
            ] else
              FilledButton(
                onPressed: state.total == 0 ? null : cubit.start,
                child: Text(l10n.prakritiStart),
              ),
          ],
        );
      case PrakritiPhase.closing:
        button = FilledButton(
          onPressed: state.submitting ? null : cubit.continueFromClosing,
          child: state.submitting ? _busy() : Text(l10n.prakritiSeeResult),
        );
      case PrakritiPhase.loading:
      case PrakritiPhase.failed:
      case PrakritiPhase.question:
      case PrakritiPhase.result:
        button = null;
    }
    if (button == null) return null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
        child: button,
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.35)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? scheme.primary : scheme.outline,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }
}
