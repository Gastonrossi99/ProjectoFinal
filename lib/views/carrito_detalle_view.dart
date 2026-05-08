import 'package:flutter/material.dart';

class CarritoDetalleView extends StatefulWidget {
  final double total;
  final VoidCallback onBack;

  const CarritoDetalleView({
    super.key,
    required this.total,
    required this.onBack,
  });

  @override
  State<CarritoDetalleView> createState() => _CarritoDetalleViewState();
}

class _CarritoDetalleViewState extends State<CarritoDetalleView> {
  String _selectedProvider = 'Correos'; // Default provider
  final List<String> _providers = ['Correos', 'SEUR', 'Ugc'];

  @override
  Widget build(BuildContext context) {
    const double shippingCost = 5.00;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBack,
        ),
        title: const Text('Checkout', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del pedido',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _buildSummaryRow('Subtotal', '${widget.total.toStringAsFixed(2)} \$'),
            _buildSummaryRow('Envío', '${shippingCost.toStringAsFixed(2)} \$'),
            const Divider(height: 40),

            const Text(
              'Método de Envío',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Provider Selection List
            RadioGroup<String>(
              groupValue: _selectedProvider,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedProvider = value;
                  });
                }
              },
              child: Column(
                children: _providers.map((provider) => RadioListTile<String>(
                  title: Text(provider),
                  value: provider,
                  activeColor: const Color(0xFF6750A4),
                )).toList(),
              ),
            ),

            const Divider(height: 40),
            _buildSummaryRow('Total', '${(widget.total + shippingCost).toStringAsFixed(2)} \$', isTotal: true),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Procesando pago con $_selectedProvider...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6750A4),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Confirmar y Pagar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}