import 'dart:developer';

/// Minimum session length before token expiration to trigger refresh (30 minutes)
const int MIN_SESSION_LENGTH_MS = 30 * 60 * 1000; // 30 minutes in milliseconds

/// Check if token is valid (not expired)
/// Token is valid if it hasn't expired yet (with 1 minute buffer)
bool isTokenValid(DateTime? tokenExpiresAt) {
  if (tokenExpiresAt == null) {
    return false;
  }

  final now = DateTime.now();
  final diff = tokenExpiresAt.difference(now).inMilliseconds;

  // Token is valid if it hasn't expired yet (with 1 minute buffer)
  return diff > 60 * 1000; // 1 minute buffer
}

/// Check if token should be refreshed
/// Token should be refreshed if less than 30 minutes remaining but not expired yet
bool shouldRefreshToken(DateTime? tokenExpiresAt) {
  if (tokenExpiresAt == null) {
    return false;
  }

  final now = DateTime.now();
  final diff = tokenExpiresAt.difference(now).inMilliseconds;

  // Should refresh if less than 30 minutes remaining but not expired yet
  // diff > 0 means token is not expired yet
  // diff < MIN_SESSION_LENGTH_MS means less than 30 minutes remaining
  return diff > 0 && diff < MIN_SESSION_LENGTH_MS;
}

/// Get time remaining until token expires (in milliseconds)
/// Returns 0 if expired or not set
int getTimeRemaining(DateTime? tokenExpiresAt) {
  if (tokenExpiresAt == null) {
    return 0;
  }

  final now = DateTime.now();
  final diff = tokenExpiresAt.difference(now).inMilliseconds;

  return diff > 0 ? diff : 0;
}

