/// Small, forgiving JSON readers shared by the data models.
Map<String, dynamic> jsonMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

int jsonInt(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;

double jsonDouble(Object? value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

String jsonString(Object? value) => value?.toString() ?? '';

String? jsonNullableString(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

List<T> jsonList<T>(Object? raw, T Function(Map<String, dynamic>) build) =>
    ((raw as List?) ?? const [])
        .whereType<Map>()
        .map((e) => build(Map<String, dynamic>.from(e)))
        .toList(growable: false);
