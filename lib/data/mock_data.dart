import '../models/user.dart';

// Simple models for orders are defined inline here to keep mock data focused
class MockOrder {
  final String id;
  final String client;
  final String phone;
  final String address;
  final List<String> items;
  final double distanceKm;
  final int etaMinutes;
  final double total;
  final String comment;
  final String status;

  const MockOrder({
    required this.id,
    required this.client,
    required this.phone,
    required this.address,
    required this.items,
    required this.distanceKm,
    required this.etaMinutes,
    required this.total,
    this.comment = '',
    required this.status,
  });
}

// Simulated current user
// Simulated current user (uses existing `User` model)
final User currentUser = User(username: "alejandro", password: "1234");

// Sample orders list
final List<MockOrder> assignedOrders = const [
  MockOrder(
    id: '120',
    client: 'Roberto Juarez',
    phone: '+591 73753036',
    address: 'Calle 2, Urbanizacion los Claveles',
    items: ['x2 Kjara Especiales', 'x1 Coca-Cola 3lts', 'x2 Porcion extra de Arroz'],
    distanceKm: 5.3,
    etaMinutes: 15,
    total: 140.0,
    comment: 'Es la casa de porton azul con una palmera afuera.',
    status: 'Pendiente',
  ),
  MockOrder(
    id: '121',
    client: 'María López',
    phone: '+591 70000000',
    address: 'Av. Principal 123',
    items: ['x1 Pizza Familiar', 'x1 Ensalada'],
    distanceKm: 3.2,
    etaMinutes: 12,
    total: 85.0,
    comment: '',
    status: 'Pendiente',
  ),
];

final List<MockOrder> completedToday = const [
  MockOrder(
    id: '101',
    client: 'Luis Gómez',
    phone: '+591 69999999',
    address: 'Calle Falsa 123',
    items: ['x1 Empanada'],
    distanceKm: 2.1,
    etaMinutes: 10,
    total: 15.0,
    comment: '',
    status: 'Entregado',
  ),
];
