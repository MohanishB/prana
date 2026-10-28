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
import '../bloc/masterclass_cart_cubit.dart';
import '../bloc/masterclass_checkout_cubit.dart';
import '../data/masterclass_checkout_models.dart';

/// Details, coupon, price summary and "Buy now" for one masterclass or the cart.
class MasterclassCheckoutScreen extends StatelessWidget {
  const MasterclassCheckoutScreen({required this.args, super.key});

  final CheckoutArgs args;

  @override
  Widget build(BuildContext context) {
    final deps = context.read<AppDependencies>();
    final session = deps.sessionManager.current;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MasterclassCheckoutCubit(
            deps.masterclassCheckoutRepository,
            args,
          )..refresh(email: session?.email ?? ''),
        ),
        BlocProvider(
          create: (_) => CountriesCubit(deps.countryRepository)..load(),
        ),
      ],
      child: _CheckoutBody(args: args),
    );
  }
}

class _CheckoutBody extends StatefulWidget {
  const _CheckoutBody({required this.args});

  final CheckoutArgs args;

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

  /// The price can depend on the email (existing students pay differently).
  void _requoteForEmail() {
    final email = _email.text.trim();
    if (_loggedIn || email == _quotedEmail) return;
    if (email.isNotEmpty && !AppValidators.isValidEmail(email)) return;
    _quotedEmail = email;
    // Like the website: a new email starts the price check again, without a coupon.
    _coupon.clear();
    context
        .read<MasterclassCheckoutCubit>()
        .refresh(email: email, coupon: '');
  }

  void _applyCoupon() {
    FocusScope.of(context).unfocus();
    final code = _coupon.text.trim();
    if (code.isEmpty) return;
    _quotedEmail = _email.text.trim();
    context
        .read<MasterclassCheckoutCubit>()
        .refresh(email: _email.text, coupon: code);
  }

  void _removeCoupon() {
    _coupon.clear();
    context.read<MasterclassCheckoutCubit>().removeCoupon(email: _email.text);
  }

  void _buy() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<MasterclassCheckoutCubit>().buy(
          CheckoutDetails(
            name: _name.text.trim(),
            email: _email.text.trim(),
            countryId: _countryId!,
            phone: _phone.text.trim(),
          ),
        );
  }

  /// Picks India (or the first country) until the visitor chooses one.
  void _preselectCountry(CountriesState countries, MasterclassQuote? quote) {
    if (_countryId != null || countries.countries.isEmpty) return;
    final inr = quote?.payable.currencyCode == 'INR';
    final match = countries.countries.where((c) => c.isIndia == inr);
    if (match.isEmpty) return;
    setState(() => _countryId = match.first.id);
  }

  void _onOrderPlaced(MasterclassOrderResult result) {
    final cart = context.read<MasterclassCartCubit>();
    if (widget.args.mode == CheckoutMode.cart) {
      cart.clear();
    } else {
      for (final id in widget.args.courseIds) {
        cart.remove(id);
      }
    }
    context.read<CatalogRefreshCubit>().refresh();
    context.pushReplacementNamed(
      RouteNames.masterclassOrderSuccess,
      extra: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MultiBlocListener(
      listeners: [
        BlocListener<MasterclassCheckoutCubit, MasterclassCheckoutState>(
          listenWhen: (a, b) => a.result == null && b.result != null,
          listener: (context, state) => _onOrderPlaced(state.result!),
        ),
        BlocListener<MasterclassCheckoutCubit, MasterclassCheckoutState>(
          listenWhen: (a, b) => a.quote == null && b.quote != null,
          listener: (context, state) =>
              _preselectCountry(context.read<CountriesCubit>().state, state.quote),
        ),
        BlocListener<CountriesCubit, CountriesState>(
          listenWhen: (a, b) => a.countries.isEmpty && b.countries.isNotEmpty,
          listener: (context, state) => _preselectCountry(
            state,
            context.read<MasterclassCheckoutCubit>().state.quote,
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
                // Same rule as the website: the coupon is offered only for a new
                // student (email checked, not enrolled). Not on page load, not for
                // an existing student, not when the email already owns the course.
                _CouponField(
                  controller: _coupon,
                  onApply: _applyCoupon,
                  onRemove: _removeCoupon,
                ),
                const SizedBox(height: AppSpacing.lg),
                _SummarySection(onRetry: () {
                  context
                      .read<MasterclassCheckoutCubit>()
                      .refresh(email: _email.text);
                }),
                const SizedBox(height: AppSpacing.lg),
                _BuyButton(onPressed: _buy),
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
    return BlocBuilder<MasterclassCheckoutCubit, MasterclassCheckoutState>(
      builder: (context, state) {
        final quote = state.quote;
        // Only a new student (email checked and not enrolled) can use a coupon.
        if (quote == null ||
            quote.email.state != 'new' ||
            quote.email.blocked) {
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
    return BlocBuilder<MasterclassCheckoutCubit, MasterclassCheckoutState>(
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
                for (final item in quote.items) _ItemRow(item: item),
                const Divider(height: AppSpacing.lg),
                CheckoutAmountRow(label: l10n.subtotal, value: quote.subtotal.formatted),
                if (quote.hasDiscount)
                  CheckoutAmountRow(
                    label: l10n.discount,
                    value: '-${quote.discount.formatted}',
                  ),
                const SizedBox(height: AppSpacing.xxs),
                CheckoutAmountRow(
                  label: l10n.totalPayable,
                  value: quote.payable.formatted,
                  strong: true,
                ),
                if (quote.email.message.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    quote.email.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: quote.email.blocked
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
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

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final CheckoutItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final String value;
    if (item.charged) {
      value = item.price.formatted;
    } else if (item.note == 'Already enrolled') {
      value = l10n.alreadyEnrolledNote;
    } else {
      value = l10n.includedFree;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(item.title, style: theme.textTheme.bodyMedium)),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: item.charged
                ? theme.textTheme.bodyMedium
                : theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _BuyButton extends StatelessWidget {
  const _BuyButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<MasterclassCheckoutCubit, MasterclassCheckoutState>(
      builder: (context, state) {
        final quote = state.quote;
        final label = quote == null || state.quoting
            ? l10n.checkingPrice
            : quote.isFree
                ? l10n.confirmFreeOrder
                : l10n.buyNowAmount(quote.payable.formatted);
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
              onPressed: state.canBuy ? onPressed : null,
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
