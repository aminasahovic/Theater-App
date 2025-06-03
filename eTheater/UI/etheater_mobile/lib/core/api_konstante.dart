class ApiKonstante {
  static final String baseUrl = _getBaseUrl();
  //static final baseUrl = 'http://192.168.45.244:5241';

  static String _getBaseUrl() {
    const String host = String.fromEnvironment(
      'API_HOST',
      defaultValue: 'localhost',
    );
    const String port = String.fromEnvironment(
      'API_PORT',
      defaultValue: '5241',
    );
    return 'http://$host:$port';
  }
}
