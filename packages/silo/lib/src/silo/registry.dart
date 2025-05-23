

class SiloFactory {
  static final _factories = <Type, dynamic Function(dynamic)>{};

  static void register<T, I>(T Function(I) factory) {
    _factories[T] = (input) => factory(input as I);
  }

  static T Function(dynamic) factoryFor<T>() {
    var type = T;

    final fn = _factories[type];

    if (fn == null) {
      throw Exception("no registered factory found for type $T");
    }

    return fn as T Function(dynamic);
  }
}
