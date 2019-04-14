import 'package:link_checker/link_checker.dart';
import 'package:test/test.dart';

void main() {
  test('dead links', () async {
    var badLinks = <BadLink>[];
    await for (BadLink badLink in getBadLinksInDirectory(
        blacklistedDirectories: [BlacklistedDirectory('.dart_tool')],
        blacklistedFilePaths: ['.packages', 'pubspec.lock'])) {
      badLinks.add(badLink);
    }
    expect(badLinks, isEmpty,
        reason: "There shouldn't be dead links in the project");
  }, timeout: Timeout.none);
}
