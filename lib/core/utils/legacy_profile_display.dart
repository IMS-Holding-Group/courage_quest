/// Maps legacy Arabic values stored before the English UI to English labels.
class LegacyProfileDisplay {
  LegacyProfileDisplay._();

  static const _anxiety = {
    'خفيف': 'Mild',
    'معتدل': 'Moderate',
    'عالٍ': 'High',
  };

  static const _behavior = {
    'غسيل اليدين / التنظيف': 'Hand washing / cleaning',
    'تكرار العبارات': 'Repeating phrases',
    'طلب التطمين المتكرر': 'Frequent reassurance seeking',
    'تجنب الأماكن/الأشخاص': 'Avoiding places/people',
    'فحص الأشياء بشكل متكرر': 'Checking things repeatedly',
    'ترتيب الأشياء': 'Ordering / arranging',
  };

  static String anxiety(String? value) {
    if (value == null || value.isEmpty) return '-';
    return _anxiety[value] ?? value;
  }

  static String behavior(String value) => _behavior[value] ?? value;
}
