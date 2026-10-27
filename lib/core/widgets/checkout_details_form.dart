import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/country_models.dart';
import '../localization/app_localizations_x.dart';
import '../theme/app_spacing.dart';
import '../validation/app_validators.dart';

/// The customer details every purchase asks for: full name, email, country and
/// mobile number (the same four fields as the website). Used by masterclass and
/// consultation checkout.
class CheckoutDetailsForm extends StatelessWidget {
  const CheckoutDetailsForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.emailFocus,
    required this.countries,
    required this.countryId,
    required this.onCountryChanged,
    super.key,
    this.emailLocked = false,
    this.onEmailDone,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final FocusNode emailFocus;
  final List<Country> countries;
  final int? countryId;
  final ValueChanged<int?> onCountryChanged;

  /// A logged-in student buys with their own email.
  final bool emailLocked;

  /// Called when the email field is finished (so the price can be re-checked).
  final VoidCallback? onEmailDone;

  Country? get _selected {
    for (final country in countries) {
      if (country.id == countryId) return country;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = _selected;
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            decoration: InputDecoration(
              labelText: l10n.fullName,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (value) =>
                (value?.trim().length ?? 0) < 2 ? l10n.fullNameRequired : null,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: emailController,
            focusNode: emailFocus,
            readOnly: emailLocked,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            onEditingComplete: () {
              onEmailDone?.call();
              FocusScope.of(context).nextFocus();
            },
            decoration: InputDecoration(
              labelText: l10n.email,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (value) {
              final input = value?.trim() ?? '';
              if (input.isEmpty) return l10n.emailRequired;
              if (!AppValidators.isValidEmail(input)) return l10n.emailInvalid;
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<int>(
            value: selected?.id,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.country,
              prefixIcon: const Icon(Icons.public),
            ),
            items: [
              for (final country in countries)
                DropdownMenuItem(
                  value: country.id,
                  child: Text(
                    '${country.name} (${country.phoneCode})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: onCountryChanged,
            validator: (value) => value == null ? l10n.countryRequired : null,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: l10n.mobileNumber,
              prefixIcon: const Icon(Icons.phone_outlined),
              prefixText: selected == null ? null : '${selected.phoneCode} ',
            ),
            validator: (value) {
              final digits = value?.trim() ?? '';
              if (selected?.isIndia ?? false) {
                return digits.length == 10 ? null : l10n.mobileNumberIndia;
              }
              return digits.length >= 6 && digits.length <= 15
                  ? null
                  : l10n.mobileNumberInvalid;
            },
          ),
        ],
      ),
    );
  }
}
