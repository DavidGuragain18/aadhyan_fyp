import 'dart:ui';

Color getStatusBackgroundColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return const Color(0xFF065F46); // Light green
    case 'reject':
    case 'rejected':
      return const Color(0xFFFEE2E2); // Light red
    case 'pending':
      return const Color(0xFFF3F4F6); // Light grey
    default:
      return const Color(0xFF065F46); // Default grey
  }
}

Color getStatusTextColor(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
      return const Color.fromARGB(255, 226, 243, 238); // Dark green
    case 'reject':
    case 'rejected':
      return const Color(0xFFDC2626); // Red
    case 'pending':
      return const Color(0xFF6B7280); // Grey
    default:
      return const Color(0xFF6B7280); // Default grey
  }
}
