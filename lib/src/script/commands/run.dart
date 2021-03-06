import 'package:dshell/dshell.dart';

import '../../pubspec/pubspec_manager.dart';

import '../../settings.dart';
import '../dart_sdk.dart';
import '../flags.dart';
import '../project_cache.dart';
import '../runner.dart';
import '../script.dart';
import 'commands.dart';

/// Runs a dart script.
class RunCommand extends Command {
  static const String NAME = 'run';

  RunCommand() : super(NAME);

  ///
  /// [arguments] - the arguments passed directly to the run command.
  /// Returns the [exitcode];
  @override
  int run(List<Flag> selectedFlags, List<String> arguments) {
    Script.validate(arguments);

    var script = Script.fromFile(arguments[0]);
    Settings().scriptPath = script.path;

    Settings().verbose('Running script ${script.path}');

    var project = ProjectCache().loadProject(script);
    Settings().verbose('Virtual Project directory ${project.path}');

    if (PubSpecManager(project).isCleanRequired()) {
      project.clean();
      Settings().verbose('Cleaning Virtual Project');
    }

    var scriptArguments = <String>[];

    if (arguments.length > 1) {
      scriptArguments = arguments.sublist(1);
    }

    Settings().verbose('Script Arguments: ${scriptArguments.join(", ")}');

    final sdk = DartSdk();

    final runner = ScriptRunner(sdk, project, scriptArguments);

    final exitCode = runner.exec();

    return exitCode;
  }

  @override
  String usage() => 'run <script path.dart>';

  @override
  String description() =>
      '''Runs the given script. This command is provided for the sake of symmetry. 
 The recommended method is to use the simplier form ${Settings().appname} <script path.dart>''';

  // CommandRun.fromScriptArg(String argument) {
  //   Script.validate(argument);
  //   Script script = Script.fromArg(selectedFlags.values.toList(), argument);
  //   script.run(selectedFlags, subarguments);
  // }

  @override
  List<String> completion(String word) {
    var dartScripts = find('*.dart', recursive: false).toList();
    var results = <String>[];
    for (var script in dartScripts) {
      if (script.startsWith(word)) {
        results.add(script);
      }
    }
    return results;
  }

  @override
  List<Flag> flags() {
    return [];
  }
}
