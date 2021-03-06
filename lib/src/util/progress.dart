import 'dart:async';

import 'waitForEx.dart';

import 'runnable_process.dart';

class Progress {
  int _exitCode;

  set exitCode(int exitCode) => _exitCode = exitCode;
  int get exitCode => _exitCode;

  Completer<bool> stdoutCompleter = Completer();
  Completer<bool> stderrCompleter = Completer();

  StreamController<String> stdoutController = StreamController();
  StreamController<String> stderrController = StreamController();

  Progress(LineAction stdout, {LineAction stderr = devNull}) {
    stderr ??= devNull;
    _wireStreams(stdout, stderr);
  }

  Progress.forEach();

  void addToStdout(String line) {
    stdoutController.sink.add(line);
  }

  void addToStderr(String line) {
    stderrController.sink.add(line);
  }

  void forEach(LineAction stdout, {LineAction stderr = devNull}) {
    stderr ??= devNull;
    _processUntilComplete(stdout, stderr: stderr);
  }

  // if the user doesn't provide a LineAction then we
  // use this to consume the output.
  static void devNull(String line) {}

  ///
  /// processes both streams until they complete
  ///
  void _processUntilComplete(LineAction stdout, {LineAction stderr = devNull}) {
    _wireStreams(stdout, stderr);

    // Wait for both streams to complete
    waitForEx(Future.wait([stdoutCompleter.future, stderrCompleter.future]));
  }

  ///
  /// processes both streams until they complete
  ///
  void _wireStreams(LineAction stdout, LineAction stderr) {
    assert(stdout != null);
    assert(stderr != null);
    stdoutController.stream.listen((line) {
      stdout(line);
    },
        onDone: () => stdoutCompleter.complete(true),
        onError: (Object e, StackTrace s) => stdoutCompleter.completeError(e),
        cancelOnError: true);

    stderrController.stream.listen((line) {
      stderr(line);
    },
        onDone: () => stderrCompleter.complete(true),
        onError: (Object e, StackTrace s) => stderrCompleter.completeError(e),
        cancelOnError: true);
  }

  /// Returns stdout and stderr lines as a list.
  ///
  /// If you pass a non-zero value to [skipLines]
  /// then the list will skip over the first [skipLines] count;
  /// [skipLines] must be +ve.
  ///
  /// See [firstLine]
  ///     [forEach]
  List<String> toList({int skipLines = 0}) {
    var lines = <String>[];

    forEach((line) {
      if (skipLines > 0) {
        skipLines--;
      } else {
        lines.add(line);
      }
    }, stderr: (line) {
      if (skipLines > 0) {
        skipLines--;
      } else {
        lines.add(line);
      }
    });
    return lines;
  }

  // Returns the first line from the command or
  // null if no lines where returned
  String get firstLine {
    String line;
    var lines = toList();
    if (lines.isNotEmpty) {
      line = lines[0];
    }
    return line;
  }

  void close() {
    stderrController.close();
    stdoutController.close();
  }
}
