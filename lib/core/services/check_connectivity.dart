import "dart:io";

import "package:connectivity_plus/connectivity_plus.dart";

class CheckConnectivityService {
  final Connectivity _connectivity;

  CheckConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  // check connection type (Mobile or WiFi)
  Future<bool> hasNetworkConnection() async {
    final List<ConnectivityResult> results =
        await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  // check internet access
  Future<bool> hasInternetAccess() async {
    final bool hasNetwork = await hasNetworkConnection();
    if (!hasNetwork) {
      return false;
    }

    try {
      final List<InternetAddress> result = await InternetAddress.lookup(
        'example.com',
      );
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }
}
