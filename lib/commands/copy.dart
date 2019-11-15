import 'dart:io';

import 'package:dshell/commands/command.dart';

import '../util/log.dart';

import 'is.dart';
import 'settings.dart';

///
/// Copies the file [from] to the file [to].
///
/// The to file must not exists unless [overwrite] is set to true.
///
/// The default for [overwrite] is false.
///
/// If an error occurs a [CopyException] is thrown.
void copy(String from, String to, {bool overwrite = false}) =>
    Copy().copy(from, to);

class Copy extends Command {
  void copy(String from, String to, {bool overwrite = false}) {
    if (overwrite == false && exists(to)) {
      throw CopyException("The target file ${absolute(to)} already exists");
    }

    if (isDirectory(to)) {
      throw CopyException("The path ${absolute(to)} is a directory.");
    }

    try {
      File(from).copySync(to);
    } catch (e) {
      throw CopyException(
          "An error occured copying ${absolute(from)} to ${absolute(to)}. Error: $e");
    }

    if (Settings().debug_on) {
      Log.d("mv ${absolute(from)} -> ${absolute(to)}");
    }
  }
}

class CopyException extends CommandException {
  CopyException(String reason) : super(reason);
}