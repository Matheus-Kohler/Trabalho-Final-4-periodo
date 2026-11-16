import '../models/class_ability_model.dart';
import '../models/rpg_class_model.dart';
import 'app_data_notifier.dart';
import 'api_client.dart';

class RPGClassService {
  final ApiClient _client = ApiClient();

  Future<List<RPGClassModel>> getClasses() async {
    final response = await _client.get('/classes');
    final data = response['data'] as List? ?? [];
    return data
        .map((item) => RPGClassModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<RPGClassModel> getClass(int id) async {
    final response = await _client.get('/classes/$id');
    final data = response['data'] as Map<String, dynamic>;
    return RPGClassModel.fromJson(data);
  }

  Future<RPGClassModel> createClass({
    required String name,
    String? description,
    int hpBase = 10,
    double goldInitial = 0.0,
    List<Map<String, String>> abilities = const [],
  }) async {
    final response = await _client.post('/classes', {
      'name': name,
      if (description != null && description.isNotEmpty)
        'description': description,
      'hp_base': hpBase,
      'gold_initial': goldInitial,
      if (abilities.isNotEmpty) 'abilities': abilities,
    });
    final data = response['data'] as Map<String, dynamic>;
    AppDataNotifier.instance.notifyDataChanged();
    return RPGClassModel.fromJson(data);
  }

  Future<RPGClassModel> updateClass(
    int id, {
    required String name,
    String? description,
    required int hpBase,
    required double goldInitial,
  }) async {
    final response = await _client.put('/classes/$id', {
      'name': name,
      'description': ?description,
      'hp_base': hpBase,
      'gold_initial': goldInitial,
    });
    final data = response['data'] as Map<String, dynamic>;
    AppDataNotifier.instance.notifyDataChanged();
    return RPGClassModel.fromJson(data);
  }

  Future<void> deleteClass(int id) async {
    await _client.delete('/classes/$id');
    AppDataNotifier.instance.notifyDataChanged();
  }

  Future<ClassAbilityModel> addAbility(
    int classId, {
    required String name,
    String? description,
  }) async {
    final response = await _client.post('/classes/$classId/abilities', {
      'name': name,
      if (description != null && description.isNotEmpty)
        'description': description,
    });
    final data = response['data'] as Map<String, dynamic>;
    AppDataNotifier.instance.notifyDataChanged();
    return ClassAbilityModel.fromJson(data);
  }

  Future<void> removeAbility(int classId, int abilityId) async {
    await _client.delete('/classes/$classId/abilities/$abilityId');
    AppDataNotifier.instance.notifyDataChanged();
  }
}
