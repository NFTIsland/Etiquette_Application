import 'dart:math';

double roundDouble(double value, int places) {
  // value를 소수점 아래 (places + 1)번째 자리에서 반올림한다.
  // 즉, 소수점 아래 places 자리까지 나타낸다.
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}