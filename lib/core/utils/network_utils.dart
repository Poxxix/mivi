import 'dart:io';

/// Network utility class for handling connectivity and network-related operations
class NetworkUtils {
  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      // Try to lookup a reliable host
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Ping a host to check connectivity
  static Future<bool> pingHost(String host, {int timeout = 5}) async {
    try {
      final result = await InternetAddress.lookup(host).timeout(
        Duration(seconds: timeout),
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check API connectivity by trying to connect to phimapi.com
  static Future<bool> checkAPIConnectivity() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://phimapi.com'))
          .timeout(const Duration(seconds: 10));
      final response = await request.close().timeout(const Duration(seconds: 10));
      client.close();
      return response.statusCode == 200 || response.statusCode == 301 || response.statusCode == 302;
    } catch (e) {
      return false;
    }
  }

  /// Get a user-friendly error message for network issues
  static String getNetworkErrorMessage() {
    return 'No internet connection. Please check your network settings and try again.';
  }

  /// Get a user-friendly error message for API issues
  static String getAPIErrorMessage() {
    return 'Unable to connect to movie database. Please try again later.';
  }

  /// Retry a network operation with exponential backoff
  static Future<T> retryOperation<T>(
    Future<T> Function() operation,
    {int maxRetries = 3, Duration initialDelay = const Duration(seconds: 1)}
  ) async {
    int retries = 0;
    Duration delay = initialDelay;

    while (retries < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        retries++;
        if (retries >= maxRetries) {
          rethrow;
        }
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
    throw Exception('Max retries exceeded');
  }
} 