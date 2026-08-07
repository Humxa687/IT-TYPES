import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

enum GameMode {
  timeAttack,
  wordLimit,
  suddenDeath,
}

enum GameDifficulty {
  easy,
  medium,
  hard,
  code,
}

class GameState extends ChangeNotifier {
  GameMode _mode = GameMode.timeAttack;
  GameDifficulty _difficulty = GameDifficulty.easy;
  int _timeLimitSec = 30; // 30, 60, 120
  int _wordLimitCount = 25; // 25, 50, 100

  // Gameplay state
  String _targetText = '';
  String _typedText = '';
  bool _isPlaying = false;
  bool _isFinished = false;
  int _correctKeys = 0;
  int _incorrectKeys = 0;

  // Real-time tracking
  int _elapsedTimeSec = 0;
  Timer? _timer;
  final List<double> _wpmHistory = [];
  bool _isSoundEnabled = true;

  // Audio players for sound effects
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _errorPlayer = AudioPlayer();
  final AudioPlayer _successPlayer = AudioPlayer();

  // Key highlight state for virtual keyboard
  String? _lastPressedKey;
  Timer? _keyHighlightTimer;

  // Getters
  GameMode get mode => _mode;
  GameDifficulty get difficulty => _difficulty;
  int get timeLimitSec => _timeLimitSec;
  int get wordLimitCount => _wordLimitCount;
  String get targetText => _targetText;
  String get typedText => _typedText;
  bool get isPlaying => _isPlaying;
  bool get isFinished => _isFinished;
  int get correctKeys => _correctKeys;
  int get incorrectKeys => _incorrectKeys;
  int get elapsedTimeSec => _elapsedTimeSec;
  List<double> get wpmHistory => _wpmHistory;
  bool get isSoundEnabled => _isSoundEnabled;
  String? get lastPressedKey => _lastPressedKey;

  // Word Corpora
  static const List<String> _easyWords = [
    'the', 'be', 'to', 'of', 'and', 'a', 'in', 'that', 'have', 'i', 'it', 'for', 'not', 'on', 'with', 'he', 'as', 'you', 'do', 'at',
    'this', 'but', 'his', 'by', 'from', 'they', 'we', 'say', 'her', 'she', 'or', 'an', 'will', 'my', 'one', 'all', 'would', 'there',
    'their', 'what', 'so', 'up', 'out', 'if', 'about', 'who', 'get', 'which', 'go', 'me', 'when', 'make', 'can', 'like', 'time', 'no',
    'just', 'him', 'know', 'take', 'people', 'into', 'year', 'your', 'good', 'some', 'could', 'them', 'see', 'other', 'than', 'then',
    'now', 'look', 'only', 'come', 'its', 'over', 'think', 'also', 'back', 'after', 'use', 'two', 'how', 'our', 'work', 'first', 'well'
  ];

  static const List<String> _mediumWords = [
    'adventure', 'beautiful', 'celebrate', 'different', 'education', 'experience', 'fabulous', 'generation', 'happiness', 'important',
    'journey', 'knowledge', 'landscape', 'mysterious', 'navigation', 'opportunity', 'passionate', 'question', 'reflection', 'strength',
    'technology', 'understanding', 'valuable', 'wilderness', 'yesterday', 'creation', 'curiosity', 'direction', 'discovery', 'energy'
  ];

  static const List<String> _hardWords = [
    'accommodate', 'conscientious', 'definitely', 'embarrass', 'hierarchy', 'indispensable', 'maintenance', 'necessary', 'occurrence',
    'pharaoh', 'pronunciation', 'rhythm', 'sacrilegious', 'threshold', 'unforeseen', 'maintenance', 'idiosyncrasy', 'juxtaposition',
    'colloquial', 'quintessential', 'exacerbate', 'obfuscate', 'cacophony', 'ephemeral', 'garrulous', 'perfunctory', 'synecdoche'
  ];

  static const List<String> _codeSnippets = [
    'void main() {\n  runApp(const MyApp());\n}',
    'class User {\n  final String name;\n  final int age;\n  User({required this.name, this.age = 0});\n}',
    'for (int i = 0; i < items.length; i++) {\n  print(items[i]);\n}',
    'Future<String> fetchData() async {\n  final response = await http.get(url);\n  return response.body;\n}',
    'Widget build(BuildContext context) {\n  return Scaffold(\n    body: Container(),\n  );\n}',
    'final StreamController<int> _controller = StreamController<int>();',
    'try {\n  await database.insert(record);\n} catch (e) {\n  print("Error: \$e");\n}'
  ];

  // Play custom sound effects
  void _playAudioEffect(String type) {
    if (!_isSoundEnabled) return;
    try {
      if (type == 'click') {
        _clickPlayer.stop();
        _clickPlayer.play(AssetSource('sounds/click.wav'));
      } else if (type == 'error') {
        _errorPlayer.stop();
        _errorPlayer.play(AssetSource('sounds/error.wav'));
      } else if (type == 'success') {
        _successPlayer.stop();
        _successPlayer.play(AssetSource('sounds/success.wav'));
      }
    } catch (e) {
      debugPrint('Error playing sound asset: $e');
    }
  }

  // Trigger keyboard highlight
  void _triggerKeyHighlight(String key) {
    _keyHighlightTimer?.cancel();
    _lastPressedKey = key.toLowerCase();
    notifyListeners();

    _keyHighlightTimer = Timer(const Duration(milliseconds: 100), () {
      _lastPressedKey = null;
      notifyListeners();
    });
  }

  // Configuration updates
  void setMode(GameMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void setDifficulty(GameDifficulty diff) {
    _difficulty = diff;
    notifyListeners();
  }

  void setTimeLimit(int seconds) {
    _timeLimitSec = seconds;
    notifyListeners();
  }

  void setWordLimit(int count) {
    _wordLimitCount = count;
    notifyListeners();
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    notifyListeners();
  }

  // Calculate stats
  double get wpm {
    if (_elapsedTimeSec <= 0) return 0;
    double words = _correctKeys / 5.0;
    double minutes = _elapsedTimeSec / 60.0;
    return (words / minutes).clamp(0.0, 300.0);
  }

  double get accuracy {
    int total = _correctKeys + _incorrectKeys;
    if (total == 0) return 100.0;
    return (_correctKeys / total) * 100.0;
  }

  int get remainingSeconds {
    if (_mode != GameMode.timeAttack) return 0;
    return max(0, _timeLimitSec - _elapsedTimeSec);
  }

  // Initialize/Start a new game session
  void initGame() {
    _timer?.cancel();
    _keyHighlightTimer?.cancel();
    _lastPressedKey = null;
    _isPlaying = false;
    _isFinished = false;
    _typedText = '';
    _correctKeys = 0;
    _incorrectKeys = 0;
    _elapsedTimeSec = 0;
    _wpmHistory.clear();
    _generateTargetText();
    notifyListeners();
  }

  void _generateTargetText() {
    final rand = Random();
    if (_difficulty == GameDifficulty.code) {
      _targetText = _codeSnippets[rand.nextInt(_codeSnippets.length)];
      return;
    }

    List<String> sourceWords;
    switch (_difficulty) {
      case GameDifficulty.easy:
        sourceWords = _easyWords;
        break;
      case GameDifficulty.medium:
        sourceWords = _mediumWords;
        break;
      case GameDifficulty.hard:
        sourceWords = _hardWords;
        break;
      default:
        sourceWords = _easyWords;
    }

    int count = (_mode == GameMode.wordLimit) ? _wordLimitCount : 40;
    List<String> chosen = [];
    for (int i = 0; i < count; i++) {
      chosen.add(sourceWords[rand.nextInt(sourceWords.length)]);
    }
    _targetText = chosen.join(' ');
  }

  // Handle a typed character or key press
  void handleCharacterInput(String character) {
    if (_isFinished) return;

    if (!_isPlaying) {
      _startTimer();
    }

    _triggerKeyHighlight(character);

    if (_typedText.length >= _targetText.length) return;

    final expectedChar = _targetText[_typedText.length];

    if (character == expectedChar) {
      _correctKeys++;
      _typedText += character;
      _playAudioEffect('click');
    } else {
      _incorrectKeys++;
      _playAudioEffect('error');
      if (_mode == GameMode.suddenDeath) {
        _endGame();
        return;
      }
      _typedText += character;
    }

    _checkCompletion();
    notifyListeners();
  }

  // Handle backspace
  void handleBackspace() {
    if (_isFinished || _typedText.isEmpty) return;

    _triggerKeyHighlight('backspace');

    final lastIndex = _typedText.length - 1;
    _typedText = _typedText.substring(0, lastIndex);
    _recalculateStats();
    _playAudioEffect('click');
    notifyListeners();
  }

  void _recalculateStats() {
    int correct = 0;
    int incorrect = 0;
    int len = min(_typedText.length, _targetText.length);
    for (int i = 0; i < len; i++) {
      if (_typedText[i] == _targetText[i]) {
        correct++;
      } else {
        incorrect++;
      }
    }
    _correctKeys = correct;
    _incorrectKeys = incorrect;
  }

  void _startTimer() {
    _isPlaying = true;
    _elapsedTimeSec = 0;
    _wpmHistory.clear();
    _wpmHistory.add(0.0);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedTimeSec++;
      _wpmHistory.add(wpm);

      if (_mode == GameMode.timeAttack && _elapsedTimeSec >= _timeLimitSec) {
        _endGame();
      }

      notifyListeners();
    });
  }

  void _checkCompletion() {
    if (_typedText.length >= _targetText.length) {
      _endGame();
    }
  }

  void _endGame() {
    _timer?.cancel();
    _isPlaying = false;
    _isFinished = true;
    _recalculateStats();
    _playAudioEffect('success');
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _keyHighlightTimer?.cancel();
    _clickPlayer.dispose();
    _errorPlayer.dispose();
    _successPlayer.dispose();
    super.dispose();
  }
}
