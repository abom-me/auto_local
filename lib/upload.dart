//
// import 'dart:convert';
// import 'dart:io';
//
//
// class Upload{
// Print print = Print();
//
//   void main() {
//     List<Map<String, dynamic>> dataList = [];
//
//     // Specify the directory path
//     String directoryPath = 'assets/lang';
//
//     // Fetch all files in the directory
//     List<FileSystemEntity> files = Directory(directoryPath).listSync();
//
//     // Extract languages from file names
//     List<String> languages = files.map((file) => file.uri.pathSegments.last.split('.').first).toList();
// List<Map<String,String>> oldData=[];
//     // Iterate through languages
//     for (String lang in languages) {
//       // Read existing data from assets/lang/{lang}.json
//       Map<String, dynamic> existingData = readExistingJson('$directoryPath/$lang.json') ?? {};
// // print(existingData);
//       // Extract 'langs' data and add it to the dataList
//       existingData.forEach((key, value) {
//     if(dataList.where((element) => element['key']==key).isEmpty){
//       dataList.add({
//         'id': 1,
//         'created_at': 2,
//         'langs': {lang: value},
//         'key': key,
//       });
//     }else{
//       dataList.where((element) => element['key']==key).forEach((element) {
// element['langs'].addAll({lang: value});
//       });
//     }
//
//
//
//       });
//
//
//       // dataList.add({
//       //   'id': 1,
//       //   'created_at': 2,
//       //   'langs': {lang: value},
//       //   'key': key,
//       // });
//     }
//     // print(":here");
//     // print(oldData);
//
//     // Print the updated dataList
//     print.green("Your Strings is uploaded to the server");
//     exit(0);
//   }
//
//   Map<String, dynamic> readExistingJson(String filePath) {
//     try {
//       File file = File(filePath);
//       if (file.existsSync()) {
//         String jsonData = file.readAsStringSync();
//         return jsonDecode(jsonData);
//       } else {
//         return {};
//       }
//     } catch (e) {
//       // Handle file not found or invalid JSON
//       return {};
//     }
//   }
//
// }