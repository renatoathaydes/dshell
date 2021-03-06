import 'package:dshell/dshell.dart';

import '../../settings.dart';
import '../command_line_runner.dart';
import '../flags.dart';
import '../script.dart';
import '../virtual_project.dart';
import 'commands.dart';

class CleanCommand extends Command {
  static const String NAME = 'clean';

  CleanCommand() : super(NAME);

  /// [arguments] must contain a single script.
  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    if (arguments.length != 1) {
      throw InvalidArguments(
          "The 'clean' command expects only a single script as its sole argument. Found ${arguments.join(",")} arguments.");
    }

    Script.validate(arguments);

    var script = Script.fromFile(arguments[0]);

    var project = VirtualProject(Settings().dshellCachePath, script);

    project.clean();

    return 0;
  }

  @override
  String usage() => 'clean <script path.dart>';

  @override
  String description() =>
      "Deletes the project cache for <scriptname.dart> and forces a rebuild of the script's cache.";

  @override
  List<String> completion(String word) {
    var dartScripts = find('*.dart', recursive: false).toList();
    var results = <String>[];
    if (word.isEmpty) {
      results = dartScripts;
    } else {
      for (var script in dartScripts) {
        if (script.startsWith(word)) {
          results.add(script);
        }
      }
    }

    return results;
  }

  @override
  List<Flag> flags() {
    return [];
  }
}
