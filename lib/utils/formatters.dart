String formatPrice(int price) {
  final s = price.toString();
  final buffer = StringBuffer();
  final start = s.length % 3;
  if (start > 0) buffer.write(s.substring(0, start));
  for (int i = start; i < s.length; i += 3) {
    if (buffer.isNotEmpty) buffer.write(',');
    buffer.write(s.substring(i, i + 3));
  }
  return '${buffer.toString()}원';
}

String formatNumber(int n) {
  final s = n.toString();
  final buffer = StringBuffer();
  final start = s.length % 3;
  if (start > 0) buffer.write(s.substring(0, start));
  for (int i = start; i < s.length; i += 3) {
    if (buffer.isNotEmpty) buffer.write(',');
    buffer.write(s.substring(i, i + 3));
  }
  return buffer.toString();
}
