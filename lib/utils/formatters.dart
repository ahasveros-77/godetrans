import 'package:intl/intl.dart';

class Formatters {
  static String rupiah(double value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  static String tanggalIndo(DateTime date) {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${bulan[date.month]} ${date.year}';
  }

  static String generateKodeBooking() {
    final now = DateTime.now();
    final ms = now.millisecondsSinceEpoch.toString();
    final suffix = ms.substring(ms.length - 6);
    return 'GDT${DateFormat('ddMMyy').format(now)}$suffix'
        .substring(0, 13)
        .toUpperCase();
  }
}
