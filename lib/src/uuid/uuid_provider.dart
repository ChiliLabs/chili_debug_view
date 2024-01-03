import 'dart:math' as math;

class UUIDProvider {
  static String generateId() {
    var first4alphabets = '';
    var middle4Digits = '';
    var last4alphabets = '';

    for (int i = 0; i < 4; i++) {
      final randomFirstCharKey = math.Random.secure().nextInt(
        _RanKeyAssets.smallAlphabets.length,
      );
      final randomDigitsKey = math.Random.secure().nextInt(
        _RanKeyAssets.digits.length,
      );
      final randomLastCharKey = math.Random.secure().nextInt(
        _RanKeyAssets.smallAlphabets.length,
      );

      first4alphabets += _RanKeyAssets.smallAlphabets[randomFirstCharKey];
      middle4Digits += _RanKeyAssets.digits[randomDigitsKey];
      last4alphabets += _RanKeyAssets.smallAlphabets[randomLastCharKey];
    }

    return '$first4alphabets-$middle4Digits-${DateTime.now().microsecondsSinceEpoch.toString().substring(8, 12)}-$last4alphabets';
  }
}

class _RanKeyAssets {
  static const smallAlphabets = [
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z'
  ];
  static const digits = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
  ];
}
