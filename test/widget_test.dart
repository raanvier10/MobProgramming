import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ngekosin/core/data/models.dart';
import 'package:ngekosin/core/di/app_state.dart';
import 'package:ngekosin/features/property/presentation/pages/property_detail_page.dart';

void main() {
  test('normalizePhoneNumber memformat nomor telepon secara aman', () {
    expect(normalizePhoneNumber('081234567890'), '+6281234567890');
    expect(normalizePhoneNumber('+6281234567890'), '+6281234567890');
  });

  test(
      'mitraTotalRevenue menghitung transaksi cicilan yang sudah lunas secara penuh',
      () {
    final state = AppState();
    state.register('Pemilik', 'owner@example.com', '081234567890', '123456');

    final property = Property(
      id: 'prop-test',
      name: 'Kos Test',
      description: 'desc',
      type: PropertyType.kos,
      roomGender: RoomGender.mixed,
      status: RoomStatus.tersedia,
      pricePerMonth: 1000000,
      imageUrls: const [],
      facilities: const [],
      area: 'Karawang',
      fullAddress: 'Jl. Test',
      latitude: -6.3,
      longitude: 107.3,
      ownerId: state.currentUser!.id,
      ownerName: state.currentUser!.name,
      ownerPhone: '081234567890',
      maxTermin: 2,
    );
    state.addProperty(property);

    final transaction = state.createTransaction(
      property: property,
      checkInDate: DateTime.now(),
      durationMonths: 1,
      scheme: PaymentScheme.cicilan,
      method: PaymentMethod.qris,
    );
    transaction.paidTermin = 2;

    expect(state.mitraTotalRevenue, 1000000.0);
  });

  testWidgets('menampilkan nomor telepon pemilik di halaman detail properti',
      (WidgetTester tester) async {
    final property = Property(
      id: 'prop-1',
      name: 'Kos Harmoni',
      description: 'Kamar nyaman',
      type: PropertyType.kos,
      roomGender: RoomGender.mixed,
      status: RoomStatus.tersedia,
      pricePerMonth: 1200000,
      imageUrls: const [],
      facilities: const ['Wi-Fi'],
      area: 'Karawang',
      fullAddress: 'Jl. Merdeka No. 1',
      latitude: -6.3021,
      longitude: 107.3010,
      ownerId: 'owner-1',
      ownerName: 'Pak Budi',
      ownerPhone: '081234567890',
    );

    final appState = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => appState,
        child: MaterialApp(
          home: PropertyDetailPage(property: property),
        ),
      ),
    );

    expect(find.textContaining('Pak Budi'), findsOneWidget);
    expect(find.textContaining('081234567890'), findsOneWidget);
  });
}
