import 'dart:io';
import 'dart:math';

void main() {
  final propTypes = ['PropertyType.kos', 'PropertyType.kontrakan'];
  final genders = ['RoomGender.mixed', 'RoomGender.male', 'RoomGender.female'];
  final statuses = ['RoomStatus.tersedia', 'RoomStatus.penuh'];
  final areas = ['Karawang Kota', 'Cikampek', 'Teluk Jambe', 'Rengasdengklok', 'Ciampel', 'Klari', 'Majalaya'];
  final facilitiesPool = ['Wi-Fi', 'AC', 'Kamar Mandi Dalam', 'Parkir Motor', 'Dapur Bersama', 'Laundry', 'CCTV', 'TV Bersama', 'Air PAM', 'Listrik PLN', 'Parkir Mobil', 'Taman', 'Spring Bed', 'Lemari'];
  final owners = [['mitra-1', 'Pak Hendra'], ['mitra-2', 'Bu Ratna'], ['admin-1', 'Admin Ngekos.in']];
  final images = [
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
      'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800',
      'https://images.unsplash.com/photo-1560448204-e02f11c45781?w=800',
      'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800',
      'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800',
      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
      'https://images.unsplash.com/photo-1502005229762-cf1b2da7c5d6?w=800',
      'https://images.unsplash.com/photo-1631049552057-403cdb8f0658?w=800',
      'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800',
      'https://images.unsplash.com/photo-1502005097973-6a7082348e28?w=800'
  ];
  final names = ['Kos Mawar', 'Kontrakan Sejati', 'Kos Bintang', 'Kos Nusantara', 'Kontrakan Amanah', 'Kos Anggrek', 'Kos Mahasiswa', 'Kontrakan Family', 'Kos Elite', 'Kos Asri', 'Kos Nyaman', 'Kontrakan Minimalis', 'Kos Murah', 'Kos VIP', 'Kontrakan Mewah', 'Kos Hijau', 'Kos Sentosa', 'Kontrakan Berkah', 'Kos Pelangi', 'Kos Harapan'];

  final rnd = Random();
  String result = '';
  
  for (int i = 7; i <= 30; i++) {
    final name = '${names[rnd.nextInt(names.length)]} ${areas[rnd.nextInt(areas.length)]} $i';
    final ptype = propTypes[rnd.nextInt(propTypes.length)];
    final gender = genders[rnd.nextInt(genders.length)];
    final status = rnd.nextDouble() > 0.7 ? statuses[1] : statuses[0]; // 70% tersedia
    final price = [800000, 1000000, 1200000, 1500000, 2000000, 2500000][rnd.nextInt(6)];
    
    final imgCount = rnd.nextInt(3) + 1;
    final imgUrls = <String>[];
    for (int j = 0; j < imgCount; j++) {
      imgUrls.add(images[rnd.nextInt(images.length)]);
    }
    
    final facCount = rnd.nextInt(5) + 3;
    final facs = <String>{};
    for (int j = 0; j < facCount; j++) {
      facs.add(facilitiesPool[rnd.nextInt(facilitiesPool.length)]);
    }
    
    final area = areas[rnd.nextInt(areas.length)];
    final address = 'Jl. Random No. $i, $area, Karawang';
    final lat = -6.3 + (rnd.nextDouble() * 0.2 - 0.1);
    final lon = 107.3 + (rnd.nextDouble() * 0.2 - 0.1);
    final owner = owners[rnd.nextInt(owners.length)];
    
    final isDp = rnd.nextBool();
    final dpAmt = isDp ? price / 2 : 0;
    final isCicil = rnd.nextBool();
    final maxT = isCicil ? [2, 3, 6][rnd.nextInt(3)] : 0;
    
    final imgStr = imgUrls.map((u) => "'$u'").join(', ');
    final facStr = facs.map((f) => "'$f'").join(', ');
    
    result += '''
    Property(
      id: 'prop-$i',
      name: '$name',
      description: 'Hunian nyaman dengan fasilitas memadai di kawasan strategis. Sangat cocok untuk mahasiswa maupun pekerja kantoran.',
      type: $ptype,
      roomGender: $gender,
      status: $status,
      pricePerMonth: $price.0,
      imageUrls: [$imgStr],
      facilities: [$facStr],
      area: '$area',
      fullAddress: '$address',
      latitude: $lat,
      longitude: $lon,
      ownerId: '${owner[0]}',
      ownerName: '${owner[1]}',
      isDpEnabled: $isDp,
      dpAmount: $dpAmt,
      isCicilanEnabled: $isCicil,
      maxTermin: $maxT,
    ),
''';
  }
  
  File('dummy.txt').writeAsStringSync(result);
}
