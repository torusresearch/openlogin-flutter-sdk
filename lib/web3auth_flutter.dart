import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:web3auth_flutter/input.dart';
import 'package:web3auth_flutter/output.dart';

class Web3AuthFlutter {
  static const MethodChannel _channel = MethodChannel('web3auth_flutter');

  /// [init] methods helps you setup [Web3AuthFlutter] SDK. You can add
  /// whitelabeling, redirect url, and set other parameters during init.
  ///
  /// Please checkout [Web3AuthOptions] for more details
  static Future<void> init(Web3AuthOptions initParams) async {
    Map<String, dynamic> initParamsJson = initParams.toJson();
    initParamsJson.removeWhere((key, value) => value == null);
    await _channel.invokeMethod('init', jsonEncode(initParamsJson));
  }

  /// [login] method will initiate login flow, opening the browser allowing
  /// users to authenticate themselves with preferred login provider.
  ///
  /// Use [loginParams] to change the login provider, curve, and other parameters.
  /// For more details, look into [LoginParams].
  static Future<Web3AuthResponse> login(LoginParams loginParams) async {
    try {
      Map<String, dynamic> loginParamsJson = loginParams.toJson();
      loginParamsJson.removeWhere((key, value) => value == null);
      final String loginResponse = await _channel.invokeMethod(
        'login',
        jsonEncode(loginParamsJson),
      );

      return Web3AuthResponse.fromJson(jsonDecode(loginResponse));
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  /// [logout] method will initiate the logout for current session.
  static Future<void> logout() async {
    try {
      await _channel.invokeMethod('logout', jsonEncode({}));
      return;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  /// Initializes the [Web3AuthFlutter] with session if present. 
  /// If no active session is present, the method will throw an error. 
  /// 
  /// You should use try and catch block to handle the error when no 
  /// active session is present.
  static Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize', jsonEncode({}));
      return;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  /// Returns the secp256k1 EVM compaitible key if the user is successfully
  /// authenticated.
  ///
  /// If user is not authenticated, it'll return empty string.
  static Future<String> getPrivKey() async {
    try {
      final String privKey =
          await _channel.invokeMethod('getPrivKey', jsonEncode({}));
      return privKey;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  /// Returns the ed25519 Solana compaitible key if the user is successfully
  /// authenticated.
  ///
  /// If user is not authenticated, it'll return empty string.
  static Future<String> getEd25519PrivKey() async {
    try {
      final String getEd25519PrivKey =
          await _channel.invokeMethod('getEd25519PrivKey', jsonEncode({}));
      return getEd25519PrivKey;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  /// Returns the user information such as email address, name, session id, and etc.
  ///
  /// If user is not authenticated, it'll throw an error.
  static Future<TorusUserInfo> getUserInfo() async {
    try {
      final String torusUserInfo =
          await _channel.invokeMethod('getUserInfo', jsonEncode({}));
      return TorusUserInfo.fromJson(jsonDecode(torusUserInfo));
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }
  
  /// [setCustomTabsClosed] helps to trigger the [UserCancelledException] exception
  /// on Android.
  ///
  /// The Android SDK uses the custom tabs and from current implementation of chrome custom tab,
  /// it's not possible to add a listener directly to chrome custom tab close button and
  /// trigger login exceptions.
  ///
  /// If you want to trigger exception for user closing the browser tab, you have to use
  /// WidgetsBindingObserver mixin with your your login screen, and call the method during 
  /// [AppLifecycleState.resumed].
  static Future<void> setCustomTabsClosed() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('setCustomTabsClosed');
      }
      return;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  static Exception _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case "UserCancelledException":
        return UserCancelledException();
      case "NoAllowedBrowserFoundException":
        return UnKnownException(e.message);
      default:
        return e;
    }
  }

  static Future<void> launchWalletServices(
    ChainConfig chainConfig, {
    String path = "wallet",
  }) async {
    try {
      Map<String, dynamic> chainConfigJson = chainConfig.toJson();
      chainConfigJson.removeWhere((key, value) => value == null);

      Map<String, dynamic> walletServicesJson = {};
      walletServicesJson["chainConfig"] = chainConfigJson;
      walletServicesJson["path"] = path;

      await _channel.invokeMethod(
        'launchWalletServices',
        jsonEncode(walletServicesJson),
      );

      return;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }
 
  /// [enableMFA] method allows us trigger the MFA flow. If the MFA is already 
  /// enable, the method will throw an error.
  static Future<bool> enableMFA({LoginParams? loginParams}) async {
    try {
      bool isMFASetup = false;
      if (loginParams == null) {
        isMFASetup = await _channel.invokeMethod('enableMFA', jsonEncode({}));
        return isMFASetup;
      } else {
        Map<String, dynamic> loginParamsJson = loginParams.toJson();
        loginParamsJson.removeWhere((key, value) => value == null);
        isMFASetup = await _channel.invokeMethod(
          'enableMFA',
          jsonEncode(loginParamsJson),
        );
      }
      return isMFASetup;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  static Future<bool> manageMFA({LoginParams? loginParams}) async {
    try {
      bool isManageMFA = false;
      if (loginParams == null) {
        isManageMFA = await _channel.invokeMethod('manageMFA', jsonEncode({}));
        return isManageMFA;
      } else {
        Map<String, dynamic> loginParamsJson = loginParams.toJson();
        loginParamsJson.removeWhere((key, value) => value == null);
        isManageMFA = await _channel.invokeMethod(
          'manageMFA',
          jsonEncode(loginParamsJson),
        );
      }
      return isManageMFA;
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  static Future<SignResponse> request(
    ChainConfig chainConfig,
    String method,
    List<dynamic> requestParams, {
    String path = "wallet/request",
    String? appState,
  }) async {
    try {
      Map<String, dynamic> chainConfigJson = chainConfig.toJson();
      chainConfigJson.removeWhere((key, value) => value == null);

      List<String> modifiedRequestParams =
          requestParams.map((param) => jsonEncode(param)).toList();

      Map<String, dynamic> requestJson = {};
      requestJson["chainConfig"] = chainConfigJson;
      requestJson["method"] = method;
      requestJson["requestParams"] = modifiedRequestParams;
      requestJson["path"] = path;
      if (appState != null) {
        requestJson["appState"] = appState;
      }

      final response =
          await _channel.invokeMethod('request', jsonEncode(requestJson));

      if (response == "null") {
        return SignResponse(
          success: false,
          error: "Something went wrong. Unable to process the request.",
        );
      }

      return SignResponse.fromJson(jsonDecode(response));
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }

  static Future<Web3AuthResponse> getWeb3AuthResponse() async {
    try {
      final String web3AuthResponse = await _channel.invokeMethod(
        'getWeb3AuthResponse',
        jsonEncode({}),
      );
      return Web3AuthResponse.fromJson(jsonDecode(web3AuthResponse));
    } on PlatformException catch (e) {
      throw _handlePlatformException(e);
    }
  }
}
