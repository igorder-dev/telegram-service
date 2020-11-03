import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:id_mvc_app_framework/model.dart';
import 'handlers/tdlib_authorization_close_handler.dart';
import 'handlers/tdlib_encryptionkey_handler.dart';
import 'handlers/tdlib_parameters_handler.dart';
import 'telegram_event_handler.dart';
import 'dart:developer' as dev;

import 'package:telegram_service/src/tdapi/tdapi.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../tdclient/tdclient.dart';

/// Describes Callback function format for telegram API library event.
/// Used in  [TelegramService.sendCommand] and [TelegramEventHandler.sendCommand]
typedef void TelegramEventCallback(TdObject event, [String requestID]);

/// Describes Callback function format if telegram servis returns error
typedef void TelegramErrorCallback(error);

/// Describes Callback function when Libabry returns that user was logout from the plugin
/// This can happen if user removed authorization in the Telegram Client.
/// Current version of pluging will require Application restartu to re-login user
typedef void TelegramServiceLogoutCallback();

///Generates random unique key. Used to link callback function to recieved event object from telegram
String _randomID() => UniqueKey().toString();

///Coded int encryption key used by library
const String ENCRYPTION_KEY = "mostrandomencryption";

/// Provides stream based wrapper for handling tdlib event from telegram plugin
///
/// Use [start] to initiate the instance of servise. It can be only one instance of service for the App
///
/// ##In order to start handling Telegram event you can use
///  1. TelegramEventHandler.start(onEvent: (TdObject event, [String requestID]) {print(event);}) - handling all events in the recieving stream
///  2. TelegramEventHandler.start(eventHandlers: [CustomTdlibEventHandler()]) - CustomTdlibEventHandler must  extend [TelegramEventHandler].
///      Each handler is manager by seperate stream.
///  3.  TelegramService.instance.listenToUpdates((event) {print(event);}); - handingly all events in the seperate stream provided by [ModelStateProvider]
///
/// ##In order to send command to Telegram library you can use
///  1. [TelegramService.sendCommand]
///  2. [CustomTdlibEventHandler.sendCommand] -  provides implementation of callback handling withing Handler class
///
class TelegramService with ModelStateProvider, GetxServiceMixin {
  /// Defines if log method should print or omit messages
  static bool _logEnabled = true;

  /// Defines standard log function withing [TelegramService] class.
  ///
  /// Prints "[TELE-SERVICE] $value"
  static void log(String value) {
    if (Get.isLogEnable && _logEnabled) {
      dev.log(value, name: 'TELE-SERVICE');
    }
  }

  /// Initializes and starts telegram service instance in the dependency injection system of GetX
  ///
  /// - [parameters] - instance of [TdlibParameters] with configuration of Telegram Library.
  /// - [eventHandlers] - list of custom [TelegramEventHandler] for processing sepcific types of TdLib objects.
  /// - [verbosityLevel] - Default value 1. Passes agrument to the TdLib function [SetLogVerbosityLevel] during start of the library
  /// - [onError] - Global callback to handle run-time and TdLib returned errors
  /// - [onEvent] - Global callback to handle all TdLibm events
  /// - [onLogOut] - Global callback to handle logout of the user driven from external
  /// - [logEnabled] - true if library should send log message on events to the terminal
  ///
  static Future<void> start({
    @required TdlibParameters parameters,
    @required List<TelegramEventHandler> eventHandlers,
    int verbosityLevel = 1,
    TelegramErrorCallback onError,
    TelegramEventCallback onEvent,
    TelegramServiceLogoutCallback onLogOut,
    bool logEnabled = true,
  }) async {
    _logEnabled = logEnabled;

    // Register instance of Telegram Service in GetX dependency injection system
    // Instance exists in App memory up until closure
    await Get.putAsync(() async {
      final _instance = TelegramService._(
        parameters: parameters,
        eventHandlers: eventHandlers,
        verbosityLevel: verbosityLevel,
        onError: onError,
        onEvent: onEvent,
        onLogOut: onLogOut,
      );

      await _instance.initClient();
      return _instance;
    }, permanent: true);
  }

  /// Does attempt to restart telegram service
  /// !!! At the moment will cause Critical Exception as TdLib is crashing during restart
  // TODO: Fix crash of the tdlib plugin during restart
  static Future<void> restart({
    TdlibParameters parameters,
    List<TelegramEventHandler> eventHandlers,
    TelegramErrorCallback onError,
    TelegramEventCallback onEvent,
    TelegramServiceLogoutCallback onLogOut,
  }) async {
    final _instance = instance;
    final newParams = parameters ?? _instance.parameters;
    final newEventHandlers = eventHandlers ?? _instance.eventHandlers;
    final verbosity = _instance.verbosityLevel;
    final newOnError = onError ?? _instance.onError;
    final newOnEvent = onEvent ?? _instance.onEvent;
    final newOnLogOut = onLogOut ?? _instance.onLogOut;
    await _instance.stop();
    await start(
      parameters: newParams,
      eventHandlers: newEventHandlers,
      onError: newOnError,
      onEvent: newOnEvent,
      onLogOut: newOnLogOut,
      verbosityLevel: verbosity,
    );
  }

  /// Returns current instance of [TelegramService].
  ///
  /// [TelegramService.start] must be called first.
  /// Throws [TelegramServiceException] if telegram service was not started.
  static TelegramService get instance {
    try {
      TelegramService _instance = Get.find();
      return _instance;
    } catch (e) {
      throw TelegramServiceException(
          "Telegram service is not started. Please use [TelegramService.start] first.");
    }
  }

  /// Passes [error] object to [errorCallback]. If [errorCallback] is Null then throws [error] as exception
  void errorCallback(error, TelegramErrorCallback errorCallback) {
    if (errorCallback != null)
      errorCallback(error);
    else
      throw error;
  }

  ///Checks if [event] is instance of [TdError].
  ///
  ///If yes, calls [this.onError] call back to handle the error. [onError] should be assigned on the [TelegramService.start]
  void tdLibErrorCheck(TdObject event) {
    if (event.getConstructor() != TdError.CONSTRUCTOR) return;
    final error = event as TdError;
    TelegramService.log(
        "[${error.extra}] returned error code [${error.code}] with message [${error.message}].");
    if (this.onError != null) {
      this.onError(event);
    }
  }

  // * Variables definition

  /// internal TdLIb client ID
  int _client;

  /// Stream used to handle events from TdLib Library
  StreamController<TdObject> _eventController;

  /// Subscribes and recieves TdLib events from plugin
  StreamSubscription<TdObject> _eventReceiver;

  Directory appDocDir;
  Directory appExtDir;

  ///Map to store registered event callbacks done via sendCommand function
  final Map<String, TelegramEventCallback> _eventCallbacks =
      Map<String, TelegramEventCallback>();

  final TdlibParameters parameters;
  final int verbosityLevel;
  final TelegramErrorCallback onError;
  final TelegramEventCallback onEvent;
  final TelegramServiceLogoutCallback onLogOut;
  final List<TelegramEventHandler> eventHandlers;
  final Map<String, Stream<TdObject>> _eventHandlersStreams = Map();
  final Map<String, StreamController<TdObject>> _eventHandlersSControllers =
      Map();

  /// Internal constructor for [TelegramService]. Check [TelegramService.start] for more information
  TelegramService._({
    @required this.parameters,
    @required this.eventHandlers,
    this.verbosityLevel = 1,
    this.onError,
    this.onEvent,
    this.onLogOut,
  }) : assert(eventHandlers != null) {
    // initializes event handling stream. All events are handled in [_onEvent] function
    _eventController = StreamController();
    _eventController.stream.listen(_onEvent);
  }

  /// Initializes TelegramEventHandler  processing system
  /// 1. Registers set of internal handlers needed for initialization and authorization of telegram client
  /// 2. Creates separate [StreamController] for each [TelegramEventHandler.eventsToHandle] and then subscribes TelegramEventHandler to the stream
  void initHandlersMap() {
    //Define directory path used by TdLIb pluging for processing and storing internal cash data.
    parameters.filesDirectory = appExtDir.path + '/tdlib';
    parameters.databaseDirectory = appDocDir.path;

    // Registers internal event handlers. Check each class seperatelly
    eventHandlers.add(TdlibParametersHandler(parameters, onError));
    eventHandlers.add(EncryptionKeyHandler(ENCRYPTION_KEY));
    eventHandlers.add(AuthorizationClosedHandler(onLogOut));

    for (var eventHandler in eventHandlers) {
      final _eventsToHandle = eventHandler.eventsToHandle;
      for (var eventType in _eventsToHandle) {
        if (!allObjects.containsKey(eventType)) continue;
        if (!_eventHandlersSControllers.containsKey(eventType)) {
          _eventHandlersSControllers[eventType] = StreamController.broadcast();
          _eventHandlersStreams[eventType] =
              _eventHandlersSControllers[eventType].stream;
        }
        _eventHandlersStreams[eventType].listen(eventHandler.onTelegramEvent);
        log("Handler [${eventHandler.runtimeType.toString()}]  registered for event type [$eventType].");
      }
    }
  }

  /// Creates a new instance of TDLib.
  /// Returns Pointer to the created instance of TDLib.
  /// Pointer 0 mean No client instance.
  Future<void> initClient() async {
    // check if client already initialized or was not created successfully last time
    if (_client != null && _client != 0) {
      return;
    }

    try {
      _client = await TdClient.createClient();

      log("Telegram client created. id: [$_client]");

      await _getPermissions();

      log("Storage permissions granted for client  [$_client]");

      appDocDir = await getApplicationDocumentsDirectory();
      appExtDir = await getTemporaryDirectory();

      log("Setting client [$_client]  verbosity level ${this.verbosityLevel}");
      await execute(
          SetLogVerbosityLevel(newVerbosityLevel: this.verbosityLevel));

      _eventReceiver = TdClient.clientEvents(_client).listen(_receiver);
      log("Client  [$_client] subscribed for incoming events");

      initHandlersMap();
    } catch (e) {
      errorCallback(e, this.onError);
    }
  }

  Future<void> _getPermissions() async {
    PermissionStatus storagePermission = await Permission.storage.request();
    if (!storagePermission.isGranted)
      throw TelegramServiceException(
          "Cannot get storage permission. Telegram service stopped.");
  }

  void _receiver(TdObject newEvent) async {
    if (newEvent != null) {
      if (newEvent is Updates) {
        newEvent.updates.forEach((Update event) => _eventController.add(event));
      } else {
        _eventController.add(newEvent);
      }
    }
  }

  ///Handles event from telegram client
  ///If @extra in event object contains callback reference tries to call stored callback function
  ///Otherwise broadcast event to specific event handling stream associated with TlObject.CONSTRUCTOR
  void _onEvent(TdObject event) async {
    final requestID = event.extra?.toString();
    log("Event [${event.getConstructor()}] is received with callback id [$requestID]");

    tdLibErrorCheck(event);

    if (this.onEvent != null) this.onEvent(event, requestID);
    updateState(event: TelegramStateEvent(event));

    if (_eventCallbacks.containsKey(requestID)) {
      _eventCallbacks[requestID](event, requestID);
      _eventCallbacks[requestID] = null;
    } else {
      final eventType = event.getConstructor();
      if (_eventHandlersSControllers.containsKey(eventType)) {
        _eventHandlersSControllers[eventType].add(event);
      }
    }
  }

  Future<void> destroyClient() async => await TdClient.destroyClient(_client);

  // TODO: Fix fatal mistake from the plugin during attempt to stop and restart service
  Future<void> stop() async {
    try {
      _eventController.close();
      _eventReceiver.cancel();
      _eventHandlersSControllers.forEach((key, value) {
        value.close();
      });
      _eventHandlersSControllers.clear();
      _eventHandlersStreams.clear();
      Get.delete<TelegramService>(force: true);
      await destroyClient();
      log("Client [$_client] was stopped. All streams disposed.");
    } catch (e) {
      errorCallback(e, this.onError);
    }
  }

  ///Executes sync command to the Client
  Future<TdObject> execute(TdFunction command) async =>
      await TdClient.clientExecute(_client, command);

  Future<dynamic> sendCommand(TdFunction command,
      {TelegramEventCallback callback,
      TelegramErrorCallback onError,
      Duration timeout}) async {
    final requestID = _randomID();
    final responseTimeout = timeout ?? 10.minutes;

    if (callback != null) {
      //registers callback in the requests pull
      _eventCallbacks[requestID] = callback;
      command.extra = requestID;
      log("Registered custom command callback [$requestID] for [${command.getConstructor()}]");
      // schedules future to cancel callback upon timeout
      Future.delayed(responseTimeout, () {
        if (!_eventCallbacks.containsKey(requestID)) return;
        log("Callback timeout for [$requestID] for [${command.getConstructor()}]");
        _eventCallbacks.remove(requestID);
      });
    }
    try {
      log('Sending command [${command.getConstructor()}] to client [$_client]');
      await TdClient.clientSend(_client, command);
      return requestID;
    } catch (e) {
      TelegramErrorCallback _onError = onError ?? this.onError;
      errorCallback(e, _onError);
    }
  }

  @override
  void dispose() async {
    await stop();
    super.dispose();
  }
}

class TelegramServiceException implements Exception {
  final _message;

  TelegramServiceException(this._message);

  String toString() {
    return "[Telegram Service Error] $_message";
  }
}

class TelegramStateEvent extends ModelStateEvent<TdObject> {
  TelegramStateEvent(TdObject eventValue) : super("ON_EVENT", eventValue);
}
