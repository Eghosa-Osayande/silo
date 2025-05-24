
mixin SiloValue {
  dynamic toJson();
}

mixin SiloTable<T> {
  Map<String, dynamic> toMap();

  String tableKey();

}
