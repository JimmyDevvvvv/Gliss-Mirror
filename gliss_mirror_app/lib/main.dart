import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/maya_service.dart';
import 'screens/analyze_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/floating_maya_widget.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MayaService()..initialize(),
      child: const GlissApp(),
    ),
  );
}

class GlissApp extends StatelessWidget {
  const GlissApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Gliss Mirror",
      theme: ThemeData(
        primarySwatch: Colors.pink,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
          brightness: Brightness.light,
        ),
      ),
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AnalyzeScreen(),
    InsightsScreen(),
  ];

  final List<String> _titles = const [
    "Hair Analyzer",
    "Insights & History",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    
    // Check for proactive notifications when app opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mayaService = Provider.of<MayaService>(context, listen: false);
      mayaService.checkForProactiveNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.pinkAccent, Colors.purpleAccent],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.face,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(_titles[_selectedIndex]),
          ],
        ),
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Current screen
          _screens[_selectedIndex],
          
          // Maya floats on top of everything
          const FloatingMaya(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: "Analyze",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: "Insights",
          ),
        ],
      ),
    );
  }
}