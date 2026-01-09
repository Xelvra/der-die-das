enum GameMode {
  // Levels
  a1,
  a2,
  b1,
  b2,
  c1,
  c2,

  // Special Modes
  reviewLearned, // Smart SRS review
  training, // Endless random practice (no score)
  survival, // Time attack
  challenge, // High score run
  weakPoints, // Fix mistakes
  autoplay; // Cinema mode (Passive learning)

  bool get isLevel => index < 6;

  bool get hasTimer => this == survival;

  bool get hasScoring => this == survival || this == challenge;

  String get dbIdentifier {
    if (isLevel) return name;
    return name;
  }

  // Helper to get associated CEFR levels for a mode
  List<String> get associatedLevels {
    switch (this) {
      case GameMode.a1:
        return ['A1'];
      case GameMode.a2:
        return ['A1', 'A2'];
      case GameMode.b1:
        return ['A1', 'A2', 'B1'];
      case GameMode.b2:
        return ['A1', 'A2', 'B1', 'B2'];
      case GameMode.c1:
        return ['A1', 'A2', 'B1', 'B2', 'C1'];
      case GameMode.c2:
        return ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
      default:
        return []; // Needs to be handled by accessing selectedLevel state
    }
  }
}
