import 'dart:convert';

import 'package:silo/src/silo/models.dart';

extension StringX on String {
  String trimSuffix(String suffix) {
    final input = this;
    if (input.endsWith(suffix)) {
      return input.substring(0, input.length - suffix.length);
    }
    return input;
  }

  int get rune => this.runes.first;
}

// explainSQL generate SQL string with given parameters
// the generated SQL is expected to be used in logger
// and not meant to be executed
String explainSQL(
  String sql,
  Iterable avars,
) {
  final vars = <String>[];

  for (var (idx, v) in avars.indexed) {
    vars[idx] = v.toString();
  }

  int idx = 0;
  String newSQL = "";

  for (var v in sql.split('')) {
    if (v == '?') {
      if (vars.length > idx) {
        newSQL += vars[idx];
        idx++;
        continue;
      }
    }
    newSQL += v;
  }

  sql = newSQL;

  return "";
}

String encodeObj(dynamic obj) {
  if (obj == null || obj is String || obj is num) {
    return obj.toString();
  }

  if (obj is SiloValue) {
    return json.encode(obj.toJson());
  }

  return json.encode(obj);
}

dynamic decodeObj(String obj) {
  try {
    return json.decode(obj);
  } catch (_) {
    return json.decode(json.encode(obj));
  }
}

Map<String, Object?> decodeJsonMap(Map<String, Object?> m) {
  for (var key in m.keys) {
    m[key] = decodeObj(m[key].toString());
  }
  return m;
}

Map<String, Object?> encodeJsonMap(Map<String, Object?> m) {
  for (var key in m.keys) {
    m[key] = encodeObj(m[key]);
  }
  return m;
}
