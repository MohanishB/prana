import 'package:flutter/widgets.dart';

import '../localization/app_localizations_x.dart';
import 'app_exception.dart';

extension AppErrorLocalization on AppException {
  String userMessage(BuildContext context) {
    return switch (type) {
      AppErrorType.noInternet => context.l10n.errorNoInternet,
      AppErrorType.timeout => context.l10n.errorTimeout,
      AppErrorType.invalidResponse => context.l10n.errorInvalidResponse,
      AppErrorType.libraryLoad => context.l10n.errorLibraryLoad,
      AppErrorType.librarySearch => context.l10n.errorLibrarySearch,
      AppErrorType.generic => context.l10n.errorGeneric,
    };
  }
}
