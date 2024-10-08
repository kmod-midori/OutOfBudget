enum SignMode {
  always,
  never,
  onlyNegative,
}

String formatFromCents(int cents, {signMode = SignMode.onlyNegative}) {
  var centsAbs = cents.abs();

  var dollars = centsAbs ~/ 100;
  var centsPart = centsAbs % 100;

  var centsString = centsPart.toString().padLeft(2, "0");

  var sign = "";

  switch (signMode) {
    case SignMode.always:
      sign = cents.isNegative ? "-" : "+";
      break;
    case SignMode.never:
      sign = "";
      break;
    case SignMode.onlyNegative:
      sign = cents.isNegative ? "-" : "";
      break;
  }

  return "$sign$dollars.$centsString";
}

int parseToCents(String amount) {
  var parsed = double.parse(amount);
  return (parsed * 100.0).toInt();
}
