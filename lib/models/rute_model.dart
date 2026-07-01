class RuteModel {
  final String id;
  final String asal;
  final String tujuan;
  final String jamBerangkat;
  final int kursiTersedia;
  final double harga;

  RuteModel({
    required this.id,
    required this.asal,
    required this.tujuan,
    required this.jamBerangkat,
    required this.kursiTersedia,
    required this.harga,
  });

  factory RuteModel.fromJson(Map<String, dynamic> json) {
    return RuteModel(
      id: json['id']?.toString() ?? '',
      asal: json['asal']?.toString() ?? '',
      tujuan: json['tujuan']?.toString() ?? '',
      jamBerangkat: json['jam_berangkat']?.toString() ?? '',
      kursiTersedia: int.tryParse(json['kursi_tersedia']?.toString() ?? '0') ?? 0,
      harga: double.tryParse(json['harga']?.toString() ?? '0') ?? 0,
    );
  }
}
