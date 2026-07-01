class PenumpangModel {
  String namaLengkap;
  String noHp;
  String jenisKelamin;
  String noKursi;

  PenumpangModel({
    required this.namaLengkap,
    required this.noHp,
    required this.jenisKelamin,
    required this.noKursi,
  });

  Map<String, dynamic> toJson() {
    return {
      'nama_lengkap': namaLengkap,
      'no_hp': noHp,
      'jenis_kelamin': jenisKelamin,
      'no_kursi': noKursi,
    };
  }
}
