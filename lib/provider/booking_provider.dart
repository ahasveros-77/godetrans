import 'package:flutter/foundation.dart';
import '../models/armada_model.dart';
import '../models/penumpang_model.dart';

class BookingProvider extends ChangeNotifier {
  String asal = 'Terminal Bekasi';
  String tujuan = 'Terminal Karawang';
  DateTime tanggalBerangkat = DateTime.now();
  int jumlahPenumpang = 1;

  String? jamBerangkat;
  ArmadaModel? armadaTerpilih;
  List<String> kursiTerpilih = [];
  List<PenumpangModel> dataPenumpang = [];

  void setRute({required String asal, required String tujuan}) {
    this.asal = asal;
    this.tujuan = tujuan;
    notifyListeners();
  }

  void setTanggal(DateTime tanggal) {
    tanggalBerangkat = tanggal;
    notifyListeners();
  }

  void setJumlahPenumpang(int jumlah) {
    jumlahPenumpang = jumlah;
    notifyListeners();
  }

  void setJadwal(String jam) {
    jamBerangkat = jam;
    notifyListeners();
  }

  void setArmada(ArmadaModel armada) {
    armadaTerpilih = armada;
    kursiTerpilih = [];
    notifyListeners();
  }

  void toggleKursi(String noKursi) {
    if (kursiTerpilih.contains(noKursi)) {
      kursiTerpilih.remove(noKursi);
    } else {
      if (kursiTerpilih.length < jumlahPenumpang) {
        kursiTerpilih.add(noKursi);
      }
    }
    notifyListeners();
  }

  void setDataPenumpang(List<PenumpangModel> data) {
    dataPenumpang = data;
    notifyListeners();
  }

  double get hargaTiket => armadaTerpilih?.harga ?? 0;
  double get biayaLayanan => 5000;
  double get totalBayar =>
      (hargaTiket * kursiTerpilih.length) + biayaLayanan;

  /// Reset semua state setelah booking berhasil dibuat, agar siap untuk
  /// pemesanan baru selanjutnya.
  void reset() {
    jamBerangkat = null;
    armadaTerpilih = null;
    kursiTerpilih = [];
    dataPenumpang = [];
    jumlahPenumpang = 1;
    notifyListeners();
  }
}
