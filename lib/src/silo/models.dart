

abstract mixin class SiloModel<T> {
  Type get instanceType => T;

  dynamic toJson();
}
