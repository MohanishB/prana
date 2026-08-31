import 'package:flutter/widgets.dart';

import '../localization/app_localizations_x.dart';
import 'app_exception.dart';

extension AppErrorLocalization on AppException {
  String userMessage(BuildContext context) {
    return switch (type) {
      AppErrorType.noInternet => context.l10n.errorNoInternet,
      AppErrorType.timeout => context.l10n.errorTimeout,
      AppErrorType.invalidResponse => context.l10n.errorInvalidResponse,
      AppErrorType.invalidCredentials => context.l10n.errorInvalidCredentials,
      AppErrorType.accountInactive => context.l10n.errorAccountInactive,
      AppErrorType.unauthorized => context.l10n.errorSessionExpired,
      AppErrorType.forbidden => context.l10n.errorAccessDenied,
      AppErrorType.courseNotAssigned => context.l10n.errorCourseNotAssigned,
      AppErrorType.courseNotFound => context.l10n.errorCourseNotFound,
      AppErrorType.validation => context.l10n.errorValidation,
      AppErrorType.server => context.l10n.errorServer,
      AppErrorType.libraryLoad => context.l10n.errorLibraryLoad,
      AppErrorType.librarySearch => context.l10n.errorLibrarySearch,
      AppErrorType.generic => context.l10n.errorGeneric,
    };
  }
}
