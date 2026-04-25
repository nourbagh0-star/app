import '../models/models.dart';

class DummyData {
  static final List<Service> dummyServices = [
    Service(id: 's1', name: 'Classic Haircut', price: 35.0, durationMinutes: 45),
    Service(id: 's2', name: 'Beard Trim', price: 20.0, durationMinutes: 30),
    Service(id: 's3', name: 'Hot Towel Shave', price: 40.0, durationMinutes: 45),
    Service(id: 's4', name: 'Coloring', price: 80.0, durationMinutes: 90),
    Service(id: 's5', name: 'Facial Massage', price: 50.0, durationMinutes: 60),
  ];

  static final List<Barber> dummyBarbers = [
    Barber(
      id: 'b1',
      name: 'Marcus Bell',
      imageUrl: 'https://images.unsplash.com/photo-1518780664697-55e3ad937233?auto=format&fit=crop&q=80&w=200',
      specialty: 'Master Barber',
      rating: 4.9,
      bio: 'Over 10 years of experience with classic fades.',
    ),
    Barber(
      id: 'b2',
      name: 'Julian Vance',
      imageUrl: 'https://images.unsplash.com/photo-1543165365-3cbd49a5b3a1?auto=format&fit=crop&q=80&w=200',
      specialty: 'Beard Specialist',
      rating: 4.8,
      bio: 'Expert in beard sculpting and hot towel shaves.',
    ),
  ];

  static final List<Shop> dummyShops = [
    Shop(
      id: 'sh1',
      name: 'The Heritage Grooming Co.',
      imageUrl: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&q=80&w=500',
      rating: 4.9,
      distance: 2.1,
      description: 'Premium grooming experience with vintage aesthetics and modern techniques.',
      location: '123 Oak Ave, Downtown',
      services: dummyServices,
      barbers: dummyBarbers,
    ),
    Shop(
      id: 'sh2',
      name: 'Gilded Scissors',
      imageUrl: 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?auto=format&fit=crop&q=80&w=500',
      rating: 4.8,
      distance: 3.5,
      description: 'Luxury haircuts tailored perfectly to your style in a modern setting.',
      location: '450 Pine Square',
      services: dummyServices.take(3).toList(),
      barbers: [dummyBarbers[0]],
    ),
    Shop(
      id: 'sh3',
      name: 'Urban Blade Studio',
      imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&q=80&w=500',
      rating: 4.7,
      distance: 5.0,
      description: 'The go-to spot for sharp fades and precise line-ups.',
      location: '88 Market St',
      services: dummyServices,
      barbers: dummyBarbers,
    ),
  ];

  static final List<Appointment> dummyAppointments = [
    Appointment(
      id: 'a1',
      shop: dummyShops[0],
      barber: dummyBarbers[0],
      services: [dummyServices[0], dummyServices[1]],
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      status: 'Upcoming',
    ),
    Appointment(
      id: 'a2',
      shop: dummyShops[1],
      barber: dummyBarbers[1],
      services: [dummyServices[1]],
      dateTime: DateTime.now().subtract(const Duration(days: 5)),
      status: 'Past',
    ),
  ];
}
