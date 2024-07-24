import 'package:args/command_runner.dart';
import 'package:auto_local/assets/assets.dart';
import 'package:auto_local/dotenv/env.dart';
import 'package:auto_local/icons/icon.dart';
import 'package:auto_local/lang/lang.dart';
import 'package:auto_local/update/update.dart';
import 'package:tint/tint.dart';

void main(List<String> args) async {

  print(
      "|------------------👋 Starting Auto Local Tool 👋----------------------------|".green());
  print("|                   This Tool Built by Github: abom-me                                 |".green());
  print("|------------------📦 Version 2.0.0 📦----------------------------|".green());
  if(!args.contains("update")) await Update().checkUpdate();
  final runner = CommandRunner('auto_local', "")
    ..addCommand(Lang())
    ..addCommand(Icons())
    ..addCommand(Update())
    ..addCommand(Env())..addCommand(Assets());
  // runner.argParser.addOption('char', help: 'The character to use for drawing');
  await runner.run(args);
}
