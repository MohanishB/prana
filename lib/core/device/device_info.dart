import 'dart:io';

abstract final class AppDeviceInfo {
  // PRANA backend contract:  1 = Android, 2 = iOS.
  static int get type {
    if (Platform.isAndroid) return 1;
    if (Platform.isIOS) return 2;
    
    throw UnsupportedError('Unsupported platform');
  }
}
