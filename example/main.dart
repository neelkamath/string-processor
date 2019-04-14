import 'package:string_processor/string_processor.dart';

void main() => print(getHighestMatch(
    ['I am a boy', 'Bob the Builder is fun'], 'Bob is a boy.',
    ignoreArticles: true, matchCaseInsensitively: false));
