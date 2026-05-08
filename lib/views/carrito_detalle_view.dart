import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../models/proveedor.dart';
import '../services/db_service.dart';
import '../services/firebase_service.dart';
import 'confirmacion_view.dart';

class CarritoDetalleView extends StatefulWidget {
  final double total;
  final String userEmail;
  final List<int> productIDs;
  final VoidCallback onBack;
  final VoidCallback onHome;

  const CarritoDetalleView({
    super.key,
    required this.total,
    required this.userEmail,
    required this.productIDs,
    required this.onBack,
    required this.onHome,
  });

  @override
  State<CarritoDetalleView> createState() => _CarritoDetalleViewState();
}

class _CarritoDetalleViewState extends State<CarritoDetalleView> {
  final FirebaseService _firebaseService = FirebaseService();
  final DBService _dbService = DBService();
  
  Proveedor? _selectedProvider;
  List<Proveedor> _availableProviders = [];
  int? _userID;
  bool _isLoading = true;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Intentamos obtener el ID del usuario desde Firebase
    final user = await _firebaseService.getUserByEmail(widget.userEmail);

    setState(() {
      // Si no existe en Firebase, usamos un ID temporal para que no se bloquee el pago
      _userID = user?.userID ?? 1;

      // Cargamos los proveedores manualmente como solicitaste
      _availableProviders = [
        Proveedor(proveedorID: 1, nombre: 'Correos'),
        Proveedor(proveedorID: 2, nombre: 'SEUR'),
        Proveedor(proveedorID: 3, nombre: 'Ugc'),
      ];

      _selectedProvider = _availableProviders.first;
      _isLoading = false;
    });
  }

  Future<void> _processPayment() async {
    // Si falta información esencial, mostramos un aviso en lugar de no hacer nada
    if (_userID == null || _selectedProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se pudo identificar al usuario o proveedor')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      const double shippingCost = 5.00;
      final double grandTotal = widget.total + shippingCost;

      final nuevoPedido = Pedido(
        userID: _userID!,
        productosIDs: widget.productIDs,
        proveedorID: _selectedProvider!.proveedorID!,
        diaDeLlegada: DateTime.now().add(const Duration(days: 7)),
        coste: grandTotal,
      );

      // Guardamos el pedido y limpiamos el carrito
      await _dbService.savePedido(nuevoPedido, widget.userEmail);
      await _dbService.clearCart(widget.userEmail);

      setState(() {
        _isLoading = false;
        _isConfirmed = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar el pedido: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isConfirmed) {
      return ConfirmacionView(
        onContinue: widget.onHome,
      );
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    const double shippingCost = 5.00;
    final double grandTotal = widget.total + shippingCost;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBack,
        ),
        title: const Text('Resumen de Pago', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Resumen Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resumen del Pedido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildSummaryRow('Subtotal', '${widget.total.toStringAsFixed(2)} \$'),
                  _buildSummaryRow('Gastos de envío', '${shippingCost.toStringAsFixed(2)} \$'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),
                  _buildSummaryRow('Total a pagar', '${grandTotal.toStringAsFixed(2)} \$', isTotal: true),
                ],
              ),
            ),

            // Proveedores Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Método de Envío', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Selecciona tu proveedor de confianza:', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 16),
                  RadioGroup<Proveedor>(
                    groupValue: _selectedProvider,
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedProvider = value);
                    },
                    child: Column(
                      children: _availableProviders.map((p) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: _selectedProvider == p ? const Color(0xFFF3F0F8) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _selectedProvider == p ? const Color(0xFF6750A4) : Colors.grey[200]!),
                        ),
                        child: RadioListTile<Proveedor>(
                          title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w500)),
                          secondary: const Icon(Icons.local_shipping_outlined),
                          value: p,
                          activeColor: const Color(0xFF6750A4),
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Pay Button Container
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment),
                    SizedBox(width: 12),
                    Text('Confirmar y Pagar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? const Color(0xFF6750A4) : Colors.black,
          ),
        ),
      ],
    );
  }
}
