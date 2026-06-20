import 'dart:async';

/// Broadcasts a signal whenever the refresh-token call fails and the user's
/// session must be terminated. Listen in the root scaffold to redirect to login.
final _controller = StreamController<void>.broadcast();

Stream<void> get sessionExpiredStream => _controller.stream;

void notifySessionExpired() {
  if (!_controller.isClosed) _controller.add(null);
}
