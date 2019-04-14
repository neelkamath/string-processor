import 'package:string_processor/string_processor.dart';
import 'package:test/test.dart';

void main() {
  group('article', () {
    test('uppercase and lowercase letters',
        () => expect(removeArticles('A an the'), isEmpty));
    test(
        'spaces',
        () => expect(removeArticles('A multiple   spaced  the    '),
            'multiple   spaced     '));
    test(
        'special characters',
        () => expect(
            removeArticles('The cake was a, good one'), 'cake was good one'));
  });

  group('remove surrounding special characters', () {
    var string = 'hi,- bob';

    test('no surrounding special characters',
        () => expect(removeSurroundingSpecialCharacters(string), string));
    test('leading and trailing special characters',
        () => expect(removeSurroundingSpecialCharacters('.$string,,'), string));
    test('no trailing special characters',
        () => expect(removeSurroundingSpecialCharacters('.,/$string'), string));
  });

  group('remove special characters around words', () {
    test(
        'special characters',
        () => expect(
            removeSpecialCharactersAroundWords(",I -don't like, it..."),
            "I don't like it"));
    test(
        'arbitrary amounts of whitespace',
        () => expect(removeSpecialCharactersAroundWords('my  !name    ::is'),
            'my  name    is'));
  });

  group('count words matched', () {
    group('articles', () {
      var matchAgainst = 'I ..am; a red Fox';
      var matchFor = 'I& am! a blue fox';

      test(
          'ignore articles',
          () => expect(
              countWordsMatched(matchAgainst, matchFor, ignoreArticles: true),
              3));
      test(
          "don't ignore articles",
          () => expect(
              countWordsMatched(matchAgainst, matchFor, ignoreArticles: false),
              4));
      test(
          'case sensitively',
          () => expect(
              countWordsMatched(matchAgainst, matchFor,
                  matchCaseInsensitively: false),
              3));
      test(
          'case insensitively',
          () => expect(
              countWordsMatched(matchAgainst, matchFor,
                  matchCaseInsensitively: true),
              4));
      test(
          'ignoring special characters',
          () => expect(
              countWordsMatched(matchAgainst, matchFor,
                  ignoreSpecialCharacters: true),
              4));
      test(
          'not ignoring special characters',
          () => expect(
              countWordsMatched(matchAgainst, matchFor,
                  ignoreSpecialCharacters: false),
              2));
    });

    test('special characters', () {
      var sentence = 'I like the tree';
      expect(countWordsMatched('$sentence.', sentence),
          sentence.split(' ').length);
    });
  });

  test('count words matched in', () {
    var sentence1 = 'I like ice-cream';
    var sentence2 = 'I grew the apple tree.';
    expect(
        countWordsMatchedIn([sentence1, sentence2], 'I like the tree',
            ignoreArticles: true),
        [
          _matchWordsMatch(WordsMatch(sentence1, 2)),
          _matchWordsMatch(WordsMatch(sentence2, 2))
        ]);
  });

  test('get percentage match', () {
    expect(
        getPercentageMatched('I really hate the pony', 'I hate pony',
            ignoreArticles: true),
        75);
  });

  test('get percentage matches', () {
    var first = 'a';
    var second = 'ball';
    var third = 'I am human';
    expect(getMatches([first, second, third], 'I am'), [
      _matchPercentageMatch(PercentageMatch(first, 0)),
      _matchPercentageMatch(PercentageMatch(second, 0)),
      _matchPercentageMatch(PercentageMatch(third, 66))
    ]);
  });

  test('get highest percentage matches', () {
    var match1 = PercentageMatch('hi bob', 33);
    var match2 = PercentageMatch('never say never', 33);
    expect(
        getHighestMatchesFromMatches([match1, PercentageMatch('a', 1), match2]),
        [_matchPercentageMatch(match1), _matchPercentageMatch(match2)]);
  });

  test('get highest percentage match', () {
    var match = PercentageMatch('balls', 33);
    expect(getHighestMatchFromMatches([PercentageMatch('a', 1), match, match]),
        _matchPercentageMatch(match));
  });

  test('get best percentage matches', () {
    var sentence = 'i play golf';
    expect(
        getHighestMatches(
            ['a', 'basketball is fun', sentence], 'i play basketball'),
        [_matchPercentageMatch(PercentageMatch(sentence, 66))]);
  });

  test('get best percentage match', () {
    var sentence = "i aren't a cat";
    expect(
        getHighestMatch(['i am a dog', sentence, sentence], "i aren't a doggo"),
        _matchPercentageMatch(PercentageMatch(sentence, 75)));
  });
}

Matcher _matchWordsMatch(WordsMatch match) => TypeMatcher<WordsMatch>()
    .having((match) => match.sentence, 'sentence', match.sentence)
    .having((match) => match.matched, 'matched', match.matched);

Matcher _matchPercentageMatch(PercentageMatch match) =>
    TypeMatcher<PercentageMatch>()
        .having((match) => match.sentence, 'sentence', match.sentence)
        .having((match) => match.percentage, 'percentage', match.percentage);
