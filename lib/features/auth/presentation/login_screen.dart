import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/validation/app_validators.dart';
import '../../../core/widgets/prana_logo.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
          AuthLoginSubmitted(_email.text.trim(), _password.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ResponsiveContent(
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final loading = state is AuthLoading;
                  final error =
                      state is AuthUnauthenticated ? state.error : null;
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: PranaLogo()),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          l10n.loginWelcome,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.loginSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            labelText: l10n.email,
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            final input = value?.trim() ?? '';
                            if (input.isEmpty) return l10n.emailRequired;
                            if (!AppValidators.isValidEmail(input)) {
                              return l10n.emailInvalid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => loading ? null : _submit(),
                          decoration: InputDecoration(
                            labelText: l10n.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          validator: (value) =>
                              AppValidators.isValidPassword(value ?? '')
                                  ? null
                                  : l10n.passwordRequired,
                        ),
                        if (error != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            error.userMessage(context),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton(
                          onPressed: loading ? null : _submit,
                          child: loading
                              ? const SizedBox.square(
                                  dimension: AppSizes.loadingIndicatorSmall,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.signIn),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
