import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  final RxBool isInternetAccessible = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(connectivityResult);
    } catch (e) {
      isConnected.value = false;
      isInternetAccessible.value = false;
    }
  }

  Future<bool> isInternetReachable() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _updateConnectionStatus(
    ConnectivityResult connectivityResult,
  ) async {
    isConnected.value = connectivityResult != ConnectivityResult.none;

    if (isConnected.value) {
      isInternetAccessible.value = await isInternetReachable();
    } else {
      isInternetAccessible.value = false;
    }

    _updateUserInterface();
  }

  void _updateUserInterface() {
    if (!isConnected.value || !isInternetAccessible.value) {
      Get.rawSnackbar(
        messageText: Text(
          !isConnected.value
              ? 'Please check your internet connection'
              : 'No internet access available',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        isDismissible: false,
        duration: const Duration(days: 1),
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.wifi_off, color: Colors.white, size: 35),
        margin: EdgeInsets.zero,
        snackStyle: SnackStyle.GROUNDED,
      );
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }

  Future<void> checkInternetAccess() async {
    isInternetAccessible.value = await isInternetReachable();
    _updateUserInterface();
  }
}
