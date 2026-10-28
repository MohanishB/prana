import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/route_names.dart';
import '../../../core/bloc/catalog_refresh_cubit.dart';
import '../../../core/checkout/checkout_models.dart';
import '../../../core/data/countries_cubit.dart';
import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/services/dependencies.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/validation/app_validators.dart';
import '../../../core/widgets/checkout_amount_row.dart';
import '../../../core/widgets/checkout_coupon_section.dart';
import '../../../core/widgets/checkout_details_form.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/consultation_checkout_cubit.dart';
import '../data/consult_checkout_models.dart';

/// Details, coupon, price and "Book now" for one consultation.
class ConsultationCheckoutScreen extends StatelessWidget {
  const ConsultationCheckoutScreen({required this.consultationId, super.key});

  final int consultationId;

  @override
  Widget build(BuildContext context) {
    final deps = context.read<AppDependencies>();
    final session = deps.sessionManager.current;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ConsultationCheckoutCubit(
            deps.consultCheckoutRepository,
            consultationId,
          )..refresh(email: session?.email ?? ''),
        ),
        BlocProvider(
          create: (_) => CountriesCubit(deps.countryRepository)..load(),
        ),
      ],
      child: const _CheckoutBody(),
    );
  }
}

class _CheckoutBody extends StatefulWidget {
  const _CheckoutBody();

  @override
  State<_CheckoutBody> createState() => _CheckoutBodyState();
}

class _CheckoutBodyState extends State<_CheckoutBody> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _coupon = TextEditingController();
  final _emailFocus = FocusNode();

  int? _countryId;
  String _quotedEmail = '';
  late final bool _loggedIn;

  @override
  void initState() {
    super.initState();
    final session = context.read<AppDependencies>().sessionManager.current;
    _loggedIn = session != null;
    if (session != null) {
      _name.text = session.fullName;
      _email.text = session.email;
      _phone.text = session.phone.replaceAll(RegExp(r'\D'), '');
      _quotedEmail = session.email.trim();
    }
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) _requoteForEmail();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _coupon.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  /// Checks the email once it is a valid address (and again if it changes).
  void _requoteForEmail() {
    final email = _email.text.trim();
    if (_loggedIn || email == _quotedEmail) return;
    if (email.isNotEmpty && !AppValidators.isValidEmail(email)) return;
    _quotedEmail = email;
    // A new email starts the check again, without a coupon.
    _coupon.clear();
    context
        .read<ConsultationCheckoutCubit>()
        .refresh(email: email, coupon: '');
  }

  void _applyCoupon() {
    FocusScope.of(context).unfocus();
    final code = _coupon.text.trim();
    if (code.isEmpty) return;
    _quotedEmail = _email.text.trim();
    context
        .read<ConsultationCheckoutCubit>()
        .refresh(email: _email.text, coupon: code);
  }

  void _removeCoupon() {
    _coupon.clear();
    context
        .read<ConsultationCheckoutCubit>()
        .removeCoupon(email: _email.text);
  }

  void _book() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ConsultationCheckoutCubit>().book(
          CheckoutDetails(
            name: _name.text.trim(),
            email: _email.text.trim(),
            countryId: _countryId!,
            phone: _phone.text.trim(),
          ),
        );
  }

  /// Picks India (or the first other country) until the visitor chooses one.
  void _preselectCountry(CountriesState countries, ConsultationQuote? quote) {
    if (_countryId != null || countries.countries.isEmpty) return;
    final inr = quote?.payable.currencyCode == 'INR';
    final match = countries.countries.where((c) => c.isIndia == inr);
    if (match.isEmpty) return;
    setState(() => _countryId = match.first.id);
  }

  void _onBooked(ConsultationOrderResult result) {
    context.read<CatalogRefreshCubit>().refresh();
    context.pushReplacementNamed(
      RouteNames.consultationBooked,
      extra: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MultiBlocListener(
      listeners: [
        BlocListener<ConsultationCheckoutCubit, ConsultationCheckoutState>(
          listenWhen: (a, b) => a.result == null && b.result != null,
          listener: (context, state) => _onBooked(state.result!),
        ),
        BlocListener<ConsultationCheckoutCubit, ConsultationCheckoutState>(
          listenWhen: (a, b) => a.quote == null && b.quote != null,
          listener: (context, state) => _preselectCountry(
            context.read<CountriesCubit>().state,
            state.quote,
          ),
        ),
        BlocListener<CountriesCubit, CountriesState>(
          listenWhen: (a, b) => a.countries.isEmpty && b.countries.isNotEmpty,
          listener: (context, state) => _preselectCountry(
            state,
            context.read<ConsultationCheckoutCubit>().state.quote,
          ),
        ),
      ],
      child: Scaffold(
        appBar: PranaAppBar(title: l10n.checkout, showBack: true),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ResponsiveContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.yourDetails,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
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
                    onEmailDone: _requoteForEmail,
                  ),
                ),
                // Not on page load: the coupon appears once the email is
                // entered and checked (existing students may use it too).
                _CouponField(
                  controller: _coupon,
                  onApply: _applyCoupon,
                  onRemove: _removeCoupon,
                ),
                const SizedBox(height: AppSpacing.lg),
                _SummarySection(
                  onRetry: () => context
                      .read<ConsultationCheckoutCubit>()
                      .refresh(email: _email.text),
                ),
                const SizedBox(height: AppSpacing.lg),
                _BookButton(onPressed: _book),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CouponField extends StatelessWidget {
  const _CouponField({
    required this.controller,
    required this.onApply,
    required this.onRemove,
  });

  final TextEditingController controller;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConsultationCheckoutCubit, ConsultationCheckoutState>(
      builder: (context, state) {
        final quote = state.quote;
        if (quote == null || quote.email.state == 'none') {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.lg),
          child: CheckoutCouponSection(
            controller: controller,
            coupon: quote.coupon,
            busy: state.quoting,
            onApply: onApply,
            onRemove: onRemove,
          ),
        );
      },
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return BlocBuilder<ConsultationCheckoutCubit, ConsultationCheckoutState>(
      builder: (context, state) {
        final quote = state.quote;
        if (quote == null) {
          if (state.quoteError != null) {
            return Column(
              children: [
                Text(
                  state.quoteError!.userMessage(context),
                  textAlign: TextAlign.center,
                ),
                TextButton(onPressed: onRetry, child: Text(l10n.retry)),
              ],
            );
          }
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.orderSummary,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    if (state.quoting)
                      const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                CheckoutAmountRow(
                  label: quote.title,
                  value: quote.price.formatted,
                ),
                if (quote.hasDiscount)
                  CheckoutAmountRow(
                    label: l10n.discount,
                    value: '-${quote.discount.formatted}',
                  ),
                const Divider(height: AppSpacing.lg),
                CheckoutAmountRow(
                  label: l10n.totalPayable,
                  value: quote.payable.formatted,
                  strong: true,
                ),
                if (quote.simulated && !quote.isFree) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.testModeNotice,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
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

class _BookButton extends StatelessWidget {
  const _BookButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<ConsultationCheckoutCubit, ConsultationCheckoutState>(
      builder: (context, state) {
        final quote = state.quote;
        final label = quote == null || state.quoting
            ? l10n.checkingPrice
            : quote.isFree
                ? l10n.confirmFreeBooking
                : l10n.bookNowAmount(quote.payable.formatted);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.orderError != null) ...[
              Text(
                state.orderError!.userMessage(context),
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            FilledButton(
              onPressed: state.canBook ? onPressed : null,
              child: state.placing
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(label),
            ),
          ],
        );
      },
    );
  }
}
