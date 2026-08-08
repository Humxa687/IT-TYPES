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
  quote,
  zen,
  custom,
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

  // Configuration options
  bool _includePunctuation = false;
  bool _includeNumbers = false;

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
  String _customText = 'the quick brown fox jumps over the lazy dog';

  // Session Authentication State
  bool _isLoggedIn = false;
  String _userEmail = '';

  // Getters
  GameMode get mode => _mode;
  GameDifficulty get difficulty => _difficulty;
  int get timeLimitSec => _timeLimitSec;
  int get wordLimitCount => _wordLimitCount;
  bool get includePunctuation => _includePunctuation;
  bool get includeNumbers => _includeNumbers;
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
  String get customText => _customText;
  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _userEmail;

  // Structured Sentence Databases
  static const List<String> _easySentences = [
    'the firm will hire a new lead code designer.',
    'we must send the team data file today.',
    'our main goal is to build a safe app.',
    'the new web site is live and runs fast.',
    'we need to check the team work plan now.',
    'the sales team made a big deal last week.',
    'please sign the forms with a blue pen.',
    'the team will meet at noon in the hall.',
    'our next task is to write the unit test.',
    'we want to make the user interface simple.',
    'the host gave a clear talk on tech growth.',
    'please log into your new work account.',
    'the code base is clean and easy to read.',
    'we will push the changes to main branch.',
    'the database server is up and running.',
    'please update your profile details now.',
    'the client sent a positive feedback note.',
    'we must optimize the page load speed.',
    'a skilled developer can solve this bug.',
    'the project manager approved the release.'
  ];

  static const List<String> _mediumSentences = [
    'the development team completed the milestone on schedule.',
    'our marketing strategy focuses on organic user acquisition.',
    'please coordinate with the design team for assets.',
    'the system administrator configured the secure firewalls.',
    'we need to integrate the user feedback into next sprint.',
    'cloud infrastructure provides scalable storage solutions.',
    'clean code architecture ensures long term project success.',
    'agile methodologies improve collaboration among engineers.',
    'the company expects significant growth in next quarter.',
    'innovative designs capture user attention instantly.',
    'business executives analyze quantitative performance data.',
    'regular code reviews maintain high engineering quality.',
    'machine learning algorithms predict consumer behavior.',
    'efficient database indexing speeds up queries.',
    'cybersecurity protocols protect sensitive user details.'
  ];

  static const List<String> _hardSentences = [
    'implementing distributed systems requires sophisticated synchronization mechanisms.',
    'our enterprise software architecture utilizes microservices for horizontal scaling.',
    'comprehensive automated testing frameworks minimize regressions during deployment.',
    'machine learning pipelines ingest heterogeneous datasets for real-time inference.',
    'refactoring legacy codebases demands careful planning and thorough unit testing.',
    'optimizing memory allocation in low-level languages prevents garbage collector latency.',
    'asymmetric encryption algorithms ensure secure authentication across distributed nodes.',
    'continuous integration pipelines automate build verification and code analysis.',
    'database sharding strategy distributes load horizontally across multiple clusters.',
    'responsive design principles ensure seamless user experiences across devices.',
    'leveraging caching layers significantly reduces API response latency.',
    'adhering to software design patterns enhances code readability and reusability.'
  ];

  static const List<String> _codeSnippets = [
    'void main() {\n  runApp(const MyApp());\n}',
    'class UserProfile {\n  final String email;\n  final String token;\n  UserProfile({required this.email, required this.token});\n}',
    'Future<void> saveSettings(AppSettings settings) async {\n  final prefs = await SharedPreferences.getInstance();\n  await prefs.setString("settings", jsonEncode(settings.toJson()));\n}',
    'Widget build(BuildContext context) {\n  return Scaffold(\n    appBar: AppBar(title: const Text("Dashboard")),\n    body: const Center(child: Text("Welcome")),\n  );\n}',
    'final response = await http.get(Uri.parse("https://api.ittypes.com/v1/scores"));\nif (response.statusCode == 200) {\n  return jsonDecode(response.body);\n}',
    'try {\n  await database.insert(record);\n} catch (error, stackTrace) {\n  logger.severe("Database insertion failed", error, stackTrace);\n}'
  ];

  static const List<String> _quotes = [
    'talk is cheap. show me the code. - linus torvalds',
    'programs must be written for people to read, and only incidentally for machines to execute. - harold abelson',
    'any fool can write code that a computer can understand. good programmers write code that humans can understand. - martin fowler',
    'first, solve the problem. then, write the code. - john johnson',
    'experience is the name everyone gives to their mistakes. - oscar wilde',
    'simplicity is the ultimate sophistication. - leonardo da vinci',
    'make it work, make it right, make it fast. - kent beck',
    'the best way to predict the future is to invent it. - alan kay',
    'control your code, or your code will control you. - anonymous',
    'clean code always looks like it was written by someone who cares. - michael feathers'
  ];

  GameState() {
    _loadUserData();
  }

  // Load userdata
  void _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('userName') ?? 'Typist';
      _customText = prefs.getString('customText') ?? 'the quick brown fox jumps over the lazy dog';
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userEmail = prefs.getString('userEmail') ?? '';
      
      final List<String>? logs = prefs.getStringList('gameLogs');
      if (logs != null) {
        _gameLogs = logs.map((log) => Map<String, dynamic>.from(jsonDecode(log))).toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Save scoring history
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

  // Auth Operations
  void login(String email, String username) async {
    _isLoggedIn = true;
    _userName = username.trim().isEmpty ? 'Typist' : username.trim();
    _userEmail = email.trim();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userName', _userName);
      await prefs.setString('userEmail', _userEmail);
    } catch (e) {
      debugPrint('Error saving login: $e');
    }
  }

  void logout() async {
    _isLoggedIn = false;
    _userName = 'Typist';
    _userEmail = '';
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.setString('userName', 'Typist');
      await prefs.remove('userEmail');
    } catch (e) {
      debugPrint('Error clearing login: $e');
    }
  }

  // Setters
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

  void setCustomText(String text) async {
    _customText = text.trim().isEmpty ? 'the quick brown fox jumps over the lazy dog' : text.trim();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('customText', _customText);
    } catch (e) {
      debugPrint('Error saving customText: $e');
    }
  }

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

  void togglePunctuation() {
    _includePunctuation = !_includePunctuation;
    notifyListeners();
  }

  void toggleNumbers() {
    _includeNumbers = !_includeNumbers;
    notifyListeners();
  }

  // Sound effects
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

  void _triggerKeyHighlight(String key) {
    _keyHighlightTimer?.cancel();
    _lastPressedKey = key.toLowerCase();
    notifyListeners();

    _keyHighlightTimer = Timer(const Duration(milliseconds: 100), () {
      _lastPressedKey = null;
      notifyListeners();
    });
  }

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

  // Initialize gameplay session
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

    String baseText = '';

    if (_mode == GameMode.custom) {
      baseText = _customText;
    } else if (_mode == GameMode.quote) {
      baseText = _quotes[rand.nextInt(_quotes.length)];
    } else {
      if (_difficulty == GameDifficulty.easy) {
        baseText = _easySentences[rand.nextInt(_easySentences.length)];
      } else if (_difficulty == GameDifficulty.medium) {
        baseText = _mediumSentences[rand.nextInt(_mediumSentences.length)];
      } else if (_difficulty == GameDifficulty.hard) {
        baseText = _hardSentences[rand.nextInt(_hardSentences.length)];
      }
    }

    _targetText = _applyPunctuationAndNumbers(baseText);
  }

  String _applyPunctuationAndNumbers(String text) {
    if (!_includePunctuation && !_includeNumbers) return text.toLowerCase();

    List<String> words = text.split(' ');
    final rand = Random();

    for (int i = 0; i < words.length; i++) {
      String word = words[i];

      // Apply numbers
      if (_includeNumbers && rand.nextDouble() < 0.12) {
        words[i] = '${rand.nextInt(100)}';
        continue;
      }

      // Apply capitalization
      if (_includePunctuation && (i == 0 || rand.nextDouble() < 0.12)) {
        if (word.isNotEmpty) {
          word = word[0].toUpperCase() + word.substring(1);
        }
      }

      // Apply punctuation marks
      if (_includePunctuation && rand.nextDouble() < 0.1) {
        final punc = rand.nextDouble();
        if (punc < 0.6) {
          word += '.';
        } else if (punc < 0.85) {
          word += ',';
        } else {
          word += '?';
        }
      }
      words[i] = word;
    }
    
    String result = words.join(' ');
    if (_includePunctuation && !result.endsWith('.')) {
      result += '.';
    }
    return result;
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

      if (_mode == GameMode.timeAttack && _timeLimitSec > 0 && _elapsedTimeSec >= _timeLimitSec) {
        _endGame();
      }

      notifyListeners();
    });
  }

  void _checkCompletion() {
    if (_typedText.length >= _targetText.length) {
      if (_mode == GameMode.zen) {
        _generateTargetText();
        _typedText = '';
        _recalculateStats();
        _playAudioEffect('success');
      } else {
        _endGame();
      }
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
