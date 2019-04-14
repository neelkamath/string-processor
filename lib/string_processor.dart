/// Article"s are the words "a", "an", and "the".
///
/// "Words" are anything separated by whitespace.
///
/// Ignoring special characters will result in `hi!` matching `hi`.
///
/// When matching words, duplicates won't be considered. So if the [String]
/// being matched contains 4 "hi"s and the [String] being matched against
/// contains 3 "hi"s, only 3 of the "hi"s would be counted.

/// Returns [sentence] without "a", "an", and "the".
///
/// ```dart
/// removeArticles('A multiple   spaced  the    '); // 'multiple   spaced     '
/// ```
String removeArticles(String sentence) {
  var words = sentence.split(' ');
  for (var word in sentence.split(' ')) {
    var modified = word.replaceAll(RegExp(r'[^a-zA-Z]*'), '').toLowerCase();
    if (['a', 'an', 'the'].contains(modified)) {
      words.remove(word);
    }
  }
  return words.join(' ');
}

/// Returns the best match of [toCheck] against [sentences].
///
/// If there are multiple matches with the same [PercentageMatch.percentage],
/// the first match will be returned.
/// `null` will be returned if there are no matches.
PercentageMatch getHighestMatch(List<String> sentences, String toCheck,
        {bool ignoreArticles = false,
        bool matchCaseInsensitively = true,
        bool ignoreSpecialCharacters = true}) =>
    getHighestMatches(sentences, toCheck,
            ignoreArticles: ignoreArticles,
            matchCaseInsensitively: matchCaseInsensitively,
            ignoreSpecialCharacters: ignoreSpecialCharacters)
        ?.first;

/// Returns the best matches of [toCheck] against [sentences].
///
/// If there are multiple [PercentageMatch]es with the same
/// [PercentageMatch.percentage], there will be more than one item in the [List]
/// returned.
/// `null` will be returned if [sentences] is empty.
List<PercentageMatch> getHighestMatches(List<String> sentences, String toCheck,
        {bool ignoreArticles = false,
        bool matchCaseInsensitively = true,
        bool ignoreSpecialCharacters = true}) =>
    getHighestMatchesFromMatches(getMatches(sentences, toCheck,
        ignoreArticles: ignoreArticles,
        matchCaseInsensitively: matchCaseInsensitively,
        ignoreSpecialCharacters: ignoreSpecialCharacters));

/// Returns the match having the highest [PercentageMatch.percentage].
///
/// If there are multiple matches with having the same
/// [PercentageMatch.percentage], the first one will be returned.
/// `null` will be returned if there are no matches.
PercentageMatch getHighestMatchFromMatches(List<PercentageMatch> matches) =>
    getHighestMatchesFromMatches(matches)?.first;

/// Returns the matches with the highest [PercentageMatch.percentage].
///
/// If there are multiple [PercentageMatch]es with the same
/// [PercentageMatch.percentage], there will be more than one item in the [List]
/// returned.
/// `null` will be returned if [matches] is empty.
List<PercentageMatch> getHighestMatchesFromMatches(
    List<PercentageMatch> matches) {
  if (matches.isEmpty) {
    return null;
  }

  matches
      .sort((first, second) => first.percentage.compareTo(second.percentage));
  return matches
    ..retainWhere((match) => match.percentage == matches.last.percentage);
}

/// Returns percentages each sentence in [sentences] matched against [toCheck].
List<PercentageMatch> getMatches(List<String> sentences, String toCheck,
    {bool ignoreArticles = false,
    bool matchCaseInsensitively = true,
    bool ignoreSpecialCharacters = true}) {
  var matches = <PercentageMatch>[];
  for (var sentence in sentences) {
    matches.add(PercentageMatch(
        sentence,
        getPercentageMatched(sentence, toCheck,
            ignoreArticles: ignoreArticles,
            matchCaseInsensitively: matchCaseInsensitively,
            ignoreSpecialCharacters: ignoreSpecialCharacters)));
  }
  return matches;
}

/// Returns the percentage [toCheck] matched against [sentence].
int getPercentageMatched(String sentence, String toCheck,
    {bool ignoreArticles = false,
    bool matchCaseInsensitively = true,
    bool ignoreSpecialCharacters = true}) {
  int match = countWordsMatched(sentence, toCheck,
      ignoreArticles: ignoreArticles,
      matchCaseInsensitively: matchCaseInsensitively,
      ignoreSpecialCharacters: ignoreSpecialCharacters);
  if (ignoreArticles) {
    sentence = removeArticles(sentence);
  }
  return _calculatePercentage(match, sentence.split(' ').length);
}

int _calculatePercentage(int obtained, int total) =>
    ((obtained / total) * 100).floor();

/// Returns how many words each item in [sentences] matched in [matchFor].
List<WordsMatch> countWordsMatchedIn(List<String> sentences, String matchFor,
    {bool ignoreArticles = false,
    bool matchCaseInsensitively = true,
    bool ignoreSpecialCharacters = true}) {
  var matches = <WordsMatch>[];
  for (var sentence in sentences) {
    var modifiedSentence = sentence;
    if (ignoreArticles) {
      modifiedSentence = removeArticles(sentence);
    }
    matches.add(WordsMatch(
        sentence,
        countWordsMatched(modifiedSentence, matchFor,
            ignoreArticles: ignoreArticles,
            matchCaseInsensitively: matchCaseInsensitively,
            ignoreSpecialCharacters: ignoreSpecialCharacters)));
  }
  return matches;
}

/// Returns how many words in [matchFor] matched against [matchAgainst].
int countWordsMatched(String matchAgainst, String matchFor,
    {bool ignoreArticles = false,
    bool matchCaseInsensitively = true,
    bool ignoreSpecialCharacters = true}) {
  if (ignoreArticles) {
    matchAgainst = removeArticles(matchAgainst);
    matchFor = removeArticles(matchFor);
  }
  if (matchCaseInsensitively) {
    matchAgainst = matchAgainst.toLowerCase();
    matchFor = matchFor.toLowerCase();
  }

  List<String> matchForWords = (ignoreSpecialCharacters
          ? removeSpecialCharactersAroundWords(matchFor)
          : matchFor)
      .split(' ');
  List<String> matchAgainstWords = (ignoreSpecialCharacters
          ? removeSpecialCharactersAroundWords(matchAgainst)
          : matchAgainst)
      .split(' ');
  var wordsMatched = 0;
  for (var word in matchAgainstWords) {
    if (matchForWords.contains(word)) {
      matchForWords.remove(word);
      ++wordsMatched;
    }
  }
  return wordsMatched;
}

/// Returns [string] after removing each word's surrounding special characters.
String removeSpecialCharactersAroundWords(String string) {
  var separator = ' ';
  List<String> words = string.split(separator);
  var newWords = <String>[];
  for (var word in words) {
    newWords.add(removeSurroundingSpecialCharacters(word));
  }
  return newWords.join(separator);
}

/// Returns [string] without trailing and leading special characters.
String removeSurroundingSpecialCharacters(String string) {
  var specialChar = RegExp(r'[^a-zA-Z0-9\s]*');
  string = string.replaceFirst(specialChar, '');
  Iterable<Match> matches = RegExp(r'[a-zA-Z0-9\s]').allMatches(string);
  if (matches.length > 0) {
    string = string.replaceFirst(specialChar, '', matches.last.start + 1);
  }
  return string;
}

/// The sentence and how much percentage it was matched.
class PercentageMatch {
  String sentence;
  int percentage;

  PercentageMatch(this.sentence, this.percentage);

  @override
  String toString() => '$sentence: $percentage%';
}

/// The sentence matched and how many words in it were matched.
class WordsMatch {
  String sentence;
  int matched;

  WordsMatch(this.sentence, this.matched);

  @override
  String toString() => '$sentence matches: $matched';
}
