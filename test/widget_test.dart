import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noto_app/main.dart'; // ganti jika nama project berbeda

void main() {
  testWidgets('Tampilan awal HomePage menampilkan catatan dan tombol tambah', (
    WidgetTester tester,
  ) async {
    // Jalankan aplikasi
    await tester.pumpWidget(const MyApp());

    // Pastikan catatan dummy tampil (ganti text-nya jika perlu)
    expect(find.text('Belajar Flutter'), findsOneWidget);
    expect(find.text('Rancang UI aplikasi Noto'), findsOneWidget);

    // Cek tombol navigasi icon tambah
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Navigasi ke halaman tambah catatan
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Cek keberadaan field input dan tombol simpan
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);

    // Simulasi isi dan simpan catatan
    await tester.enterText(find.byType(TextField), 'Catatan dari test');
    await tester.tap(find.text('Simpan'));
    await tester.pump(); // jalankan semua aksi async

    // Cek snackbar muncul
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Catatan disimpan!'), findsOneWidget);
  });
}
