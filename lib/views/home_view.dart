import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/categoria.dart';
import '../models/licencia.dart';

class HomeView extends StatefulWidget {
  final Function(String name, int id, String type) onShowDetail;

  const HomeView({super.key, required this.onShowDetail});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseService service = FirebaseService();
  final ScrollController _categoriaController = ScrollController();
  final ScrollController _licenciaController = ScrollController();

  @override
  void dispose() {
    _categoriaController.dispose();
    _licenciaController.dispose();
    super.dispose();
  }

  void _scrollNext(ScrollController controller, double itemSize) {
    if (!controller.hasClients) return;
    
    double nextOffset = controller.offset + itemSize;
    if (nextOffset > controller.position.maxScrollExtent + 50) {
      nextOffset = 0;
    }
    
    controller.animateTo(
      nextOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECCIÓN CATEGORÍAS ---
            _buildSectionTitle(
              'Categorias',
              onTap: () => _scrollNext(_categoriaController, 180.0), // 160 + 20 padding
            ),
            SizedBox(
              height: 210,
              child: StreamBuilder<List<Categoria>>(
                stream: service.getCategorias(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay categorías'));
                  }

                  final categorias = snapshot.data!;
                  return ListView.builder(
                    controller: _categoriaController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categorias.length,
                    itemBuilder: (context, index) {
                      return _buildCategoriaItem(context, categorias[index]);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // --- SECCIÓN LICENCIAS ---
            _buildSectionTitle(
              'Licencias',
              onTap: () => _scrollNext(_licenciaController, 420.0), // 400 + 20 padding
            ),
            SizedBox(
              height: 500,
              child: StreamBuilder<List<Licencia>>(
                stream: service.getLicencias(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay licencias'));
                  }

                  final licencias = snapshot.data!;
                  return ListView.builder(
                    controller: _licenciaController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: licencias.length,
                    itemBuilder: (context, index) {
                      return _buildLicenciaItem(context, licencias[index]);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1B20),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaItem(BuildContext context, Categoria categoria) {
    return GestureDetector(
      onTap: () {
        widget.onShowDetail(categoria.nombre, categoria.categoriaID ?? 0, 'Categoria');
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
                image: categoria.backgroundImage.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(categoria.backgroundImage),
                        fit: BoxFit.contain,
                      )
                    : null,
              ),
              child: categoria.backgroundImage.isEmpty
                  ? const Icon(Icons.category, color: Colors.grey, size: 40)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              categoria.nombre,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1D1B20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenciaItem(BuildContext context, Licencia licencia) {
    return GestureDetector(
      onTap: () {
        widget.onShowDetail(licencia.nombre, licencia.licenseID ?? 0, 'Licencia');
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 400,
                height: 400,
                color: Colors.grey[200],
                child: licencia.backgroundImage.isNotEmpty
                    ? Image.network(
                        licencia.backgroundImage,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 340,
                      child: Text(
                        licencia.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D1B20),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Text(
                      'Collection',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE8DEF8),
                  ),
                  child: const Icon(Icons.stars, size: 20, color: Color(0xFF6750A4)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
