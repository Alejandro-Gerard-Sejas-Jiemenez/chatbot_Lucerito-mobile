import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../services/order_service.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/pedido.dart';
import '../data/models/usuario.dart';
import '../data/models/ubicacion.dart';
import '../data/models/traking.dart';
import 'dart:async';
import '../utils/location_helper.dart';
import '../utils/background_location_sender.dart';
import '../widgets/menu/menu_header.dart';
import '../widgets/menu/stat_card.dart';
import '../widgets/menu/completed_orders_list.dart';
import 'mapa_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Timer? _pollingTimer;
  int? _ultimoIdOrdenMostrado;
  final LocationService _locationService = LocationService(
    baseUrl: ApiConfig.baseUrl,
  );
  List<Map<String, dynamic>> _historial = [];
  int _totalRegistros = 0;
  bool _isLoadingHistorial = true;
  String _deliveryUsername = '';

  @override
  void initState() {
    super.initState();
    _startPolling();
    _setupBackgroundLocationCallback();
    LocationHelper.printCurrentLocation();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deliveryIdStr = prefs.getString('delivery_id');

      if (deliveryIdStr != null) {
        final deliveryId = int.tryParse(deliveryIdStr);
        if (deliveryId != null) {
          final resultado = await _orderService.obtenerHistorialDelivery(
            deliveryId,
          );
          if (resultado != null && mounted) {
            setState(() {
              _historial = List<Map<String, dynamic>>.from(
                resultado['historial'] ?? [],
              );
              _totalRegistros = resultado['total_registros'] ?? 0;
              _deliveryUsername = resultado['delivery_username'] ?? '';
              _isLoadingHistorial = false;
            });
          }
        }
      }
    } catch (e) {
      print('Error al cargar historial: $e');
      if (mounted) {
        setState(() => _isLoadingHistorial = false);
      }
    }
  }

  Future<void> _navegarAMapa(Pedido pedido) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapaScreen(pedido: pedido)),
    );

    // Si regresó del mapa, recargar el historial
    if (resultado == true && mounted) {
      await _cargarHistorial();
    }
  }

  void _setupBackgroundLocationCallback() {
    // Registrar callback para recibir notificaciones de nuevas órdenes del BackgroundLocationSender
    final sender = BackgroundLocationSender();
    sender.onNewOrderReceived = (idOrden) {
      print(
        'Callback ejecutado: Nueva orden #$idOrden desde BackgroundLocationSender',
      );
      if (_ultimoIdOrdenMostrado == null || idOrden != _ultimoIdOrdenMostrado) {
        _ultimoIdOrdenMostrado = idOrden;
        print('Verificando si el widget está montado: $mounted');
        if (!mounted) {
          print(
            'ADVERTENCIA: Widget no está montado, no se puede mostrar el popup',
          );
          return;
        }

        print('Widget montado, mostrando popup para orden #$idOrden');
        // Llamar directamente sin post frame callback
        _mostrarPopupOrden(idOrden);
      } else {
        print('Orden #$idOrden ya fue mostrada anteriormente, ignorando');
      }
    };
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        // Obtener ubicación real actual
        final position = await LocationHelper.getCurrentPosition();
        final response = await _locationService
            .pollCurrentOrderWithDummyLocation(
              latitud: position?.latitude ?? 0.0,
              longitud: position?.longitude ?? 0.0,
            );
        if (response != null && response['id_orden_actual'] != null) {
          final idOrden = response['id_orden_actual'];
          if (_ultimoIdOrdenMostrado == null ||
              idOrden != _ultimoIdOrdenMostrado) {
            _ultimoIdOrdenMostrado = idOrden;
            if (mounted) {
              _mostrarPopupOrden(idOrden);
            }
          }
        }
      } catch (e) {
        print('Error en polling de órdenes: $e');
      }
    });
  }

  // Método para procesar la aceptación de orden sin problemas de contexto
  Future<void> _procesarAceptacionOrden(int idOrden, int deliveryId) async {
    try {
      // Aceptar la orden (actualizar estado)
      final url = Uri.parse('${ApiConfig.baseUrl}/orden/$idOrden/estado');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'estado': 'pendiente'}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Orden aceptada exitosamente')),
        );

        // Obtener ubicación actual del delivery para crear el tracking
        final currentPosition = await LocationHelper.getCurrentPosition();

        // Crear tracking para la orden
        final trackingData = Traking(
          latitud: currentPosition?.latitude.toString() ?? '0.0',
          longitud: currentPosition?.longitude.toString() ?? '0.0',
          userDeliveryID: deliveryId.toString(),
          estado: 'asignada',
          ordenCod: idOrden.toString(),
          comentario: 'Asignación automática',
        );

        print('Creando tracking para orden #$idOrden...');
        final trackingId = await _orderService.createTracking(trackingData);

        if (trackingId != null) {
          print('Tracking creado con ID: $trackingId');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('tracking_id_$idOrden', trackingId);
          await prefs.setString('delivery_id', deliveryId.toString());
          print('Tracking ID guardado en SharedPreferences');
        } else {
          print('Advertencia: No se pudo crear el tracking');
        }

        // Obtener ubicación de la orden
        final ubicacion = await _orderService.obtenerUbicacionOrden(idOrden);

        if (!mounted) return;

        if (ubicacion != null) {
          final lat = ubicacion['latitud'];
          final lng = ubicacion['longitud'];
          final nombreContacto = ubicacion['nombre_contacto'] as String?;
          final comentario = ubicacion['comentario'] as String?;

          final pedidoSimulado = Pedido(
            id: idOrden,
            usuario: Usuario(
              id: 0,
              nombre: 'Desconocido',
              correo: '',
              telefono: '',
              direccion: '',
            ),
            productos: [],
            total: 0.0,
            estado: 'pendiente',
            ubicacionLocal: Ubicacion(
              latitud: lat ?? 0.0,
              longitud: lng ?? 0.0,
            ),
            ubicacionCliente: Ubicacion(
              latitud: lat ?? 0.0,
              longitud: lng ?? 0.0,
            ),
            nombreContacto: nombreContacto,
            comentario: comentario,
          );

          await _navegarAMapa(pedidoSimulado);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo obtener la ubicación de la orden'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al aceptar la orden')),
        );
      }
    } catch (e) {
      print('Error al procesar aceptación de orden: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  final OrderService _orderService = OrderService();

  void _mostrarPopupOrden(int idOrden) async {
    print('_mostrarPopupOrden llamado para orden #$idOrden');

    // Guardar referencia al context antes de operaciones asíncronas
    final dialogContext = context;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      print('ERROR: No hay token JWT, no se puede mostrar el popup');
      return;
    }
    final AuthService authService = AuthService();
    final deliveryId = authService.getUserIdFromToken(token);
    print('Delivery ID obtenido del token: $deliveryId');
    if (deliveryId == null) {
      print(
        'ERROR: No se pudo extraer el ID del token, no se puede mostrar el popup',
      );
      return;
    }

    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (dialogCtx) {
        print('Builder del AlertDialog ejecutado');
        return AlertDialog(
          title: const Text('Nueva orden asignada'),
          content: Text('¿Deseas aceptar la orden #$idOrden?'),
          actions: [
            TextButton(
              onPressed: () async {
                // Guardar referencias antes de cerrar el diálogo
                final navigator = Navigator.of(dialogCtx);
                final scaffoldMessenger = ScaffoldMessenger.of(dialogContext);

                navigator.pop();

                // Rechazar la orden
                final success = await _orderService.rejectOrder(
                  idOrden,
                  deliveryId,
                );
                if (!mounted) return;
                if (success) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Orden rechazada exitosamente'),
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Error al rechazar la orden')),
                  );
                }
              },
              child: const Text('Rechazar'),
            ),
            TextButton(
              onPressed: () async {
                // Cerrar el diálogo inmediatamente
                Navigator.of(dialogCtx).pop();

                // Procesar la aceptación en segundo plano
                _procesarAceptacionOrden(idOrden, deliveryId);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                MenuHeader(username: _deliveryUsername),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const StatCard(title: 'Pendientes', value: '1'),
                      const StatCard(title: 'En Camino', value: '1'),
                      StatCard(title: 'Hoy', value: _totalRegistros.toString()),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: _isLoadingHistorial
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      children: [CompletedOrdersList(historial: _historial)],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
