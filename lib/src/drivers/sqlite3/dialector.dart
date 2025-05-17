import 'package:silo/src/drivers/interfaces/database.dart';
import 'package:silo/src/drivers/interfaces/dialector.dart';
import 'package:silo/src/sql/expression/expression.dart';

mixin SqliteDialector on DB implements Dialector {

  @override
  String quote(String str) {
    bool underQuoted = false;
    bool selfQuoted = false;
    int continuousBacktick = 0;
    int shiftDelimiter = 0;
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      final v = str[i];

      switch (v) {
        case '`':
          continuousBacktick++;
          if (continuousBacktick == 2) {
            buffer.write('``');
            continuousBacktick = 0;
          }
          break;
        case '.':
          if (continuousBacktick > 0 || !selfQuoted) {
            shiftDelimiter = 0;
            underQuoted = false;
            continuousBacktick = 0;
            buffer.write('`');
          }
          buffer.write(v);
          continue;
        default:
          if (shiftDelimiter - continuousBacktick <= 0 && !underQuoted) {
            buffer.write('`');
            underQuoted = true;
            if (selfQuoted = continuousBacktick > 0) {
              continuousBacktick -= 1;
            }
          }

          while (continuousBacktick > 0) {
            buffer.write('``');
            continuousBacktick -= 1;
          }

          buffer.write(v);
      }

      shiftDelimiter++;
    }

    if (continuousBacktick > 0 && !selfQuoted) {
      buffer.write('``');
    }
    buffer.write('`');

    return buffer.toString();
  }

  @override
  writeVar(ExprBuilder builder) {
    builder.writeString("?");
  }
}
