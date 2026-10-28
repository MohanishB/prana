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
import '../../../core/widgets/checkout_amount_row.dart';
import '../../../core/widgets/checkout_details_form.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/gut_reset_checkout_cubit.dart';
import '../data/gut_reset_models.dart';

/// A guest's details (name, email, country, mobile) before "Book now" for a
/// Gut Reset. A new email gets a student account, as for masterclasses.
class GutResetCheckoutScreen extends StatelessWidget {
  const GutResetCheckoutScreen({required this.offer, super.key});

  final GutResetOffer offer;

  @override
  Widget build(BuildContext context) {
    final deps = context.read<AppDependencies>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GutResetCheckoutCubit(deps.gutResetRepository),
        ),
        BlocProvider(
          create: (_) => CountriesCubit(deps.countryRepository)..load(),
        ),
      ],
      child: _CheckoutBody(offer: offer),
    );
  }
}

class _CheckoutBody extends StatefulWidget {
  const _CheckoutBody({required this.offer});

  final GutResetOffer offer;

  @override
  State<_CheckoutBody> createState() => _CheckoutBodyState();
}

class _CheckoutBodyState extends State<_CheckoutBody> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _emailFocus = FocusNode();
  int? _countryId;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  /// India (INR price) or the first other country (USD price).
  void _preselectCountry(CountriesState countries) {
    if (_countryId != null || countries.countries.isEmpty) return;
    final inr = widget.offer.price.currencyCode == 'INR';
    final match = countries.countries.where((c) => c.isIndia == inr);
    setState(() => _countryId =
        (match.isNotEmpty ? match.first : countries.countries.first).id);
  }

  void _book() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<GutResetCheckoutCubit>().book(
          widget.offer.type,
          details: CheckoutDetails(
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
    final theme = Theme.of(context);
    final offer = widget.offer;
    return MultiBlocListener(
      listeners: [
        BlocListener<GutResetCheckoutCubit, GutResetCheckoutState>(
          listenWhen: (a, b) => a.result == null && b.result != null,
          listener: (context, state) {
            context.read<CatalogRefreshCubit>().refresh();
            context.pushReplacementNamed(
              RouteNames.gutResetBooked,
              extra: state.result,
            );
          },
        ),
        BlocListener<CountriesCubit, CountriesState>(
          listenWhen: (a, b) => a.countries.isEmpty && b.countries.isNotEmpty,
          listener: (context, state) => _preselectCountry(state),
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
                Text(l10n.yourDetails, style: theme.textTheme.titleSmall),
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
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.orderSummary,
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: AppSpacing.sm),
                        CheckoutAmountRow(
                          label: offer.title,
                          value: offer.price.formatted,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.testModeNotice,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
            child: BlocBuilder<GutResetCheckoutCubit, GutResetCheckoutState>(
              builder: (context, state) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.error != null) ...[
                    Text(
                      state.error!.userMessage(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  FilledButton(
                    onPressed: state.placing ? null : _book,
                    child: state.placing
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.bookNowAmount(offer.price.formatted)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
