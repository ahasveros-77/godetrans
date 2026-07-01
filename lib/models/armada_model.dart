class ArmadaModel {
  final String id;
  final String nama; // Hiace A, Hiace B, dst
  final int jumlahKursi;
  final double harga;
  final String status; // Tersedia / Penuh

  ArmadaModel({
    required this.id,
    required this.nama,
    required this.jumlahKursi,
    required this.harga,
    required this.status,
  });

  factory ArmadaModel.fromJson(Map<String, dynamic> json) {
    return ArmadaModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      jumlahKursi: int.tryParse(json['jumlah_kursi']?.toString() ?? '0') ?? 0,
      harga: double.tryParse(json['harga']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'Tersedia',
    );
  }
}
