import 'package:intl/intl.dart';

class Helpers {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}