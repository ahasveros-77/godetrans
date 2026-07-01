/**
 * =========================================================================
 *  GODETRANS - BACKEND API (Google Apps Script + Google Sheets)
 * =========================================================================
 *  Cara pakai:
 *  1. Buat Google Sheet baru, beri nama "GodeTrans Database".
 *  2. Buka menu Extensions > Apps Script di Google Sheet tersebut.
 *  3. Hapus semua isi file Code.gs default, lalu copy-paste SELURUH isi
 *     file ini ke sana.
 *  4. Jalankan fungsi "setupSheets" sekali (pilih dari dropdown function,
 *     lalu klik Run) untuk membuat semua sheet & header secara otomatis.
 *  5. Klik Deploy > New deployment > pilih jenis "Web app".
 *     - Execute as: Me
 *     - Who has access: Anyone
 *  6. Copy URL yang diberikan (.../exec), lalu tempel ke
 *     lib/services/sheets_api_service.dart pada variabel baseUrl.
 *
 *  Detail lengkap ada di README.md proyek Flutter.
 * =========================================================================
 */

const SHEET_USERS = 'Users';
const SHEET_RUTE = 'RutePopuler';
const SHEET_JADWAL = 'Jadwal';
const SHEET_ARMADA = 'Armada';
const SHEET_KURSI = 'Kursi';
const SHEET_BOOKING = 'Booking';

/** =========================================================
 *  SETUP AWAL - jalankan SEKALI saja secara manual dari editor
 *  ========================================================= */
function setupSheets() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();

  createSheetIfNotExists(ss, SHEET_USERS,
    ['id', 'nama', 'email', 'password', 'no_hp', 'role', 'created_at']);

  createSheetIfNotExists(ss, SHEET_RUTE,
    ['id', 'asal', 'tujuan', 'jam_berangkat', 'kursi_tersedia', 'harga']);

  createSheetIfNotExists(ss, SHEET_JADWAL,
    ['id', 'asal', 'tujuan', 'jam', 'kursi_tersedia']);

  createSheetIfNotExists(ss, SHEET_ARMADA,
    ['id', 'asal', 'tujuan', 'jam', 'nama', 'jumlah_kursi', 'harga', 'status']);

  createSheetIfNotExists(ss, SHEET_KURSI,
    ['id', 'armada_id', 'tanggal', 'jam', 'no_kursi', 'status']);

  createSheetIfNotExists(ss, SHEET_BOOKING,
    ['id', 'user_id', 'asal', 'tujuan', 'tanggal_berangkat', 'jam_berangkat',
     'armada_id', 'armada_nama', 'nama_penumpang', 'kursi', 'jumlah_penumpang',
     'harga_tiket', 'biaya_layanan', 'total_bayar', 'status', 'created_at']);

  // Contoh data awal supaya aplikasi langsung bisa dicoba.
  seedSampleData(ss);

  SpreadsheetApp.getUi().alert('Setup selesai! Semua sheet & contoh data sudah dibuat.');
}

function createSheetIfNotExists(ss, name, headers) {
  let sheet = ss.getSheetByName(name);
  if (!sheet) {
    sheet = ss.insertSheet(name);
  }
  if (sheet.getRange(1, 1).getValue() === '') {
    sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
    sheet.setFrozenRows(1);
  }
  return sheet;
}

function seedSampleData(ss) {
  const ruteSheet = ss.getSheetByName(SHEET_RUTE);
  if (ruteSheet.getLastRow() < 2) {
    ruteSheet.getRange(2, 1, 2, 6).setValues([
      ['R1', 'Terminal Bekasi', 'Terminal Karawang', '08:00', 4, 75000],
      ['R2', 'Terminal Karawang', 'Terminal Bekasi', '16:00', 3, 75000],
    ]);
  }

  const armadaSheet = ss.getSheetByName(SHEET_ARMADA);
  if (armadaSheet.getLastRow() < 2) {
    armadaSheet.getRange(2, 1, 4, 8).setValues([
      ['A1', 'Terminal Bekasi', 'Terminal Karawang', '08:00', 'Hiace A', 4, 60000, 'Tersedia'],
      ['A2', 'Terminal Bekasi', 'Terminal Karawang', '08:00', 'Hiace B', 6, 75000, 'Tersedia'],
      ['A3', 'Terminal Bekasi', 'Terminal Karawang', '08:00', 'Hiace C', 12, 85000, 'Tersedia'],
      ['A4', 'Terminal Bekasi', 'Terminal Karawang', '08:00', 'Hiace D', 16, 95000, 'Tersedia'],
    ]);
  }

  const usersSheet = ss.getSheetByName(SHEET_USERS);
  if (usersSheet.getLastRow() < 2) {
    usersSheet.getRange(2, 1, 2, 7).setValues([
      ['U_ADMIN', 'Admin', 'admin@godetrans.local', 'admin123', '081234567890', 'admin', new Date().toISOString()],
      ['U_USER', 'Demo User', 'user@example.com', 'user123', '081111111111', 'user', new Date().toISOString()]
    ]);
  }
}

/** =========================================================
 *  ENTRY POINT - GET & POST
 *  ========================================================= */
function doGet(e) {
  try {
    const action = e.parameter.action;
    let data;

    switch (action) {
      case 'getRutePopuler':
        data = getRutePopuler();
        break;
      case 'getJadwal':
        data = getJadwal(e.parameter.asal, e.parameter.tujuan, e.parameter.tanggal);
        break;
      case 'getArmada':
        data = getArmada(e.parameter.asal, e.parameter.tujuan, e.parameter.jam);
        break;
      case 'getKursi':
        data = getKursi(e.parameter.armada_id, e.parameter.tanggal, e.parameter.jam);
        break;
      case 'getTiketSaya':
        data = getTiketSaya(e.parameter.user_id);
        break;
      case 'getAllBookings':
        data = getAllBookings();
        break;
      case 'getAllJadwal':
        data = getAllJadwal();
        break;
      default:
        return jsonResponse({ success: false, message: 'Action tidak dikenali: ' + action });
    }

    return jsonResponse({ success: true, data: data });
  } catch (err) {
    return jsonResponse({ success: false, message: err.message });
  }
}

function doPost(e) {
  try {
    const body = JSON.parse(e.postData.contents);
    const action = body.action;
    const payload = body.data;
    let data;

    switch (action) {
      case 'register':
        data = registerUser(payload);
        break;
      case 'login':
        data = loginUser(payload);
        break;
      case 'createBooking':
        data = createBooking(payload);
        break;
      case 'updateBookingStatus':
        data = updateBookingStatus(payload);
        break;
      case 'cancelBooking':
        data = cancelBooking(payload);
        break;
      case 'addRute':
        data = addRute(payload);
        break;
      case 'updateRute':
        data = updateRute(payload);
        break;
      case 'deleteRute':
        data = deleteRute(payload);
        break;
      case 'addJadwal':
        data = addJadwal(payload);
        break;
      case 'updateJadwal':
        data = updateJadwal(payload);
        break;
      case 'deleteJadwal':
        data = deleteJadwal(payload);
        break;
      default:
        return jsonResponse({ success: false, message: 'Action tidak dikenali: ' + action });
    }

    return jsonResponse({ success: true, data: data });
  } catch (err) {
    return jsonResponse({ success: false, message: err.message });
  }
}

function jsonResponse(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}

/** =========================================================
 *  HELPER: baca sheet jadi array of object
 *  ========================================================= */
function sheetToObjects(sheetName) {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(sheetName);
  const range = sheet.getDataRange().getValues();
  const headers = range[0];
  const rows = range.slice(1);
  return rows
    .filter(row => row.some(cell => cell !== ''))
    .map(row => {
      const obj = {};
      headers.forEach((h, i) => { obj[h] = row[i]; });
      return obj;
    });
}

function getSheet(name) {
  return SpreadsheetApp.getActiveSpreadsheet().getSheetByName(name);
}

/** =========================================================
 *  AUTH
 *  ========================================================= */
function registerUser(payload) {
  const sheet = getSheet(SHEET_USERS);
  const users = sheetToObjects(SHEET_USERS);

  const existing = users.find(u => u.email === payload.email);
  if (existing) {
    throw new Error('Email sudah terdaftar, silakan login.');
  }

  const id = 'U' + new Date().getTime();
  const createdAt = new Date().toISOString();
  // Default role untuk registrasi biasa adalah 'user'
  sheet.appendRow([id, payload.nama, payload.email, payload.password, payload.no_hp, 'user', createdAt]);

  return { id: id, nama: payload.nama, email: payload.email, no_hp: payload.no_hp, role: 'user' };
}

function loginUser(payload) {
  const users = sheetToObjects(SHEET_USERS);
  const user = users.find(u => u.email === payload.email && String(u.password) === String(payload.password));

  if (!user) {
    throw new Error('Email atau kata sandi salah.');
  }

  return { id: user.id, nama: user.nama, email: user.email, no_hp: user.no_hp, role: user.role };
}

/** =========================================================
 *  RUTE / JADWAL / ARMADA / KURSI
 *  ========================================================= */
function getRutePopuler() {
  return sheetToObjects(SHEET_RUTE);
}

function getJadwal(asal, tujuan, tanggal) {
  // Jika sheet Jadwal kosong/tidak dipakai, fallback ke jam standar.
  const jadwalRows = sheetToObjects(SHEET_JADWAL).filter(j =>
    (!asal || j.asal === asal) && (!tujuan || j.tujuan === tujuan)
  );

  if (jadwalRows.length > 0) {
    return jadwalRows.map(j => ({ jam: j.jam, kursi_tersedia: j.kursi_tersedia }));
  }

  // Fallback default
  const jamDefault = ['06:00','08:00','10:00','12:00','14:00','16:00','18:00','20:00'];
  return jamDefault.map(jam => ({ jam: jam, kursi_tersedia: 4 }));
}

function getAllJadwal() {
  return sheetToObjects(SHEET_JADWAL);
}

function addRute(payload) {
  const sheet = getSheet(SHEET_RUTE);
  const id = 'R' + new Date().getTime();
  sheet.appendRow([
    id,
    payload.asal,
    payload.tujuan,
    payload.jam_berangkat,
    payload.kursi_tersedia,
    payload.harga,
  ]);
  return { id: id, ...payload };
}

function addJadwal(payload) {
  const sheet = getSheet(SHEET_JADWAL);
  const id = 'J' + new Date().getTime();
  sheet.appendRow([
    id,
    payload.asal,
    payload.tujuan,
    payload.jam,
    payload.kursi_tersedia,
  ]);
  return { id: id, ...payload };
}

function getArmada(asal, tujuan, jam) {
  const armada = sheetToObjects(SHEET_ARMADA).filter(a =>
    (!asal || a.asal === asal) && (!tujuan || a.tujuan === tujuan) && (!jam || a.jam === jam)
  );
  return armada.map(a => ({
    id: a.id,
    nama: a.nama,
    jumlah_kursi: a.jumlah_kursi,
    harga: a.harga,
    status: a.status,
  }));
}

function getKursi(armadaId, tanggal, jam) {
  const kursi = sheetToObjects(SHEET_KURSI).filter(k =>
    k.armada_id === armadaId && k.tanggal === tanggal && k.jam === jam
  );
  return kursi.map(k => ({ no_kursi: k.no_kursi, status: k.status }));
}

/** =========================================================
 *  BOOKING
 *  ========================================================= */
function createBooking(payload) {
  const sheet = getSheet(SHEET_BOOKING);

  sheet.appendRow([
    payload.id,
    payload.user_id,
    payload.asal,
    payload.tujuan,
    payload.tanggal_berangkat,
    payload.jam_berangkat,
    payload.armada_id,
    payload.armada_nama,
    payload.nama_penumpang,
    payload.kursi,
    payload.jumlah_penumpang,
    payload.harga_tiket,
    payload.biaya_layanan,
    payload.total_bayar,
    payload.status,
    payload.created_at,
  ]);

  // Tandai kursi yang dipesan sebagai "Terisi" di sheet Kursi.
  markKursiTerisi(payload);

  return payload;
}

function markKursiTerisi(payload) {
  const kursiSheet = getSheet(SHEET_KURSI);
  const kursiList = String(payload.kursi).split(',').map(s => s.trim());
  const tanggal = payload.tanggal_berangkat;
  const jam = payload.jam_berangkat;

  kursiList.forEach(noKursi => {
    kursiSheet.appendRow(['K' + new Date().getTime() + noKursi, payload.armada_id || '', tanggal, jam, noKursi, 'Terisi']);
  });
}

function getTiketSaya(userId) {
  const bookings = sheetToObjects(SHEET_BOOKING).filter(b => b.user_id === userId);
  return bookings.map(b => ({
    id: b.id,
    user_id: b.user_id,
    asal: b.asal,
    tujuan: b.tujuan,
    tanggal_berangkat: b.tanggal_berangkat,
    jam_berangkat: b.jam_berangkat,
    armada_id: b.armada_id,
    armada_nama: b.armada_nama,
    nama_penumpang: b.nama_penumpang,
    kursi: b.kursi,
    harga_tiket: b.harga_tiket,
    biaya_layanan: b.biaya_layanan,
    total_bayar: b.total_bayar,
    status: b.status,
    created_at: b.created_at,
  }));
}

/** Admin: ambil semua booking (untuk dashboard admin) */
function getAllBookings() {
  return sheetToObjects(SHEET_BOOKING);
}

/** Admin: update status booking berdasarkan id */
function updateBookingStatus(payload) {
  const sheet = getSheet(SHEET_BOOKING);
  const values = sheet.getDataRange().getValues();

  // header di row 0, data mulai row index 1
  for (let i = 1; i < values.length; i++) {
    const row = values[i];
    if (String(row[0]) === String(payload.id)) {
      // kolom status adalah kolom ke-15 (1-based index)
      sheet.getRange(i + 1, 15).setValue(payload.status);
      return { id: payload.id, status: payload.status };
    }
  }

  throw new Error('Booking tidak ditemukan: ' + payload.id);
}

/** Admin: batalkan booking (hapus dari sheet) */
function cancelBooking(payload) {
  const sheet = getSheet(SHEET_BOOKING);
  const values = sheet.getDataRange().getValues();

  for (let i = 1; i < values.length; i++) {
    const row = values[i];
    if (String(row[0]) === String(payload.id)) {
      sheet.deleteRow(i + 1);
      return { success: true, id: payload.id };
    }
  }
  throw new Error('Booking tidak ditemukan: ' + payload.id);
}

/** Admin: update rute berdasarkan id */
function updateRute(payload) {
  const sheet = getSheet(SHEET_RUTE);
  const values = sheet.getDataRange().getValues();

  for (let i = 1; i < values.length; i++) {
    const row = values[i];
    if (String(row[0]) === String(payload.id)) {
      sheet.getRange(i + 1, 2).setValue(payload.asal);
      sheet.getRange(i + 1, 3).setValue(payload.tujuan);
      sheet.getRange(i + 1, 4).setValue(payload.jam_berangkat);
      sheet.getRange(i + 1, 5).setValue(payload.kursi_tersedia);
      sheet.getRange(i + 1, 6).setValue(payload.harga);
      return { id: payload.id, ...payload };
    }
  }
  throw new Error('Rute tidak ditemukan: ' + payload.id);
}

/** Admin: hapus rute berdasarkan id */
function deleteRute(payload) {
  const sheet = getSheet(SHEET_RUTE);
  const values = sheet.getDataRange().getValues();

  for (let i = 1; i < values.length; i++) {
    const row = values[i];
    if (String(row[0]) === String(payload.id)) {
      sheet.deleteRow(i + 1);
      return { success: true, id: payload.id };
    }
  }
  throw new Error('Rute tidak ditemukan: ' + payload.id);
}

/** Admin: update jadwal berdasarkan id */
function updateJadwal(payload) {
  const sheet = getSheet(SHEET_JADWAL);
  const values = sheet.getDataRange().getValues();

  for (let i = 1; i < values.length; i++) {
    const row = values[i];
    if (String(row[0]) === String(payload.id)) {
      sheet.getRange(i + 1, 2).setValue(payload.asal);
      sheet.getRange(i + 1, 3).setValue(payload.tujuan);
      sheet.getRange(i + 1, 4).setValue(payload.jam);
      sheet.getRange(i + 1, 5).setValue(payload.kursi_tersedia);
      return { id: payload.id, ...payload };
    }
  }
  throw new Error('Jadwal tidak ditemukan: ' + payload.id);
}

/** Admin: hapus jadwal berdasarkan id */
function deleteJadwal(payload) {
  const sheet = getSheet(SHEET_JADWAL);
  const values = sheet.getDataRange().getValues();

  for (let i = 1; i < values.length; i++) {
    const row = values[i];
    if (String(row[0]) === String(payload.id)) {
      sheet.deleteRow(i + 1);
      return { success: true, id: payload.id };
    }
  }
  throw new Error('Jadwal tidak ditemukan: ' + payload.id);
}
