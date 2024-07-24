

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:auto_local/settings.dart';
import 'package:dart_widget/dart_widget.dart';
import 'package:tint/tint.dart';
import 'package:yaml_edit/yaml_edit.dart';

class Env extends Command {

  Env() {
    argParser.addFlag('new',
        abbr: 'n',
        negatable: false,
        help: 'Create a new environment variable.');
    argParser.addFlag('ref',
        abbr: 'r',
        negatable: false,
        help: 'Refresh the dart class file.');
    argParser.addFlag('delete',
        abbr: 'd',
        negatable: false,
        help: 'Delete the environment variable.');
  }
Settings settings = Settings();
  @override
  Future<void> run() async {
  await  _createEnvFile();
    if (argResults!['new'] == true) {
      _createEnv();
    }  else if (argResults!['ref'] == true) {
    _refreshDartClass();
  } else if (argResults!['delete'] == true) {
      _deleteKey();
  }
    else {
      print('Getting environment variables');
    }
  }


  Future<void> _createEnvFile() async {
    await Directory("lib/env/").create(recursive: true);

    // check if the .env file exists
    File file = File('.env');
    if (!file.existsSync()) {
      file.createSync();
      // add it to the gitignore

      file.writeAsStringSync('''
# This file crated by Auto Local Tool
# To add new environment variables, run the command:
# auto_local env --new
# To add new environment variables, manually add them like this:
# Example:
# API_KEY=your_api_key
# OR
# APIKEY=your_api_key
''');
      print('✅ .env file created successfully and added to .gitignore'.green());

    }
    File gitignore = File('.gitignore');
    if (gitignore.existsSync()) {
      gitignore.readAsStringSync().contains('.env')
          ? null
          : gitignore.writeAsStringSync('.env');
    }
    _checkAssets();
  }
  _checkAssets() {
    final pubspec = File('pubspec.yaml');
  final data=pubspec.readAsStringSync();
  if(data.contains("- .env")||data.contains("-.env")){

  }else{
    print("Please add .env to assets in pubspec.yaml file, to you can use it".yellow());
  }
  }

  Future<void> _createEnv() async {
    _createENVGFile();
    final name = TextField(
        prompt: '✏️ Enter the environment variable name',
      hint: 'API_KEY',
      validator: (value) {

    if(!RegExp(r'^[A-Z_]*$').hasMatch(value)){
     throw ValidationErrors('Environment variable name must be in uppercase and separated by underscore');
    }else if(value.endsWith('_') || value.startsWith('_')) {
      throw ValidationErrors(
          'Environment variable name must not start or end with underscore');
     }else{
        return true;
    }
      },

    ).oneline();

    final value = TextField(
        prompt: '✏️ Enter the environment variable value',
        hint: 'your_api_key',


    ).oneline();
    File file = File('.env');
    file.writeAsStringSync('$name=$value\n', mode: FileMode.append);
    final loading=CircleLoading(
        loadingText: "Adding environment variable to .env file",
        onDoneText: "Environment variable added successfully and added to env.dart file",
    );
    loading.start();
  await  _refreshDartClass();
    loading.stop();

  }
Future<void> _createENVGFile() async {

  File file = File('lib/env/env.g.dart');
  if (!file.existsSync()) {
    file.createSync();
    file.writeAsStringSync('''
    part of 'env.dart';


class ENVSettings extends ChangeNotifier {
  static final ENVSettings _instance = ENVSettings._internal();

  factory ENVSettings() {
    return _instance;
  }

  ENVSettings._internal();

  final Map<String, dynamic> _keys = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    try {
      final file = await rootBundle.loadString(".env");
      var lines = file.split("\\n");
      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty || line.startsWith('#')) continue;
        var parts = line.split("=");
        if (parts.length == 2) {
          _keys[parts[0].trim()] = parts[1].trim();
        } else {
          developer.log('Invalid line: \$line', name: 'ENVSettings');}
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      throw '.env file not found or unreadable';
    }
  }

  String? read(String key) {
    if (!_isInitialized) {
      throw 'ENVSettings is not initialized';
    }
    if (_keys.containsKey(key)) {
      return _keys[key];
    } else {
      developer.log('Key not found: \$key', name: 'ENVSettings');
      throw '\$key not found';
    }
  }

  void reload() async {
    _keys.clear();
    _isInitialized = false;
    await init();
  }
}
    ''');
    print('✅ env.g.dart file created successfully'.green());
  }

}

Future<void> _refreshDartClass() async {
    List<String> keys = [];
  File file = File('.env');
  final data=file.readAsStringSync();
  final lines=data.split('\n');
  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    var parts = line.split("=");
    if (parts.length == 2) {
     keys.add(parts[0].trim());
    } else {
      print('Invalid line: $line'.red());
    }
  await  _generateEnvClass(keys);
  }


}
  Future _generateEnvClass(List<String> keys) async {

    var buffer = StringBuffer();

    buffer.write('''
// This file is generated by Auto Local Tool
// To access the environment variables, use the following code:
// add the following code to the main.dart file
// void main() async {
// <---- Add the following code ---->
//   WidgetsFlutterBinding.ensureInitialized();
// <---- Add the following code ----> 
// await Env().init();
//   runApp(const MyApp());
// }
    
// To access the environment variables, use the following code:
// final env = Env();
// final apiKey = env.apiKey;
//OR
// final apiKey = ENV().apiKey;
    
library env;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:developer' as developer;
part 'env.g.dart';

    ''');
    buffer.writeln('class Env {');
    buffer.writeln();
    buffer.writeln('  Future init() async {');
    buffer.writeln('    await ENVSettings().init();');
    buffer.writeln('  }');
    buffer.writeln();

    for (var key in keys) {
      String keyVal=key;
      final kk=key.split('_');
       String keyName = kk[0].toLowerCase()+kk.sublist(1).map((e) => e[0].toUpperCase()+e.substring(1).toLowerCase()).join();

      buffer.writeln('  String get ${keyName} => ENVSettings().read("$keyVal") ?? "";');
    }

    buffer.writeln('}');

    var content = buffer.toString();
   await _saveToFile(content);
  }

  Future<void> _saveToFile(String content) async {
    var file = File("lib/env/env.dart");
    if(!file.existsSync()){
      file.createSync();
    }
    await file.writeAsString(content);
  }

  _deleteKey() {
    final key = TextField(
      prompt: '✏️ Enter the environment variable name to delete',
validator: (value) {
  if(!RegExp(r'^[A-Z_]*$').hasMatch(value)){
    throw ValidationErrors('Environment variable name must be in uppercase and separated by _');
  }else if(value.endsWith('_') || value.startsWith('_')) {
    throw ValidationErrors(
        'Environment variable name must not start or end with underscore');
  }else{
    return true;
  }
      }
    ).oneline()!;
    File file = File('.env');
    final data=file.readAsStringSync();
    final lines=data.split('\n');
    final newLines=lines.where((element) => !element.contains(key)).toList();
    file.writeAsStringSync(newLines.join('\n'));
    print('✅ Environment variable deleted successfully'.green());
    _refreshDartClass();
  }
  @override
  String get description =>
      'This command is used to add the environment variables to the .env file and use it in the project from dart class.';

  @override
  String get name => 'env';

}