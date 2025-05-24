abstract class SiloRegistry {
  static final _typedFactories = <Type, dynamic Function(dynamic)>{};
  static final _typeNames = <Type, String>{};

  static void registerFactory<T, I>(T Function(I) factory) {
    fn(input) => factory(input as I);

    _typedFactories[T] = fn;
  }

  static void registerNamedFactory<T, I>(
    String name,
    T Function(I) factory,
  ) {
    fn(input) => factory(input as I);

    _typeNames[T] = name;

    _typedFactories[T] = fn;
  }

  static T Function(dynamic) factoryFor<T>() {
    var type = T;

    final fn = _typedFactories[type];

    if (fn == null) {
      throw Exception("no registered factory found for type $T");
    }

    return fn as T Function(dynamic);
  }

  static String? factoryNameOrNull<T>() {
    var type = T;

    final name = _typeNames[type];

    return name;
  }

  static String factoryName<T>() {
    var type = T;

    final name = _typeNames[type];

    if (name == null) {
      throw Exception("no registered named factory found for type $T");
    }

    return name;
  }
}
