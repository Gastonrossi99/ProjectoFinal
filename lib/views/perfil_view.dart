import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import '../models/user.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoggedIn = false;
  bool _showLogin = true;
  User? _currentUser;
  bool _isLoading = true;

  // Controllers
  final _nombreController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    
    if (email != null) {
      final user = await _firebaseService.getUserByEmail(email);
      if (user != null) {
        setState(() {
          _isLoggedIn = true;
          _currentUser = user;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final user = await _firebaseService.getUserByEmail(_correoController.text);
      
      if (user != null && user.password == _passwordController.text) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', user.correo);

        setState(() {
          _isLoggedIn = true;
          _currentUser = user;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Correo o contraseña incorrectos'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final newUser = User(
        nombre: _nombreController.text,
        apellidos: _apellidosController.text,
        correo: _correoController.text,
        password: _passwordController.text,
        telefono: _telefonoController.text,
        direccion: _direccionController.text,
      );

      await _firebaseService.addUser(newUser);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', newUser.correo);

      setState(() {
        _isLoggedIn = true;
        _currentUser = newUser;
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    setState(() {
      _isLoggedIn = false;
      _currentUser = null;
      _correoController.clear();
      _passwordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: _isLoggedIn 
            ? _buildProfileInfo() 
            : (_showLogin ? _buildLoginForm() : _buildRegistrationForm()),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.account_circle, size: 100, color: Color(0xFF6750A4)),
          const SizedBox(height: 16),
          Text(
            'Hola, ${_currentUser?.nombre}!',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          _buildInfoTile(Icons.email, 'Correo', _currentUser?.correo ?? ''),
          _buildInfoTile(Icons.person, 'Nombre completo', '${_currentUser?.nombre} ${_currentUser?.apellidos}'),
          _buildInfoTile(Icons.phone, 'Teléfono', _currentUser?.telefono ?? ''),
          _buildInfoTile(Icons.location_on, 'Dirección', _currentUser?.direccion ?? ''),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red,
              minimumSize: const Size(200, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6750A4)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_outline, size: 80, color: Color(0xFF6750A4)),
          const SizedBox(height: 16),
          const Text(
            'Bienvenido de nuevo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Inicia sesión para continuar',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _buildTextField(_correoController, 'Correo Electrónico', Icons.email, keyboardType: TextInputType.emailAddress),
          _buildTextField(_passwordController, 'Contraseña', Icons.lock, isPassword: true),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6750A4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => setState(() => _showLogin = false),
            child: const Text('¿No tienes cuenta? Regístrate aquí'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.person_add_outlined, size: 80, color: Color(0xFF6750A4)),
          const SizedBox(height: 16),
          const Text(
            'Crea tu cuenta',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Únete a nuestra comunidad para mejores beneficios',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _buildTextField(_nombreController, 'Nombre', Icons.person),
          _buildTextField(_apellidosController, 'Apellidos', Icons.person_outline),
          _buildTextField(_correoController, 'Correo Electrónico', Icons.email, keyboardType: TextInputType.emailAddress),
          _buildTextField(_passwordController, 'Contraseña', Icons.lock, isPassword: true),
          _buildTextField(_telefonoController, 'Teléfono', Icons.phone, keyboardType: TextInputType.phone),
          _buildTextField(_direccionController, 'Dirección', Icons.home),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6750A4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Registrarse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => setState(() => _showLogin = true),
            child: const Text('¿Ya tienes cuenta? Inicia sesión'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF6750A4)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa tu $label';
          }
          return null;
        },
      ),
    );
  }
}
