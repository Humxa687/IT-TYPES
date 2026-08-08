import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _timeLimitSec = 30; // 0 (unlimited), 15, 30, 60, 120
  int _wordLimitCount = 25; // 10, 25, 50, 100

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
  double _soundVolume = 1.0;

  // Audio players for sound effects
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _errorPlayer = AudioPlayer();
  final AudioPlayer _successPlayer = AudioPlayer();

  // Key highlight state for virtual keyboard
  String? _lastPressedKey;
  Timer? _keyHighlightTimer;

  // User Profile & Stats History (Persistent)
  String _userName = 'Typist';
  List<Map<String, dynamic>> _gameLogs = [];

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
  double get soundVolume => _soundVolume;
  String? get lastPressedKey => _lastPressedKey;
  String get userName => _userName;
  List<Map<String, dynamic>> get gameLogs => _gameLogs;

  // Structured Sentence Databases
  static const List<String> _easySentences = [
    'the cat saw a red cup on the bed.',
    'we can run and play in the sun.',
    'the big dog ran to the blue box.',
    'he saw a cow and a pig in the mud.',
    'this book is very good to read now.',
    'let us go to the park and play.',
    'the hot sun was bright all day long.',
    'she sat by the tree to eat a bun.',
    'my dad got a new blue toy car.',
    'we saw a fish swim in the lake.',
    'the blue bird sat on a tall tree.',
    'a fly is on my cup of hot milk.',
    'ten boys ran fast to the red gate.',
    'the wet grass was cold to my feet.',
    'we saw a fox run into the woods.',
    'can you find the key to the door?',
    'she got a nice doll for her birth day.',
    'the man saw a black bug on his bag.',
    'the ship swam far out in the deep sea.',
    'he sent a long card to his best pal.',
    'we love to eat sweet plum jam.',
    'the wind blew a dry leaf away.',
    'tell me a fun story of a brave king.',
    'the dark room was cold and quiet.',
    'he put the coin in his warm hand.',
    'a tall tree is near the old barn.',
    'she gave a big hug to her sweet aunt.',
    'the lazy toad sat on a wet log.',
    'we like to sing a nice soft song.',
    'the tiny boy had a gold ring.',
    'my left shoe has a tiny hole in it.',
    'the fire is warm and the room is dark.',
    'she wore a pink hat to the show.',
    'the rain fell on the dirt road.',
    'we will take a ride in the red bus.',
    'he swam in the cold pool at noon.',
    'the coop has hens ducks and eggs.',
    'she has a soft wool coat for cold days.',
    'the boat was safe in the calm bay.',
    'we saw a huge crab in the sand.',
    'he gave a red rose to his dear wife.',
    'the clock ticks on the wood wall.',
    'we walk on the soft yellow sand.',
    'the cook made a hot beef soup.',
    'the wild deer ran in the deep snow.',
    'she wrote a note with a gray lead pen.',
    'the bird flew high in the blue sky.',
    'we must wash our hands with soap.',
    'the wood desk was clean and neat.',
    'he left his coat on the back seat.',
    'she drew a star on the clay wall.',
    'the soup is warm and the bun is soft.'
  ];

  static const List<String> _mediumSentences = [
    'about forty green frogs jumps under clear water ponds.',
    'every young child likes eating fresh fruit juice daily.',
    'honest people always build great trust among friends.',
    'silver clouds slowly float across bright summer skies.',
    'simple coding guides beginners write basic script lines.',
    'please write short email reply about their final offer.',
    'plants absorb light energy through green leafy stems.',
    'active driver leaves motor running while buying bread.',
    'strong winds shake heavy branches during winter storms.',
    'camera capturing magic moment under orange sunset glows.',
    'school buses carry happy pupils along quiet street roads.',
    'system update offers better visual layout design styles.',
    'guitar player plays sweet music under shade trees.',
    'yellow lemons taste very sour under fresh water wash.',
    'father built small wood house inside empty garden space.',
    'doctor checks heart beats using modern sound sensor.',
    'coffee drinks taste really great during rainy days.',
    'travel agent books flight ticket toward sunny beach.',
    'brave soldiers defend their nation under royal flag.',
    'clever rabbit escapes clever hunter inside dense bush.',
    'winter nights bring cold winds across silent valley hills.',
    'famous actors perform great drama on the theater stage.',
    'forest rangers protect wild animals inside nature park.',
    'bakers prepare fresh bakery items before sunrise hours.',
    'bright lights shine above active sports fields.',
    'farmers harvest yellow wheat crops during autumn season.',
    'artist paints colorful picture using custom canvas board.',
    'friendly neighbors share delicious dishes during summer picnic.',
    'postal worker delivers letters inside local urban sector.',
    'engineers develop modern vehicle using hybrid battery energy.'
  ];

  static const List<String> _hardSentences = [
    'extraordinary circumstances require outstanding intelligence.',
    'professional maintenance requires sophisticated technological instruments.',
    'conscientious individuals demonstrate incredible character qualities.',
    'information technology revolutionizes contemporary communication systems.',
    'scientific experiments generate meaningful quantitative database observations.',
    'comprehensive development programs stimulate sustainable economic growth.',
    'environmental preservation guarantees comfortable atmospheric conditions.',
    'independent researchers investigate mysterious archaeological discoveries.',
    'enthusiastic developers contribute valuable open-source software packages.',
    'meaningful conversation facilitates mutual understanding between communities.',
    'continuous learning stimulates intellectual growth and creative thinking.',
    'architectural masterpieces combine historical aesthetic values with modern designs.',
    'fundamental principles guide ethical business administration decisions.',
    'international relations influence global political environments significantly.',
    'educational institutions cultivate responsible citizenship values among youths.',
    'creative writing represents therapeutic emotional expression for authors.',
    'advanced algorithm optimizations improve system application speed dramatically.',
    'collaborative teamwork achieves exceptional results in complex assignments.',
    'strategic planning ensures successful product launch in competitive markets.',
    'comprehensive assessment identifies critical engineering design vulnerabilities.'
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

  GameState() {
    _loadUserData();
  }

  // Load username & stats history
  void _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('userName') ?? 'Typist';
      final List<String>? logs = prefs.getStringList('gameLogs');
      if (logs != null) {
        _gameLogs = logs.map((log) => Map<String, dynamic>.from(jsonDecode(log))).toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Save score logs
  void _saveGameLog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final log = {
        'wpm': wpm,
        'accuracy': accuracy,
        'mode': _mode.name,
        'difficulty': _difficulty.name,
        'date': DateTime.now().toIso8601String(),
      };
      _gameLogs.add(log);
      final List<String> encoded = _gameLogs.map((item) => jsonEncode(item)).toList();
      await prefs.setStringList('gameLogs', encoded);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving game log: $e');
    }
  }

  // Update userName
  void setUserName(String name) async {
    _userName = name.trim().isEmpty ? 'Typist' : name.trim();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _userName);
    } catch (e) {
      debugPrint('Error saving username: $e');
    }
  }

  // Clear stats history
  void resetStatistics() async {
    _gameLogs.clear();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('gameLogs');
    } catch (e) {
      debugPrint('Error clearing stats: $e');
    }
  }

  // Sound effects trigger
  void _playAudioEffect(String type) {
    if (!_isSoundEnabled) return;
    try {
      if (type == 'click') {
        _clickPlayer.stop();
        _clickPlayer.setVolume(_soundVolume);
        _clickPlayer.play(AssetSource('sounds/click.wav'));
      } else if (type == 'error') {
        _errorPlayer.stop();
        _errorPlayer.setVolume(_soundVolume);
        _errorPlayer.play(AssetSource('sounds/error.wav'));
      } else if (type == 'success') {
        _successPlayer.stop();
        _successPlayer.setVolume(_soundVolume);
        _successPlayer.play(AssetSource('sounds/success.wav'));
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  // Keyboard highlight trigger
  void _triggerKeyHighlight(String key) {
    _keyHighlightTimer?.cancel();
    _lastPressedKey = key.toLowerCase();
    notifyListeners();

    _keyHighlightTimer = Timer(const Duration(milliseconds: 100), () {
      _lastPressedKey = null;
      notifyListeners();
    });
  }

  // Configuration changes
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

  void setSoundVolume(double vol) {
    _soundVolume = vol.clamp(0.0, 1.0);
    notifyListeners();
  }

  // Calculations
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
    if (_mode != GameMode.timeAttack || _timeLimitSec == 0) return 0;
    return max(0, _timeLimitSec - _elapsedTimeSec);
  }

  // Initialize a new gameplay session
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

    if (_difficulty == GameDifficulty.easy) {
      _targetText = _easySentences[rand.nextInt(_easySentences.length)];
    } else if (_difficulty == GameDifficulty.medium) {
      _targetText = _mediumSentences[rand.nextInt(_mediumSentences.length)];
    } else if (_difficulty == GameDifficulty.hard) {
      _targetText = _hardSentences[rand.nextInt(_hardSentences.length)];
    }
  }

  // Handle keystroke inputs
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

  // Handle backspace deletes
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

      // End game if countdown timer finishes (only if not unlimited/0)
      if (_mode == GameMode.timeAttack && _timeLimitSec > 0 && _elapsedTimeSec >= _timeLimitSec) {
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
    _saveGameLog();
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
