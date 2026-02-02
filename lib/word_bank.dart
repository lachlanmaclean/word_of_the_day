/// A single vocabulary entry for the word of the day.
class WordEntry {
  const WordEntry({
    required this.word,
    required this.description,
    required this.exampleSentence,
    this.pronunciation = '',
    this.partOfSpeech = '',
  });

  final String word;
  final String description;
  final String exampleSentence;
  final String pronunciation;
  final String partOfSpeech;

  factory WordEntry.fromJson(Map<String, dynamic> json) {
    return WordEntry(
      word: json['word'] as String,
      description: json['description'] as String,
      exampleSentence: json['exampleSentence'] as String,
      pronunciation: json['pronunciation'] as String? ?? '',
      partOfSpeech: json['partOfSpeech'] as String? ?? '',
    );
  }
}

/// Word bank of 365 educational vocabulary words.
/// Currently contains sample entries; expand to 365 and use index % length for selection.
final List<WordEntry> wordBank = [
  const WordEntry(
    word: 'Cogent',
    pronunciation: '/ˈkəʊ.dʒənt/',
    partOfSpeech: 'adjective',
    description:
        'Clear, logical, and convincing; powerfully persuasive.',
    exampleSentence:
        'She presented a cogent argument that swayed even her harshest critics.',
  ),
  const WordEntry(
    word: 'Ephemeral',
    pronunciation: '/ɪˈfem.ər.əl/',
    partOfSpeech: 'adjective',
    description:
        'Lasting for a very short time; transitory. Often used to describe moments, trends, or experiences that are fleeting.',
    exampleSentence:
        'The cherry blossoms were beautiful but ephemeral, falling within a week.',
  ),
  const WordEntry(
    word: 'Ubiquitous',
    pronunciation: '/juːˈbɪk.wɪ.təs/',
    partOfSpeech: 'adjective',
    description:
        'Present, appearing, or found everywhere. Something that seems to be in all places at once.',
    exampleSentence:
        'Smartphones have become ubiquitous in modern society.',
  ),
  const WordEntry(
    word: 'Paradigm',
    pronunciation: '/ˈpær.ə.daɪm/',
    partOfSpeech: 'noun',
    description:
        'A typical example, pattern, or model of something. In broader use, a framework of ideas or assumptions that shapes how we see the world.',
    exampleSentence:
        'The shift to remote work represented a paradigm change for many industries.',
  ),
  const WordEntry(
    word: 'Eloquent',
    pronunciation: '/ˈel.ə.kwənt/',
    partOfSpeech: 'adjective',
    description:
        'Fluent or persuasive in speaking or writing. Expressing oneself clearly and movingly.',
    exampleSentence:
        'She gave an eloquent speech that moved the entire audience.',
  ),
  const WordEntry(
    word: 'Resilient',
    pronunciation: '/rɪˈzɪl.i.ənt/',
    partOfSpeech: 'adjective',
    description:
        'Able to withstand or recover quickly from difficulty; tough and adaptable.',
    exampleSentence:
        'Children are often more resilient than we give them credit for.',
  ),
  const WordEntry(
    word: 'Pragmatic',
    pronunciation: '/præɡˈmæt.ɪk/',
    partOfSpeech: 'adjective',
    description:
        'Dealing with things sensibly and realistically; focused on practical outcomes rather than theory.',
    exampleSentence:
        'We need a pragmatic approach to solve this problem quickly.',
  ),
  const WordEntry(
    word: 'Nuance',
    pronunciation: '/ˈnjuː.ɑːns/',
    partOfSpeech: 'noun',
    description:
        'A subtle difference in or shade of meaning, expression, or sound. The small details that matter.',
    exampleSentence:
        'The translation lost some of the nuance of the original poem.',
  ),
  const WordEntry(
    word: 'Juxtaposition',
    pronunciation: '/ˌdʒʌk.stə.pəˈzɪʃ.ən/',
    partOfSpeech: 'noun',
    description:
        'The fact of two things being placed close together with contrasting effect for comparison.',
    exampleSentence:
        'The juxtaposition of the old cathedral and the new skyscraper was striking.',
  ),
  const WordEntry(
    word: 'Quintessential',
    pronunciation: '/ˌkwɪn.tɪˈsen.ʃəl/',
    partOfSpeech: 'adjective',
    description:
        'Representing the most perfect or typical example of a quality or class.',
    exampleSentence:
        'The small café was the quintessential Parisian experience.',
  ),
  const WordEntry(
    word: 'Meticulous',
    pronunciation: '/məˈtɪk.jə.ləs/',
    partOfSpeech: 'adjective',
    description:
        'Showing great attention to detail; very careful and precise.',
    exampleSentence:
        'She was meticulous about keeping her notes organized and up to date.',
  ),
];
