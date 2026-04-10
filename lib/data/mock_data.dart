import '../models/lead.dart';
import '../models/property.dart';

class MockData {
  static List<Lead> get fakeLeads => [
    Lead(
      id: '1',
      userId: 'test_user',
      name: 'Alhaji Musa Bello',
      email: 'musa.b@example.com',
      phone: '+234 803 123 4567',
      budget: 150000000.0,
      status: 'New Lead',
      propertyId: '5',
      source: 'Website',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      currency: 'NGN'
    ),
    Lead(
      id: '2',
      userId: 'test_user',
      name: 'Sarah Jenkins',
      email: 'sarah.j@example.com',
      phone: '+234 812 987 6543',
      budget: 45000000.0,
      status: 'Follow Up',
      propertyId: '2',
      source: 'Referral',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      currency: 'USD'
    ),
    Lead(
      id: '3',
      userId: 'test_user',
      name: 'Chief Okonkwo',
      email: 'okonkwo.c@example.com',
      phone: '+234 706 555 0192',
      budget: 320000000.0,
      status: 'Closed',
      propertyId: '3',
      source: 'Word of Mouth',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      currency: 'NGN'
    ),
    Lead(
      id: '4',
      userId: 'test_user',
      name: 'Amina Yusuf',
      email: 'amina.y@example.com',
      phone: '+234 901 222 3333',
      budget: 12000000.0,
      status: 'Interested',
      propertyId: '4',
      source: 'Website',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      currency: 'USD'
    ),
    Lead(
      id: '5',
      userId: 'test_user',
      name: 'Michael Chen',
      email: 'm.chen@example.com',
      phone: '+234 805 444 7777',
      budget: 85000000.0,
      status: 'New Lead',
      propertyId: '1',
      source: 'Website',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      currency: 'NGN'
    ),
    Lead(
      id: '6',
      userId: 'test_user',
      name: 'Dr. Elizabeth Adeyemi',
      email: 'e.adeyemi@health.ng',
      phone: '+234 811 000 9999',
      budget: 65000000.0,
      status: 'Follow Up',
      propertyId: '3',
      source: 'Website',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      currency: 'NGN'
    ),
    Lead(
      id: '7',
      userId: 'test_user',
      name: 'Emeka Okafor',
      email: 'e.okafor@test.com',
      phone: '+234 809 555 1234',
      budget: 450000000.0,
      status: 'Negotiation',
      propertyId: '2',
      source: 'Referral',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      currency: 'NGN'
    ),
  ];

  static List<Property> get fakeProperties => [
    Property(
      id: '1',
      developer: 'Bilaad',
      title: '5 Bedroom Detached Duplex in Maitama',
      description: 'A luxurious 5 bedroom detached duplex located in the prestigious Maitama district of Abuja. Features a spacious living area, modern kitchen, private pool, and landscaped garden.',
      price: 150000000.0,
      location: 'Maitama, Abuja',
      image: 'https://images.unsplash.com/photo-1774612673121-7da610a4e1aa?q=80&w=1171&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      status: 'Available',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      currency: 'USD'
    ),
    Property(
      id: '2',
      developer: 'Bilaad',
      title: 'Luxury Condo in Victoria Island',
      description: 'A stunning luxury condo located in the heart of Victoria Island, Lagos. Offers breathtaking views of the Atlantic Ocean, state-of-the-art amenities, and 24/7 security.',
      price: 45000000.0,
      location: 'Victoria Island, Lagos',
      image: 'https://images.unsplash.com/photo-1560448070-9c8e1bfbf1b4?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      status: 'Available',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      currency: 'NGN'
    ),
    Property(
      id: '3',
      developer: 'Bilaad',
      title: 'Multi-acre Estate in Enugu',
      description: 'A sprawling multi-acre estate located in the serene outskirts of Enugu. Features a main house with 6 bedrooms, guest cottages, a private lake, and extensive gardens.',
      price: 320000000.0,
      location: 'Enugu State',
      image: 'https://images.unsplash.com/photo-1501854140801-50d01698950b?q=80&w=1287&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      status: 'Available',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      currency: 'NGN'
    ),
    Property(
      id: '4',
      developer: 'Bilaad',
      title: 'Studio Apartment in Gwarinpa',
      description: 'A cozy studio apartment located in the bustling Gwarinpa area of Abuja. Ideal for young professionals or students, offering a compact living space with modern amenities.',
      price: 12000000.0,
      location: 'Gwarinpa, Abuja',
      image: 'https://images.unsplash.com/photo-1560448070-9c8e1bfbf1b4?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      status: 'Available',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      currency: 'NGN'
    ),
    Property(
      id: '5',
      developer: 'Bilaad',
      title: 'Modern Office Space in Central Business District',
      description: 'A modern office space located in the vibrant Central Business District. Features high-speed internet, meeting rooms, and a collaborative work environment.',
      price: 85000000.0,
      location: 'Central Business District, Abuja',
      image: 'https://images.unsplash.com/photo-1551836022-d5d88e9218df?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      status: 'Available',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      currency: 'USD'
    ),
  ];
}