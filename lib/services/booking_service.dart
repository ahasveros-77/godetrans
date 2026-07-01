import '../models/rute_model.dart';
import '../models/armada_model.dart';
import '../models/booking_model.dart';
import 'sheets_api_service.dart';

class BookingService {
  /// Mengambil daftar rute populer untuk ditampilkan di Home.
  static Future<List<RuteModel>> getRutePopuler() async {
    final result = await SheetsApiService.get('getRutePopuler');
    final list = (result as List);
    return list
        .map((e) => RuteModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Mengambil daftar jam keberangkatan yang tersedia untuk asal-tujuan tertentu.
  static Future<List<Map<String, dynamic>>> getJadwal({
    required String asal,
    required String tujuan,
    required String tanggal,
  }) async {
    final result = await SheetsApiService.get('getJadwal', {
      'asal': asal,
      'tujuan': tujuan,
      'tanggal': tanggal,
    });
    final list = (result as List);
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Mengambil daftar armada (Hiace A/B/C/D) untuk jadwal tertentu.
  static Future<List<ArmadaModel>> getArmada({
    required String asal,
    required String tujuan,
    required String jam,
  }) async {
    final result = await SheetsApiService.get('getArmada', {
      'asal': asal,
      'tujuan': tujuan,
      'jam': jam,
    });
    final list = (result as List);
    return list
        .map((e) => ArmadaModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Mengambil daftar kursi & status terisi/tersedia untuk armada tertentu.
  static Future<List<Map<String, dynamic>>> getKursi({
    required String armadaId,
    required String tanggal,
    required String jam,
  }) async {
    final result = await SheetsApiService.get('getKursi', {
      'armada_id': armadaId,
      'tanggal': tanggal,
      'jam': jam,
    });
    final list = (result as List);
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Menyimpan booking baru ke sheet "Booking" sekaligus menandai kursi terisi.
  static Future<BookingModel> createBooking(BookingModel booking) async {
    final result = await SheetsApiService.post('createBooking', booking.toJson());
    return BookingModel.fromJson(Map<String, dynamic>.from(result));
  }

  /// Mengambil semua tiket milik user, dipisah oleh status di sisi UI.
  static Future<List<BookingModel>> getTiketSaya(String userId) async {
    final result = await SheetsApiService.get('getTiketSaya', {
      'user_id': userId,
    });
    final list = (result as List);
    return list
        .map((e) => BookingModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Batalkan tiket milik user
  static Future<void> cancelBooking(String bookingId) async {
    await SheetsApiService.post('cancelBooking', {'id': bookingId});
  }
}
