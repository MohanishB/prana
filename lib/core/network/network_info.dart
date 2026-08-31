import 'dart:io';

abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}

final class DefaultNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('pranabydimpleacademy.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on Object {
      return false;
    }
  }
}
