import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum LandmarkCategory {
  shoppingMall,
  hospital,
}

class PastoParkingLot {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double pricePerHour;
  final int carSpaces;
  final int motoSpaces;
  final int distanceMeters;
  final double rating;
  final String openingHours;
  final bool isCovered;
  final bool hasSecurity;
  final bool hasCharging;
  final String landmarkId;

  const PastoParkingLot({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.pricePerHour,
    required this.carSpaces,
    required this.motoSpaces,
    required this.distanceMeters,
    this.rating = 4.8,
    this.openingHours = '6:00 AM - 10:00 PM',
    this.isCovered = true,
    this.hasSecurity = true,
    this.hasCharging = false,
    required this.landmarkId,
  });

  int get totalSpaces => carSpaces + motoSpaces;
  String get formattedPrice => '\$${pricePerHour.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} COP/h';
}

class Landmark {
  final String id;
  final String name;
  final String shortName;
  final LandmarkCategory category;
  final String address;
  final double latitude;
  final double longitude;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String badgeText;
  final List<PastoParkingLot> nearbyParkingLots;

  const Landmark({
    required this.id,
    required this.name,
    required this.shortName,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.badgeText,
    required this.nearbyParkingLots,
  });
}

class PastoDataService {
  static const List<Landmark> landmarks = [
    // 1. Centro Comercial Unicentro
    Landmark(
      id: 'unicentro',
      name: 'Centro Comercial Unicentro',
      shortName: 'Unicentro',
      category: LandmarkCategory.shoppingMall,
      address: 'Av. Panamericana con Calle 11, Pasto',
      latitude: 1.2241,
      longitude: -77.2908,
      description: 'Principal centro comercial del norte de Pasto con salas de cine, plazoleta y almacenes de cadena.',
      icon: Icons.shopping_bag_rounded,
      accentColor: AppColors.primary,
      badgeText: 'CENTRO COMERCIAL',
      nearbyParkingLots: [
        PastoParkingLot(
          id: 'pasto-unicentro-1',
          name: 'Parqueadero Unicentro Plaza',
          address: 'Av. Panamericana # 11-40',
          latitude: 1.2245,
          longitude: -77.2915,
          pricePerHour: 2500,
          carSpaces: 24,
          motoSpaces: 16,
          distanceMeters: 60,
          rating: 4.9,
          openingHours: '24 Horas',
          isCovered: true,
          hasSecurity: true,
          hasCharging: true,
          landmarkId: 'unicentro',
        ),
        PastoParkingLot(
          id: 'pasto-unicentro-2',
          name: 'Estacionamiento Los Álamos',
          address: 'Calle 12 # 35-15',
          latitude: 1.2235,
          longitude: -77.2898,
          pricePerHour: 2200,
          carSpaces: 14,
          motoSpaces: 10,
          distanceMeters: 130,
          rating: 4.7,
          openingHours: '6:30 AM - 9:30 PM',
          isCovered: true,
          hasSecurity: true,
          hasCharging: false,
          landmarkId: 'unicentro',
        ),
      ],
    ),

    // 2. Centro Comercial Único
    Landmark(
      id: 'unico',
      name: 'Centro Comercial Único Outlet',
      shortName: 'Único Outlet',
      category: LandmarkCategory.shoppingMall,
      address: 'Calle 22 con Carrera 6 / Panamericana Sur, Pasto',
      latitude: 1.2052,
      longitude: -77.2762,
      description: 'Centro comercial formato outlet con marcas líderes y amplia afluencia vehicular en el sur de Pasto.',
      icon: Icons.local_mall_rounded,
      accentColor: AppColors.primary,
      badgeText: 'CENTRO COMERCIAL',
      nearbyParkingLots: [
        PastoParkingLot(
          id: 'pasto-unico-1',
          name: 'Estacionamiento Único Outlet',
          address: 'Calle 22 # 6-30',
          latitude: 1.2056,
          longitude: -77.2758,
          pricePerHour: 2000,
          carSpaces: 35,
          motoSpaces: 25,
          distanceMeters: 45,
          rating: 4.8,
          openingHours: '8:00 AM - 10:00 PM',
          isCovered: true,
          hasSecurity: true,
          hasCharging: true,
          landmarkId: 'unico',
        ),
        PastoParkingLot(
          id: 'pasto-unico-2',
          name: 'Parqueadero Sur Panamericana',
          address: 'Carrera 6 # 21-80',
          latitude: 1.2048,
          longitude: -77.2770,
          pricePerHour: 1800,
          carSpaces: 16,
          motoSpaces: 12,
          distanceMeters: 120,
          rating: 4.6,
          openingHours: '6:00 AM - 9:00 PM',
          isCovered: false,
          hasSecurity: true,
          hasCharging: false,
          landmarkId: 'unico',
        ),
      ],
    ),

    // 3. Pasaje Nova Centro
    Landmark(
      id: 'novacentro',
      name: 'Pasaje Nova Centro',
      shortName: 'Nova Centro',
      category: LandmarkCategory.shoppingMall,
      address: 'Calle 19 # 25-06, Centro, Pasto',
      latitude: 1.2155,
      longitude: -77.2798,
      description: 'Tradicional galería comercial en el corazón financiero y comercial de San Juan de Pasto.',
      icon: Icons.storefront_rounded,
      accentColor: AppColors.primary,
      badgeText: 'PASAJE COMERCIAL',
      nearbyParkingLots: [
        PastoParkingLot(
          id: 'pasto-nova-1',
          name: 'Parqueadero Pasaje Nova',
          address: 'Calle 19 # 25-22',
          latitude: 1.2156,
          longitude: -77.2794,
          pricePerHour: 3000,
          carSpaces: 18,
          motoSpaces: 20,
          distanceMeters: 40,
          rating: 4.8,
          openingHours: '6:30 AM - 9:00 PM',
          isCovered: true,
          hasSecurity: true,
          hasCharging: false,
          landmarkId: 'novacentro',
        ),
        PastoParkingLot(
          id: 'pasto-nova-2',
          name: 'Parqueadero La Merced Centro',
          address: 'Carrera 25 # 19-30',
          latitude: 1.2160,
          longitude: -77.2804,
          pricePerHour: 2800,
          carSpaces: 15,
          motoSpaces: 14,
          distanceMeters: 80,
          rating: 4.7,
          openingHours: '7:00 AM - 8:30 PM',
          isCovered: true,
          hasSecurity: true,
          hasCharging: false,
          landmarkId: 'novacentro',
        ),
      ],
    ),

    // 4. Sebastián de Belalcázar
    Landmark(
      id: 'belalcazar',
      name: 'C.C. Sebastián de Belalcázar',
      shortName: 'Belalcázar',
      category: LandmarkCategory.shoppingMall,
      address: 'Calle 19 # 24-45 / Carrera 25, Centro Histórico',
      latitude: 1.2158,
      longitude: -77.2785,
      description: 'Centro comercial y empresarial icónico del centro histórico con más de 80 locales de moda y tecnología.',
      icon: Icons.apartment_rounded,
      accentColor: AppColors.primary,
      badgeText: 'CENTRO COMERCIAL',
      nearbyParkingLots: [
        PastoParkingLot(
          id: 'pasto-belalcazar-1',
          name: 'Parqueadero Plaza Belalcázar',
          address: 'Calle 19 # 24-60',
          latitude: 1.2159,
          longitude: -77.2782,
          pricePerHour: 3000,
          carSpaces: 20,
          motoSpaces: 15,
          distanceMeters: 30,
          rating: 4.9,
          openingHours: '24 Horas',
          isCovered: true,
          hasSecurity: true,
          hasCharging: true,
          landmarkId: 'belalcazar',
        ),
        PastoParkingLot(
          id: 'pasto-belalcazar-2',
          name: 'Estacionamiento San Juan Central',
          address: 'Calle 20 # 24-18',
          latitude: 1.2165,
          longitude: -77.2780,
          pricePerHour: 2800,
          carSpaces: 12,
          motoSpaces: 10,
          distanceMeters: 90,
          rating: 4.7,
          openingHours: '6:00 AM - 9:30 PM',
          isCovered: true,
          hasSecurity: true,
          hasCharging: false,
          landmarkId: 'belalcazar',
        ),
      ],
    ),

    // 5. Hospital Universitario Departamental de Nariño (HUDN)
    Landmark(
      id: 'hudn',
      name: 'Hospital Departamental de Nariño',
      shortName: 'HUDN',
      category: LandmarkCategory.hospital,
      address: 'Calle 22 # 7-93 / Parque Bolívar, Pasto',
      latitude: 1.2185,
      longitude: -77.2685,
      description: 'Hospital universitario de alta complejidad y centro de referencia hospitalaria en Nariño.',
      icon: Icons.local_hospital_rounded,
      accentColor: Color(0xFFFF3B30),
      badgeText: 'HOSPITAL UNIVERSITARIO',
      nearbyParkingLots: [
        PastoParkingLot(
          id: 'pasto-hudn-1',
          name: 'Parqueadero Departamental Salud',
          address: 'Calle 22 # 7-50',
          latitude: 1.2182,
          longitude: -77.2690,
          pricePerHour: 2500,
          carSpaces: 22,
          motoSpaces: 18,
          distanceMeters: 55,
          rating: 4.9,
          openingHours: '24 Horas',
          isCovered: true,
          hasSecurity: true,
          hasCharging: true,
          landmarkId: 'hudn',
        ),
        PastoParkingLot(
          id: 'pasto-hudn-2',
          name: 'Estacionamiento Bolívar HUDN',
          address: 'Carrera 7 # 21-80',
          latitude: 1.2190,
          longitude: -77.2678,
          pricePerHour: 2200,
          carSpaces: 15,
          motoSpaces: 10,
          distanceMeters: 95,
          rating: 4.6,
          openingHours: '24 Horas',
          isCovered: true,
          hasSecurity: true,
          hasCharging: false,
          landmarkId: 'hudn',
        ),
      ],
    ),

    // 6. Hospital San Pedro
    Landmark(
      id: 'san_pedro',
      name: 'Hospital San Pedro',
      shortName: 'Hospital San Pedro',
      category: LandmarkCategory.hospital,
      address: 'Carrera 44 # 18A-136, Pasto',
      latitude: 1.2295,
      longitude: -77.2935,
      description: 'Fundación Hospital San Pedro, referente en servicios especializados, oncología y urgencias.',
      icon: Icons.local_hospital_rounded,
      accentColor: Color(0xFFFF3B30),
      badgeText: 'HOSPITAL ESPECIALIZADO',
      nearbyParkingLots: [
        PastoParkingLot(
          id: 'pasto-sanpedro-1',
          name: 'Parqueadero San Pedro Urgencias',
          address: 'Carrera 44 # 18-50',
          latitude: 1.2290,
          longitude: -77.2940,
          pricePerHour: 3000,
          carSpaces: 25,
          motoSpaces: 20,
          distanceMeters: 60,
          rating: 4.9,
          openingHours: '24 Horas',
          isCovered: true,
          hasSecurity: true,
          hasCharging: true,
          landmarkId: 'san_pedro',
        ),
        PastoParkingLot(
          id: 'pasto-sanpedro-2',
          name: 'Estacionamiento Clínica del Norte',
          address: 'Calle 19 # 43-20',
          latitude: 1.2285,
          longitude: -77.2925,
          pricePerHour: 2800,
          carSpaces: 14,
          motoSpaces: 8,
          distanceMeters: 130,
          rating: 4.7,
          openingHours: '6:00 AM - 10:00 PM',
          isCovered: true,
          hasSecurity: true,
          hasCharging: false,
          landmarkId: 'san_pedro',
        ),
      ],
    ),

    // 7. Hospital Infantil Los Ángeles
    Landmark(
      id: 'infantil',
      name: 'Hospital Infantil Los Ángeles',
      shortName: 'Hospital Infantil',
      category: LandmarkCategory.hospital,
      address: 'Carrera 32 # 21A-08 / Av. Los Estudiantes, Pasto',
      latitude: 1.2225,
      longitude: -77.2875,
      description: 'Hospital pediátrico de referencia en el suroccidente colombiano en la zona estudiantil de Pasto.',
      icon: Icons.child_care_rounded,
      accentColor: Color(0xFFFF3B30),
      badgeText: 'HOSPITAL PEDIÁTRICO',
      nearbyParkingLots: [
        PastoParkingLot(
          id: 'pasto-infantil-1',
          name: 'Parqueadero Infantil Los Estudiantes',
          address: 'Carrera 32 # 21-40',
          latitude: 1.2220,
          longitude: -77.2870,
          pricePerHour: 2500,
          carSpaces: 18,
          motoSpaces: 15,
          distanceMeters: 50,
          rating: 4.9,
          openingHours: '24 Horas',
          isCovered: true,
          hasSecurity: true,
          hasCharging: false,
          landmarkId: 'infantil',
        ),
        PastoParkingLot(
          id: 'pasto-infantil-2',
          name: 'Estacionamiento Maridíaz Infantil',
          address: 'Calle 21 # 31-18',
          latitude: 1.2230,
          longitude: -77.2882,
          pricePerHour: 2400,
          carSpaces: 12,
          motoSpaces: 12,
          distanceMeters: 110,
          rating: 4.6,
          openingHours: '6:00 AM - 9:00 PM',
          isCovered: true,
          hasSecurity: true,
          hasCharging: false,
          landmarkId: 'infantil',
        ),
      ],
    ),

    // 8. Clínica Pasto
    Landmark(
      id: 'clinica_pasto',
      name: 'Clínica Pasto',
      shortName: 'Clínica Pasto',
      category: LandmarkCategory.hospital,
      address: 'Calle 16 # 29-67, Pasto',
      latitude: 1.2162,
      longitude: -77.2845,
      description: 'Centro hospitalario de tercer nivel ubicado estratégicamente en el sector Maridíaz de Pasto.',
      icon: Icons.local_hospital_rounded,
      accentColor: Color(0xFFFF3B30),
      badgeText: 'CLÍNICA PRIVADA',
      nearbyParkingLots: [
        PastoParkingLot(
          id: 'pasto-clinicapasto-1',
          name: 'Parqueadero Médica Pasto',
          address: 'Calle 16 # 29-30',
          latitude: 1.2165,
          longitude: -77.2840,
          pricePerHour: 3200,
          carSpaces: 14,
          motoSpaces: 10,
          distanceMeters: 45,
          rating: 4.8,
          openingHours: '24 Horas',
          isCovered: true,
          hasSecurity: true,
          hasCharging: true,
          landmarkId: 'clinica_pasto',
        ),
        PastoParkingLot(
          id: 'pasto-clinicapasto-2',
          name: 'Estacionamiento Las Lajas',
          address: 'Carrera 29 # 15-80',
          latitude: 1.2158,
          longitude: -77.2852,
          pricePerHour: 2500,
          carSpaces: 10,
          motoSpaces: 8,
          distanceMeters: 80,
          rating: 4.5,
          openingHours: '6:30 AM - 9:30 PM',
          isCovered: true,
          hasSecurity: true,
          hasCharging: false,
          landmarkId: 'clinica_pasto',
        ),
      ],
    ),
  ];

  static List<Landmark> getLandmarks() => landmarks;

  static List<PastoParkingLot> getAllParkingLots() {
    final List<PastoParkingLot> all = [];
    for (final l in landmarks) {
      all.addAll(l.nearbyParkingLots);
    }
    return all;
  }

  static PastoParkingLot? getParkingLotById(String id) {
    for (final l in landmarks) {
      for (final p in l.nearbyParkingLots) {
        if (p.id == id) return p;
      }
    }
    return null;
  }

  static Landmark? getLandmarkById(String id) {
    for (final l in landmarks) {
      if (l.id == id) return l;
    }
    return null;
  }
}
