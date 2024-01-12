import 'dart:convert';
import 'dart:io';
import 'package:auto_local/print_color.dart';
import 'package:watcher/watcher.dart';
class AutoLocal{
  Print pen = Print();

  run(){
    pen.green("|------------------👋 Starting Auto Local Tool 👋----------------------------|");
    pen.green("|                   This Tool Built by Github: abom-me                                 |");
pen.yellow("""
  This tool is used to generate a dart class from a JSON file.
  the json file path should be in assets/lang/ directory.
  because this tool is depend on flutter_locales2 package.
  """);
    final String directoryPath = 'assets/lang/';
    final directory = Directory(directoryPath);

    if (directory.existsSync()) {
      _generateLocalizationClasses(); // Initial generation

      // Watch for changes in the directory
      final watcher = DirectoryWatcher(directoryPath);
      watcher.events.listen((event) {
        if (event.type == ChangeType.MODIFY) {

          _updateDartClass(event.path);
        }
      });

      pen.magenta("|------------------Waiting new data in $directoryPath---------------------|");

      // // Keep the process running
      // stdin.readLineSync();
    } else {
      pen.red('Directory not found: $directoryPath');
    }
  }

  void _generateLocalizationClasses() {


    final String directoryPath = 'assets/lang/';

    final directory = Directory(directoryPath);
    if (directory.existsSync()) {
      final files = directory.listSync().whereType<File>().toList();
      for (final file in files) {
        if (file.path.endsWith('.json')) {

        }
      }
      _updateDartClass(files[0].path);
    } else {
      print('Directory not found: $directoryPath');
    }
  }

  void _updateDartClass(String jsonPath) {
    final jsonString = File(jsonPath).readAsStringSync();
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final generatedCode = _generateClassCode(jsonData);
    Directory("lib/auto_local").create(recursive: true).then((Directory directory) {

      File('${directory.path}/lang.dart')
          .writeAsStringSync(generatedCode);
      print("""
|-----------------------Done 👀----------------------------|
-> 🥳 Your file is created in ${directory.path}/lang.dart 🥳 <-
""");



    });


  }

  String _generateClassCode( Map<String, dynamic> jsonData) {
    final StringBuffer classMethods = StringBuffer();
    classMethods.writeln('  enum LangKey{');

    int count = jsonData.length;
    jsonData.forEach((key, value) {
      if (value is String) {
        String formattedKey = key.replaceAllMapped(RegExp('_(\\w)'), (match) {
          return match.group(1)!.toUpperCase();
        });

        classMethods.write("$formattedKey('$key')");
        if (--count > 0) {
          classMethods.writeln(',');
        } else {
          classMethods.writeln(';');
        }
      }
      // Add other types handling if necessary (e.g., nested maps, lists, etc.)
    });

    classMethods.writeln(''' 
  const LangKey(this.key);
  final String key;
 }\n''');

    return '''
  // This file is generated by Auto Local. Do not edit any things.
  import 'package:flutter/material.dart';
import 'package:flutter_locales2/flutter_locales2.dart';
  class Lang {

    static String get(BuildContext context,{required LangKey key}) {
    return Locales.string(context, key.key) ?? '';
  }
  }
    $classMethods

  ''';
  }





}