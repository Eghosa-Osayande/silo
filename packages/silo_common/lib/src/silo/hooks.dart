import 'dart:async';

import 'finisher.dart';
import '../sql/expression/expression.dart';

import 'silo.dart';

typedef AfterPutHook<O> = Function(
  String key,
  O value,
  ExprBuilder builder,
);

typedef AfterRemoveHook<O> = Function(
  String key,
  ExprBuilder builder,
);

typedef AfterFindHook<O> = Function(
  String? key,
  ExprBuilder builder,
  List<SiloRow<O>> results,
);

mixin SiloHooks<S extends Silo<O>, O> {
  static final Map<Type, Set<dynamic>> _afterPutHooks = {};

  static final Map<Type, Set<dynamic>> _afterRemoveHooks = {};

  static final Map<Type, Set<dynamic>> _afterFindHooks = {};

  void registerAfterPut(AfterPutHook<O> hook) {
    final hooks =
        _afterPutHooks.putIfAbsent(O, () => <AfterPutHook<dynamic>>{});
    hooks.add(hook);
  }

  void registerAfterRemove(AfterRemoveHook<O> hook) {
    final hooks =
        _afterRemoveHooks.putIfAbsent(O, () => <AfterRemoveHook<dynamic>>{});
    hooks.add(hook);
  }

  void registerAfterFind(AfterFindHook<O> hook) {
    final hooks = _afterFindHooks.putIfAbsent(O, () => {});
    hooks.add(hook);
  }

  void unregisterAfterPut(AfterPutHook<O> hook) {
    final hooks = _afterPutHooks[O];
    if (hooks != null) {
      hooks.remove(hook);
      if (hooks.isEmpty) _afterPutHooks.remove(O);
    }
  }

  void unregisterAfterRemove(AfterRemoveHook<O> hook) {
    final hooks = _afterRemoveHooks[O];
    if (hooks != null) {
      hooks.remove(hook);
      if (hooks.isEmpty) _afterRemoveHooks.remove(O);
    }
  }

  void unregisterAfterFind(AfterFindHook<O> hook) {
    final hooks = _afterFindHooks[O];
    if (hooks != null) {
      hooks.remove(hook);
      if (hooks.isEmpty) _afterFindHooks.remove(O);
    }
  }

  // Trigger hooks

  Future<void> triggerAfterPut(
    String key,
    O value,
    ExprBuilder builder,
  ) async {
    final hooks = _afterPutHooks[O] ?? {};
    for (final hook in hooks) {
      runZonedGuarded(
        () {
          hook(key, value, builder);
        },
        (error, stack) {
          print(error);
          print(stack);
        },
      );
    }
  }

  Future<void> triggerAfterRemove(
    String key,
    ExprBuilder builder,
  ) async {
    final hooks = _afterRemoveHooks[O] ?? {};
    for (final hook in hooks) {
      runZonedGuarded(
        () {
          hook(key, builder);
        },
        (error, stack) {
          print(error);
          print(stack);
        },
      );
    }
  }

  Future<void> triggerAfterFind(
      String? key, ExprBuilder builder, List<SiloRow<O>> results) async {
    final hooks = _afterFindHooks[O] ?? {};
    for (final hook in hooks) {
      runZonedGuarded(
        () {
          hook(key, builder, results);
        },
        (error, stack) {
          print(error);
          print(stack);
        },
      );
    }
  }
}
