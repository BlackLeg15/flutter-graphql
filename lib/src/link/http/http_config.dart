class HttpQueryOptions {
  HttpQueryOptions({
    this.includeQuery,
    this.includeExtensions,
  });

  bool? includeQuery;
  bool? includeExtensions;

  void addAll(HttpQueryOptions options) {
    if (options.includeQuery != null) {
      includeQuery = options.includeQuery;
    }

    if (options.includeExtensions != null) {
      includeExtensions = options.includeExtensions;
    }
  }
}

class HttpConfig {
  HttpConfig({
    this.http,
    this.options,
    this.credentials,
    this.headers,
  });

  HttpQueryOptions? http;
  Map<String, dynamic>? options;
  Map<String, dynamic>? credentials;
  Map<String, String>? headers;
}

class HttpOptionsAndBody {
  HttpOptionsAndBody({
    this.options,
    this.body,
  });

  final Map<String, dynamic>? options;
  final String? body;
}