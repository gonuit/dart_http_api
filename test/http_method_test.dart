import 'package:http_api/http_api.dart';
import 'package:test/test.dart';

void main() {
  test("HttpMethod returns correct values", () {
    expect(HttpMethod.get.value, equals("GET"));
    expect(HttpMethod.post.value, equals("POST"));
    expect(HttpMethod.delete.value, equals("DELETE"));
    expect(HttpMethod.head.value, equals("HEAD"));
    expect(HttpMethod.patch.value, equals("PATCH"));
    expect(HttpMethod.put.value, equals("PUT"));
  });
}
