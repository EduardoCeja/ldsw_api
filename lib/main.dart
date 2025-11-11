import 'dart:async';
import 'dart:convert';
import 'dart:ui'; // ← Necesario para ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

/// Duración configurable del Splash.
/// Recomendado: segundos (p. ej., 3–5 s).
/// Si quieres "unos minutos", cambia a Duration(minutes: 2)
const Duration kSplashDuration = Duration(minutes: 1); // <- opción en minutos

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diseño de aplicaciones móviles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      // Ruta inicial: Splash
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        MainPage.routeName: (_) => const MainPage(),
      },
    );
  }
}

/// Splash / Home Screen animado con imagen de fondo
class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Animaciones: Fade + Scale
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scaleIn = Tween<double>(begin: 0.95, end: 1.0).animate(_controller);

    // Timer para navegar al main
    _timer = Timer(kSplashDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(MainPage.routeName);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Extiende contenido bajo status bar
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo original
          Image.asset(
            'assets/images/bg.jpg',
            fit: BoxFit.cover,
          ),

          // Aplicar difuminado (blur)
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 5.0, // ← intensidad horizontal del blur
              sigmaY: 5.0, // ← intensidad vertical del blur
            ),
            child: Container(
              color: Colors.black.withOpacity(0.2), // oscurece un poco el fondo
            ),
          ),

          // Capa de degradado para mejorar legibilidad del texto
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black45, Colors.transparent, Colors.black45],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Contenido centrado con animación
          FadeTransition(
            opacity: _fadeIn,
            child: ScaleTransition(
              scale: _scaleIn,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nombre de la app
                      Text(
                        'Diseño de aplicaciones móviles',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.white, // color negro
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Mensaje de bienvenida
                      Text(
                        '¡Bienvenido! Explora los widgets y la UI en Flutter.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: Colors.white70, // color negro suave
                              fontWeight: FontWeight.w500,
                            ),
                      ),

                      const SizedBox(height: 28),

                      // Indicador sutil de progreso
                      const _PillProgress(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicador de progreso tipo "pill" (estético)
class _PillProgress extends StatelessWidget {
  const _PillProgress();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black26),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child:
                  CircularProgressIndicator(strokeWidth: 2.4, color: Colors.black),
            ),
            SizedBox(width: 10),
            Text('Cargando...',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

/// ==========================
///  Modelos y consumo API
/// ==========================

/// Modelo básico de Pokémon (para la lista)
class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  /// Construye desde el item de la lista /pokemon (name + url)
  /// Extraemos el id desde el campo "url" y armamos el sprite oficial.
  factory Pokemon.fromListItem(Map<String, dynamic> json) {
    final String name = json['name'];
    final String url = json['url']; // .../pokemon/25/
    final idMatch = RegExp(r'pokemon/(\d+)/').firstMatch(url);
    final int id = int.parse(idMatch!.group(1)!);

    // Sprite público mantenido por PokeAPI
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

    return Pokemon(id: id, name: name, imageUrl: imageUrl);
  }
}

/// Detalle de Pokémon (para el modal)
class PokemonDetail {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final double heightMeters; // PokeAPI: decímetros → m
  final double weightKg;     // PokeAPI: hectogramos → kg
  final Map<String, int> baseStats; // hp, attack, defense, sp-attack, sp-defense, speed

  PokemonDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.heightMeters,
    required this.weightKg,
    required this.baseStats,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;

    // sprite "official-artwork" si está disponible; si no, fallback al front_default
    String? artwork = json['sprites']?['other']?['official-artwork']?['front_default'];
    artwork ??= json['sprites']?['front_default'];

    // tipos
    final typesList = (json['types'] as List)
        .map<String>((t) => (t['type']['name'] as String))
        .toList();

    // stats
    final statsRaw = (json['stats'] as List);
    final Map<String, int> stats = {
      for (final s in statsRaw) (s['stat']['name'] as String): (s['base_stat'] as int),
    };

    // alturas y peso (conversiones)
    final heightMeters = (json['height'] as int) / 10.0; // dm → m
    final weightKg = (json['weight'] as int) / 10.0;     // hg → kg

    return PokemonDetail(
      id: id,
      name: name,
      imageUrl: artwork ?? '',
      types: typesList,
      heightMeters: heightMeters,
      weightKg: weightKg,
      baseStats: stats,
    );
  }
}

/// Lista paginada (sin pedir detalle por cada uno)
Future<List<Pokemon>> fetchPokemon({int limit = 30, int offset = 0}) async {
  // 1) Construimos la URL con query params `limit` y `offset`
  final uri = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset');

  // 2) Hacemos la petición HTTP GET a PokeAPI
  final res = await http.get(uri);

  // 3) Validamos el código HTTP (200 = OK). Si no, lanzamos excepción.
  if (res.statusCode != 200) {
    throw Exception('Error al consultar PokeAPI: ${res.statusCode}');
  }

  // 4) Parseamos el cuerpo (JSON) a un Map
  final decoded = json.decode(res.body) as Map<String, dynamic>;

  // 5) Tomamos la lista "results" (cada item tiene `name` y `url`)
  final results = (decoded['results'] as List).cast<Map<String, dynamic>>();

  // (Opcional) Log para ver los IDs extraídos desde la URL de cada resultado
  for (var item in results) {
    final url = item['url'];
    final match = RegExp(r'pokemon/(\d+)/').firstMatch(url);
    if (match != null) {
      print('ID recibido desde lista: ${match.group(1)}');
    }
  }

  // 6) Convertimos cada item al modelo `Pokemon` (extrayendo id desde la URL)
  return results.map((e) => Pokemon.fromListItem(e)).toList();
}



/// Detalle por id
Future<PokemonDetail> fetchPokemonDetail(int id) async {
  // 1) Construimos la URL RESTful con el ID del Pokémon
  final uri = Uri.parse('https://pokeapi.co/api/v2/pokemon/$id');

  // 2) Hacemos la petición HTTP GET a PokeAPI
  final res = await http.get(uri);

  // (Opcional) Log para depurar qué ID se está consultando
  print('Consultando detalle de Pokémon con ID: $id');

  // 3) Validamos el código HTTP (200 = OK). Si no, lanzamos excepción.
  if (res.statusCode != 200) {
    throw Exception('Error al cargar detalle: ${res.statusCode}');
  }

  // 4) Parseamos el cuerpo (JSON) a un Map
  final decoded = json.decode(res.body) as Map<String, dynamic>;

  // (Opcional) Log del JSON completo recibido para inspección en consola
  print('JSON completo del Pokémon $id:\n${jsonEncode(decoded)}');

  // 5) Convertimos el Map al modelo `PokemonDetail` que usa la UI del modal
  return PokemonDetail.fromJson(decoded);
}



/// Helpers
String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String formatMeters(double m) => '${m.toStringAsFixed(m >= 1 ? 2 : 1)} m';
String formatKg(double kg) => '${kg.toStringAsFixed(1)} kg';

/// ==========================
///  Pantalla principal
/// ==========================
class MainPage extends StatelessWidget {
  static const routeName = '/main';
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Pokemon'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ======== Contenido informativo ========
            const Text(
              'Materia: Diseño de aplicaciones móviles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              '3.6. Peticiones HTTP',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            const Text('Asesora: Lotzy Beatriz Fonseca Chiu', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Alumno: Eduardo Ceja Robles', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text(
              'Fecha: 10/11/2025',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 30),
            const Text(
              'Hello World',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),

            // ======== Título de la sección de API ========
            Row(
              children: [
                Icon(Icons.catching_pokemon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Pokémon (PokeAPI)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ======== Lista (FutureBuilder) ========
            Expanded(
              child: FutureBuilder<List<Pokemon>>(
                future: fetchPokemon(limit: 50), // ajusta el límite si quieres
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Ocurrió un error al cargar: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  final data = snapshot.data;
                  if (data == null || data.isEmpty) {
                    return const Center(child: Text('No se encontraron Pokémon.'));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      // Simulación de refresh
                      await Future<void>.delayed(const Duration(milliseconds: 400));
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final p = data[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              p.imageUrl,
                              width: 48,
                              height: 48,
                              filterQuality: FilterQuality.medium,
                              errorBuilder: (context, error, stack) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),
                          title: Text(capitalize(p.name)),
                          subtitle: Text('ID: #${p.id}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                          print('Se seleccionó Pokémon con ID: ${p.id}');
                          _showPokemonDetailModal(context, p.id);
                        },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ==========================
///  Modal de Detalle
/// ==========================
Future<void> _showPokemonDetailModal(BuildContext context, int id) async {
  final theme = Theme.of(context);

  await showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) {
          return FutureBuilder<PokemonDetail>(
            future: fetchPokemonDetail(id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        'No se pudo cargar el detalle.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              }

              final d = snapshot.data!;
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    // Header
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            d.imageUrl.isNotEmpty
                                ? d.imageUrl
                                : 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
                            width: 84,
                            height: 84,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported, size: 64),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${capitalize(d.name)}  #${d.id}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: -6,
                                children: d.types
                                    .map((t) => Chip(
                                          label: Text(capitalize(t)),
                                          visualDensity: VisualDensity.compact,
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Medidas
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.height,
                            label: 'Altura',
                            value: formatMeters(d.heightMeters),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoTile(
                            icon: Icons.monitor_weight_outlined,
                            label: 'Peso',
                            value: formatKg(d.weightKg),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Stats
                    Text(
                      'Estadísticas base',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._buildStatsBars(context, d.baseStats),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Construye barras para stats conocidos; PokeAPI maneja hasta ~255 por stat.
/// Normalizamos a 255 para el progreso.
List<Widget> _buildStatsBars(BuildContext context, Map<String, int> stats) {
  final theme = Theme.of(context);
  final entries = <MapEntry<String, String>>[
    MapEntry('hp', 'HP'),
    MapEntry('attack', 'Ataque'),
    MapEntry('defense', 'Defensa'),
    MapEntry('special-attack', 'At. Esp.'),
    MapEntry('special-defense', 'Def. Esp.'),
    MapEntry('speed', 'Velocidad'),
  ];

  const maxStat = 255.0;

  return entries.map((e) {
    final val = stats[e.key] ?? 0;
    final progress = (val / maxStat).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 108,
                child: Text(
                  e.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                child: Text(
                  '$val',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }).toList();
}
