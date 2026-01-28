import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';
import '../repository/attendance_repository.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LocationService());
    Get.put(NotificationService());

    // DatabaseService is initialized in main()

    Get.lazyPut(() => AttendanceRepository(Get.find<DatabaseService>()));
    Get.lazyPut(() => AttendanceController(
      Get.find<LocationService>(),
      Get.find<AttendanceRepository>(),
      Get.find<NotificationService>(),
    ));
  }
}
