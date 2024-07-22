import 'dart:convert';
import 'dart:io';
import 'package:dart_widget/dart_widget.dart';
import 'package:args/command_runner.dart';
import 'package:auto_local/settings.dart';
import 'package:http/http.dart' as http;
import 'package:tint/tint.dart';
import 'package:watcher/watcher.dart';

class Lang extends Command {
  Lang() {
    argParser.addFlag('adg',
        help: 'Add new text to the language file using GPT <you have to provide API Key>');
    argParser.addFlag('eapi', help: 'Edit the API Key for the GPT');
    argParser.addFlag('adm',
        help: 'Add new text to the language file manually for all languages');
    argParser.addFlag('ep', help: 'Edit the path of the language file');
    argParser.addFlag('ref', help: 'To refresh the dart class file');
    argParser.addFlag('auto',
        help:
            'Listen for any changes in language/path/<json files> and update the dart class');
  }

  late String _directoryPath;
  late bool _usingAppLocal;
  final Settings settings = Settings();
  // final input = stdout;

  @override
  Future<void> run() async {
    await _checkLanguageFolderPath();

    if (argResults?['adg'] == true) {

      await _handleAddWithGPT();
    } else if (argResults?['eapi'] == true) {
      await _editAPIKey();
    } else if (argResults?['ep'] == true) {
      _editPath();
    } else if (argResults?['auto'] == true) {
      _listener();
    } else if (argResults?['ref'] == true) {
      _updateDartClass();
    } else if (argResults?['adm'] == true) {
      _addManualy();
    } else {
      print('No valid flag provided. Use --help to see available options.'.red());
    }
  }
  _editPath() {
    String? newPath = TextField(
        prompt: "Enter The New Path",
        hint: "ex: assets/lang/",
        validator: (String path) {
          if (path.isEmpty) {
            throw ValidationErrors("The path can not be empty");
          } else if (!Directory(path).existsSync()) {
            throw ValidationErrors("This path is not exist in your project");
          } else {
            return true;
          }
        }).oneline();

    settings.createFile({"lang_path": newPath});
  }

  Future<void> _checkLanguageFolderPath() async {
    if (settings.loadFile()?['lang_path'] == null) {
      String path = TextField(
                  prompt: "✏️ Enter your language folder path: ",
                  hint: "ex:assets/lng/",
      validator: (String path) {
                    print(path);
        if (path.isEmpty) {
          throw ValidationErrors("The path can not be empty");
        } else if (!Directory(path).existsSync()) {
          throw ValidationErrors("This path is not exist in your project");
        } else {
          return true;
        }
      }
      )
              .oneline() ??
          "";
      _directoryPath = path;
      settings.createFile({"lang_path": _directoryPath});
    } else {
      _directoryPath = settings.loadFile()!['lang_path']!;
    }
  }

  Future<void> _handleAddWithGPT() async {
    if (settings.loadFile()?['gpt_key'] == null) {
      await _promptForAPIKey();
    } else {
      await _processAddText();
    }
  }

  Future<void> _promptForAPIKey() async {

    String apiKey = TextField(
        prompt: '✏️ Enter your API Key: ',
      hint: "From OpenAI"
    ).oneline()!;
    Map<String, dynamic> keys = settings.createJwt(apiKey);
    settings.createFile({"gpt_key": keys['api'], "secret_key": keys['secret']});
  }

  Future<void> _editAPIKey() async {
    String apiKey = TextField(
        prompt: '✏️ Enter your API Key',
        hint: "From OpenAI"
    ).oneline()!;
    Map<String, dynamic> keys = settings.createJwt(apiKey);
    settings.createFile({"gpt_key": keys['api'], "secret_key": keys['secret']});
  }

  Future<void> _processAddText() async {
    if (argResults!.rest.isNotEmpty) {
      Map<String, dynamic> data = settings.checkToken();
      if (data['status'] == true) {
        String text = argResults!.rest[0];
        String api = data['apiKey'];
        await addText(text, api).whenComplete(() {
          if (argResults?['ref'] == true) {
            _updateDartClass();
          }
        });
      }
    } else {
      print(
          '\n\n ⚠️No data provided to add. Use --add "your text here" to add new text.⚠️'.yellow());
    }
  }

  Future<void> _updateDartClass() async {

    settings.pathChecker(_directoryPath);
    final directory = Directory(_directoryPath);
    late File langFile;

    if (directory.existsSync()) {
      final files = directory.listSync().whereType<File>().toList();
      for (final file in files) {
        if (file.path.endsWith('.json')) {
          langFile = file;
          break;
        }
      }
    } else {
      print('Directory not found: $_directoryPath'.red());
      return;
    }

    final jsonString = await langFile.readAsString();
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final generatedCode = _generateClassCode(jsonData);
final loading = CircleLoading(
          onDoneText: 'Your Dart class updated successfully',
          loadingText: 'Updating your Dart class',
        );
        loading.start();
    await Directory("lib/auto_local").create(recursive: true);
    await File('lib/auto_local/lang.dart').writeAsString(generatedCode);
    loading.stop();
  }

  String _generateClassCode(Map<String, dynamic> jsonData) {
    final StringBuffer classMethods = StringBuffer();
    _checkUsingAppLocal();
    if (_usingAppLocal) {
      _checkAddAppLocal();
    }
    classMethods.writeln('enum LangKey {');

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
    });

    classMethods.writeln('''
  const LangKey(this.key);
  final String key;
 }\n''');

    return _usingAppLocal
        ? '''
// This file is generated by Auto Local. Do not edit anything.
import 'package:flutter/material.dart';
import 'package:app_local/app_local.dart';
  changeLang(BuildContext context, String lang) {
 
    Locales.change(context, lang);
  }
class Lang {
  static String get(BuildContext context, {required LangKey key}) {
    return Locales.string(context, key.key) ?? '';
  }
}
$classMethods
'''
        : '''
// This file is generated by Auto Local. Do not edit anything.

$classMethods
''';
  }

  Future<void> addText(String text, String api) async {
    final directory = Directory(_directoryPath);

    if (directory.existsSync()) {
      List<FileSystemEntity> files = directory.listSync();
      List<String> languages = files
          .map((file) => file.uri.pathSegments.last.split('.').first)
          .toList();
      final loading = CircleLoading(
        onDoneText: 'The Translation Added',
        loadingText: 'Adding the translation with GPT',
      );
      loading.start();
      Map<String, dynamic> data = await askGPT(text, languages, api);

      if (data.isNotEmpty) {
        var encoder = JsonEncoder.withIndent('  ');

        for (var entry in data.entries) {
          String key = entry.key;
          String value = entry.value;
          File newLangFile = File('$_directoryPath/$key.json');
          if (newLangFile.existsSync()) {
            try {
              String jsonString = await newLangFile.readAsString();
              Map<String, dynamic> jsonMap2 = jsonDecode(jsonString);
              jsonMap2[data['en']
                  .replaceAll(" ", "_")
                  .replaceAll(".", "")
                  .replaceAll("'", "")
                  .toLowerCase()] = value;
              String updatedJsonString = encoder.convert(jsonMap2);

              await newLangFile.writeAsString(updatedJsonString, flush: true);
            } catch (e) {
              print('Error reading or updating file for language: $key'.red());
              print('Error details: $e'.red());
            }
          } else {
            print('Language file not found for code: $key'.red());
          }
        }
loading.stop();
        print('''
          -----------------👀 The Translation Added 👀-----------------
          -> The text translated to [${languages.join(', ')}]
          -> Original text: $text
          -> The text Key: ${data['en'].replaceAll(" ", "_").replaceAll(".", "").replaceAll("'", "").toLowerCase()}
          -----------------------------------------------------------
        '''.green());
      } else {
        print('Empty or invalid data received from GPT'.red());
      }
    }
  }

  _listener() {
    final watcher = DirectoryWatcher(_directoryPath);
    watcher.events.listen((event) {
      if (event.type == ChangeType.MODIFY) {
        _updateDartClass();
      }
    });

    print(
        "|------------------Waiting new data in $_directoryPath---------------------|".magenta());
  }

  _checkUsingAppLocal() {
    if (settings.loadFile()?['app_local'] == null) {
      String? selection = TextField(
          prompt: 'Do you want to use app_local package?',
          hint: '[y]yes [n]no',
          validator: (data) {
            if (data == 'y' || data == 'n') {
              return true;
            } else {
              throw ValidationErrors(
                  'Invalid selection, only [y] or [n] are allowed');
            }
          }).oneline();

      settings.createFile({"app_local": selection == "y" ? true : false});
      _usingAppLocal = selection == 'y' ? true : false;
    } else {
      _usingAppLocal = settings.loadFile()!['app_local']!;
    }
  }

  _checkAddAppLocal() async {
    File file = File('pubspec.yaml');
    if (file.existsSync()) {
      String content = file.readAsStringSync();
      if (content.contains('app_local')) {
      } else {
        final loading = CircleLoading(
          onDoneText: 'Added app_local package successfully',
          loadingText: 'Adding app_local package',
        );
        loading.start();
        await Process.run('flutter', ['pub', 'add', 'app_local']);
        loading.stop();
      }
      // var userLibrary = await settings.loadLibrary("lib/auto_local/lang.dart");

      // Invoke the method
      // await settings.invokeMethod(userLibrary, "changeLang", ['context', 'ar']);
    }
  }

  Future<Map<String, dynamic>> askGPT(
      String text, List<String> languages, String api) async {
    var uri = Uri.parse('https://api.openai.com/v1/chat/completions');

    String body = '''
{
  "model": "gpt-3.5-turbo",
  "messages": [
    {"role": "system", "content": "You are a translator."},
    {"role": "system", "content": "The output will be as JSON lang code with text like this: {en: 'Hello World'} it has to be JSON always"},
    {"role": "user", "content": "Translate the following text to ${languages.join(', ')}, en: '$text'"}
  ]
}''';

    var headers = {
      "Authorization": "Bearer $api",
      "content-type": "application/json; charset=utf-8"
    };

    final response = await http.post(uri, headers: headers, body: body);
    int statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      var responseBody = utf8.decode(response.bodyBytes);

      try {
        var data = jsonDecode(responseBody);
        var result = jsonDecode(data['choices'][0]['message']['content']);
        return result;
      } catch (e) {
        askGPT(text, languages, api);
        print('Error parsing response body: $e'.red());
        return {};
      }
    } else {
      // askGPT(text, languages, api);
      print('Error Status Code: $statusCode'.red());
      print('Error Response Body: ${response.body}'.red());
      return {};
    }
  }

  _addManualy() async {
    final directory = Directory(_directoryPath);

    if (directory.existsSync()) {
      List<FileSystemEntity> files = directory.listSync();
      List<String> languages = files
          .map((file) => file.uri.pathSegments.last.split('.').first)
          .toList();
      final keyName = TextField(
        prompt: 'Key Name',
        hint: 'ex: app_name', // optional, will provide the user as a hint
        validator: (String data) {
          if (RegExp(r'^[a-z0-9_]+$').hasMatch(data)) {
            if (data.endsWith('_')) {
              throw ValidationErrors(
                  'The Key it\'s not valid , it\'s can\'t be ends with _');
            } else {
              return true;
            }
          } else {
            throw ValidationErrors(
                'The Key it\'s not valid , only [a-z, 0-9 ,_ ] are allowed');
          }
        },
      ).oneline();

      var encoder = JsonEncoder.withIndent('  ');

      for (var lang in languages) {
        String? text = TextField(
          prompt: 'Enter text for $lang language',
          hint: 'Enter The Text', // optional, will provide the user as a hint
          validator: (String data) {
            if (data.isEmpty) {
              throw ValidationErrors('The text can not be empty');
            } else {
              return true;
            }
          },
        ).oneline();
        File newLangFile = File('$_directoryPath/$lang.json');
        if (newLangFile.existsSync()) {
          try {
            String jsonString = await newLangFile.readAsString();
            Map<String, dynamic> jsonMap2 = jsonDecode(jsonString);
            jsonMap2[keyName.toString()] = text;

            String updatedJsonString = encoder.convert(jsonMap2);

            await newLangFile.writeAsString(updatedJsonString, flush: true);
          } catch (e) {
            print('Error reading or updating file for language: $lang'.red());
            print('Error details: $e'.red());
          }
        } else {
          print('Language file not found for code: $lang'.red());
        }
      }
    } else {
      throw Exception("Directory not found");
    }
  }


  @override
  String get description =>
      "Generate language file and listen for any changes in language/path/<json files>";

  @override
  String get name => "lang";
}
