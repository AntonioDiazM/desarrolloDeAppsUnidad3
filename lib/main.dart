import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MiAppMedioAmbiente());
}

class MiAppMedioAmbiente extends StatelessWidget {
  const MiAppMedioAmbiente({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoReportes Ambientales',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/registro1': (context) => const RegistroPaso1Screen(),
        '/registro2': (context) => const RegistroPaso2Screen(),
        '/inicio': (context) => const InicioScreen(),
        '/registrar_incidencia': (context) => const RegistrarIncidenciaScreen(),
        '/ver_incidencias': (context) => const VerIncidenciasScreen(),
      },
    );
  }
}

// ==========================================
// 1. PANTALLA DE LOGIN (CON VALIDACIÓN REAL DE CONTRASEÑA)
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _iniciarSesion() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atención: Ingresa correo y contraseña.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    final registeredEmail = prefs.getString('registered_email');
    final registeredPassword = prefs.getString('registered_password');

    bool esCredencialValida = false;
    String nombreAMostrar = '';

    if (email == 'test@eco.com' && password == '123456') {
      esCredencialValida = true;
      nombreAMostrar = 'Usuario Test'; // Nombre asignado para la cuenta test
    } else if (registeredEmail != null &&
        email == registeredEmail &&
        registeredPassword != null &&
        password == registeredPassword) {
      esCredencialValida = true;
      nombreAMostrar = prefs.getString('registered_name') ?? email;
    }

    if (esCredencialValida) {
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_email', email);
      // Actualizamos 'temp_nombre' con el nombre del usuario actual
      await prefs.setString('temp_nombre', nombreAMostrar);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Inicio de sesión exitoso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacementNamed(context, '/inicio');
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Correo o contraseña incorrectos.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EcoReportes ')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.eco, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _iniciarSesion,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Iniciar Sesión'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/registro1'),
                child: const Text('¿No tienes cuenta? Regístrate'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Datos de prueba rápido:\nUsuario: test@eco.com\nClave: 123456',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. REGISTRO PASO 1 (Datos personales)
// ==========================================
class RegistroPaso1Screen extends StatefulWidget {
  const RegistroPaso1Screen({super.key});

  @override
  State<RegistroPaso1Screen> createState() => _RegistroPaso1ScreenState();
}

class _RegistroPaso1ScreenState extends State<RegistroPaso1Screen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();

  void _validarYAvanzar() {
    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();

    if (nombre.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atención: Debes llenar todos los campos obligatorios.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atención: Ingresa un correo electrónico válido.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('temp_nombre', nombre);
      prefs.setString('temp_email', email);
    });

    Navigator.pushNamed(context, '/registro2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro ')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _validarYAvanzar,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. REGISTRO PASO 2 (Guardar contraseña de registro)
// ==========================================
class RegistroPaso2Screen extends StatefulWidget {
  const RegistroPaso2Screen({super.key});

  @override
  State<RegistroPaso2Screen> createState() => _RegistroPaso2ScreenState();
}

class _RegistroPaso2ScreenState extends State<RegistroPaso2Screen> {
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  Future<void> _finalizarRegistro() async {
    final pass = _passController.text;
    final confirmPass = _confirmPassController.text;

    if (pass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atención: Ingresa y confirma tu contraseña.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (pass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atención: Las contraseñas no coinciden.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Guardar credenciales de registro para poder validar el login posteriormente
    final prefs = await SharedPreferences.getInstance();
    final tempEmail = prefs.getString('temp_email') ?? '';
    await prefs.setString('registered_email', tempEmail);
    await prefs.setString('registered_password', pass);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Cuenta creada exitosamente! Ahora puedes iniciar sesión.'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.popUntil(context, ModalRoute.withName('/login'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro ')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _finalizarRegistro,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Crear Cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. HOME Y NAVEGACIÓN
// ==========================================
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  String _usuarioLogueado = 'Usuario';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? 'Usuario';
    final nombreTemp = prefs.getString('temp_nombre');

    setState(() {
      _usuarioLogueado = (nombreTemp != null && nombreTemp.isNotEmpty) ? nombreTemp : email;
    });
  }

  void _cerrarSesion(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cierre de sesión exitoso')),
    );
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _mostrarDialogoConfirmacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cierre de Sesión'),
        content: const Text('¿Estás seguro de que deseas salir de la aplicación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cerrarSesion(context);
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoReportes'),
        backgroundColor: Colors.green.shade100,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_usuarioLogueado),
              accountEmail: const Text('reporte_ambiental@ecorapp.org'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.green, size: 40),
              ),
              decoration: const BoxDecoration(color: Colors.green),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add_location_alt),
              title: const Text('Reportar Problema Ambiental'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/registrar_incidencia');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Ver Lista de Reportes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/ver_incidencias');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _mostrarDialogoConfirmacion();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: Colors.green.shade50,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(Icons.eco, size: 60, color: Colors.green),
                    const SizedBox(height: 10),
                    Text(
                      '¡Bienvenido, $_usuarioLogueado!',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Plataforma para el reporte comunitario de problemas ambientales.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/registrar_incidencia'),
              icon: const Icon(Icons.warning_amber),
              label: const Text('Crear Nuevo Reporte'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/ver_incidencias'),
              icon: const Icon(Icons.visibility),
              label: const Text('Ver Reportes Registrados'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. REGISTRO DE PROBLEMA AMBIENTAL
// ==========================================
class RegistrarIncidenciaScreen extends StatefulWidget {
  const RegistrarIncidenciaScreen({super.key});

  @override
  State<RegistrarIncidenciaScreen> createState() => _RegistrarIncidenciaScreenState();
}

class _RegistrarIncidenciaScreenState extends State<RegistrarIncidenciaScreen> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _tipoProblema = 'Bota de basura ilegal';

  final List<String> _tiposIncidencia = [
    'Bota de basura ilegal',
    'Incendio forestal',
    'Tala indebida de árboles',
    'Contaminación de fuentes de agua',
    'Otro problema ambiental',
  ];

  Future<void> _guardarReporteEnSharedPreferences() async {
    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa el título del reporte')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? reportesExistentesString = prefs.getString('lista_reportes');
    List<dynamic> listaReportes = [];

    if (reportesExistentesString != null) {
      listaReportes = jsonDecode(reportesExistentesString);
    }

    final ahora = DateTime.now();
    final fechaFormateada = "${ahora.day}/${ahora.month}/${ahora.year}";

    final nuevoReporte = {
      'titulo': _tituloController.text.trim(),
      'tipo': _tipoProblema,
      'descripcion': _descripcionController.text.trim(),
      'fecha': fechaFormateada,
    };

    listaReportes.add(nuevoReporte);
    await prefs.setString('lista_reportes', jsonEncode(listaReportes));

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Reporte Guardado!'),
        content: Text('Tu reporte sobre "$_tipoProblema" se ha registrado con éxito en SharedPreferences.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Incidencia')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tipo de Problema Ambiental:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _tipoProblema,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _tiposIncidencia.map((String tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _tipoProblema = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título o ubicación corta',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción detallada del impacto o estado',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _guardarReporteEnSharedPreferences,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Reporte'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 6. LECTURA DE REPORTES DESDE SHARED PREFERENCES
// ==========================================
class VerIncidenciasScreen extends StatefulWidget {
  const VerIncidenciasScreen({super.key});

  @override
  State<VerIncidenciasScreen> createState() => _VerIncidenciasScreenState();
}

class _VerIncidenciasScreenState extends State<VerIncidenciasScreen> {
  List<dynamic> _listaReportes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _leerReportesDeSharedPreferences();
  }

  Future<void> _leerReportesDeSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final String? reportesExistentesString = prefs.getString('lista_reportes');

    if (reportesExistentesString != null) {
      setState(() {
        _listaReportes = jsonDecode(reportesExistentesString);
        _cargando = false;
      });
    } else {
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes Ambientales')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _listaReportes.isEmpty
          ? const Center(
        child: Text('No hay reportes registrados en SharedPreferences.'),
      )
          : ListView.builder(
        itemCount: _listaReportes.length,
        itemBuilder: (context, index) {
          final reporte = _listaReportes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.report_problem, color: Colors.orange),
              title: Text(reporte['titulo'] ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tipo: ${reporte['tipo']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(reporte['descripcion'] ?? ''),
                ],
              ),
              trailing: Text(
                reporte['fecha'] ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}