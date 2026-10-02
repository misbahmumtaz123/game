import 'package:flutter/material.dart';

/// Represents a cheerful quote and joke combo for the happy reward.
class HappyRewardItem {
  final String quote;
  final String author;
  final String jokeQuestion;
  final String jokePunchline;

  const HappyRewardItem({
    required this.quote,
    required this.author,
    required this.jokeQuestion,
    required this.jokePunchline,
  });
}

/// Model representing bad starting mood configurations and happy transformation rewards.
class MoodModel {
  final String emoji;
  final String name;
  final String subtitle;
  final String gameTitle;
  final String rule;
  final List<Color> backgroundColors;
  final Color tintColor;
  final List<String> targetEmojis; // Positive emojis to tap (+10)
  final List<String> distractionEmojis; // Bad mood emojis to avoid (-5)
  final double speed;

  const MoodModel({
    required this.emoji,
    required this.name,
    required this.subtitle,
    required this.gameTitle,
    required this.rule,
    required this.backgroundColors,
    required this.tintColor,
    required this.targetEmojis,
    required this.distractionEmojis,
    required this.speed,
  });

  /// Curated list of starting bad moods.
  /// The goal of the game is to burst through these negative emotions to reach Happy mood!
  static const List<MoodModel> badMoodPresets = [
    MoodModel(
      emoji: '😢',
      name: 'Sad',
      subtitle: 'Feeling down & gloomy',
      gameTitle: 'Sunshine Uplift',
      rule: 'Shoot floating TARGET (+10)! Missing a shot at target deducts score (-5). Non-targets are safe.',
      backgroundColors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
      tintColor: Color(0xFF60A5FA),
      targetEmojis: ['☀️', '🌈', '💖', '🌸', '✨', '🌻'],
      distractionEmojis: ['🌧️', '💔', '☁️', '😭', '🥀'],
      speed: 0.0260,
    ),
    MoodModel(
      emoji: '😡',
      name: 'Angry',
      subtitle: 'Frustrated & heated',
      gameTitle: 'Cool Down Calm',
      rule: 'Blast shifting TARGET (+10)! Missed shots at target cost -5. Dynamic scaling speed!',
      backgroundColors: [Color(0xFF2A0808), Color(0xFF7F1D1D)],
      tintColor: Color(0xFFF87171),
      targetEmojis: ['🕊️', '🧘', '💧', '🍃', '🧊', '🌊'],
      distractionEmojis: ['😡', '💢', '🔥', '👿', '💥'],
      speed: 0.0300,
    ),
    MoodModel(
      emoji: '😰',
      name: 'Anxious',
      subtitle: 'Stressed & racing mind',
      gameTitle: 'Peace & Serenity',
      rule: 'Catch floating TARGET (+10)! Don’t miss shots at the target (-5). Non-targets safe.',
      backgroundColors: [Color(0xFF1E1035), Color(0xFF4C1D95)],
      tintColor: Color(0xFFA78BFA),
      targetEmojis: ['🌿', '🕯️', '🌸', '🕊️', '🌙', '🍵'],
      distractionEmojis: ['😰', '⚡', '🌪️', '🌀', '🕸️'],
      speed: 0.0280,
    ),
    MoodModel(
      emoji: '😴',
      name: 'Tired',
      subtitle: 'Drained & exhausted',
      gameTitle: 'Energy Wake-Up',
      rule: 'Target the shifting ENERGY (+10)! Missed target shots deduct -5. Smooth power-up!',
      backgroundColors: [Color(0xFF18181B), Color(0xFF334155)],
      tintColor: Color(0xFFCBD5E1),
      targetEmojis: ['⚡', '☕', '☀️', '💡', '🚀', '🔥'],
      distractionEmojis: ['😴', '🥱', '💤', '🪫', '🌑'],
      speed: 0.0250,
    ),
    MoodModel(
      emoji: '😔',
      name: 'Lonely',
      subtitle: 'Isolated & bored',
      gameTitle: 'Friendship Warmth',
      rule: 'Tap shifting WARMTH (+10)! Only missed target shots deduct score (-5). Full screen freedom.',
      backgroundColors: [Color(0xFF111827), Color(0xFF312E81)],
      tintColor: Color(0xFF818CF8),
      targetEmojis: ['🤗', '💖', '🎈', '🤝', '⭐', '🎉'],
      distractionEmojis: ['😔', '🥀', '🌫️', '🍂', '🧊'],
      speed: 0.0270,
    ),
  ];

  /// Happy mood settings unlocked after reaching the target score.
  static const List<Color> happyBackgroundColors = [
    Color(0xFFFF7E5F),
    Color(0xFFFEB47B),
  ];
  static const Color happyTintColor = Color(0xFFFFD700);

  /// Uplifting quotes and funny jokes for the Happy reward.
  static const List<HappyRewardItem> happyRewards = [
    HappyRewardItem(
      quote: 'Happiness is not by chance, but by choice. Your smile is your superpower!',
      author: 'Jim Rohn',
      jokeQuestion: 'What do you call a happy cowboy?',
      jokePunchline: 'A jolly rancher! 🤠🍬',
    ),
    HappyRewardItem(
      quote: 'Turn your face toward the sun, and the shadows will always fall behind you.',
      author: 'Maori Proverb',
      jokeQuestion: 'Why did the tomato blush?',
      jokePunchline: 'Because it saw the salad dressing! 🍅🥗',
    ),
    HappyRewardItem(
      quote: 'Keep your face always toward the sunshine, and shadows will fall behind you.',
      author: 'Walt Whitman',
      jokeQuestion: 'Why was the math book happy?',
      jokePunchline: 'Because it finally solved all its problems! 📐😄',
    ),
    HappyRewardItem(
      quote: 'You did it! Negative thoughts popped away, pure joy remains.',
      author: 'Emoji Pop 4D',
      jokeQuestion: 'What do you call a bear with no teeth?',
      jokePunchline: 'A gummy bear! 🐻✨',
    ),
    HappyRewardItem(
      quote: 'Every day may not be good, but there is something good in every day.',
      author: 'Alice Morse Earle',
      jokeQuestion: 'What do you call a sleeping dinosaur?',
      jokePunchline: 'A dino-snore! 🦖💤',
    ),
  ];
}
