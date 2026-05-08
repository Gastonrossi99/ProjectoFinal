import 'dart:typed_data';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import '../services/db_service.dart';
import '../models/producto.dart';

class IADesignView extends StatefulWidget {
  const IADesignView({super.key});

  @override
  State<IADesignView> createState() => _IADesignViewState();
}

class _IADesignViewState extends State<IADesignView> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseService _firebaseService = FirebaseService();
  final DBService _dbService = DBService();
  
  Uint8List? _generatedImage;
  XFile? _pickedFile;
  bool _isLoading = false;
  bool _isAddingToCart = false;
  
  // Tu API Key
  final String _apiKey = 'sk-74nxQDGO3URhhCzg0sctGFIpeEJ6W2olZD9V3ZlHDXWKlZg0';

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedFile = image;
        _generatedImage = null; 
      });
    }
  }

  /// Función que implementa Image-to-Image usando Structure Control (V2)
  /// Esta versión es la mejor para mantener la forma de la imagen original del usuario.
  Future<Uint8List?> _generateImg2Img({
    required Uint8List initImageBytes,
    required String prompt,
  }) async {
    // Endpoint de Control de Estructura: mantiene la forma de tu foto original
    final url = Uri.parse('https://api.stability.ai/v2beta/stable-image/control/structure');

    debugPrint('Iniciando transformación con Structure Control...');

    // Generamos una semilla aleatoria para asegurar que cada resultado sea diferente
    final int randomSeed = Random().nextInt(4294967295);

    final request = http.MultipartRequest('POST', url)
      ..headers.addAll({
        'Authorization': 'Bearer $_apiKey',
        'Accept': 'image/*', 
      })
      ..fields['prompt'] = prompt
      ..fields['strength'] = '0.7' // Ajuste de fidelidad a la estructura original
      ..fields['seed'] = randomSeed.toString()
      ..fields['output_format'] = 'png';
      
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      initImageBytes,
      filename: 'input.png',
    ));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Respuesta recibida: ${response.statusCode}');

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        debugPrint('Error de API: ${response.body}');
        throw Exception('Error de la API (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('Excepción en _generateImg2Img: $e');
      rethrow;
    }
  }

  Future<void> _generateAnimeImage() async {
    if (_pickedFile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona una imagen primero')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Uint8List initImageBytes = await _pickedFile!.readAsBytes();
      
      // Prompt específico para forzar el estilo anime sobre la estructura
      final Uint8List? resultImage = await _generateImg2Img(
        initImageBytes: initImageBytes,
        prompt: 'Professional anime style illustration, clean lineart, vibrant flat colors, high quality studio ghibli style',
      );

      if (mounted && resultImage != null) {
        setState(() {
          _generatedImage = resultImage;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al transformar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addToCart() async {
    if (_generatedImage == null) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');

      if (email == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, inicia sesión para añadir al carrito')),
          );
        }
        return;
      }

      // Convertir imagen a Base64 para guardarla en Firestore (como string)
      // Nota: Si la imagen es muy grande, esto podría fallar en Firestore (límite 1MB)
      final String base64Image = base64Encode(_generatedImage!);
      final String dataUri = 'data:image/png;base64,$base64Image';

      final nuevoProducto = Producto(
        nombre: 'IA Design',
        stock: 99,
        coste: 39.99, // Precio fijo para diseños IA
        detalles: 'Camiseta personalizada diseñada con Inteligencia Artificial.',
        categoriaID: 1, // Usamos una categoría por defecto (ej. Camisetas)
        backgroundImage: dataUri,
        licenseID: 0, // Sin licencia
      );

      // 1. Guardar producto en Firestore
      await _firebaseService.addProducto(nuevoProducto);

      // 2. Añadir al carrito local (SQLite/SharedPrefs)
      if (nuevoProducto.productID != null) {
        await _dbService.addToCart(nuevoProducto.productID!, email);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Diseño añadido al carrito!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir al carrito: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Widget _buildPreviewImage() {
    if (_generatedImage != null) {
      return Image.memory(_generatedImage!, fit: BoxFit.cover);
    }
    if (_pickedFile != null) {
      return Opacity(
        opacity: 0.5,
        child: kIsWeb 
          ? Image.network(_pickedFile!.path, fit: BoxFit.cover)
          : Image.file(File(_pickedFile!.path), fit: BoxFit.cover),
      );
    }
    return const Center(
      child: Text(
        'Tu diseño\naquí',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IA Design Studio'),
        backgroundColor: const Color(0xFF1D1B20),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Imagen base de la camiseta
                  Image.network(
                    'https://m.media-amazon.com/images/I/51WGR+Xb46L._AC_UY1000_.jpg',
                    height: 350,
                    width: 350,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 350,
                        width: 350,
                        color: Colors.grey[200],
                        child: const Icon(Icons.dry_cleaning, size: 200, color: Color(0xFF1D1B20)),
                      );
                    },
                  ),
                  
                  // Área del diseño sobre la camiseta
                  Positioned(
                    top: 85,
                    child: Container(
                      width: 120,
                      height: 140,
                      decoration: BoxDecoration(
                        border: (_pickedFile == null && _generatedImage == null)
                            ? Border.all(color: Colors.grey.withAlpha(77))
                            : null,
                      ),
                      child: _isLoading 
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF1D1B20)))
                        : _buildPreviewImage(),
                    ),
                  ),
                ],
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Personaliza tu Camiseta Anime',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('1. Seleccionar mi Foto'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Color(0xFF1D1B20)),
                      foregroundColor: const Color(0xFF1D1B20),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: (_pickedFile == null || _isLoading) ? null : _generateAnimeImage,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('2. Convertir a Anime con IA'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: const Color(0xFF1D1B20),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: (_generatedImage == null || _isAddingToCart) ? null : _addToCart,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: const Color(0xFF6750A4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _isAddingToCart
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.add_shopping_cart),
                            const SizedBox(width: 12),
                            const Text('3. Añadir al Carrito'),
                          ],
                        ),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '39.99€',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
