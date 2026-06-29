import random
import json

prop_types = ['PropertyType.kos', 'PropertyType.kontrakan']
genders = ['RoomGender.mixed', 'RoomGender.male', 'RoomGender.female']
statuses = ['RoomStatus.tersedia', 'RoomStatus.penuh']
areas = ['Karawang Kota', 'Cikampek', 'Teluk Jambe', 'Rengasdengklok', 'Ciampel', 'Klari', 'Majalaya']
facilities_pool = ['Wi-Fi', 'AC', 'Kamar Mandi Dalam', 'Parkir Motor', 'Dapur Bersama', 'Laundry', 'CCTV', 'TV Bersama', 'Air PAM', 'Listrik PLN', 'Parkir Mobil', 'Taman', 'Spring Bed', 'Lemari']
owners = [('mitra-1', 'Pak Hendra'), ('mitra-2', 'Bu Ratna'), ('admin-1', 'Admin Ngekos.in')]
images = [
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
]

names = ['Kos Mawar', 'Kontrakan Sejati', 'Kos Bintang', 'Kos Nusantara', 'Kontrakan Amanah', 'Kos Anggrek', 'Kos Mahasiswa', 'Kontrakan Family', 'Kos Elite', 'Kos Asri', 'Kos Nyaman', 'Kontrakan Minimalis', 'Kos Murah', 'Kos VIP', 'Kontrakan Mewah', 'Kos Hijau', 'Kos Sentosa', 'Kontrakan Berkah', 'Kos Pelangi', 'Kos Harapan']

result = ''
for i in range(7, 31):
    name = random.choice(names) + ' ' + random.choice(areas) + ' ' + str(i)
    ptype = random.choice(prop_types)
    gender = random.choice(genders)
    status = random.choices(statuses, weights=[0.7, 0.3])[0]
    price = random.choice([800000, 1000000, 1200000, 1500000, 2000000, 2500000])
    img_urls = random.sample(images, random.randint(1, 3))
    facs = random.sample(facilities_pool, random.randint(3, 7))
    area = random.choice(areas)
    address = f'Jl. Random No. {i}, {area}, Karawang'
    lat = -6.3 + random.uniform(-0.1, 0.1)
    lon = 107.3 + random.uniform(-0.1, 0.1)
    owner = random.choice(owners)
    is_dp = random.choice(['true', 'false'])
    dp_amt = price // 2 if is_dp == 'true' else 0
    is_cicil = random.choice(['true', 'false'])
    max_t = random.choice([2, 3, 6]) if is_cicil == 'true' else 0
    
    img_str = ', '.join([f"'{u}'" for u in img_urls])
    fac_str = ', '.join([f"'{f}'" for f in facs])
    
    block = f"""    Property(
      id: 'prop-{i}',
      name: '{name}',
      description: 'Hunian nyaman dengan fasilitas memadai di kawasan strategis. Sangat cocok untuk mahasiswa maupun pekerja kantoran.',
      type: {ptype},
      roomGender: {gender},
      status: {status},
      pricePerMonth: {price}.0,
      imageUrls: [{img_str}],
      facilities: [{fac_str}],
      area: '{area}',
      fullAddress: '{address}',
      latitude: {lat:.4f},
      longitude: {lon:.4f},
      ownerId: '{owner[0]}',
      ownerName: '{owner[1]}',
      isDpEnabled: {is_dp},
      dpAmount: {dp_amt}.0,
      isCicilanEnabled: {is_cicil},
      maxTermin: {max_t},
    ),
"""
    result += block

with open('dummy.txt', 'w') as f:
    f.write(result)
print('Done!')
