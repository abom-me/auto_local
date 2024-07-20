import 'package:args/command_runner.dart';
import 'package:auto_local/icons/icon.dart';
import 'package:auto_local/lang/lang.dart';
import 'package:auto_local/print_color.dart';

void main(List<String> args) async {
  Print pen = Print();
  pen.green(
      "|------------------👋 Starting Auto Local Tool 👋----------------------------|");
  pen.green(
      "|                   This Tool Built by Github: abom-me                                 |");
  final runner = CommandRunner('auto_local', "")
    ..addCommand(Lang())
    ..addCommand(AutoIcon());
  // runner.argParser.addOption('char', help: 'The character to use for drawing');
  await runner.run(args);
}
//
