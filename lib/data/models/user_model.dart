class UserModel {
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.ocdType,
    required this.anxietyLevel,
    required this.compulsiveBehaviors,
    required this.stars,
    required this.equippedItem,
    required this.unlockedItems,
    required this.welcomeGiftReceived,
    required this.age,
  });

  final int id;
  final String username;
  final String email;
  final String name;
  final String birthDate;
  final String gender;
  final String ocdType;
  final String anxietyLevel;
  final List<String> compulsiveBehaviors;
  int stars;
  String? equippedItem;
  List<String> unlockedItems;
  final int welcomeGiftReceived;
  final int age;

  factory UserModel.fromJson(Map<String, dynamic> j) {
    final rawBeh = j['compulsive_behaviors'];
    List<String> beh = [];
    if (rawBeh is List) {
      beh = rawBeh.map((e) => e.toString()).toList();
    }
    List<String> unl = [];
    final rawUnl = j['unlocked_items'];
    if (rawUnl is List) {
      unl = rawUnl.map((e) => e.toString()).toList();
    }
    return UserModel(
      id: (j['id'] as num).toInt(),
      username: (j['username'] ?? '') as String,
      email: (j['email'] ?? '') as String,
      name: (j['name'] ?? '') as String,
      birthDate: (j['birth_date'] ?? '') as String,
      gender: (j['gender'] ?? 'male') as String,
      ocdType: (j['ocd_type'] ?? '') as String,
      anxietyLevel: (j['anxiety_level'] ?? '') as String,
      compulsiveBehaviors: beh,
      stars: (j['stars'] ?? 0) as int,
      equippedItem: j['equipped_item'] as String?,
      unlockedItems: unl,
      welcomeGiftReceived: (j['welcome_gift_received'] ?? 0) as int,
      age: (j['age'] ?? 8) as int,
    );
  }
}
