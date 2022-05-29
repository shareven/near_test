import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'app_storage.dart';

Api? webApi;
String inAppUrl = "about:blank";

class Api {
  Api(
    this.context,
  );

  final BuildContext context;

  Map<String, Function> _msgHandlers = {};
  Map<String, Completer> _msgCompleters = {};
  HeadlessInAppWebView? _web;
  int _evalJavascriptUID = 0;

  /// preload js code for opening dApps
  String? asExtensionJSCode;
  bool _webViewLoaded = false;
  Timer? _webViewReloadTimer;
  // Jaguar? server;
  bool hasLoadAccountData = false;

  Future<void> close() async {
    await _web?.dispose();
  }

  _setSubNewHeads(Map lastHeader) {}

  ///sub status of connecting
  _setDisconnected(bool disconnected) {}

  void init() {
    launchWebview();
  }

  Future<void> launchWebview() async {
    /// reset state before webView launch or reload
    _msgHandlers = {};
    _msgCompleters = {};
    _evalJavascriptUID = 0;
    bool hasLoadedpage = false;

    //subscription

    _msgHandlers['newHeadsChange'] = _setSubNewHeads;
    _msgHandlers['disconnected'] = _setDisconnected;
    // _onLaunched = onLaunched;
    _webViewLoaded = false;
    hasLoadAccountData = false;

    var _jsCode = await DefaultAssetBundle.of(context)
        .loadString('lib/js_service/dist/main.js');

    if (_web == null) {
      _web = new HeadlessInAppWebView(
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(),
        ),
        onWebViewCreated: (controller) {
          print('HeadlessInAppWebView created!');
        },
        onConsoleMessage: (controller, message) {
          if (!message.message.contains('{"path":"newHeadsChange",')) {
            print("CONSOLE MESSAGE: " + message.message);
          }
          if (message.messageLevel != ConsoleMessageLevel.LOG) return;
          try {
            compute(jsonDecode, message.message).then((msg) {
              final String path = msg['path'];
              if (_msgCompleters[path] != null) {
                Completer? handler = _msgCompleters[path];
                handler?.complete(msg['data']);
                if (path.contains('uid=')) {
                  _msgCompleters.remove(path);
                  print(" unsolved：${_msgCompleters.keys}");
                }
              }
              if (_msgHandlers[path] != null) {
                Function handler = _msgHandlers[path]!;
                handler(msg['data']);
              }
            });
          } catch (e) {
            print(e);
          }
        },
        onLoadStop: (controller, url) async {
          print('webview loaded,url:$url');

          _handleReloaded();
          if (url.toString() == inAppUrl && !hasLoadedpage) {
            hasLoadedpage = true;
            await _web!.webViewController.evaluateJavascript(source: _jsCode);
            await _start();
          }
          // await _startJSCode(keyring, keyringStorage);
        },
      );

      await _web?.run();
      _web?.webViewController
          .loadUrl(urlRequest: URLRequest(url: Uri.parse(inAppUrl)));
    } else {
      _tryReload();
    }
  }

  Future<void> _start() async {
    // await account?.initAccounts();
    // connect remote node

    connectNode();
  }

  void _tryReload() {
    if (!_webViewLoaded) {
      _web?.webViewController.reload();

      _webViewReloadTimer = Timer(Duration(seconds: 3), _tryReload);
    }
  }

  void _handleReloaded() {
    _webViewReloadTimer?.cancel();
    _webViewLoaded = true;
  }

  int _getEvalJavascriptUID() {
    return _evalJavascriptUID++;
  }

  Future<dynamic> evalJavascript(
    String code, {
    bool wrapPromise = true,
    bool allowRepeat = false,
  }) async {
    // check if there's a same request loading
    if (!allowRepeat) {
      for (String i in _msgCompleters.keys) {
        String call = code.split('(')[0];
        if (i.contains(call)) {
         
          return _msgCompleters[i]?.future;
        }
      }
    }

    if (!wrapPromise) {
      final res =
          await _web!.webViewController.evaluateJavascript(source: code);
      return res;
    }

    Completer c = new Completer();

    final uid = _getEvalJavascriptUID();
    final method = 'uid=$uid;${code.split('(')[0]}';
    _msgCompleters[method] = c;

    String script = '$code.then(function(res) {'
        '  console.log(JSON.stringify({ path: "$method", data: res }));'
        '}).catch(function(err) {'
        '  console.log(JSON.stringify({ path: "log", data: err.message }));'
        '});$uid;';
    _web!.webViewController.evaluateJavascript(source: script);

    return c.future;
  }

  Future<void> connectNode({String? newTypes}) async {
    String endpoint1 = "https://rpc.testnet.near.org";
    String endpoint2 = "https://archival-rpc.testnet.near.org";
    String endpoint = "https://public-rpc.blockpi.io/http/near-testnet";

    String? res = await evalJavascript('settings.connect("$endpoint")');
    
    if (res == null) {
      print('connect failed');

      return;
    }

    /// todo something
  }

  Future<Map?> recoverAccount(String seedPhrase) async {
    Map? res = await evalJavascript('account.recover("$seedPhrase")');

    if (res != null && res["accountId"] != null) {
      print(res);
      await AppStorage.setAccount(res);
    }
    return res;
  }
}
