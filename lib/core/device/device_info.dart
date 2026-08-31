import 'dart:io';

abstract final class AppDeviceInfo {
  // PRANA backend contract: 1 = iOS, 2 = Android.
  static int get type {
    if (Platform.isIOS) return 1;
    if (Platform.isAndroid) return 2;
    throw UnsupportedError('Unsupported platform');
  }
}
