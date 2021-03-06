#! /usr/bin/env dshell
import 'dart:io';
import 'package:dshell/dshell.dart';

///
/// running unit tests from vs-code doesn't seem to work as it spawns
/// two isolates and runs tests in parallel (even when using the -j1 option)
/// Given we are actively modifying the file system this is a bad idea.
/// So this script forces the test to run serially via the -j1 option.
///
void main() {
  if (!exists('pubspec.yaml')) {
    printerr(red("This script must be run from the package's root directory."));
    exit(1);
  }
  'pub run test -j1'.run;
}
