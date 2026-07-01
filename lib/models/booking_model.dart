import 'penumpang_model.dart';

class BookingModel {
  final String id; // Kode booking, contoh GDT2007200820
  final String userId;
  final String asal;
  final String tujuan;
  final String tanggalBerangkat;
  final String jamBerangkat;
  final String armadaId;
  final String armadaNama;
  final List<PenumpangModel> penumpang;
  final List<String> kursi;
  final double hargaTiket; // per kursi
  final double biayaLayanan;
  final double totalBayar;
  final String status; // Akan Berangkat / Selesai / Menunggu Pembayaran
  final String createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.asal,
    required this.tujuan,
    required this.tanggalBerangkat,
    required this.jamBerangkat,
    required this.armadaId,
    required this.armadaNama,
    required this.penumpang,
    required this.kursi,
    required this.hargaTiket,
    required this.biayaLayanan,
    required this.totalBayar,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'asal': asal,
      'tujuan': tujuan,
      'tanggal_berangkat': tanggalBerangkat,
      'jam_berangkat': jamBerangkat,
      'armada_id': armadaId,
      'armada_nama': armadaNama,
      'nama_penumpang': penumpang.map((p) => p.namaLengkap).join(', '),
      'kursi': kursi.join(', '),
      'jumlah_penumpang': penumpang.length,
      'harga_tiket': hargaTiket,
      'biaya_layanan': biayaLayanan,
      'total_bayar': totalBayar,
      'status': status,
      'created_at': createdAt,
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      asal: json['asal']?.toString() ?? '',
      tujuan: json['tujuan']?.toString() ?? '',
      tanggalBerangkat: json['tanggal_berangkat']?.toString() ?? '',
      jamBerangkat: json['jam_berangkat']?.toString() ?? '',
      armadaId: json['armada_id']?.toString() ?? '',
      armadaNama: json['armada_nama']?.toString() ?? '',
      penumpang: (json['nama_penumpang']?.toString() ?? '')
          .split(',')
          .where((e) => e.trim().isNotEmpty)
          .map((nama) => PenumpangModel(
                namaLengkap: nama.trim(),
                noHp: '',
                jenisKelamin: '',
                noKursi: '',
              ))
          .toList(),
      kursi: (json['kursi']?.toString() ?? '')
          .split(',')
          .where((e) => e.trim().isNotEmpty)
          .map((e) => e.trim())
          .toList(),
      hargaTiket: double.tryParse(json['harga_tiket']?.toString() ?? '0') ?? 0,
      biayaLayanan:
          double.tryParse(json['biaya_layanan']?.toString() ?? '0') ?? 0,
      totalBayar: double.tryParse(json['total_bayar']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'Akan Berangkat',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
