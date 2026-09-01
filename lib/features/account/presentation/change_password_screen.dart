import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_error_localization.dart';
import '../../../core/localization/app_localizations_x.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/validation/app_validators.dart';
import '../../../core/widgets/prana_app_bar.dart';
import '../../../core/widgets/responsive_content.dart';
import '../bloc/change_password_cubit.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: PranaAppBar(title: l10n.changePassword, showBack: true),
      body: BlocListener<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.passwordChanged)),
            );
            context.pop();
          }
        },
        child: SingleChildScrollView(
          child: ResponsiveContent(
            maxWidth: AppSizes.compactContentMaxWidth,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.changePasswordDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextFormField(
                    controller: _currentPassword,
                    obscureText: true,
                    decoration:
                        InputDecoration(labelText: l10n.currentPassword),
                    textInputAction: TextInputAction.next,
                    validator: (value) => (value ?? '').isEmpty
                        ? l10n.passwordRequired
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _newPassword,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.newPassword),
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                        AppValidators.isValidNewPassword(value ?? '')
                            ? null
                            : l10n.passwordMinimumSix,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _confirmPassword,
                    obscureText: true,
                    decoration:
                        InputDecoration(labelText: l10n.confirmPassword),
                    textInputAction: TextInputAction.done,
                    validator: (value) => value != _newPassword.text
                        ? l10n.passwordsDoNotMatch
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                    builder: (context, state) {
                      final submitting = state is ChangePasswordSubmitting;
                      return FilledButton(
                        onPressed: submitting ? null : _submit,
                        child: submitting
                            ? Text(l10n.updatingPassword)
                            : Text(l10n.updatePassword),
                      );
                    },
                  ),
                  BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                    builder: (context, state) {
                      if (state case ChangePasswordFailure(:final error)) {
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Text(
                            error.userMessage(context),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    context.read<ChangePasswordCubit>().submit(
          currentPassword: _currentPassword.text,
          newPassword: _newPassword.text,
          confirmPassword: _confirmPassword.text,
        );
  }
}
