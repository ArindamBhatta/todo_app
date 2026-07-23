import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/check_connectivity.dart';

enum ConnectivityStatus { unknown, online, offline }

class ConnectivityManager extends Cubit<ConnectivityStatus> {
  final CheckConnectivityService _connectivityService;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityManager({CheckConnectivityService? connectivityService})
    : _connectivityService = connectivityService ?? CheckConnectivityService(),
      super(ConnectivityStatus.unknown);

  Future<void> startMonitoring() async {
    await _emitCurrentStatus();

    _subscription ??= _connectivityService.onConnectivityChanged.listen((_) {
      _emitCurrentStatus();
    });
  }

  Future<void> _emitCurrentStatus() async {
    final bool hasInternet = await _connectivityService.hasInternetAccess();
    emit(hasInternet ? ConnectivityStatus.online : ConnectivityStatus.offline);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
