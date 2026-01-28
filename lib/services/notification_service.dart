import 'package:get/get.dart';

class NotificationService extends GetxService {
  void showSnackbar(String title, String message, {SnackPosition snackPosition = SnackPosition.BOTTOM}) {
    Get.snackbar(title, message, snackPosition: snackPosition);
  }
}
