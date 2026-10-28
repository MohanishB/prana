import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/checkout/checkout_models.dart';
import '../../../core/data/countries_cubit.dart';
import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/services/dependencies.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/checkout_details_form.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/dosha_quiz_cubit.dart';
import '../data/dosha_models.dart';

/// The Dosha quiz, open to everyone: one question per page, then the details
/// (empty for a guest, filled in for a signed-in student), then the result.
class DoshaQuizScreen extends StatelessWidget {
  const DoshaQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = context.read<AppDependencies>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => DoshaQuizCubit(deps.doshaRepository)..load(),
        ),
        BlocProvider(
          create: (_) => CountriesCubit(deps.countryRepository)..load(),
        ),
      ],
      child: const _QuizBody(),
    );
  }
}

class _QuizBody extends StatefulWidget {
  const _QuizBody();

  @override
  State<_QuizBody> createState() => _QuizBodyState();
}

class _QuizBodyState extends State<_QuizBody> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _emailFocus = FocusNode();

  int? _countryId;
  bool _loggedIn = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  /// A signed-in student's details are filled in; a guest starts empty.
  void _fillFromProfile(DoshaProfile? profile) {
    if (profile == null) return;
    _loggedIn = true;
    _name.text = profile.name;
    _email.text = profile.email;
    _phone.text = profile.phone;
    if (profile.countryId > 0) _countryId = profile.countryId;
    _preselectCountry(context.read<CountriesCubit>().state);
    setState(() {});
  }

  /// India until the visitor (or the saved profile) chooses another country.
  void _preselectCountry(CountriesState countries) {
    if (_countryId != null || countries.countries.isEmpty) return;
    final india = countries.countries.where((c) => c.isIndia);
    setState(() => _countryId =
        (india.isNotEmpty ? india.first : countries.countries.first).id);
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<DoshaQuizCubit>().submit(
          CheckoutDetails(
            name: _name.text.trim(),
            email: _email.text.trim(),
            countryId: _countryId!,
            phone: _phone.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MultiBlocListener(
      listeners: [
        BlocListener<DoshaQuizCubit, DoshaQuizState>(
          listenWhen: (a, b) => a.quiz == null && b.quiz != null,
          listener: (context, state) => _fillFromProfile(state.quiz!.profile),
        ),
        BlocListener<DoshaQuizCubit, DoshaQuizState>(
          listenWhen: (a, b) => a.result == null && b.result != null,
          listener: (context, state) => context.pushReplacementNamed(
            RouteNames.doshaQuizResult,
            extra: state.result,
          ),
        ),
        BlocListener<CountriesCubit, CountriesState>(
          listenWhen: (a, b) => a.countries.isEmpty && b.countries.isNotEmpty,
          listener: (context, state) => _preselectCountry(state),
        ),
      ],
      child: BlocBuilder<DoshaQuizCubit, DoshaQuizState>(
        builder: (context, state) {
          // Back (top left or the phone's back button) always leaves the quiz
          // for My account; it never goes to the previous question.
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) context.goNamed(RouteNames.account);
            },
            child: Scaffold(
              appBar: PranaAppBar(
                title: l10n.doshaQuiz,
                showBack: true,
                onBack: () => context.goNamed(RouteNames.account),
              ),
              body: _content(context, state),
              bottomNavigationBar: _footer(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context, DoshaQuizState state) {
    final l10n = context.l10n;
    final quiz = state.quiz;
    if (quiz == null) {
      if (state.error != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.error!.userMessage(context),
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => context.read<DoshaQuizCubit>().load(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    final progress = (state.step.clamp(0, state.questionCount)) /
        (state.questionCount == 0 ? 1 : state.questionCount);
    return Column(
      children: [
        LinearProgressIndicator(value: progress, minHeight: 4),
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ResponsiveContent(
              child: state.onDetails
                  ? _details(context, state)
                  : _question(context, state, quiz.questions[state.step]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _question(
    BuildContext context,
    DoshaQuizState state,
    DoshaQuestion question,
  ) {
    final theme = Theme.of(context);
    final chosen = state.answers[state.step];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.doshaQuestionOf(state.step + 1, state.questionCount),
          style: theme.textTheme.labelLarge
              ?.copyWith(color: theme.colorScheme.primary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(question.question, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.lg),
        for (var i = 0; i < question.options.length; i++) ...[
          _OptionTile(
            label: question.options[i],
            selected: chosen == i,
            onTap: () => context.read<DoshaQuizCubit>().select(i),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  Widget _details(BuildContext context, DoshaQuizState state) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.doshaDetailsTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.doshaDetailsBody, style: theme.textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.lg),
        BlocBuilder<CountriesCubit, CountriesState>(
          builder: (context, countries) => CheckoutDetailsForm(
            formKey: _formKey,
            nameController: _name,
            emailController: _email,
            phoneController: _phone,
            emailFocus: _emailFocus,
            countries: countries.countries,
            countryId: _countryId,
            onCountryChanged: (id) => setState(() => _countryId = id),
            emailLocked: _loggedIn,
          ),
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

  /// Only the last screen (the details) has a button; the questions move on
  /// as soon as an answer is tapped.
  Widget? _footer(BuildContext context, DoshaQuizState state) {
    if (state.quiz == null || !state.onDetails) return null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
        child: FilledButton(
          onPressed: state.submitting ? null : _submit,
          child: state.submitting
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(context.l10n.doshaGetResult),
        ),
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
