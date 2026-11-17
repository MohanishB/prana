import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/countries_cubit.dart';
import '../../../core/data/country_models.dart';
import '../../../core/errors/app_error_localization.dart';
import '../../../core/services/dependencies.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/validation/app_validators.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/register_cubit.dart';
import '../data/auth_models.dart';

/// Create an account. Same rules as the admin's "Add student": first name,
/// country, mobile, email and a password of 6+ characters are required.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _city = TextEditingController();
  final _pincode = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _gender = '';
  DateTime? _dob;
  int? _countryId;

  @override
  void dispose() {
    for (final c in [_first, _last, _city, _pincode, _phone, _email, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  /// India until the student picks another country.
  void _preselectCountry(CountriesState countries) {
    if (_countryId != null || countries.countries.isEmpty) return;
    final india = countries.countries.where((c) => c.isIndia);
    setState(() => _countryId =
        (india.isNotEmpty ? india.first : countries.countries.first).id);
  }

  Country? _selected(List<Country> countries) {
    for (final c in countries) {
      if (c.id == _countryId) return c;
    }
    return null;
  }

  String _dobText() {
    final d = _dob;
    if (d == null) return '';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false) || _countryId == null) {
      return;
    }
    context.read<RegisterCubit>().submit(RegisterRequest(
          firstName: _first.text,
          lastName: _last.text,
          gender: _gender,
          dob: _dobText(),
          countryId: _countryId!,
          city: _city.text,
          pincode: _pincode.text,
          phone: _phone.text,
          email: _email.text,
          password: _password.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => CountriesCubit(
        context.read<AppDependencies>().countryRepository,
      )..load(),
      child: Builder(
        builder: (context) => BlocListener<CountriesCubit, CountriesState>(
          listenWhen: (a, b) => a.countries.isEmpty && b.countries.isNotEmpty,
          listener: (context, state) => _preselectCountry(state),
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.registerTitle)),
            body: SafeArea(
              child: SingleChildScrollView(
                child: ResponsiveContent(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: BlocBuilder<RegisterCubit, RegisterState>(
                      builder: (context, reg) => Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(l10n.registerSubtitle,
                                style: theme.textTheme.bodyMedium),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _first,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              decoration:
                                  InputDecoration(labelText: l10n.registerFirstName),
                              validator: (v) =>
                                  AppValidators.isValidProfileText(v ?? '')
                                      ? null
                                      : l10n.registerFirstNameInvalid,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _last,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              decoration:
                                  InputDecoration(labelText: l10n.registerLastName),
                              validator: (v) =>
                                  AppValidators.isValidOptionalProfileText(v ?? '')
                                      ? null
                                      : l10n.registerLastNameInvalid,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            DropdownButtonFormField<String>(
                              value: _gender.isEmpty ? null : _gender,
                              decoration:
                                  InputDecoration(labelText: l10n.registerGender),
                              items: [
                                DropdownMenuItem(
                                    value: 'MALE', child: Text(l10n.registerMale)),
                                DropdownMenuItem(
                                    value: 'FEMALE',
                                    child: Text(l10n.registerFemale)),
                              ],
                              onChanged: (v) => setState(() => _gender = v ?? ''),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            InkWell(
                              onTap: _pickDob,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: l10n.registerDob,
                                  suffixIcon:
                                      const Icon(Icons.calendar_today_outlined),
                                ),
                                child: Text(_dob == null
                                    ? ''
                                    : MaterialLocalizations.of(context)
                                        .formatMediumDate(_dob!)),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            BlocBuilder<CountriesCubit, CountriesState>(
                              builder: (context, countries) {
                                final selected = _selected(countries.countries);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    DropdownButtonFormField<int>(
                                      value: selected?.id,
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                          labelText: l10n.registerCountry),
                                      items: [
                                        for (final c in countries.countries)
                                          DropdownMenuItem(
                                            value: c.id,
                                            child: Text(
                                              '${c.name} (${c.phoneCode})',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                      onChanged: (v) =>
                                          setState(() => _countryId = v),
                                      validator: (v) =>
                                          v == null ? l10n.registerCountryRequired : null,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    TextFormField(
                                      controller: _phone,
                                      keyboardType: TextInputType.phone,
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        labelText: l10n.registerPhone,
                                        prefixIcon:
                                            const Icon(Icons.phone_outlined),
                                        prefixText: selected == null
                                            ? null
                                            : '${selected.phoneCode} ',
                                      ),
                                      validator: (v) {
                                        final digits = (v ?? '')
                                            .replaceAll(RegExp(r'\D'), '');
                                        if (digits.isEmpty) {
                                          return l10n.registerPhoneRequired;
                                        }
                                        if (selected?.isIndia ?? false) {
                                          return digits.length == 10
                                              ? null
                                              : l10n.registerPhoneIndia;
                                        }
                                        return digits.length >= 6 &&
                                                digits.length <= 15
                                            ? null
                                            : l10n.registerPhoneInvalid;
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _city,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                              decoration:
                                  InputDecoration(labelText: l10n.registerCity),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _pincode,
                              textInputAction: TextInputAction.next,
                              decoration:
                                  InputDecoration(labelText: l10n.registerPincode),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              decoration: InputDecoration(
                                labelText: l10n.email,
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              validator: (v) {
                                final input = v?.trim() ?? '';
                                if (input.isEmpty) return l10n.emailRequired;
                                return AppValidators.isValidEmail(input)
                                    ? null
                                    : l10n.emailInvalid;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _password,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              onFieldSubmitted: (_) =>
                                  reg.submitting ? null : _submit(),
                              decoration: InputDecoration(
                                labelText: l10n.password,
                                prefixIcon: const Icon(Icons.lock_outline),
                              ),
                              validator: (v) =>
                                  AppValidators.isValidNewPassword(v ?? '')
                                      ? null
                                      : l10n.registerPasswordShort,
                            ),
                            if (reg.error != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                reg.error!.userMessage(context),
                                style: TextStyle(color: theme.colorScheme.error),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            FilledButton(
                              onPressed: reg.submitting ? null : _submit,
                              child: reg.submitting
                                  ? const SizedBox.square(
                                      dimension: AppSizes.loadingIndicatorSmall,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : Text(l10n.registerButton),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextButton(
                              onPressed: reg.submitting
                                  ? null
                                  : () => context.pop(),
                              child: Text(l10n.registerHaveAccount),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
