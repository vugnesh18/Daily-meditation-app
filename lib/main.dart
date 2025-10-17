import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MeditationApp());
}

class MeditationApp extends StatelessWidget {
  const MeditationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meditation & Yoga',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white.withOpacity(0.9),
          elevation: 8,
          shadowColor: Colors.purple.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String today = DateFormat('yMMMd').format(DateTime.now());
  bool timerDone = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? userName;
  int? userAge;

  final List<String> quotes = [
    "Peace comes from within.",
    "Breathe deeply, live calmly.",
    "Yoga is the journey of the self.",
    "Meditation is the key to clarity."
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName');
      userAge = prefs.getInt('userAge');
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dailyQuote = quotes[DateTime.now().day % quotes.length];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView(
                children: [
                  Card(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.purpleAccent, Colors.blueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName != null ? "Hello, $userName!" : "Hello, Guest!",
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "🌟 Daily Quote: $dailyQuote",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildSectionCard(
                    context,
                    "👤 Profile",
                    "Manage your profile details",
                    ProfileScreen(onProfileSaved: _loadUserProfile),
                  ),
                  buildSectionCard(
                    context,
                    "🧘 Yoga",
                    "Learn different yoga postures",
                    const YogaScreen(),
                  ),
                  buildSectionCard(
                    context,
                    "🎵 Meditation",
                    "Play sounds and set timer",
                    MeditationScreen(onTimerComplete: () {
                      setState(() {
                        timerDone = true;
                      });
                    }),
                  ),
                  buildSectionCard(
                    context,
                    "📊 Health Tracker",
                    "Check your daily progress",
                    HealthTrackerScreen(timerDone: timerDone, today: today),
                  ),
                  buildSectionCard(
                    context,
                    "⏰ Reminders",
                    "Set meditation reminders",
                    const ReminderScreen(),
                  ),
                  buildSectionCard(
                    context,
                    "ℹ️ Benefits",
                    "Discover benefits of meditation and yoga",
                    const BenefitsScreen(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeditationScreen(onTimerComplete: () {
              setState(() {
                timerDone = true;
              });
            }),
          ),
        ),
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.play_arrow, color: Colors.white),
        tooltip: 'Start Meditation',
      ),
    );
  }

  Widget buildSectionCard(
      BuildContext context, String title, String subtitle, Widget page) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          title: Text(
            title,
            style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final VoidCallback onProfileSaved;
  const ProfileScreen({super.key, required this.onProfileSaved});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('userName') ?? '';
    _ageController.text = prefs.getInt('userAge')?.toString() ?? '';
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = _nameController.text.trim();
    final ageText = _ageController.text.trim();
    if (name.isEmpty || ageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both name and age")),
      );
      return;
    }
    final age = int.tryParse(ageText);
    if (age == null || age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid age")),
      );
      return;
    }
    await prefs.setString('userName', name);
    await prefs.setInt('userAge', age);
    widget.onProfileSaved();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile saved successfully!")),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: GoogleFonts.poppins(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _ageController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Age",
                  labelStyle: GoogleFonts.poppins(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text("Save Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  TimeOfDay? _selectedTime;
  Timer? _timer;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadReminderTime();
    _startReminderCheck();
  }

  Future<void> _loadReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt('reminderHour');
    final minute = prefs.getInt('reminderMinute');
    if (hour != null && minute != null) {
      setState(() {
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      });
    }
  }

  Future<void> _saveReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminderHour', time.hour);
    await prefs.setInt('reminderMinute', time.minute);
  }

  void _startReminderCheck() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_selectedTime != null) {
        final now = DateTime.now();
        if (now.hour == _selectedTime!.hour && now.minute == _selectedTime!.minute && now.second == 0) {
          _playReminderSound();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Time to meditate!")),
          );
        }
      }
    });
  }

  Future<void> _playReminderSound() async {
    await _player.play(AssetSource('sounds/notification.mp3'));
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            primaryColor: Colors.purple,
            colorScheme: const ColorScheme.dark(
              primary: Colors.purple,
              surface: Colors.teal,
            ),
            textTheme: GoogleFonts.poppinsTextTheme().apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      await _saveReminderTime(picked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Reminder set for ${picked.format(context)}")),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reminders", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Set Meditation Reminder",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purpleAccent, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _selectedTime == null
                          ? "No reminder set"
                          : "Reminder set for ${_selectedTime!.format(context)}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _selectTime(context),
                child: const Text("Pick Time"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class YogaScreen extends StatelessWidget {
  const YogaScreen({super.key});

  final List<Map<String, String>> poses = const [
    {
      "name": "Mountain Pose",
      "image": "assets/images/yoga1.png",
      "desc": "Stand tall, breathe deeply, balance evenly."
    },
    {
      "name": "Tree Pose",
      "image": "assets/images/yoga2.png",
      "desc": "Balance on one leg, place the other on thigh, join palms."
    },
    {
      "name": "Cobra Pose",
      "image": "assets/images/yoga3.png",
      "desc": "Lie on stomach, lift chest with hands, look upward."
    },
    {
      "name": "Downward Dog Pose",
      "image": "assets/images/yoga4.png",
      "desc": "Form an inverted V, keeping your spine straight and heels down."
    },
    {
      "name": "Warrior Pose",
      "image": "assets/images/yoga5.png",
      "desc":
          "Step one foot forward, bend the knee, stretch arms wide, and look ahead."
    },
    {
      "name": "Child’s Pose",
      "image": "assets/images/yoga6.png",
      "desc":
          "Kneel down, stretch arms forward, rest forehead on the mat, and relax."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yoga Poses", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: poses.length,
          itemBuilder: (context, index) {
            final pose = poses[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => YogaDetailScreen(pose: pose),
                ),
              ),
              child: Card(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purpleAccent, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                          child: Image.asset(pose["image"]!, fit: BoxFit.cover)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          pose["name"]!,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
    );
  }
}

class YogaDetailScreen extends StatelessWidget {
  final Map<String, String> pose;
  const YogaDetailScreen({super.key, required this.pose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pose["name"]!, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(child: Image.asset(pose["image"]!, fit: BoxFit.contain)),
              const SizedBox(height: 20),
              Text(
                pose["desc"]!,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MeditationScreen extends StatefulWidget {
  final VoidCallback onTimerComplete;
  const MeditationScreen({super.key, required this.onTimerComplete});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  int _remainingSeconds = 0;
  final TextEditingController _durationController = TextEditingController();
  String _selectedSound = "birds.mp3";

  late AnimationController _animationController;
  late Animation<double> _circleAnimation;
  final Map<String, String> _soundNames = {
    "birds.mp3": "Birds",
    "rain.mp3": "Rain",
    "ocean.mp3": "Ocean",
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });

    _circleAnimation = Tween<double>(begin: 120, end: 180).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );

    _animationController.repeat(reverse: true);
    if (!_isPlaying) {
      _animationController.stop();
    }
  }

  void _startMeditation() async {
    if (_isPlaying) return;

    int customDuration = 0;
    try {
      final input = int.tryParse(_durationController.text);
      if (input != null && input > 0) {
        customDuration = input * 60;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid duration greater than 0")),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid number")),
      );
      return;
    }

    setState(() {
      _remainingSeconds = customDuration;
      _isPlaying = true;
    });

    _animationController.repeat(reverse: true);
    await _player.play(AssetSource("sounds/$_selectedSound"));

    while (_remainingSeconds > 0 && _isPlaying) {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isPlaying) break;
      setState(() => _remainingSeconds--);
    }

    if (_isPlaying) {
      await _player.stop();
      _animationController.stop();
      widget.onTimerComplete();
      setState(() {
        _isPlaying = false;
        _remainingSeconds = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Meditation completed!")),
      );
    }
  }

  void _stopMeditation() async {
    await _player.stop();
    _animationController.stop();
    setState(() {
      _isPlaying = false;
      _remainingSeconds = 0;
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    _durationController.dispose();
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meditation Timer", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.teal, Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "🧘 Select Your Meditation",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedSound,
                dropdownColor: Colors.purple.withOpacity(0.9),
                style: GoogleFonts.poppins(color: Colors.white),
                items: _soundNames.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: !_isPlaying
                    ? (value) => setState(() => _selectedSound = value!)
                    : null,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _durationController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Duration (minutes)",
                  labelStyle: GoogleFonts.poppins(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                keyboardType: TextInputType.number,
                enabled: !_isPlaying,
              ),
              const SizedBox(height: 40),
              if (_isPlaying)
                Container(
                  width: _circleAnimation.value,
                  height: _circleAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.pinkAccent, Colors.teal, Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 40),
              if (_isPlaying)
                Text(
                  "Time Left: ${_formatTime(_remainingSeconds)}",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _isPlaying ? _stopMeditation : _startMeditation,
                icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                label: Text(_isPlaying ? "Stop" : "Start Meditation"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HealthTrackerScreen extends StatelessWidget {
  final bool timerDone;
  final String today;
  const HealthTrackerScreen(
      {super.key, required this.timerDone, required this.today});

  @override
  Widget build(BuildContext context) {
    String message = timerDone
        ? "✅ You are running good today ($today)"
        : "⚠️ You need some health care. Try meditation or yoga.";
    return Scaffold(
      appBar: AppBar(
        title: Text("Health Tracker", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class BenefitsScreen extends StatelessWidget {
  const BenefitsScreen({super.key});

  final List<String> yogaBenefits = const [
    "Improves flexibility and range of motion.",
    "Increases muscle strength and tone.",
    "Enhances balance and coordination.",
    "Promotes better posture and alignment.",
    "Reduces risk of injury in daily activities.",
    "Boosts cardiovascular health.",
    "Relieves chronic pain, such as back pain.",
    "Improves respiratory function and lung capacity.",
    "Reduces stress and anxiety levels.",
    "Enhances mental focus and concentration.",
    "Promotes relaxation and better sleep quality.",
    "Increases body awareness and mindfulness.",
    "Supports weight management and metabolism.",
    "Improves joint health and mobility.",
    "Enhances circulation and blood flow.",
    "Boosts immune system function.",
    "Improves digestion and gut health.",
    "Reduces symptoms of arthritis.",
    "Supports mental health and emotional balance.",
    "Fosters a sense of community in group practice."
  ];

  final List<String> meditationBenefits = const [
    "Reduces stress and cortisol levels.",
    "Improves focus and concentration.",
    "Enhances emotional well-being.",
    "Promotes self-awareness and mindfulness.",
    "Reduces symptoms of anxiety and depression.",
    "Improves sleep quality and reduces insomnia.",
    "Boosts creativity and problem-solving skills.",
    "Enhances emotional resilience.",
    "Lowers blood pressure and heart rate.",
    "Improves memory and cognitive function.",
    "Reduces perception of pain.",
    "Increases compassion and empathy.",
    "Supports addiction recovery and impulse control.",
    "Enhances clarity in decision-making.",
    "Promotes a sense of inner peace.",
    "Improves attention span and mental clarity.",
    "Reduces symptoms of PTSD.",
    "Supports emotional regulation.",
    "Enhances overall mental health.",
    "Fosters a positive outlook on life."
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Benefits of Meditation & Yoga", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Text(
                "Benefits of Yoga",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ...yogaBenefits.asMap().entries.map((entry) => Card(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.purpleAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          "${entry.key + 1}. ${entry.value}",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              Text(
                "Benefits of Meditation",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              ...meditationBenefits.asMap().entries.map((entry) => Card(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.purpleAccent, Colors.blueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          "${entry.key + 1}. ${entry.value}",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}