


import 'package:args/command_runner.dart';
import 'package:dart_widget/dart_widget.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:tint/tint.dart';

class Update extends Command{

  Update(){
    // argParser.addFlag('version', abbr: 'v', negatable: false, help: 'current version of the package.');
  }
  final pubUpdater = PubUpdater();

String get version => "0.0.1";

  @override
  void run() {
update();
  }

update() async {
    final loading = CircleLoading(
        loadingText: 'Updating package',
        onDoneText: 'Package updated successfully\n',

    );
    loading.start();
  await pubUpdater.update(packageName: 'my_package');
loading.stop();

}
  checkUpdate() async {

    final isUpToDate = await pubUpdater.isUpToDate(
      packageName: 'auto_local',
      currentVersion: version,
    );
    if(!isUpToDate){
      final latestVersion = await pubUpdater.getLatestVersion("auto_local");

      print("\n⚠️ There is a new update".yellow()+" $version -> $latestVersion".green());
      print("Run ${"auto_local update".blue().bold()} to update\n");
    }
  }
  @override
  String get description => 'Update the package.';

  @override
  String get name => 'update';
}