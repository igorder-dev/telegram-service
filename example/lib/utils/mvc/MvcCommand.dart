import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:id_mvc_app_framework/framework.dart';

abstract class MvcCommand<TParam extends MvcCommandParams, TResult>
    extends Rx<MvcCommandResult<TParam, TResult>> {
  static const int CALL_STACK_INTERVAL = 10;

  //*Variables
  final List<RxInterface> triggers;
  Worker _triggersWorker;
  final bool canBeDoneOnce;
  final TResult _initResultValue;
  Completer<MvcCommandResult<TParam, TResult>> _futureCompleter;
  final dynamic condition;
  final bool catchExceptions;
  final bool autoReset;
  final bool useCallStack;
  final StreamController<TParam> _callStack = StreamController();

  //*Factories
  factory MvcCommand.sync({
    @required MvcCommandFuncSync<TParam, TResult> func,
    TParam params,
    TResult initResult,
    List<RxInterface> triggers,
    bool canBeDoneOnce = false,
    dynamic condition,
    bool catchExceptions = true,
    bool autoReset = true,
    bool useCallStack = false,
  }) =>
      MvcCommandSync(
        func: func,
        params: params,
        initResult: initResult,
        triggers: triggers,
        canBeDoneOnce: canBeDoneOnce,
        condition: condition,
        catchExceptions: catchExceptions,
        autoReset: autoReset,
        useCallStack: useCallStack,
      );

  factory MvcCommand.async({
    @required MvcCommandFuncAsync<TParam, TResult> func,
    TParam params,
    TResult initResult,
    List<RxInterface> triggers,
    bool canBeDoneOnce = false,
    dynamic condition,
    bool catchExceptions = true,
    bool autoReset = true,
    bool useCallStack = false,
  }) =>
      MvcCommandAsync(
        func: func,
        params: params,
        initResult: initResult,
        triggers: triggers,
        canBeDoneOnce: canBeDoneOnce,
        condition: condition,
        catchExceptions: catchExceptions,
        autoReset: autoReset,
        useCallStack: useCallStack,
      );

  //*Constructors
  MvcCommand({
    TParam params,
    TResult initResult,
    this.triggers,
    this.canBeDoneOnce = false,
    this.condition,
    this.catchExceptions = true,
    this.autoReset = true,
    this.useCallStack = false,
  })  : _initResultValue = initResult,
        super(MvcCommandResult<TParam, TResult>(
          params: params,
          result: initResult,
        )) {
    _registerTriggers();
    if (useCallStack) {
      _callStack.stream.listen(_processCallStack);
    }
  }

  void _registerTriggers() {
    if (triggers == null) return;
    _triggersWorker = everAll(triggers, (_) {
      if (canExecute) {
        execute();
      } else {
        _addToCallStack();
      }
    });
  }

  void _addToCallStack([TParam params]) {
    if (useCallStack) {
      _callStack.add(params ?? this.result.params);
    }
  }

  void _processCallStack(TParam params) async {
    if (canExecute)
      execute(params);
    else
      await Future.delayed(CALL_STACK_INTERVAL.milliseconds, () {
        _callStack.add(params);
      });
  }

  void execute([TParam params]);

  Future<MvcCommandResult<TParam, TResult>> executeWithFuture([TParam params]) {
    //      assert(this is CommandAsync,
    //      'executeWithFuture can\t be used with synchronous Commands');
    _futureCompleter = Completer<MvcCommandResult<TParam, TResult>>();
    execute(params);
    return _futureCompleter.future;
  }

  void dispose() {
    _triggersWorker?.dispose();
    _callStack.close();
    if (!(_futureCompleter?.isCompleted ?? true)) {
      _futureCompleter.complete(null);
    }
    close();
  }

  void complete({bool disposeAfter = false}) {
    _setStatus(MvcCommandStatus.competed);
    if (!(_futureCompleter?.isCompleted ?? true)) {
      _futureCompleter.complete(null);
    }
    if (disposeAfter) dispose();
  }

  void resetCommand() {
    assert(status != MvcCommandStatus.executing,
        "Cannot reset command status while it is executing");
    if (!canBeDoneOnce && status != MvcCommandStatus.executing) {
      update((val) {
        val.status = MvcCommandStatus.ready;
        val.result = _initResultValue;
        val.error = null;
      });
    }
  }

  MvcCommandResult<TParam, TResult> get result => this.value;

  void _setError(Error error) {
    update((val) {
      val.status = MvcCommandStatus.error;
      val.error = MvcCommandError<TParam>(result.params, error);
    });
  }

  void _setStatus(MvcCommandStatus status) {
    update((val) {
      val.status = status;
    });
  }

  bool _conditional(dynamic condition) {
    if (condition == null) return true;
    if (condition is bool) return condition;
    if (condition is bool Function()) return condition();
    return true;
  }

  bool get canExecute =>
      _conditional(condition) && result.status == MvcCommandStatus.ready;

  MvcCommandStatus get status => result.status;
}

class MvcCommandSync<TParam extends MvcCommandParams, TResult>
    extends MvcCommand<TParam, TResult> {
  final MvcCommandFuncSync<TParam, TResult> _func;
  MvcCommandSync({
    @required MvcCommandFuncSync<TParam, TResult> func,
    TParam params,
    TResult initResult,
    List<RxInterface> triggers,
    bool canBeDoneOnce = false,
    dynamic condition,
    bool catchExceptions = true,
    bool autoReset = true,
    bool useCallStack = false,
  })  : _func = func,
        super(
          params: params,
          initResult: initResult,
          triggers: triggers,
          canBeDoneOnce: canBeDoneOnce,
          condition: condition,
          catchExceptions: catchExceptions,
          autoReset: autoReset,
          useCallStack: useCallStack,
        );

  @override
  void execute([TParam params]) {
    if (canExecute) {
      try {
        _setStatus(MvcCommandStatus.executing);
        result.result = _func(params ?? this.result.params);
        _futureCompleter?.complete(result);
        _setStatus(MvcCommandStatus.competed);
      } catch (error) {
        _setError(error);
        _futureCompleter?.completeError(result.error);
        if (!catchExceptions) rethrow;
      } finally {
        if (autoReset) resetCommand();
      }
    } else if (useCallStack && !canBeDoneOnce) {
      _addToCallStack(params);
    } else {
      assert(canExecute,
          "Command is not ready to  execute. Please use resetCommand function and check if canBeDoneOnce is not true");
    }
  }
}

class MvcCommandAsync<TParam extends MvcCommandParams, TResult>
    extends MvcCommand<TParam, TResult> {
  final MvcCommandFuncAsync<TParam, TResult> _func;
  MvcCommandAsync({
    @required MvcCommandFuncAsync<TParam, TResult> func,
    TParam params,
    TResult initResult,
    List<RxInterface> triggers,
    bool canBeDoneOnce = false,
    dynamic condition,
    bool catchExceptions = true,
    bool autoReset = true,
    bool useCallStack = false,
  })  : _func = func,
        super(
          params: params,
          initResult: initResult,
          triggers: triggers,
          canBeDoneOnce: canBeDoneOnce,
          condition: condition,
          catchExceptions: catchExceptions,
          autoReset: autoReset,
          useCallStack: useCallStack,
        );

  @override
  void execute([TParam params]) async {
    if (canExecute) {
      try {
        _setStatus(MvcCommandStatus.executing);
        result.result = await _func(params ?? this.result.params);
        _futureCompleter?.complete(result);
        _setStatus(MvcCommandStatus.competed);
      } catch (error) {
        _setError(error);
        _futureCompleter?.completeError(result.error);
        if (!catchExceptions) rethrow;
      } finally {
        if (autoReset) resetCommand();
      }
    } else if (useCallStack && !canBeDoneOnce) {
      _addToCallStack(params);
    } else {
      assert(canExecute,
          "Command is not ready to  execute. Please use resetCommand function and check if canBeDoneOnce is not true");
    }
  }
}

class MvcCommandResult<TParam extends MvcCommandParams, TResult> {
  MvcCommandResult({this.params, this.result});

  MvcCommandStatus status = MvcCommandStatus.ready;
  TResult result;
  TParam params;
  MvcCommandError error;

  bool get hasResult => hasResult != null;
  bool get hasError => error != null;

  @override
  bool operator ==(Object other) =>
      other is MvcCommandResult<TParam, TResult> &&
      other.params == params &&
      other.result == result &&
      other.error == error &&
      other.status == status;

  @override
  int get hashCode =>
      (params.hashCode + result?.hashCode ?? 0 + status.hashCode).hashCode;

  @override
  String toString() {
    return 'ParamData $params - Data: $result - HasError: $hasError - status: $status';
  }

  T handleStatus<T>({
    MvcCommandStatusHandler<T, TParam, TResult> onReady,
    MvcCommandStatusHandler<T, TParam, TResult> onExecuting,
    MvcCommandStatusHandler<T, TParam, TResult> onError,
    MvcCommandStatusHandler<T, TParam, TResult> onCompleted,
  }) {
    switch (status) {
      case MvcCommandStatus.ready:
        return onReady?.call(this);
      case MvcCommandStatus.executing:
        return onExecuting?.call(this);
      case MvcCommandStatus.error:
        return onError?.call(this);
      case MvcCommandStatus.competed:
        return onCompleted?.call(this);
    }
    return null;
  }
}

class MvcCommandParams {}

class MvcCommandSingleParam<TParam> extends MvcCommandParams {
  final TParam value;
  MvcCommandSingleParam(this.value);
}

class MvcCommandMapParam extends MvcCommandSingleParam<Map<String, dynamic>> {
  MvcCommandMapParam(Map<String, dynamic> value) : super(value);
}

enum MvcCommandStatus {
  ready,
  executing,
  competed,
  error,
}

class MvcCommandError<TParam> {
  final Object error;
  final TParam paramData;

  MvcCommandError(
    this.paramData,
    this.error,
  );

  @override
  String toString() {
    return '$error - for param: $paramData';
  }
}

typedef TResult MvcCommandFuncSync<TParam extends MvcCommandParams, TResult>(
    TParam param);

typedef Future<TResult> MvcCommandFuncAsync<TParam extends MvcCommandParams,
    TResult>(TParam param);

typedef T MvcCommandStatusHandler<T, TParam extends MvcCommandParams, TResult>(
    MvcCommandResult<TParam, TResult> commandResult);
