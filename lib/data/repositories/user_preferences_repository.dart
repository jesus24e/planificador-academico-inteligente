import 'package:planificador_academico_inteligente/data/database/dataAccessObject/user_preferences_dao.dart';
import 'package:planificador_academico_inteligente/entities/user_preferences.dart';

class UserPreferencesRepository {
  final _dao = UserPreferencesDao();

  Future<UserPreferences> get() => _dao.get();
  Future<void> save(UserPreferences prefs) => _dao.save(prefs);
}
