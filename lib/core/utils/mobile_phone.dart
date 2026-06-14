String normalizeSomaliaPhone(String input) {
  final trimmed = input.trim();
  if (trimmed.contains('@')) return trimmed;

  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('252')) return digits;
  if (digits.startsWith('0')) return '252${digits.substring(1)}';
  if (digits.startsWith('61') ||
      digits.startsWith('62') ||
      digits.startsWith('63')) {
    return '252$digits';
  }
  return digits;
}
