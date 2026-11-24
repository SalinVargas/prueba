import 'package:material_ui/material_ui.dart';



// Resultados 
enum ResultadoCedula {
  valida,
  longitud,
  formato,
  provincia,
  tercerDigito,
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

  bool verificada = false;
  bool valida = false;
  String mensaje = '';

  // Función para validar cédula ecuatoriana
  ResultadoCedula validarCedula(String cedula) {

    // Verificar longitud
    if (cedula.length != 10) {
      return ResultadoCedula.longitud;
    }

    // Verificar que contenga únicamente números
    if (!RegExp(r'^[0-9]{10}$').hasMatch(cedula)) {
      return ResultadoCedula.formato;
    }

    // Obtener código de provincia
    int provincia = int.parse(cedula.substring(0, 2));

    if (provincia < 1 || provincia > 24) {
      return ResultadoCedula.provincia;
    }

    // Verificar tercer dígito
    int tercerDigito = int.parse(cedula[2]);

    if (tercerDigito > 5) {
      return ResultadoCedula.tercerDigito;
    }

    // verifica los coeficientes 
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

  // Función para verificar si se cumpli o no con la valdiacion
  void verificar() {
    final cedula = controller.text.trim();

    final resultado = validarCedula(cedula);

    setState(() {
      verificada = true;

      switch (resultado) {
        case ResultadoCedula.valida:
          valida = true;
          mensaje = 'Cédula válida en su estructura';
          break;

        case ResultadoCedula.longitud:
          valida = false;
          mensaje =
              'Cédula inválida: debe contener exactamente 10 dígitos';
          break;

        case ResultadoCedula.formato:
          valida = false;
          mensaje =
              'Cédula inválida: solo se permiten números';
          break;

        case ResultadoCedula.provincia:
          valida = false;
          mensaje =
              'Cédula inválida: código de provincia incorrecto';
          break;

        case ResultadoCedula.tercerDigito:
          valida = false;
          mensaje =
              'Cédula inválida: tercer dígito incorrecto';
          break;

        case ResultadoCedula.digito:
          valida = false;
          mensaje =
              'Cédula inválida: dígito verificador incorrecto';
          break;
      }
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Segunda pantalla
class SegundaPantalla extends StatelessWidget {
  const SegundaPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Siguiente paso'),
      ),

      body: const Center(
        child: Text(
          '¡Verificación completada!\nBienvenido.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
