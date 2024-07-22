import 'package:args/command_runner.dart';
import 'package:auto_local/icons/icon.dart';
import 'package:auto_local/lang/lang.dart';
import 'package:auto_local/update/update.dart';
import 'package:tint/tint.dart';

void main(List<String> args) async {

  print(
      "|------------------👋 Starting Auto Local Tool 👋----------------------------|".green());
  print(
      "|                   This Tool Built by Github: abom-me                                 |".green());
  final runner = CommandRunner('auto_local', "|------------------📦 Version 2.0.0 📦----------------------------|".green())
    ..addCommand(Lang())
    ..addCommand(Icons())..addCommand(Update());
  // runner.argParser.addOption('char', help: 'The character to use for drawing');
  await runner.run(args);
 if(!args.contains("update")) Update().checkUpdate();
}
//
