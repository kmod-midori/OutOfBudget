String formatFromCents(int cents, {bool compact = false}) {
  var sign = "";
  if (cents < 0) {
    sign = "-";
    cents = -cents;
  }
  var dollars = cents ~/ 100;
  if (dollars > 999 && compact) {
    return "$sign${dollars ~/ 1000}k";
  }

  var centsPart = (cents % 100).toString().padLeft(2, "0");
  return "$sign$dollars.$centsPart";
}

int parseToCents(String amount) {
  var parsed = double.parse(amount);
  return (parsed * 100.0).toInt();
}
