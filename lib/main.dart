import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notification_service.dart';
import 'word_bank.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const WordOfTheDayApp());
}

/// Returns day-of-year (1-365). Leap year day 366 is treated as 365.
int dayOfYear(DateTime date) {
  final start = DateTime(date.year, 1, 1);
  final diff = date.difference(start).inDays;
  return (diff + 1).clamp(1, 365);
}

/// Picks the word for the given date from the bank using day-of-year index.
WordEntry wordForDate(DateTime date) {
  final day = dayOfYear(date);
  final index = (day - 1) % wordBank.length;
  return wordBank[index];
}

const List<String> _weekdays = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];
const List<String> _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String formatDate(DateTime date) {
  return '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}';
}

// Design colors from reference
const Color _cream = Color(0xFFFBF9F4);
const Color _textPrimary = Color(0xFF2D2E30);
const Color _textSecondary = Color(0xFF6F7073);
const Color _accent = Color(0xFFE6AF2E);
const Color _accentLight = Color(0xFFF7DCB4);
const Color _pillGray = Color(0xFFEAEAEA);

class WordOfTheDayApp extends StatelessWidget {
  const WordOfTheDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word of the Day',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: _cream,
        colorScheme: ColorScheme.light(
          surface: _cream,
          onSurface: _textPrimary,
          primary: _accent,
          onPrimary: _textPrimary,
        ),
        textTheme: GoogleFonts.sourceSans3TextTheme(
          ThemeData.light().textTheme.apply(
                bodyColor: _textPrimary,
                displayColor: _textPrimary,
              ),
        ),
        useMaterial3: true,
      ),
      home: const WordOfTheDayScreen(),
    );
  }
}

class WordOfTheDayScreen extends StatefulWidget {
  const WordOfTheDayScreen({super.key});

  @override
  State<WordOfTheDayScreen> createState() => _WordOfTheDayScreenState();
}

class _WordOfTheDayScreenState extends State<WordOfTheDayScreen> {
  @override
  void initState() {
    super.initState();
    // Show reminder prompt only after a few minutes of use, not immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(minutes: 2), () {
        if (mounted) _maybeShowReminderPrompt();
      });
    });
  }

  Future<void> _maybeShowReminderPrompt() async {
    if (!mounted) return;
    final dismissed = await NotificationService.wasPromptDismissed();
    final scheduled = await NotificationService.getScheduledReminderTime();
    if (dismissed || scheduled != null) return;
    if (!mounted) return;
    await _showReminderPromptDialog(context);
  }

  Future<void> _showReminderPromptDialog(BuildContext context) async {
    TimeOfDay selected = const TimeOfDay(hour: 9, minute: 0);
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: _cream,
            title: Text(
              'Daily reminder',
              style: GoogleFonts.sourceSans3(
                color: _textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Get your Word of the Day once a day. Choose when you'd like to be reminded.",
                  style: GoogleFonts.sourceSans3(
                    fontSize: 15,
                    color: _textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Reminder time',
                    style: GoogleFonts.sourceSans3(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: _textSecondary,
                    ),
                  ),
                  subtitle: Text(
                    selected.format(context),
                    style: GoogleFonts.sourceSans3(
                      fontSize: 18,
                      color: _textPrimary,
                    ),
                  ),
                  trailing: Icon(Icons.access_time, color: _accent),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selected,
                    );
                    if (picked != null) {
                      setDialogState(() => selected = picked);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await NotificationService.setPromptDismissed();
                  if (context.mounted) Navigator.of(context).pop(false);
                },
                child: Text(
                  'Not now',
                  style: GoogleFonts.sourceSans3(color: _textSecondary),
                ),
              ),
              FilledButton(
                onPressed: () async {
                  final ok = await NotificationService.scheduleDailyReminder(selected);
                  if (context.mounted) Navigator.of(context).pop(ok);
                },
                style: FilledButton.styleFrom(backgroundColor: _accent),
                child: Text(
                  'Enable',
                  style: GoogleFonts.sourceSans3(color: _textPrimary),
                ),
              ),
            ],
          );
        },
      ),
    );
    if (result == true && mounted) setState(() {});
  }

  void _openReminderSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const SettingsScreen(),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final entry = wordForDate(now);
    final day = dayOfYear(now);
    const totalDays = 365;

    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
              // Header: centered title, settings cog at far right
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu_book_rounded, color: _accent, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'WORD OF THE DAY',
                            style: GoogleFonts.sourceSans3(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: _textSecondary, size: 24),
                    onPressed: _openReminderSettings,
                    tooltip: 'Settings',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Day pill: "Day X of 365"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _pillGray,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: _accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Day $day of $totalDays',
                      style: GoogleFonts.sourceSans3(
                        fontSize: 14,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Word (serif, large, centered)
              Text(
                entry.word,
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                  height: 1.2,
                ),
              ),
              if (entry.pronunciation.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  entry.pronunciation,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sourceSans3(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: _textSecondary,
                  ),
                ),
              ],
              if (entry.partOfSpeech.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accentLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry.partOfSpeech,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 14,
                      color: _accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              // Definition block (left-aligned)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'DEFINITION',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: _textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.description,
                style: GoogleFonts.sourceSans3(
                  fontSize: 16,
                  height: 1.6,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              // Example block with left accent bar
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'EXAMPLE',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: _textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: _accent, width: 4),
                  ),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(2)),
                ),
                child: Text(
                  '"${entry.exampleSentence}"',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 16,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                    color: _textPrimary,
                  ),
                ),
              ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Text(
                'Expand your vocabulary, one word at a time',
                textAlign: TextAlign.center,
                style: GoogleFonts.sourceSans3(
                  fontSize: 13,
                  color: _textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay? _scheduled;
  TimeOfDay _selected = const TimeOfDay(hour: 9, minute: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final scheduled = await NotificationService.getScheduledReminderTime();
    if (mounted) {
      setState(() {
        _scheduled = scheduled;
        _selected = scheduled ?? const TimeOfDay(hour: 9, minute: 0);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _accent))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              'Settings',
                              style: GoogleFonts.sourceSans3(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _textPrimary,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: _textPrimary),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Daily reminder',
                          style: GoogleFonts.sourceSans3(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Time',
                            style: GoogleFonts.sourceSans3(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: _textSecondary,
                            ),
                          ),
                          subtitle: Text(
                            _selected.format(context),
                            style: GoogleFonts.sourceSans3(
                              fontSize: 20,
                              color: _textPrimary,
                            ),
                          ),
                          trailing: Icon(Icons.access_time, color: _accent),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _selected,
                            );
                            if (picked != null) setState(() => _selected = picked);
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (_scheduled != null)
                              TextButton(
                                onPressed: () async {
                                  await NotificationService.cancelReminder();
                                  if (mounted) setState(() => _scheduled = null);
                                },
                                child: Text(
                                  'Turn off',
                                  style: GoogleFonts.sourceSans3(color: _textSecondary),
                                ),
                              ),
                            const Spacer(),
                            FilledButton(
                              onPressed: () async {
                                await NotificationService.updateReminderTime(_selected);
                                if (mounted) setState(() => _scheduled = _selected);
                              },
                              style: FilledButton.styleFrom(backgroundColor: _accent),
                              child: Text(
                                _scheduled != null ? 'Update' : 'Set reminder',
                                style: GoogleFonts.sourceSans3(color: _textPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Previous words',
                          style: GoogleFonts.sourceSans3(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const PreviousWordsScreen(),
                              ),
                            );
                          },
                          icon: Icon(Icons.history, color: _accent, size: 20),
                          label: Text(
                            'View last 7 days',
                            style: GoogleFonts.sourceSans3(
                              fontSize: 15,
                              color: _textPrimary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _textPrimary,
                            side: BorderSide(color: _accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Who's Sid?",
                          style: GoogleFonts.sourceSans3(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Sid is my cat, and my inspiration for writing educational and fun apps. This app is dedicated to Sid.",
                          style: GoogleFonts.sourceSans3(
                            fontSize: 15,
                            height: 1.5,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Made with love in New Zealand ❤️',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.sourceSans3(
                            fontSize: 12,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

/// Screen showing the words for the last 7 days.
class PreviousWordsScreen extends StatelessWidget {
  const PreviousWordsScreen({super.key});

  static const int _daysCount = 7;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final entries = List.generate(_daysCount, (i) {
      final date = now.subtract(Duration(days: i));
      return _DayWord(date: date, entry: wordForDate(date));
    });

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Previous words',
          style: GoogleFonts.sourceSans3(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 28),
            child: IconButton(
              icon: Icon(Icons.close, color: _textPrimary),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Close',
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final dayWord = entries[index];
          return _PreviousWordTile(dayWord: dayWord);
        },
      ),
    );
  }
}

class _DayWord {
  const _DayWord({required this.date, required this.entry});
  final DateTime date;
  final WordEntry entry;
}

class _PreviousWordTile extends StatelessWidget {
  const _PreviousWordTile({required this.dayWord});
  final _DayWord dayWord;

  @override
  Widget build(BuildContext context) {
    final date = dayWord.date;
    final entry = dayWord.entry;
    final isToday = _isSameDay(date, DateTime.now());

    return Material(
      color: _pillGray.withOpacity(0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _showWordDetail(context, date, entry),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.word,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(date) + (isToday ? ' (Today)' : ''),
                      style: GoogleFonts.sourceSans3(
                        fontSize: 13,
                        color: _textSecondary,
                      ),
                    ),
                    if (entry.partOfSpeech.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _accentLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          entry.partOfSpeech,
                          style: GoogleFonts.sourceSans3(
                            fontSize: 12,
                            color: _accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: _textSecondary, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showWordDetail(BuildContext context, DateTime date, WordEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _cream,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                entry.word,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatDate(date),
                style: GoogleFonts.sourceSans3(
                  fontSize: 14,
                  color: _textSecondary,
                ),
              ),
              if (entry.partOfSpeech.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _accentLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    entry.partOfSpeech,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 14,
                      color: _accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'DEFINITION',
                style: GoogleFonts.sourceSans3(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.description,
                style: GoogleFonts.sourceSans3(
                  fontSize: 15,
                  height: 1.5,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'EXAMPLE',
                style: GoogleFonts.sourceSans3(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: _textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: _accent, width: 4),
                  ),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(2)),
                ),
                child: Text(
                  '"${entry.exampleSentence}"',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 15,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: _textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
