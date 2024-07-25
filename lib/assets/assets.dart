import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dart_widget/dart_widget.dart';
import 'package:tint/tint.dart';
import 'package:watcher/watcher.dart';

import '../settings.dart';

/// A command to manage assets in a Flutter/Dart project.
class Assets extends Command {
  Assets() {
    argParser.addFlag('generate',
        abbr: 'g', negatable: false, help: 'Generate assets class.');
    argParser.addFlag('listen',
        abbr: 'l', negatable: false, help: 'Listen to the assets folder.');
    argParser.addFlag('ignore',
        abbr: 'i', negatable: false, help: 'Ignore folder.');
  }

  // List of asset folders
  final List<String> _folders = ["assets"];
  // Settings object for configuration management
  final Settings settings = Settings();
  // List of active watchers for the folders
  final List<StreamSubscription<WatchEvent>> _activeWatchers = [];

  @override
  Future<void> run() async {
    _getFolders();
    if (argResults!['generate'] == true) {
      _generateAssetsClass();
    } else if (argResults!['listen'] == true) {
      _watchAssetsFolder();
    } else if (argResults!['ignore'] == true) {
      _ignoreFolder();
    } else {
      print('This command not found. Try to use help $name'.red());
    }
  }

  /// Recursively gets all folders within the specified path.
  void _getFolders([String path = "assets"]) {
    final directory = Directory(path);

    if (directory.existsSync()) {
      directory.listSync().forEach((element) {
        if (element is Directory) {
          _folders.add(element.path);
          _getFolders(element.path);
        }
      });
    } else {
      print("❌ You don't have an assets folder".red());
    }
  }

  /// Ignores a specified folder by saving it in the settings.
  void _ignoreFolder() {
    // List the folders with numbers
    print("📁 Folders".green());
    for (var i = 0; i < _folders.length; i++) {
      print("$i. ${_folders[i]}");
    }

    // Prompt user to enter the folder number to ignore
    final folder = TextField(
      prompt: "Enter the folder number to ignore it ",
      validator: (value) {
        var number = int.tryParse(value);
        if (number == null) {
          throw ValidationErrors("Please enter a number");
        }
        if (number < 0 || number >= _folders.length) {
          throw ValidationErrors("This folder does not exist");
        }
        return true;
      },
    ).oneline();

    // Load current settings and update ignored folders
    Map<String, dynamic>? data = settings.loadFile();
    List<String> newData = [];

    if (data != null) {
      if (data["ignored_assets_folders"] != null) {
        newData = List<String>.from(data["ignored_assets_folders"]);
        String folderToIgnore = _folders[int.parse(folder.toString())];
        if (newData.contains(folderToIgnore)) {
          newData.remove(folderToIgnore);
        }
      }
      newData.add(_folders[int.parse(folder.toString())]);
    } else {
      newData = [_folders[int.parse(folder.toString())]];
    }

    settings.createFile({"ignored_assets_folders": newData});
  }

  /// Generates a Dart class containing constants for each asset.
  void _generateAssetsClass() {
    int total = 0;
    Directory directory = Directory("lib/auto_local");
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    File file = File("lib/auto_local/assets.dart");
    if (!file.existsSync()) {
      file.createSync();
    }
    String content = """
class Assets {
""";
    for (var element in _folders) {
      List ignoreFolders = settings.loadFile()?["ignored_assets_folders"] ?? [];
      if (ignoreFolders.contains(element)) {
        continue;
      }

      final directory = Directory(element);
      if (directory.existsSync()) {
        directory.listSync().forEach((element) {
          if (element.path.contains("DS_Store")) {
            return;
          }
          if (element is File) {
            total++;
            String name = element.path.split("/").last.split(".").first;
            final kk = name.replaceAll("-", "_").split("_");
            name = kk[0].toLowerCase() +
                kk
                    .sublist(1)
                    .map((e) =>
                e[0].toUpperCase() + e.substring(1).toLowerCase())
                    .join();
            content += "  static const String $name = '${element.path}';\n";
          }
        });
      }
    }
    content += """
}
""";
    file.writeAsStringSync(content);

    print("\n✅ $total assets generated successfully".green());
  }

  /// Watches the assets folder for changes and regenerates the assets class when changes occur.
  void _watchAssetsFolder() {
    print("📁 Listening to the assets folder".green());
    print("\n⚠️ Press 'Q' to stop listening\n".yellow());

    for (var element in _folders) {
      List ignoreFolders = settings.loadFile()?["ignored_assets_folders"] ?? [];
      if (ignoreFolders.contains(element)) {
        continue;
      }
      final watcher = DirectoryWatcher(element);
      var subscription = watcher.events.listen((event) {
        // Get the path of the file that changed
        final path = event.path.split("/");
        String folderName = path[path.length - 2];
        if (folderName == element.split("/").last) {
          print("🔄 ${element.split("/").last} folder changed");
          _generateAssetsClass();
        }
      });
      _activeWatchers.add(subscription);
    }

    stdin.listen((input) {
      if (String.fromCharCodes(input).trim().toUpperCase() == 'Q') {
        for (var watcher in _activeWatchers) {
          watcher.cancel();
        }
        _activeWatchers.clear();
        print("🛑 Stopped listening to the assets folders".red());
        exit(0); // Exit the program
      }
    });
  }

  @override
  String get description =>
      "Generate assets class and listen to the assets folder";

  @override
  String get name => "assets";
}
