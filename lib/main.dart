import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Duración del splash
const Duration kSplashDuration = Duration(seconds: 3);

/// Usuario y contraseña hardcodeados para el login
const String kHardcodedUsername = 'usuario@test.com';
const String kHardcodedPassword = '123456';

/// Usuario administrador
const String kAdminUsername = 'admin@test.com';
const String kAdminPassword = 'admin123';

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
        LoginPage.routeName: (_) => const LoginPage(),
        MainPage.routeName: (_) => const MainPage(),
        AdminPage.routeName: (_) => const AdminPage(),
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
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
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
///   LOGIN / PANTALLA DE INICIO
/// =======================================
class LoginPage extends StatefulWidget {
  static const routeName = '/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simular pequeña espera de login
    await Future.delayed(const Duration(milliseconds: 600));

    final user = _userController.text.trim();
    final pass = _passwordController.text;

    if (user == kAdminUsername && pass == kAdminPassword) {
      // Admin → va a pantalla de administración
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AdminPage.routeName);
    } else if (user == kHardcodedUsername && pass == kHardcodedPassword) {
      // Usuario normal → va al catálogo
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, MainPage.routeName);
    } else {
      // Credenciales incorrectas
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario o contraseña incorrectos'),
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showRegisterDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Registro de usuario'),
          content: const Text(
            'Esta es una simulación de registro.\n\n'
            'Para acceder usa:\n'
            'Usuario: usuario@test.com\n'
            'Contraseña: 123456\n\n'
            'En una app real, aquí se guardarían los datos '
            'en una base de datos o en Firebase Auth.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.movie,
                  size: 72,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Bienvenido',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aplicación de ejemplo\nDiseño de aplicaciones móviles',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // -------- Formulario ----------
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _userController,
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          hintText: 'usuario@test.com',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el usuario';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa la contraseña';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Botón de ingresar
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Ingresar'),
                  ),
                ),

                const SizedBox(height: 12),

                // Botón de registro simulado
                TextButton(
                  onPressed: _showRegisterDialog,
                  child: const Text('Registrarse'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =======================================
///   MODELO DE PELÍCULA Y CATÁLOGO
/// =======================================
class Movie {
  final String title;
  final String imageUrl;
  final String tag; // idioma / categoría
  final String year; // Año
  final String director; // Director
  final String genre; // Género
  final String synopsis; // Sinopsis

  Movie({
    required this.title,
    required this.imageUrl,
    required this.tag,
    required this.year,
    required this.director,
    required this.genre,
    required this.synopsis,
  });
}

final List<Movie> kMovies = [
  Movie(
    title: 'El Conjuro 4: Last Rites',
    tag: 'English',
    year: '2025',
    director: 'Michael Chaves',
    genre: 'Terror, Sobrenatural',
    synopsis:
        'Los investigadores paranormales Ed y Lorraine Warren enfrentan uno de los casos más peligrosos de sus carreras, enfrentándose a una presencia demoniaca más poderosa que cualquier otra vista anteriormente.',
    imageUrl:
        'https://play-lh.googleusercontent.com/UkmdZlGJu-qcy3ue7IidfF2l3WD9BbNPcchOToBnYQHg6zORNuPSFKy5Xt8NbYQ7MpxyZz1KaBt7AJV5yoVB=w240-h480-rw',
  ),
  Movie(
    title: 'Avengers: Endgame',
    tag: 'English',
    year: '2019',
    director: 'Anthony y Joe Russo',
    genre: 'Acción, Ciencia ficción',
    synopsis:
        'Los Vengadores restantes deben revertir el chasquido de Thanos y restaurar el universo.',
    imageUrl:
        'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
  ),
  Movie(
    title: 'Interstellar',
    tag: 'English',
    year: '2014',
    director: 'Christopher Nolan',
    genre: 'Ciencia ficción, Drama',
    synopsis:
        'Un grupo de exploradores viaja a través de un agujero de gusano en busca de un nuevo hogar para la humanidad.',
    imageUrl:
        'https://image.tmdb.org/t/p/w500/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg',
  ),
  Movie(
    title: 'The Dark Knight',
    tag: 'English',
    year: '2008',
    director: 'Christopher Nolan',
    genre: 'Acción, Crimen',
    synopsis:
        'Batman se enfrenta al Joker, un criminal caótico que quiere sumir a Ciudad Gótica en la anarquía.',
    imageUrl:
        'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
  ),
  Movie(
    title: 'Spider-Man: No Way Home',
    tag: 'English',
    year: '2021',
    director: 'Jon Watts',
    genre: 'Acción, Superhéroes',
    synopsis:
        'Peter Parker pide ayuda al Doctor Strange y provoca la apertura del multiverso.',
    imageUrl:
        'https://image.tmdb.org/t/p/w500/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg',
  ),
  Movie(
    title: 'Harry Potter',
    tag: 'English',
    year: '2001',
    director: 'Chris Columbus',
    genre: 'Fantasía, Aventura',
    synopsis:
        'Un niño descubre que es un mago y comienza su aventura en el Colegio Hogwarts de Magia y Hechicería.',
    imageUrl:
        'https://somosdecine.com/wp-content/uploads/harry-potter-saga-poster-1.jpg',
  ),
  Movie(
    title: 'Toy Story',
    tag: 'Animated',
    year: '1995',
    director: 'John Lasseter',
    genre: 'Animación, Familiar',
    synopsis:
        'Los juguetes de Andy cobran vida cuando los humanos no están y deben lidiar con la llegada de Buzz Lightyear.',
    imageUrl:
        'https://image.tmdb.org/t/p/w500/uXDfjJbdP4ijW5hWSBrPrlKpxab.jpg',
  ),
  Movie(
    title: 'Star Wars',
    tag: 'English',
    year: '1977',
    director: 'George Lucas',
    genre: 'Ciencia ficción, Aventura',
    synopsis:
        'Luke Skywalker se une a la Alianza Rebelde para enfrentarse al Imperio Galáctico y destruir la Estrella de la Muerte.',
    imageUrl:
        'https://i.blogs.es/23bbf2/starwars-stylec/450_1000.jpg',
  ),
];

/// =======================================
///   MAIN PAGE: HOME / CATÁLOGO PELÍCULAS
/// =======================================
class MainPage extends StatefulWidget {
  static const routeName = '/main';
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController(viewportFraction: 0.9);

  final List<String> _genres = [
    'English',
    'Gujarati',
    'South Indian',
    'Animated',
  ];
  int _selectedGenreIndex = 0;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // gris carbón
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2E2E2E), // gris oscuro
                Color(0xFF4B4B4B), // gris más claro
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ============================
            /// ENCABEZADO ACTIVIDAD CENTRADO
            /// ============================
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 380,
                ),
                child: Card(
                  color: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Materia: Diseño de aplicaciones móviles',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Actividad: Producto Integrador',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Asesora: Lotzy Beatriz Fonseca Chiu',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Alumno: Eduardo Ceja Robles',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Fecha: 29/11/2025',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ============================
            /// CARRUSEL DESTACADO
            /// ============================
            Text(
              'Destacadas',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 210,
              child: PageView.builder(
                controller: _pageController,
                itemCount: kMovies.length,
                itemBuilder: (context, index) {
                  final movie = kMovies[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        _showMovieDetailModal(context, movie);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Imagen de fondo
                            Image.network(
                              movie.imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('Error cargando imagen: $error');
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),

                            // Overlay oscuro
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.8),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),

                            // TAG categoría
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF555555),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  movie.tag,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),

                            // Título + reseñas
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 18,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: const [
                                      Icon(Icons.star,
                                          size: 14, color: Colors.amber),
                                      SizedBox(width: 4),
                                      Text(
                                        '4.8 • 1.2k reviews',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            /// ============================
            /// PUNTITOS DEL CARRUSEL
            /// ============================
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(kMovies.length, (index) {
                  final isActive = (index - _currentPage).abs() < 0.5;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

            /// ============================
            /// CATEGORÍAS (chips)
            /// ============================
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _genres.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = index == _selectedGenreIndex;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedGenreIndex = index;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4A4A4A) // gris claro
                            : const Color(0xFF2A2A2A), // gris oscuro
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _genres[index],
                        style: TextStyle(
                          color:
                              isSelected ? Colors.white : Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            /// ============================
            /// LATEST MOVIE
            /// ============================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Latest Movie',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'See all',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kMovies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final movie = kMovies[index];
                  return GestureDetector(
                    onTap: () {
                      _showMovieDetailModal(context, movie);
                    },
                    child: SizedBox(
                      width: 130,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                movie.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            movie.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

/// =======================================
///   MODAL DETALLE DE PELÍCULA
/// =======================================
Future<void> _showMovieDetailModal(
  BuildContext context,
  Movie movie,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF222222),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Handle" superior
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      movie.imageUrl,
                      width: 100,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Título y datos básicos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Año: ${movie.year}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Director: ${movie.director}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Género: ${movie.genre}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                'Sinopsis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                movie.synopsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}

/// =======================================
///   PANTALLA DE ADMINISTRACIÓN DE CATÁLOGO
/// =======================================
class AdminPage extends StatefulWidget {
  static const routeName = '/admin';

  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _directorCtrl = TextEditingController();
  final _genreCtrl = TextEditingController();
  final _synopsisCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _yearCtrl.dispose();
    _directorCtrl.dispose();
    _genreCtrl.dispose();
    _synopsisCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _addMovie() async {
    if (!_formKey.currentState!.validate()) return;

    final movie = Movie(
      title: _titleCtrl.text.trim(),
      year: _yearCtrl.text.trim(),
      director: _directorCtrl.text.trim(),
      genre: _genreCtrl.text.trim(),
      synopsis: _synopsisCtrl.text.trim(),
      imageUrl: _imageUrlCtrl.text.trim(),
      tag: 'Custom', // etiqueta genérica para admin
    );

    try {
      // 1) Guardar registro en Firebase (colección de catálogo)
      await FirebaseFirestore.instance.collection('moviesCatalog').add({
        'title': movie.title,
        'year': movie.year,
        'director': movie.director,
        'genre': movie.genre,
        'synopsis': movie.synopsis,
        'imageUrl': movie.imageUrl,
        'tag': movie.tag,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': kAdminUsername, // admin@test.com
      });

      // 2) Actualizar la lista en memoria para que se vea en la app
      setState(() {
        kMovies.add(movie);
      });

      // 3) Feedback al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Película agregada y registrada en Firebase'),
        ),
      );

      // 4) Limpiar formulario
      _titleCtrl.clear();
      _yearCtrl.clear();
      _directorCtrl.clear();
      _genreCtrl.clear();
      _synopsisCtrl.clear();
      _imageUrlCtrl.clear();
    } catch (e, st) {
      debugPrint('Error guardando película en Firebase: $e');
      debugPrintStack(stackTrace: st);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar en Firebase'),
        ),
      );
    }
  }

  Future<void> _removeMovie(int index) async {
    final removed = kMovies[index];

    setState(() {
      kMovies.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Película "${removed.title}" eliminada')),
    );

    // Registrar la baja en Firebase (log de auditoría)
    try {
      await FirebaseFirestore.instance.collection('moviesDeletions').add({
        'title': removed.title,
        'year': removed.year,
        'director': removed.director,
        'genre': removed.genre,
        'synopsis': removed.synopsis,
        'imageUrl': removed.imageUrl,
        'tag': removed.tag,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': kAdminUsername,
      });
    } catch (e) {
      debugPrint('Error registrando baja en Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Administrar catálogo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // título e íconos en negro
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, LoginPage.routeName);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ============================
              // FORMULARIO ALTA PELÍCULA
              // ============================
              Card(
                color: Colors.white.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dar de alta película',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _titleCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Título',
                              labelStyle: TextStyle(color: Colors.white70),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Ingresa el título'
                                : null,
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _yearCtrl,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Año',
                              labelStyle: TextStyle(color: Colors.white70),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Ingresa el año'
                                : null,
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _directorCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Director',
                              labelStyle: TextStyle(color: Colors.white70),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Ingresa el director'
                                : null,
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _genreCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Género',
                              labelStyle: TextStyle(color: Colors.white70),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Ingresa el género'
                                : null,
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _synopsisCtrl,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Sinopsis',
                              labelStyle: TextStyle(color: Colors.white70),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Ingresa la sinopsis'
                                : null,
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            controller: _imageUrlCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'URL de imagen',
                              labelStyle: TextStyle(color: Colors.white70),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Ingresa la URL de la imagen'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _addMovie,
                              child: const Text('Agregar película'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ============================
              // LISTA DE PELÍCULAS (BAJA)
              // ============================
              Expanded(
                child: Card(
                  color: Colors.white.withOpacity(0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: kMovies.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay películas en el catálogo',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: kMovies.length,
                            separatorBuilder: (_, __) =>
                                const Divider(color: Colors.white24),
                            itemBuilder: (context, index) {
                              final movie = kMovies[index];
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    movie.imageUrl,
                                    width: 50,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.movie,
                                            color: Colors.white70),
                                  ),
                                ),
                                title: Text(
                                  movie.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${movie.year} • ${movie.genre}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _removeMovie(index),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
