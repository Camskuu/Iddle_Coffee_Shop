import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const CoffeeIdleGame(),
    );
  }
}

class CoffeeIdleGame extends StatefulWidget {
  const CoffeeIdleGame({super.key});

  @override
  State<CoffeeIdleGame> createState() => _CoffeeIdleGameState();
}

class _CoffeeIdleGameState extends State<CoffeeIdleGame> {
  // Resource
  double _coffee = 0;

  // Click Upgrade
  int _brewLevel = 1;
  double _coffeePerClick = 1;
  double _brewUpgradeCost = 10;

  // Passive Income
  int _baristaLevel = 0;
  double _coffeePerSecond = 0;
  double _baristaUpgradeCost = 25;

  // Unique Twist: Happy Hour
  bool _happyHour = false;
  double get _multiplier => _happyHour ? 2.0 : 1.0;
  int _cycleSecond = 0;

  String _lastEvent = "Welcome! Tap BREW to start earning ☕";

  Timer? _timer;
  final _rng = Random();

  @override
  void initState() {
    super.initState();

    int seconds = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      seconds++;

      setState(() {
        if (_coffeePerSecond > 0) {
          _coffee += _coffeePerSecond * _multiplier;
        }

        _cycleSecond = seconds % 15;

        // Toggle Happy Hour every 15 seconds
        if (seconds % 15 == 0) {
          _happyHour = !_happyHour;
          _lastEvent = _happyHour
              ? "Happy Hour started! Earnings are 2× 🎉"
              : "Happy Hour ended. Back to regular rates.";
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
    );
  }

  void _brewCoffee() {
    setState(() {
      // 10% chance for a Perfect Brew (double)
      final bool perfectBrew = _rng.nextInt(10) == 0;
      final double bonus = perfectBrew ? 2.0 : 1.0;

      final double gain = _coffeePerClick * _multiplier * bonus;
      _coffee += gain;

      if (perfectBrew) {
        _lastEvent =
            "Perfect Brew! +${gain.toStringAsFixed(1)} ☕ (bonus applied)";
      } else {
        _lastEvent = "Brewed coffee: +${gain.toStringAsFixed(1)} ☕";
      }
    });
  }

  void _upgradeBrew() {
    if (_coffee < _brewUpgradeCost) {
      _toast("Not enough coffee to upgrade your brew.");
      return;
    }

    setState(() {
      _coffee -= _brewUpgradeCost;
      _brewLevel++;
      _coffeePerClick += 1;
      _brewUpgradeCost = (_brewUpgradeCost * 1.6).ceilToDouble();
      _lastEvent = "Upgraded Brew! You now make $_coffeePerClick ☕ / click";
    });
  }

  void _upgradeBarista() {
    if (_coffee < _baristaUpgradeCost) {
      _toast("Not enough coffee to hire a barista.");
      return;
    }

    setState(() {
      _coffee -= _baristaUpgradeCost;
      _baristaLevel++;
      _coffeePerSecond += 0.5;
      _baristaUpgradeCost = (_baristaUpgradeCost * 1.75).ceilToDouble();
      _lastEvent =
          "Hired a Barista! Passive is now ${_coffeePerSecond.toStringAsFixed(1)} ☕ / sec";
    });
  }

  void _resetGame() {
    setState(() {
      _coffee = 0;

      _brewLevel = 1;
      _coffeePerClick = 1;
      _brewUpgradeCost = 10;

      _baristaLevel = 0;
      _coffeePerSecond = 0;
      _baristaUpgradeCost = 25;

      _happyHour = false;
      _cycleSecond = 0;

      _lastEvent = "Reset complete. Welcome back to the coffee counter ☕";
    });
  }

  // Helpers
  bool get _canUpgradeBrew => _coffee >= _brewUpgradeCost;
  bool get _canUpgradeBarista => _coffee >= _baristaUpgradeCost;

  @override
  Widget build(BuildContext context) {
    final TextStyle big =
        const TextStyle(fontSize: 40, fontWeight: FontWeight.w800);
    final TextStyle subtle =
        TextStyle(fontSize: 14, color: Colors.grey.shade700);

    // progress for the 15 second cycle
    final double cycleProgress = _cycleSecond / 15.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Idle Coffee Shop"),
        actions: [
          IconButton(
            tooltip: "Reset",
            onPressed: _resetGame,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown.shade50,
              Colors.brown.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _HeaderPanel(
                  coffee: _coffee,
                  bigStyle: big,
                  subtitleStyle: subtle,
                  happyHour: _happyHour,
                  multiplier: _multiplier,
                ),

                const SizedBox(height: 12),

                // Happy Hour cycle indicator
                _CyclePanel(
                  happyHour: _happyHour,
                  progress: cycleProgress,
                  secondsLeft: 15 - _cycleSecond,
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatsCard(
                          brewLevel: _brewLevel,
                          coffeePerClick: _coffeePerClick,
                          baristaLevel: _baristaLevel,
                          coffeePerSecond: _coffeePerSecond,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ShopCard(
                          canUpgradeBrew: _canUpgradeBrew,
                          canUpgradeBarista: _canUpgradeBarista,
                          brewUpgradeCost: _brewUpgradeCost,
                          baristaUpgradeCost: _baristaUpgradeCost,
                          onUpgradeBrew: _upgradeBrew,
                          onUpgradeBarista: _upgradeBarista,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                _EventBanner(text: _lastEvent),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _brewCoffee,
                    icon: const Icon(Icons.coffee),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        "BREW COFFEE",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// UI WIDGETS 
class _HeaderPanel extends StatelessWidget {
  final double coffee;
  final TextStyle bigStyle;
  final TextStyle subtitleStyle;
  final bool happyHour;
  final double multiplier;

  const _HeaderPanel({
    required this.coffee,
    required this.bigStyle,
    required this.subtitleStyle,
    required this.happyHour,
    required this.multiplier,
  });

  @override
  Widget build(BuildContext context) {
    final String status = happyHour ? "Happy Hour (2×)" : "Regular Hours";
    final IconData icon = happyHour ? Icons.nightlife : Icons.wb_sunny;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.brown.shade200,
              child: const Icon(Icons.local_cafe, size: 28, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${coffee.toStringAsFixed(1)} ☕", style: bigStyle),
                  const SizedBox(height: 4),
                  Text("Earnings Multiplier: ${multiplier.toStringAsFixed(1)}×",
                      style: subtitleStyle),
                ],
              ),
            ),
            Column(
              children: [
                Icon(icon),
                const SizedBox(height: 4),
                Text(status, style: const TextStyle(fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _CyclePanel extends StatelessWidget {
  final bool happyHour;
  final double progress;
  final int secondsLeft;

  const _CyclePanel({
    required this.happyHour,
    required this.progress,
    required this.secondsLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              happyHour ? "Happy Hour Timer" : "Next Happy Hour",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 6),
            Text("$secondsLeft seconds until the next switch",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int brewLevel;
  final double coffeePerClick;
  final int baristaLevel;
  final double coffeePerSecond;

  const _StatsCard({
    required this.brewLevel,
    required this.coffeePerClick,
    required this.baristaLevel,
    required this.coffeePerSecond,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your Cafe", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const Divider(),
            _row(Icons.auto_awesome, "Brew Level", "Lv $brewLevel"),
            const SizedBox(height: 15),
            _row(Icons.touch_app, "Coffee / Click", coffeePerClick.toStringAsFixed(1)),
            const SizedBox(height: 15),
            _row(Icons.people, "Baristas", "$baristaLevel hired"),
            const SizedBox(height: 15),
            _row(Icons.timelapse, "Coffee / Sec", coffeePerSecond.toStringAsFixed(1)),
            const Spacer(),
            // Text(
            //   "Tip: Keep upgrading baristas for steady income!",
            //   style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ShopCard extends StatelessWidget {
  final bool canUpgradeBrew;
  final bool canUpgradeBarista;
  final double brewUpgradeCost;
  final double baristaUpgradeCost;
  final VoidCallback onUpgradeBrew;
  final VoidCallback onUpgradeBarista;

  const _ShopCard({
    required this.canUpgradeBrew,
    required this.canUpgradeBarista,
    required this.brewUpgradeCost,
    required this.baristaUpgradeCost,
    required this.onUpgradeBrew,
    required this.onUpgradeBarista,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Shop", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const Divider(),

            const Text("Upgrade your click power:"),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: canUpgradeBrew ? onUpgradeBrew : null,
              child: Text("Upgrade Brew (-${brewUpgradeCost.toStringAsFixed(0)} ☕)"),
            ),
            const SizedBox(height: 8),
            Text("• +1 coffee per click", style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),

            const SizedBox(height: 16),

            const Text("Increase passive income:"),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: canUpgradeBarista ? onUpgradeBarista : null,
              child: Text("Hire Barista (-${baristaUpgradeCost.toStringAsFixed(0)} ☕)"),
            ),
            const SizedBox(height: 8),
            Text("• +0.5 coffee per second", style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),

            const Spacer(),

            // OutlinedButton.icon(
            //   onPressed: () => Navigator.of(context).maybePop(),
            //   icon: const Icon(Icons.info_outline),
            //   label: const Text("Pro Tip"),
            // ),
            // Text(
            //   "Happy Hour doubles both click + passive earnings.",
            //   style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            // )
          ],
        ),
      ),
    );
  }
}

class _EventBanner extends StatelessWidget {
  final String text;
  const _EventBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.brown.shade200,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.campaign),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}