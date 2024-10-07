String formatFromCents(int cents) {
  var sign = "";
  if (cents < 0) {
    sign = "-";
    cents = -cents;
  }
  var dollars = cents ~/ 100;
  var centsPart = (cents % 100).toString().padLeft(2, "0");
  return "$sign$dollars.$centsPart";
}

int parseToCents(String amount) {
  var parsed = double.parse(amount);
  return (parsed * 100.0).toInt();
}
