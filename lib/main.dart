import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const WaterIntakeApp());
}

class WaterIntakeApp extends StatelessWidget {
  const WaterIntakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Water Intake App',

      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _waterIntake = 0;
  int _dailyGoal = 8;
  final List<int> dailyGoalOptions = [8, 9, 10, 11, 12];

  @override
  void initState() {
    _loadPreferences();
    super.initState();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _waterIntake = (pref.getInt('waterIntake') ?? 0);
      _dailyGoal = (pref.getInt('dailyGoal') ?? 8);
    });
  }

  Future<void> _incrementWaterIntake() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _waterIntake++;
      pref.setInt('waterIntake', _waterIntake);
      if (_waterIntake >= _dailyGoal) {
        _showGoalReachedDialog();
      }
    });
  }

  Future<void> _resetWaterIntake() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _waterIntake = 0;
      pref.setInt('waterIntake', _waterIntake);
    });
  }

  Future<void> _setDailyGoal(int newGoal) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _dailyGoal = newGoal;
      pref.setInt('dailyGoal', newGoal);
    });
  }

  Future<void> _showGoalReachedDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('You have reached your daily goal of $_dailyGoal glasses of water!'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showResetConfirmationDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Water Intake'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                const Text('Are you sure you want to reset?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _resetWaterIntake();
                Navigator.of(context).pop();
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = _waterIntake / _dailyGoal;
    bool goalReached = _waterIntake >= _dailyGoal;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Water Intake App',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        backgroundColor: Colors.grey,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Icon(
                Icons.water_drop_sharp,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'You have consumed:',
                style: TextStyle(fontSize: 25, fontStyle: FontStyle.italic),
              ),
              Text(
                '$_waterIntake glasses of water',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation(Colors.blueGrey),
                minHeight: 10,
              ),
              const SizedBox(height: 20),
              const Text(
                'Daily Goal',
                style: TextStyle(fontSize: 20),
              ),
              DropdownButton<int>(
                value: _dailyGoal,
                items: dailyGoalOptions.map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value glasses'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    _setDailyGoal(newValue);
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                onPressed: (){
                  goalReached ? null : _incrementWaterIntake();
                },
                child: const Text('Add a glass of water',style: TextStyle(color: Colors.white),),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                onPressed: _showResetConfirmationDialog,
                child: const Text('Reset',style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
