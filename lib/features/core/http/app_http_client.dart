import 'package:http/http.dart' as http;

class AppHttpClient {
  final http.Client _client;
  AppHttpClient({http.Client? client}) : _client = client ?? http.Client();

  Future<http.Response> get(String url) {
    return _client.get(Uri.parse(url));
  }

  void close() => _client.close();
}
