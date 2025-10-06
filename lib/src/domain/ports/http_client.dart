abstract class HttpClientPort {
  Future<(int status, Map<String, dynamic> json)> getJson(Uri url, {Map<String,String>? headers});
  Future<(int status, Map<String, dynamic> json)> postForm(Uri url, Map<String,String> form, {Map<String,String>? headers});
}
