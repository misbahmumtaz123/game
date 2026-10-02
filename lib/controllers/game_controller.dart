import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bubble_model.dart';
import '../models/mood_model.dart';
import '../models/particle_model.dart';

/// GameController managing game loops, 3 lives of 50 score, 1-minute countdown,
/// target score goals, target hits (+10), missed target shots (-5),
/// and the Happy Mood reward transformation. Complete free movement without boundary lines.
class GameController extends ChangeNotifier {
  final Random _rnd = Random();
  int _bubbleIdCounter = 0;

  // Mood configuration (starts with bad moods)
  int _currentMoodIndex = 0;
  List<MoodModel> get moods => MoodModel.badMoodPresets;
  int get currentMoodIndex => _currentMoodIndex;
  MoodModel get currentMood => MoodModel.badMoodPresets[_currentMoodIndex];

  // User-defined Target Score to achieve Happy Mood (150 pts = 15 target hits in 1 minute)
  int _targetScore = 150;
  int get targetScore => _targetScore;

  // Game state
  int _score = 0;
  int _bestScore = 0;
  int _timeRemaining = 60; // 1 minute
  bool _isPlaying = false;
  bool _isGameOver = false;
  bool _isGoalReached = false;

  // Life system: 3 lives of 50 HP each
  static const int maxLives = 3;
  static const int hpPerLife = 50;
  int _lives = maxLives;
  int _currentLifeHp = hpPerLife;

  // Active game variables
  String _currentTargetEmoji = '☀️';
  int _currentTargetHits = 0;
  int _activeWhackIndex = -1;
  String _flashFeedback = '';
  double _elapsedTime = 0.0;
  int _spawnAccumulatorMs = 0;
  DateTime _lastTargetChangeTime = DateTime.now();

  late HappyRewardItem _currentReward;

  final List<BubbleModel> _bubbles = [];
  final List<ParticleModel> _particles = [];

  // Timers
  Timer? _loopTimer;
  Timer? _clockTimer;
  Timer? _spawnTimer;
  Timer? _targetRotationTimer;
  Timer? _flashResetTimer;

  GameController() {
    _pickNewReward();
  }

  // Public Getters
  int get score => _score;
  int get bestScore => _bestScore;
  int get timeRemaining => _timeRemaining;
  int get lives => _lives;
  int get currentLifeHp => _currentLifeHp;
  bool get isPlaying => _isPlaying;
  bool get isGameOver => _isGameOver;
  bool get isGoalReached => _isGoalReached;
  String get currentTargetEmoji => _currentTargetEmoji;
  int get activeWhackIndex => _activeWhackIndex;
  String get whackCellEmoji => _currentTargetEmoji;
  String get flashFeedback => _flashFeedback;
  double get elapsedTime => _elapsedTime;
  HappyRewardItem get currentReward => _currentReward;
  List<BubbleModel> get bubbles => List.unmodifiable(_bubbles);
  List<ParticleModel> get particles => List.unmodifiable(_particles);

  /// Progressive speed calculation based on casual mobile game design standards:
  /// - Starting speed provides a comfortable ~5.0 - 5.5s screen transit time.
  /// - At 5-10 points (early game), the speed increase is subtle and gentle (+1% to +4%),
  ///   ensuring the player never feels overwhelmed early on.
  /// - As score climbs towards 350-500 points, it follows a smooth sub-linear power curve
  ///   accelerating up to a peak ~3.0s transit time for an exciting, reactable challenge.
  double get currentSpeed {
    // Base speed provides a relaxed ~5.2s transit across the screen
    final double baseSpeed = currentMood.speed * 0.27;
    // Sublinear power progression smoothly scaled over the target score
    final double progress = (_score / _targetScore).clamp(0.0, 1.0);
    final double curve = pow(progress, 0.85).toDouble();
    // Max speed at endgame is 1.75x baseSpeed (approx 3.0s transit time)
    return baseSpeed * (1.0 + 0.75 * curve);
  }

  /// Dynamic spawn interval in ms that shortens as score increases.
  /// Starts at an unhurried 1100ms and scales gradually to 650ms at peak score,
  /// keeping the arena readable and fair without balloon clutter.
  int get currentSpawnIntervalMs {
    final double progress = (_score / _targetScore).clamp(0.0, 1.0);
    final double curve = pow(progress, 0.85).toDouble();
    return (1100 - (curve * 450)).round().clamp(650, 1100);
  }

  /// Allows user to set custom target score to transform mood into happy
  void setTargetScore(int target) {
    if (target > 0) {
      _targetScore = target;
      notifyListeners();
    }
  }

  /// Select a starting bad mood
  void selectMood(int index) {
    if (index >= 0 && index < MoodModel.badMoodPresets.length) {
      _currentMoodIndex = index;
      notifyListeners();
    }
  }

  /// Start a 1-minute game session with 3 lives of 50 points
  void startGame() {
    _stopTimers();
    _score = 0;
    _currentTargetHits = 0;
    _lives = maxLives;
    _currentLifeHp = hpPerLife;
    _bubbles.clear();
    _particles.clear();
    _flashFeedback = '';
    _elapsedTime = 0.0;
    _isPlaying = true;
    _isGameOver = false;
    _isGoalReached = false;
    _timeRemaining = 60; // 1 minute duration
    _lastTargetChangeTime = DateTime.now();

    _pickNewReward();
    _pickNextTargetEmoji();
    _resetTargetRotationTimer();

    _spawnAccumulatorMs = 0;
    _spawnBubble();
    // Pre-populate an initial target bubble so the arena is interactive immediately
    _bubbles.add(
      BubbleModel(
        id: ++_bubbleIdCounter,
        emoji: _currentTargetEmoji,
        baseX: 0.30 + _rnd.nextDouble() * 0.40,
        y: 0.60,
        z: 1.0,
        phase: _rnd.nextDouble() * 6.28,
        swayAmplitude: 0.04,
      ),
    );

    // High frequency loop (30 FPS) for physics.
    _loopTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (!_isPlaying) return;
      _elapsedTime += 0.033;

      // Dynamic spawn pacing based on progressive score
      _spawnAccumulatorMs += 33;
      if (_spawnAccumulatorMs >= currentSpawnIntervalMs) {
        _spawnAccumulatorMs = 0;
        _spawnBubble();
      }

      // Update positions using progressive speed curve: gentle float, smooth acceleration
      final speed = currentSpeed;
      for (final bubble in _bubbles) {
        bubble.updatePosition(speed);
      }

      // Detect escaped target bubbles BEFORE pruning them.
      // 3.5-second grace period after target changes prevents unfair damage for balloons that were already near the top.
      final bool inGracePeriod =
          DateTime.now().difference(_lastTargetChangeTime).inMilliseconds < 3500;
      final escaped = inGracePeriod
          ? 0
          : _bubbles
              .where((b) => b.y < -0.10 && b.emoji == _currentTargetEmoji)
              .length;
      if (escaped > 0) {
        _score = max(0, _score - escaped);
        for (int i = 0; i < escaped; i++) {
          _takeDamage(1);
          if (!_isPlaying) break; // game ended mid-loop
        }
        if (_isPlaying) {
          _triggerFlash('-$escaped Target Escaped! 💨');
        }
      }

      // Prune all off-screen bubbles (target and non-target alike)
      _bubbles.removeWhere((b) => b.y < -0.10);

      // Advance particles
      for (final particle in _particles) {
        particle.advanceAge(0.08);
      }
      _particles.removeWhere((p) => p.age > 1.0);

      notifyListeners();
    });

    // 1-minute countdown clock
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_timeRemaining > 1) {
        _timeRemaining--;
        notifyListeners();
      } else {
        _timeRemaining = 0;
        _endGame(goalAchieved: _score >= _targetScore);
      }
    });

    notifyListeners();
  }

  /// Spawns a floating bubble with guaranteed presence of the active target
  void _spawnBubble() {
    if (!_isPlaying) return;

    final int targetCount =
        _bubbles.where((b) => b.emoji == _currentTargetEmoji).length;
    final String emoji;

    // Guarantee 1 to 2 active target bubbles in the arena at all times
    if (targetCount == 0) {
      emoji = _currentTargetEmoji;
    } else if (targetCount == 1) {
      // 70% chance of spawning another target for fluid, engaging gameplay
      emoji = _rnd.nextDouble() < 0.70
          ? _currentTargetEmoji
          : _pickRandom(currentMood.distractionEmojis);
    } else {
      final isTarget = _rnd.nextDouble() < 0.50;
      if (isTarget) {
        emoji = _rnd.nextDouble() < 0.60
            ? _currentTargetEmoji
            : _pickRandom(currentMood.targetEmojis);
      } else {
        emoji = _pickRandom(currentMood.distractionEmojis);
      }
    }

    final double baseX = 0.08 + _rnd.nextDouble() * 0.78;
    final double swayAmp = 0.035 + _rnd.nextDouble() * 0.045;

    _bubbles.add(
      BubbleModel(
        id: ++_bubbleIdCounter,
        emoji: emoji,
        baseX: baseX,
        y: 1.05,
        z: 0.75 + _rnd.nextDouble() * 0.5,
        phase: _rnd.nextDouble() * 6.28,
        swayAmplitude: swayAmp,
      ),
    );
  }

  /// Handle a shot fired at (tapX, tapY).
  /// Rule 1: Only deduct from the score if a player fires a shot at a specific targeted emoji and misses.
  /// Firing at other non-target emojis or failing to hit a specific target on a missed shot does not decrease the score.
  void handleShot(
    double tapX,
    double tapY,
    double fieldWidth,
    double fieldHeight,
  ) {
    if (!_isPlaying) return;

    final tapOffset = Offset(tapX, tapY);

    // 1. Check if any bubble was directly hit (closest depth first)
    BubbleModel? hitBubble;
    final sortedBubbles = [..._bubbles]..sort((a, b) => b.z.compareTo(a.z));

    for (final bubble in sortedBubbles) {
      final size = 64.0 * bubble.z;
      final center = Offset(
        bubble.currentX * fieldWidth + size / 2,
        bubble.y * fieldHeight + size / 2,
      );
      final radius = size * 0.55;
      if ((tapOffset - center).distance <= radius) {
        hitBubble = bubble;
        break;
      }
    }

    if (hitBubble != null) {
      final size = 64.0 * hitBubble.z;
      final bool isTargetHit = hitBubble.emoji == _currentTargetEmoji;
      _bubbles.remove(hitBubble);

      // Particle burst
      _particles.add(
        ParticleModel(
          x: hitBubble.currentX * fieldWidth + size / 2,
          y: hitBubble.y * fieldHeight + size / 2,
          size: size,
          isSuccess: isTargetHit,
        ),
      );

      if (isTargetHit) {
        // TARGET HIT: +10 Points!
        _score += 10;
        _currentTargetHits++;
        HapticFeedback.lightImpact();

        if (_score >= _targetScore) {
          _isGoalReached = true;
          _endGame(goalAchieved: true);
          return;
        }

        // 3-hit combo on the active target triggers a combo fanfare and rotates target
        if (_currentTargetHits >= 3) {
          _currentTargetHits = 0;
          _triggerFlash('+10 COMBO! 🔥');
          _pickNextTargetEmoji(announced: true);
        } else {
          _triggerFlash('+10');
        }
      } else {
        // Non-target bubble hit: "Firing at other non-target emojis should not decrease the score."
        _triggerFlash('Safe Pop');
        HapticFeedback.selectionClick();
      }

      notifyListeners();
      return;
    }

    // 2. No bubble directly hit — missed shot.
    // Penalty-free: target-escape events handle life damage.
    // Just show a small harmless tap spark.
    _particles.add(
      ParticleModel(
        x: tapX,
        y: tapY,
        size: 22.0,
        isSuccess: true,
      ),
    );

    notifyListeners();
  }

  /// Compatibility handler for bubble taps
  void handleBubbleTap(
    BubbleModel bubble,
    double fieldWidth,
    double fieldHeight,
  ) {
    final size = 64.0 * bubble.z;
    handleShot(
      bubble.currentX * fieldWidth + size / 2,
      bubble.y * fieldHeight + size / 2,
      fieldWidth,
      fieldHeight,
    );
  }

  /// Handle tap on Whack mini-game cell (+10 on target, -5 & damage on distraction)
  void handleWhackTap(int gridIndex) {
    if (!_isPlaying || gridIndex != _activeWhackIndex) return;

    final isTargetHit =
        whackCellEmoji == _currentTargetEmoji ||
        currentMood.targetEmojis.contains(whackCellEmoji);

    if (isTargetHit) {
      _score += 10;
      _triggerFlash('+10');
      HapticFeedback.lightImpact();

      if (_score >= _targetScore) {
        _isGoalReached = true;
        _endGame(goalAchieved: true);
        return;
      }
      _pickNextTargetEmoji();
    } else {
      _score = max(0, _score - 5);
      _takeDamage(5);
      _triggerFlash('-5');
      HapticFeedback.heavyImpact();
    }

    _activeWhackIndex = -1;
    notifyListeners();
  }

  /// Deduct life points. When 50 HP depleted, 1 life is lost.
  void _takeDamage(int amount) {
    _currentLifeHp -= amount;
    if (_currentLifeHp <= 0) {
      _lives--;
      if (_lives > 0) {
        _currentLifeHp = hpPerLife + _currentLifeHp; // Carry over overflow
      } else {
        _lives = 0;
        _currentLifeHp = 0;
        _endGame(goalAchieved: false);
      }
    }
  }

  void _pickNextTargetEmoji({bool announced = false}) {
    _currentTargetHits = 0;
    final candidates =
        currentMood.targetEmojis.where((e) => e != _currentTargetEmoji).toList();
    _currentTargetEmoji = _pickRandom(
      candidates.isNotEmpty ? candidates : currentMood.targetEmojis,
    );
    _lastTargetChangeTime = DateTime.now();
    if (announced && _isPlaying) {
      _triggerFlash('NEW TARGET: $_currentTargetEmoji');
      HapticFeedback.selectionClick();
    }
    _resetTargetRotationTimer();
    notifyListeners();
  }

  void _resetTargetRotationTimer() {
    _targetRotationTimer?.cancel();
    _targetRotationTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) {
        if (_isPlaying) {
          _pickNextTargetEmoji(announced: true);
        }
      },
    );
  }

  void _pickNewReward() {
    _currentReward =
        MoodModel.happyRewards[_rnd.nextInt(MoodModel.happyRewards.length)];
  }

  void _triggerFlash(String message) {
    _flashFeedback = message;
    _flashResetTimer?.cancel();
    _flashResetTimer = Timer(const Duration(milliseconds: 550), () {
      _flashFeedback = '';
      notifyListeners();
    });
  }

  void _endGame({required bool goalAchieved}) {
    _stopTimers();
    _isGoalReached = goalAchieved;
    if (_score > _bestScore) {
      _bestScore = _score;
    }
    _isPlaying = false;
    _isGameOver = true;
    notifyListeners();
  }

  void _stopTimers() {
    _loopTimer?.cancel();
    _loopTimer = null;
    _clockTimer?.cancel();
    _clockTimer = null;
    _spawnTimer?.cancel();
    _spawnTimer = null;
    _targetRotationTimer?.cancel();
    _targetRotationTimer = null;
    _flashResetTimer?.cancel();
    _flashResetTimer = null;
  }

  void stopGame() {
    _stopTimers();
    _isPlaying = false;
    notifyListeners();
  }

  String _pickRandom(List<String> list) {
    if (list.isEmpty) return '⭐';
    return list[_rnd.nextInt(list.length)];
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }
}
