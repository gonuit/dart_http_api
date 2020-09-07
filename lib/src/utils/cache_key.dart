part of http_api;

const _m = 0x5bd1e995;
const _r = 24;
int _simpleHash(int value, [int seed = 0]) {
  var len = 4; // int length 32 bit (assumption).
  var h = seed ^ len;

  var k = value;

  k *= _m;
  k ^= k >> _r;
  k *= _m;

  h *= _m;
  h ^= k;

  h ^= h >> 13;
  h *= _m;
  h ^= h >> 15;

  return h;
}

@immutable
class CacheKey {
  final String value;
  const CacheKey(this.value);

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is CacheKey &&
      other.value == value;

  int get hashCode => _simpleHash(value.hashCode, runtimeType.hashCode);

  @override
  String toString() => "$runtimeType('$value')";
}
