import 'package:silo/src/silo/models.dart';

import 'silo.dart';

mixin SiloRegistry<S extends Silo> {
  static final _factories = <Type, dynamic Function(dynamic)>{};

  void registerSilo<T extends SiloModel, I>(T Function(I) factory) {
    _factories[T] = (input) => factory(input as I);
  }

  T Function(dynamic) siloFor<T>([T? obj]) {
    var type = T;
   
    final fn = _factories[type];

    if (fn == null) {
      throw Exception("no registered factory found for type $T");
    }

    return fn as T Function(dynamic);
  }
}
