class Service {
  final String id;
  final String name;
  final double price;
  final int durationMinutes;

  Service({required this.id, required this.name, required this.price, required this.durationMinutes});
}

class Barber {
  final String id;
  final String name;
  final String imageUrl;
  final String specialty;
  final double rating;
  final String bio;

  Barber({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.specialty,
    required this.rating,
    required this.bio,
  });
}

class Shop {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final double distance; // in km
  final String description;
  final String location;
  final List<Service> services;
  final List<Barber> barbers;

  Shop({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.distance,
    required this.description,
    required this.location,
    required this.services,
    required this.barbers,
  });
}

class Appointment {
  final String id;
  final Shop shop;
  final Barber barber;
  final List<Service> services;
  final DateTime dateTime;
  final String status; // 'Upcoming', 'Past', 'Canceled'

  Appointment({
    required this.id,
    required this.shop,
    required this.barber,
    required this.services,
    required this.dateTime,
    required this.status,
  });
}
