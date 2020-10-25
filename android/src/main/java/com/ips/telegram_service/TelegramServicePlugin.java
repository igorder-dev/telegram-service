package com.ips.telegram_service;

import android.os.Looper;
import android.os.Handler;
import android.content.Context;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

import org.drinkless.tdlib.JsonClient;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.EventChannel.StreamHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** TelegramServicePlugin */
public class TelegramServicePlugin implements FlutterPlugin, MethodCallHandler, StreamHandler {

  private static final String TELEGRAM_METHOD_CHANNEL = "telegram_service_call";
  private static final String TELEGRAM_EVENTS_CHANNEL = "telegram_service_event";
  private static final String TELEGRAM_LABEL = "TELE-PLUGIN";
  private static long currentClientID = -1;

  private MethodChannel methodChannel;
  private EventChannel eventChannel;
  private final HashMap<Long, Client> clients = new HashMap<Long, Client>();


  @Override
  public void onAttachedToEngine( FlutterPluginBinding flutterPluginBinding) {

    methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), TELEGRAM_METHOD_CHANNEL);
    eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), TELEGRAM_EVENTS_CHANNEL);

    methodChannel.setMethodCallHandler(this);
    eventChannel.setStreamHandler(this);

    Log.d(TELEGRAM_LABEL,"onAttachedToEngine called.");

  }

  @Override
  public void onMethodCall( MethodCall call,  Result rawResult) {

    Result result = new MethodResultWrapper(rawResult);

    Log.d(TELEGRAM_LABEL,"onMethodCall called. Method:" + call.method);

    switch (call.method) {
      case "getPlatformVersion":{
        rawResult.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      }
      case "clientReceive": {
        String res = JsonClient.receive((long) call.argument("client"), (double) call.argument("timeout"));
        result.success(res);
        break;
      }
      case "clientSend": {
        JsonClient.send((long) call.argument("client"), (String) call.argument("query"));
        result.success(null);
        break;
      }
      case "clientExecute": {
        String res = JsonClient.execute((long) call.argument("client"), (String) call.argument("query"));
        result.success(res);
        break;
      }
      case "clientCreate":
        if(currentClientID == -1) {
          currentClientID = (long) JsonClient.create();
        }
        result.success( (long) currentClientID);
        break;
      case "clientDestroy": {
        JsonClient.destroy((long) call.argument("client"));
        currentClientID=-1;
        result.success(null);
        break;
      }
      default:
        result.notImplemented();
        break;
    }


  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {

    Log.d(TELEGRAM_LABEL,"onDetachedFromEngine called.");

    methodChannel.setMethodCallHandler(null);
    methodChannel = null;
    eventChannel.setStreamHandler(null);
    eventChannel = null;
    for (Map.Entry<Long, Client> entry : clients.entrySet()) {
      entry.getValue().close();
    }
    clients.clear();
  }

  @Override
  public void onListen(Object arguments, EventSink events) {

    Log.d(TELEGRAM_LABEL,"onListen called.");

    long clientId = ((Number) arguments).longValue();

    Log.d(TELEGRAM_LABEL,"onListen. clientId:" + Long.toString(clientId));

    Client client = clients.get(clientId);
    if (client == null) {
      client = new Client(clientId, events);
      clients.put(clientId, client);
      Log.d(TELEGRAM_LABEL,"Starting listening new client"+ Long.toString(clientId) +".");
      new Thread(client, String.format("Telegram Client Client#%s", clientId)).start();
    } else {
      Log.d(TELEGRAM_LABEL,"This Client "+ Long.toString(clientId) +" is being listened already. re-opening");
      client.open();
      //events.error("UNAVAILABLE", "This Client Already is being listened to ", null);
    }

  }

  @Override
  public void onCancel(Object arguments) {

    Log.d(TELEGRAM_LABEL,"onCancel called.");

    if(arguments == null) {
      for(Map.Entry<Long, Client> pair : clients.entrySet()){
        pair.getValue().close();
      }
      return;
    }

    long clientId = ((Number) arguments).longValue();
    Client client = clients.remove(clientId);
    if (client != null) {
      client.close();
    }
  }




  private static class MethodResultWrapper implements Result {
    private final Result methodResult;
    private final Handler handler;

    MethodResultWrapper(Result result) {
      methodResult = result;
      handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void success(final Object result) {
      handler.post(
              new Runnable() {
                @Override
                public void run() {
                  methodResult.success(result);
                }
              }
      );
    }

    @Override
    public void error(
            final String errorCode, final String errorMessage, final Object errorDetails) {
      handler.post(
              new Runnable() {
                @Override
                public void run() {
                  methodResult.error(errorCode, errorMessage, errorDetails);
                }
              }
      );
    }

    @Override
    public void notImplemented() {
      handler.post(
              new Runnable() {
                @Override
                public void run() {
                  methodResult.notImplemented();
                }
              }
      );
    }
  }

  private static class Client implements Runnable {

    private volatile boolean stopFlag = false;
    private final Handler handler;
    private final EventSink events;
    private final long clientId;

    Client(long clientId, EventSink events){
      this.clientId = clientId;
      this.events = events;
      handler = new Handler(Looper.getMainLooper());
    }

    @Override
    public void run() {
      while (!stopFlag) {
        final String res = JsonClient.receive((long) clientId, (double) 30.0);
        handler.post(
                new Runnable() {
                  @Override
                  public void run() {
                    events.success(res);
                  }
                }
        );
      }
    }

    @Override
    protected void finalize() throws Throwable{
      close();
      super.finalize();
    }

    public void close() {
      stopFlag = true;
      Log.d(TELEGRAM_LABEL,"Client" + Long.toString(clientId) + "stopped.");
      //JsonClient.destroy((long) clientId);
    }
    public void open(){
      Log.d(TELEGRAM_LABEL,"Client" + Long.toString(clientId) + "started.");
      stopFlag = false;
    }


  }


}
