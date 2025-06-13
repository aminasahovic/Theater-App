class ApiKonstante {
  static final String baseUrl = _getBaseUrl();

  static String _getBaseUrl() {
    const String host = String.fromEnvironment(
      'API_HOST',
      defaultValue: '192.168.45.146',
    );
    const String port = String.fromEnvironment(
      'API_PORT',
      defaultValue: '5000',
    );
    return 'http://$host:$port';
  }
}
