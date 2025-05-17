import 'dart:convert';

import 'package:silo/src/silo/models.dart';

String escapeChars(String v) => "'${v.replaceAll('\'', '\'\'')}'";

String encodeDateTimeForSqlite(DateTime dt) {
  return encodeDateTime(dt);
}

DateTime parseDateTimeFromSqlite(String input) {
  return DateTime.parse(input);
}

String encodeDateTime(DateTime dartValue) {
  if (dartValue.isUtc) {
    return dartValue.toIso8601String();
  } else {
    final offset = dartValue.timeZoneOffset;
    // Quick sanity check: We can only store the UTC offset as `hh:mm`,
    // so if the offset has seconds for some reason we should refuse to
    // store that.
    if (offset.inSeconds - 60 * offset.inMinutes != 0) {
      throw ArgumentError.value(
        dartValue,
        'dartValue',
        'Cannot be mapped to SQL: Invalid UTC offset $offset',
      );
    }

    final hours = offset.inHours.abs();
    final minutes = offset.inMinutes.abs() - 60 * hours;

    // For local date times, add the offset as ` +hh:mm` in the end. This
    // format is understood by `DateTime.parse` and date time functions in
    // sqlite.
    final prefix = offset.isNegative ? ' -' : ' +';
    final formattedOffset = '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}';

    return '${dartValue.toIso8601String()}$prefix$formattedOffset';
  }
}

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

  if (obj is SiloModel) {
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
