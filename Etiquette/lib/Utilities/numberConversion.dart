double hexToDouble (String hexString) {
  double res = 0.0;
  int length = hexString.length;

  BigInt hex = BigInt.from(16);

  for (int i = 0; i < length; i++) {
    int digit = int.parse(hexString[length - i - 1], radix: 16);
    res = res + digit * hex.pow(i).toDouble();
  }

  return res;
}

double pebToKlayConversion (double peb) { // peb을 klay로 전환
  // 1 klay = 10^18 peb
  BigInt decimal = BigInt.from(10);
  return peb / decimal.pow(18).toDouble(); // decimal.pow(18) = 10^18
}

double klayToPebConversion (double klay) { // klay를 peb으로 전환
  BigInt decimal = BigInt.from(10);
  return klay * decimal.pow(18).toDouble();
}

String doubleToHexString (double peb) {
  String res = "0x";
  List stack = [];
  BigInt hex = BigInt.from(16);
  BigInt int_peb = BigInt.from(peb);

  while(int_peb > hex) {
    BigInt reminder = int_peb % hex;
    if (reminder <= BigInt.from(9)) {
      stack.add(reminder);
    } else if (reminder == BigInt.from(10)) {
      stack.add('A');
    } else if (reminder == BigInt.from(11)) {
      stack.add('B');
    } else if (reminder == BigInt.from(12)) {
      stack.add('C');
    } else if (reminder == BigInt.from(13)) {
      stack.add('D');
    } else if (reminder == BigInt.from(14)) {
      stack.add('E');
    } else if (reminder == BigInt.from(15)) {
      stack.add('F');
    }

    int_peb = int_peb ~/ hex;
  }

  if (int_peb <= BigInt.from(9)) {
    stack.add(int_peb);
  } else if (int_peb == BigInt.from(10)) {
    stack.add('A');
  } else if (int_peb == BigInt.from(11)) {
    stack.add('B');
  } else if (int_peb == BigInt.from(12)) {
    stack.add('C');
  } else if (int_peb == BigInt.from(13)) {
    stack.add('D');
  } else if (int_peb == BigInt.from(14)) {
    stack.add('E');
  } else if (int_peb == BigInt.from(15)) {
    stack.add('F');
  }

  int len = stack.length;
  for (int i = len - 1; i >= 0; i--) {
    res = res + stack[i].toString();
  }

  return res;
}