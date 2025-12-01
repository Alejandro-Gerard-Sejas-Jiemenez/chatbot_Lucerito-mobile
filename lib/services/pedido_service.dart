
import '../data/mock_data.dart';
import '../data/models/pedido.dart';

class PedidoService {
  // Devuelve el primer pedido asignado del mock data (puedes ajustar la lógica según lo que necesites probar)
  Future<MockOrder?> getPedidoAsignado() async {
    if (assignedOrders.isNotEmpty) {
      return assignedOrders.first;
    }
    return null;
  }
}
