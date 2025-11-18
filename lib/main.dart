import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Duración del splash
const Duration kSplashDuration = Duration(seconds: 3);

/// ==========================
///   MAIN
/// ==========================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa Firebase
  runApp(const MyApp());
}

/// ==========================
///   APP ROOT
/// ==========================
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
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        MainPage.routeName: (_) => const MainPage(),
      },
    );
  }
}

/// ==========================
///   SPLASH SCREEN
/// ==========================
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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scaleIn = Tween<double>(begin: 0.95, end: 1.0).animate(_controller);

    Future.delayed(kSplashDuration, () {
      Navigator.pushReplacementNamed(context, MainPage.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black45, Colors.transparent, Colors.black45],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          FadeTransition(
            opacity: _fadeIn,
            child: ScaleTransition(
              scale: _scaleIn,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Diseño de aplicaciones móviles',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    _PillProgress(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
      ),
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 10),
            Text('Cargando...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

/// =======================================
///   HELPERS GLOBALES (IMPORTANTE)
/// =======================================
String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

String formatMeters(double m) =>
    '${m.toStringAsFixed(m >= 1 ? 2 : 1)} m';

String formatKg(double kg) =>
    '${kg.toStringAsFixed(1)} kg';

/// =======================================
///   MODELOS
/// =======================================
class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  Pokemon({required this.id, required this.name, required this.imageUrl});

  factory Pokemon.fromListItem(Map<String, dynamic> json) {
    final name = json['name'];
    final url = json['url'];
    final id = int.parse(RegExp(r'pokemon/(\d+)/')
        .firstMatch(url)!
        .group(1)!);

    return Pokemon(
      id: id,
      name: name,
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
    );
  }
}

class PokemonDetail {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final double heightMeters;
  final double weightKg;
  final Map<String, int> stats;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.heightMeters,
    required this.weightKg,
    required this.stats,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final artwork =
        json['sprites']['other']['official-artwork']['front_default'] ??
            json['sprites']['front_default'];

    return PokemonDetail(
      id: json['id'],
      name: json['name'],
      imageUrl: artwork,
      types: (json['types'] as List)
          .map((e) => e['type']['name'] as String)
          .toList(),
      heightMeters: json['height'] / 10,
      weightKg: json['weight'] / 10,
      stats: {
        for (var s in json['stats'])
          s['stat']['name']: s['base_stat'],
      },
    );
  }
}

/// =======================================
///   API CALLS
/// =======================================
Future<List<Pokemon>> fetchPokemon({int limit = 50}) async {
  final uri = Uri.parse(
      'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=0');

  final res = await http.get(uri);

  if (res.statusCode != 200) {
    throw Exception('Error al obtener Pokémon');
  }

  final list = json.decode(res.body)['results'] as List;

  return list.map((e) => Pokemon.fromListItem(e)).toList();
}

Future<PokemonDetail> fetchPokemonDetail(int id) async {
  final res = await http.get(
    Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'),
  );

  if (res.statusCode != 200) {
    throw Exception('Error al cargar detalle');
  }

  return PokemonDetail.fromJson(json.decode(res.body));
}

/// =======================================
///   FIREBASE SAVE
/// =======================================
Future<bool> savePokemonSelection(Pokemon pokemon) async {
  try {
    await FirebaseFirestore.instance.collection('pokemonSelections').add({
      'pokemonId': pokemon.id,
      'name': pokemon.name,
      'imageUrl': pokemon.imageUrl,
      'selectedAt': DateTime.now().toIso8601String(),
      'studentName': 'Eduardo Ceja Robles',
    });

    return true;
  } catch (e) {
    print('Error Firebase: $e');
    return false;
  }
}

/// =======================================
///   MAIN PAGE (ACTUALIZADA)
/// =======================================
class MainPage extends StatelessWidget {
  static const routeName = '/main';
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Pokémon'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ============================
            // ENCABEZADO DE ACTIVIDAD
            // ============================
            const Text(
              'Materia: Diseño de aplicaciones móviles',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            const Text(
              'Actividad: 3.7. Integración de base de datos',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            const Text(
              'Asesora: Lotzy Beatriz Fonseca Chiu',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
                        const Text(
              'Alumno: Eduardo Ceja Robles',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Fecha: 17/11/2025',
              style: TextStyle(
                  fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            // Título Pokémon
            Row(
              children: [
                Icon(Icons.catching_pokemon,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Pokémon (PokeAPI)',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ============================
            // LISTA DE POKÉMON
            // ============================
            Expanded(
              child: FutureBuilder<List<Pokemon>>(
                future: fetchPokemon(limit: 50),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final pokemons = snapshot.data!;

                  return ListView.separated(
                    itemCount: pokemons.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, index) {
                      final p = pokemons[index];

                      return ListTile(
                        leading: Image.network(p.imageUrl, width: 50),
                        title: Text(capitalize(p.name)),
                        subtitle: Text('ID: ${p.id}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final ok = await savePokemonSelection(p);

                          // Borrar banners anteriores
                          messenger.clearMaterialBanners();

                          // Banner verde o rojo
                          messenger.showMaterialBanner(
                            MaterialBanner(
                              backgroundColor:
                                  ok ? Colors.green : Colors.red,
                              leading: Icon(
                                ok ? Icons.check_circle : Icons.error,
                                color: Colors.white,
                              ),
                              content: Text(
                                ok
                                    ? 'Registro guardado exitosamente en Firebase.'
                                    : 'Error al guardar en Firebase.',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => messenger
                                      .hideCurrentMaterialBanner(),
                                  child: const Text(
                                    'Cerrar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          );

                          // Auto-hide banner
                          Future.delayed(const Duration(seconds: 3), () {
                            if (messenger.mounted) {
                              messenger.hideCurrentMaterialBanner();
                            }
                          });

                          _showPokemonDetailModal(context, p.id);
                        },
                      );
                    },
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

/// =======================================
///   MODAL DETALLE
/// =======================================
Future<void> _showPokemonDetailModal(
    BuildContext context, int id) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return FutureBuilder<PokemonDetail>(
        future: fetchPokemonDetail(id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final p = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${capitalize(p.name)} (#${p.id})',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Image.network(p.imageUrl, height: 120),
                const SizedBox(height: 20),
                Text('Tipos: ${p.types.join(", ")}'),
                Text('Altura: ${formatMeters(p.heightMeters)}'),
                Text('Peso: ${formatKg(p.weightKg)}'),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
}


