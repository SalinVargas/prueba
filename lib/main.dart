
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//simular la api 
import 'dart:convert';

// Resultados de validación
enum ResultadoCedula {
  valida,
  longitud,
  provincia,
  digito,
}

// Función principal
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Verificador de cédula',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const VerificarCedula(),
    );
  }
}

class VerificarCedula extends StatefulWidget {
  const VerificarCedula({super.key});

  @override
  State<VerificarCedula> createState() =>
      _VerificarCedulaState();
}

class _VerificarCedulaState extends State<VerificarCedula> {

  final TextEditingController controller =
      TextEditingController();

  // Almacenamiento seguro
  final FlutterSecureStorage storage =
      const FlutterSecureStorage();

  bool verificada = false;
  bool valida = false;
  String mensaje = '';

  // Recuperar cédula guardada al iniciar
  @override
  void initState() {
    super.initState();
    cargarCedula();
  }

  Future<void> cargarCedula() async {
    try {
      final cedulaGuardada = await storage.read(
        key: 'cedula',
      );

      if (!mounted) return;

      if (cedulaGuardada != null) {
        setState(() {
          controller.text = cedulaGuardada;
        });
      }
    } catch (e) {
      debugPrint('Error al recuperar cédula');
    }
  }

  // Validar cédula ecuatoriana
  ResultadoCedula validarCedula(String cedula) {

    // Verificar longitud
    if (cedula.length != 10) {
      return ResultadoCedula.longitud;
    }



    // Obtener provincia
    int provincia = int.parse(cedula.substring(0, 2));

    if (provincia < 1 || provincia > 24) {
      return ResultadoCedula.provincia;
    }



    // Algoritmo módulo 10
    int suma = 0;

    for (int i = 0; i < 9; i++) {
      int numero = int.parse(cedula[i]);

      if (i % 2 == 0) {
        numero *= 2;

        if (numero > 9) {
          numero -= 9;
        }
      }

      suma += numero;
    }

    // Calcular dígito verificador
    int verificador = (10 - (suma % 10)) % 10;

    // Comparar dígito verificador
    if (verificador != int.parse(cedula[9])) {
      return ResultadoCedula.digito;
    }

    return ResultadoCedula.valida;
  }

  // Verificar y guardar cédula
  Future<void> verificar() async {

    final cedula = controller.text.trim();

    final resultado = validarCedula(cedula);

    // Guardar únicamente si la cédula es válida
    if (resultado == ResultadoCedula.valida) {
      try {
        await storage.write(
          key: 'cedula',
          value: cedula,
        );
      } catch (e) {
        debugPrint('Error al guardar cédula');
      }
    }

    if (!mounted) return;

    setState(() {
      verificada = true;

      switch (resultado) {

        case ResultadoCedula.valida:
          valida = true;
          mensaje = 'Cédula válida';
          break;

        case ResultadoCedula.longitud:
          valida = false;
          mensaje =
              'Cédula inválida: debe contener exactamente 10 dígitos';
          break;


        case ResultadoCedula.provincia:
          valida = false;
          mensaje =
              'Cédula inválida: código de provincia incorrecto';
          break;

        case ResultadoCedula.digito:
          valida = false;
          mensaje =
              'Cédula inválida: dígito verificador incorrecto';
          break;
      }
    });
  }

  // Eliminar cédula almacenada
  Future<void> eliminarCedula() async {
    await storage.delete(key: 'cedula');

    if (!mounted) return;

    setState(() {
      controller.clear();
      verificada = false;
      valida = false;
      mensaje = '';
    });
  }

  // Continuar a la siguiente pantalla
  void continuar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SegundaPantalla(),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      appBar: AppBar(
        title: const Text('Verificación de identidad'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            child: Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Icon(
                    Icons.verified_user,
                    size: 65,
                    color: Colors.blue,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Verifica tu cédula',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Ingresa tu número de cédula ecuatoriana '
                    'para continuar.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 25),

                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    maxLength: 10,

                    onChanged: (_) {
                      setState(() {
                        verificada = false;
                        valida = false;
                        mensaje = '';
                      });
                    },

                    decoration: InputDecoration(
                      labelText: 'Número de cédula',
                      hintText: 'Ej. 1712345678',
                      prefixIcon: const Icon(Icons.badge),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: verificar,
                      child: const Text('VERIFICAR'),
                    ),
                  ),

                  const SizedBox(height: 15),

                  if (verificada)
                    Text(
                      mensaje,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: valida ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton(
                      onPressed: valida && verificada
                          ? continuar
                          : null,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),

                      child: const Text(
                        'CONTINUAR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Botón para eliminar cédula guardada
                  TextButton(
                    onPressed: eliminarCedula,
                    child: const Text(
                      'Eliminar cédula guardada',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// construir la pantalla y simulacion del consumo. json para la llamada API 
class Producto {
  final String nombre;
  final int cantidad;
  final double precio;
  final double subtotal;

  Producto({
    required this.nombre,
    required this.cantidad,
    required this.precio,
    required this.subtotal,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      nombre: json['nombre'],
      cantidad: json['cantidad'],
      precio: (json['precio'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}

class Pulsera {
  final String id;
  final String local;
  final String cedula;
  final double total;
  final bool activo;
  final List<Producto> productos;

  Pulsera({
    required this.id,
    required this.local,
    required this.cedula,
    required this.total,
    required this.activo,
    required this.productos,
  });

  factory Pulsera.fromJson(Map<String, dynamic> json) {
    return Pulsera(
      id: json['id'],
      local: json['local'],
      cedula: json['cedula'],
      total: (json['total'] as num).toDouble(),
      activo: json['activo'],
      productos: (json['productos'] as List)
          .map((p) => Producto.fromJson(p))
          .toList(),
    );
  }
}

//simula las api , indicando valores que ya tiene cada una de ellas 
class SimuladorApi {

  static Future<List<Pulsera>> obtenerPulseras({
    required String cedula,
    required bool forzarError,
  }) async {

    // Simular tiempo de respuesta del servidor
    await Future.delayed(const Duration(seconds: 2));

    // Forzar error para pruebas
    if (forzarError) {
      throw Exception('Error de conexión con el servidor');
    }

    // Simulación de respuesta JSON
    final jsonSimulado = '''
    [
      {
        "id": "PX-00451",
        "local": "KATARI whimper",
        "cedula": "$cedula",
        "total": 18.50,
        "activo": true,
        "productos": [
          {
            "nombre": "consumo diskoteka",
            "cantidad": 2,
            "precio": 5.00,
            "subtotal": 10.00
          },
          {
            "nombre": "snacks",
            "cantidad": 3,
            "precio": 1.50,
            "subtotal": 4.50
          },
          {
            "nombre": "Bebida",
            "cantidad": 2,
            "precio": 2.00,
            "subtotal": 4.00
          }
        ]
      },
      {
        "id": "PX-00452",
        "local": "KATARI Cumbayá",
        "cedula": "$cedula",
        "total": 12.00,
        "activo": false,
        "productos": [
          {
            "nombre": "alitas",
            "cantidad": 1,
            "precio": 5.00,
            "subtotal": 5.00
          },
          {
            "nombre": "vino",
            "cantidad": 4,
            "precio": 1.50,
            "subtotal": 6.00
          },
          {
            "nombre": "Agua",
            "cantidad": 1,
            "precio": 1.00,
            "subtotal": 1.00
          }
        ]
      },
      {
        "id": "PX-00453",
        "local": "KATARI PLAZA",
        "cedula": "$cedula",
        "total": 7.50,
        "activo": false,
        "productos": [
          {
            "nombre": "cerveza",
            "cantidad": 5,
            "precio": 1.50,
            "subtotal": 7.50
          }
        ]
      }
    ]
    ''';

    // Convertir JSON a objetos Dart
    final List<dynamic> datos = jsonDecode(jsonSimulado);

    return datos.map((item) {
      return Pulsera.fromJson(item);
    }).toList();
  }
}



// Segunda pantalla

class SegundaPantalla extends StatefulWidget {
  const SegundaPantalla({super.key});

  @override
  State<SegundaPantalla> createState() => _SegundaPantallaState();
}

class _SegundaPantallaState extends State<SegundaPantalla> {

  final FlutterSecureStorage storage =
      const FlutterSecureStorage();

  List<Pulsera> pulseras = [];

  String cedula = '';
  String? error;

  bool cargando = true;

  // VARIABLE PARA FORZAR ERRORES
  bool forzarError = false;

  @override
  void initState() {
    super.initState();
    cargarPulseras();
  }

  // Consultar API
  Future<void> cargarPulseras() async {

    setState(() {
      cargando = true;
      error = null;
    });

    try {

      // Recuperar cédula del almacenamiento seguro
      final cedulaGuardada = await storage.read(
        key: 'cedula',
      );

      if (cedulaGuardada == null ||
          cedulaGuardada.isEmpty) {
        throw Exception('No existe una cédula guardada');
      }

      cedula = cedulaGuardada;

      // Consultar API simulada
      final resultado = await SimuladorApi.obtenerPulseras(
        cedula: cedula,
        forzarError: forzarError,
      );

      if (!mounted) return;

      setState(() {
        pulseras = resultado;
        cargando = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        cargando = false;
        error = e.toString().replaceFirst('Exception: ', '');
        pulseras = [];
      });
    }
  }

  // Mostrar detalle de pulsera
  void mostrarDetalle(Pulsera pulsera) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),

      builder: (context) {

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [

                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Detalle de pulsera',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text('ID: ${pulsera.id}'),

                  Text('Local: ${pulsera.local}'),

                  Text('Cédula: ${pulsera.cedula}'),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Text('Estado: '),

                      Chip(
                        label: Text(
                          pulsera.activo ? 'ACTIVA' : 'INACTIVA',
                        ),
                        backgroundColor: pulsera.activo
                            ? Colors.green[100]
                            : Colors.grey[300],
                      ),
                    ],
                  ),

                  const Divider(height: 30),

                  const Text(
                    'Productos consumidos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  ...pulsera.productos.map((producto) {

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.blue,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Text(
                                  producto.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Text(
                                  'Cantidad: ${producto.cantidad}',
                                ),

                                Text(
                                  'Precio: \$${producto.precio.toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                          ),

                          Text(
                            '\$${producto.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      const Text(
                        'TOTAL CONSUMIDO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        '\$${pulsera.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CERRAR'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Consulta de pulseras'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [

          // Información de la cédula
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  'Cliente identificado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text('Cédula: ${cedula.isEmpty ? "Consultando..." : cedula}'),
              ],
            ),
          ),

          // Control para demostrar errores
          SwitchListTile(
            title: const Text(
              'Forzar error de conexión',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            subtitle: const Text(
              'Activar para simular un fallo de API',
            ),

            value: forzarError,

            onChanged: (valor) {
              setState(() {
                forzarError = valor;
              });

              cargarPulseras();
            },
          ),

          const Divider(height: 1),

          // Estados de la consulta
          Expanded(
            child: Builder(
              builder: (context) {

                // ESTADO DE CARGA
                if (cargando) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        CircularProgressIndicator(),

                        SizedBox(height: 20),

                        Text(
                          'Consultando pulseras...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          'Esperando respuesta del servidor',
                        ),
                      ],
                    ),
                  );
                }

                // ESTADO DE ERROR
                if (error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(25),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 65,
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            'Error de conexión',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),

                          const SizedBox(height: 25),

                          ElevatedButton.icon(
                            onPressed: cargarPulseras,
                            icon: const Icon(Icons.refresh),
                            label: const Text('REINTENTAR'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ESTADO SIN DATOS
                if (pulseras.isEmpty) {
                  return const Center(
                    child: Text('No existen pulseras registradas'),
                  );
                }

                // ESTADO CON DATOS
                return ListView.builder(
                  padding: const EdgeInsets.all(16),

                  itemCount: pulseras.length,

                  itemBuilder: (context, index) {

                    final pulsera = pulseras[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 3,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),

                        onTap: () {
                          mostrarDetalle(pulsera);
                        },

                        child: Padding(
                          padding: const EdgeInsets.all(16),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                children: [

                                  Text(
                                    pulsera.id,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Chip(
                                    label: Text(
                                      pulsera.activo
                                          ? 'ACTIVA'
                                          : 'INACTIVA',
                                    ),

                                    backgroundColor: pulsera.activo
                                        ? Colors.green[100]
                                        : Colors.grey[300],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Text('Local: ${pulsera.local}'),

                              Text('Cédula: ${pulsera.cedula}'),

                              const Divider(height: 25),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                children: [

                                  const Text(
                                    'Total consumido',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  Text(
                                    '\$${pulsera.total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Ver detalle ',
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
