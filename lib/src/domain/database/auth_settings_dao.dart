import 'package:hive/hive.dart';
import 'package:map_assignment/src/domain/database/base_hive_dao.dart';

class AuthSettingsDao extends BaseHiveDao {
  static const kLastTokenRefresh = 'last_token_refresh';

  Future<Box> getBox() {
    return Hive.openBox('auth_settings');
  }

  Future<void> saveLastTokenRefresh(DateTime data) async {
    final box = await getBox();
    await box.put(kLastTokenRefresh, data);
  }

  Future<DateTime?> getLastTokenRefresh() async {
    final box = await getBox();
    final value = box.get(kLastTokenRefresh);
    if (value == null) {
      return null;
    }
    return value as DateTime;
  }

  @override
  Future<void> clear() async {
    final box = await getBox();
    await box.clear();
  }
}
