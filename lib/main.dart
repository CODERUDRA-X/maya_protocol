import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// --- 1. DATA MODELS ---
class Choice {
  final String text;
  final String outcome;
  final int resilienceChange;
  final int healthChange;

  Choice({required this.text, required this.outcome, required this.resilienceChange, required this.healthChange});
}

class Scenario {
  final String id;
  final String title;
  final String description;
  final List<Choice> choices;

  Scenario({required this.id, required this.title, required this.description, required this.choices});
}

// --- 2. GAME LOGIC ---
class GameProvider with ChangeNotifier {
  int _health = 80;
  int _resilience = 30;
  String _currentFeedback = "Initiating Maya Protocol... Breakdown the illusion.";
  
  // Scenario 1: The Pressure Cooker
  final Scenario currentScenario = Scenario(
    id: '1',
    title: 'PROTOCOL 1: The Exam Glitch',
    description: 'System Alert: Stress levels critical. Exam in 8 hours. \n\nA peer offers you a "Memory Booster" pill. It is unauthorized tech.',
    choices: [
      Choice(
        text: 'Accept the Glitch (Take Pill)',
        outcome: 'System Overload. Energy spike followed by total crash. Resilience compromised.',
        resilienceChange: -15,
        healthChange: -20,
      ),
      Choice(
        text: 'Reject & Reboot (Sleep)',
        outcome: 'System Reboot successful. Memory retention optimal. Resilience increased.',
        resilienceChange: 20,
        healthChange: 5,
      ),
    ],
  );

  int get health => _health;
  int get resilience => _resilience;
  String get feedback => _currentFeedback;

  void makeChoice(Choice choice) {
    _health += choice.healthChange;
    _resilience += choice.resilienceChange;
    _health = _health.clamp(0, 100);
    _resilience = _resilience.clamp(0, 100);
    _currentFeedback = choice.outcome;
    notifyListeners();
  }
}

// --- 3. UI SCREEN ---
void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GameProvider())],
      child: const MayaApp(),
    ),
  );
}

class MayaApp extends StatelessWidget {
  const MayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050505), // Pure Black
        primaryColor: const Color(0xFF00FFC2), // Neon Green/Cyan
        textTheme: GoogleFonts.rajdhaniTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: const Color(0xFF00FFC2),
        ),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final scenario = game.currentScenario;

    return Scaffold(
      appBar: AppBar(
        title: const Text("MAYA PROTOCOL", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Color(0xFF00FFC2))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
            IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF00FFC2)),
                onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FutureSelfScanner()));
                },
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- STATUS BARS ---
              Row(
                children: [
                  Expanded(child: _buildStatBar("SYSTEM INTEGRITY", game.health, Colors.redAccent)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildStatBar("WILLPOWER", game.resilience, const Color(0xFF00FFC2))),
                ],
              ),
              const SizedBox(height: 30),
        
              // --- IMAGE AREA ---
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xFF00FFC2).withOpacity(0.5)),
                  // Cyberpunk placeholder image
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=2070&auto=format&fit=crop'), 
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.lock_person, size: 50, color: Colors.white.withOpacity(0.5)),
                ),
              ),
              
              const SizedBox(height: 30),
        
              // --- SCENARIO CARD ---
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(color: const Color(0xFF00FFC2).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(scenario.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00FFC2))),
                    const SizedBox(height: 15),
                    Text(scenario.description, style: const TextStyle(fontSize: 16, height: 1.5), textAlign: TextAlign.center),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                "> ${game.feedback}",
                style: const TextStyle(color: Colors.yellowAccent, fontFamily: 'Courier', fontSize: 14),
                textAlign: TextAlign.center,
              ),
        
              const SizedBox(height: 30),
        
              // --- CHOICES ---
              ...scenario.choices.map((choice) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFF00FFC2),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    side: const BorderSide(color: Color(0xFF00FFC2)),
                    shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero), // Futuristic Sharp Edges
                  ),
                  onPressed: () => game.makeChoice(choice),
                  child: Text(choice.text.toUpperCase(), style: const TextStyle(fontSize: 16, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey[900],
          color: color,
          minHeight: 6,
        ),
      ],
    );
  }
}

// --- FAKE AI SCANNER ---
class FutureSelfScanner extends StatefulWidget {
  const FutureSelfScanner({super.key});

  @override
  State<FutureSelfScanner> createState() => _FutureSelfScannerState();
}

class _FutureSelfScannerState extends State<FutureSelfScanner> {
  bool isScanning = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if(mounted) setState(() => isScanning = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
             child: isScanning 
             ? Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.face_retouching_natural, size: 100, color: Color(0xFF00FFC2)),
                   const SizedBox(height: 20),
                   Text("SCANNING BIOMETRICS...", style: TextStyle(color: const Color(0xFF00FFC2).withOpacity(0.7), letterSpacing: 3)),
                 ],
               )
             : Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.warning_amber_rounded, size: 100, color: Colors.redAccent),
                   const SizedBox(height: 20),
                   const Text("PROJECTED DAMAGE DETECTED", style: TextStyle(color: Colors.redAccent, letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 18)),
                   const SizedBox(height: 10),
                   const Padding(
                     padding: EdgeInsets.symmetric(horizontal: 40),
                     child: Text("Analysis indicates 40% rapid aging and neural decline within 5 years of substance abuse.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                   )
                 ],
               ),
          ),
          if (isScanning)
            Center(
              child: SizedBox(
                width: 200, height: 200,
                child: CircularProgressIndicator(color: const Color(0xFF00FFC2), strokeWidth: 1),
              ),
            ),
          Positioned(
            top: 50, left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}