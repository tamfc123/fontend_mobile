import 'package:mobile/data/models/class_schedule_model.dart';

extension ClassScheduleModelExtension on ClassScheduleModel {
  int dayStringToInt() {
    switch (dayOfWeek) {
      case 'Thứ 2':
        return 2;
      case 'Thứ 3':
        return 3;
      case 'Thứ 4':
        return 4;
      case 'Thứ 5':
        return 5;
      case 'Thứ 6':
        return 6;
      case 'Thứ 7':
        return 7;
      case 'Chủ nhật':
        return 8;
      default:
        return 0;
    }
  }
}
