abstract interface class ConnectionChecker {
  Future<bool> get isConnected;
}

/// Convex handles connectivity natively; we always return true here.
class ConnectionCheckerImpl implements ConnectionChecker {
  const ConnectionCheckerImpl();

  @override
  Future<bool> get isConnected async => true;
}
