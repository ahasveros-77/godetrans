import 'dart:convert';
import 'package:http/http.dart' as http;

/// =============================================================
/// SHEETS API SERVICE
/// =============================================================
/// Service ini menghubungkan aplikasi Flutter ke Google Sheets,
/// menggunakan Google Apps Script yang di-deploy sebagai Web App
/// (berfungsi seperti REST API).
///
/// PENTING: Ganti [baseUrl] di bawah ini dengan URL Web App hasil
/// deploy Apps Script Anda. Lihat README.md -> "Setup Backend"
/// untuk langkah lengkapnya.
/// =============================================================
class SheetsApiService {
  // GANTI dengan URL deployment Apps Script Anda, contoh:
  // "https://script.google.com/macros/s/AKfycbx.../exec"
  static const String baseUrl =
      "https://script.google.com/macros/s/AKfycbwRcN9Iv5VlkWn9Valk5n_rlIXGq-eEUrTOPSQ8sNPwM5-cU6KVbaSD-fj7Rs1R-VEn2A/exec";

  /// Melakukan request GET ke Apps Script dengan parameter `action`.
  /// Contoh: action=getRute, action=getJadwal, dst.
  static Future<dynamic> get(String action,
      [Map<String, String>? params]) async {
    final query = {
      'action': action,
      ...?params,
    };
    final uri = Uri.parse(baseUrl).replace(queryParameters: query);

    try {
      final response = await http.get(uri).timeout(
            const Duration(seconds: 20),
          );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  /// Melakukan request POST ke Apps Script (untuk insert/update data).
  /// Body dikirim sebagai JSON, Apps Script akan membaca `e.postData.contents`.
  static Future<dynamic> post(
      String action, Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {'Content-Type': 'text/plain'},
            body: jsonEncode({
              'action': action,
              'data': data,
            }),
          )
          .timeout(const Duration(seconds: 20));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is Map && body['success'] == false) {
        throw Exception(body['message'] ?? 'Terjadi kesalahan pada server');
      }
      return body is Map ? body['data'] : body;
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
