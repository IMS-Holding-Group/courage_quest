import 'package:flutter/foundation.dart';
import '../core/services/api_service.dart';
import '../data/models/user_model.dart';

class CourageQuestState extends ChangeNotifier {
  UserModel? user;

  int? get userId => user?.id;

  Future<void> loadUser(int id) async {
    final r = await ApiService.getJson('/api/auth/user/$id');
    if (r['success'] == true && r['user'] != null) {
      user = UserModel.fromJson(Map<String, dynamic>.from(r['user'] as Map));
      notifyListeners();
    }
  }

  void setLocalStars(int stars) {
    if (user != null) {
      user!.stars = stars;
      notifyListeners();
    }
  }

  void setEquipped(String? item) {
    if (user != null) {
      user!.equippedItem = item;
      notifyListeners();
    }
  }

  void setUnlocked(List<String> items) {
    if (user != null) {
      user!.unlockedItems = List.from(items);
      notifyListeners();
    }
  }
}
