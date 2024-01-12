# auto_local:


####  A command-line tool to generate localizations for your app automatically.
This tool is used to generate a dart class from a JSON file.
the json file path should be in assets/lang/ directory.
because this tool is depend on [flutter_locales2](https://pub.dev/packages/flutter_locales2) package.
the tool will keep watching for changes in assets/lang/ directory.
and will generate a dart class with the name lang.dart in lib/auto_local/ directory.
the class will contain all the keys in the json file.

![GitHub](https://img.shields.io/github/license/abom-me/auto_local)
![GitHub stars](https://img.shields.io/github/stars/abom-me/auto_local)

------------------


-------------------
### 👨‍💻 *Developed  by:*

<img alt="profile" src="https://abom.me/packages/profile.png" width="50" height="50"  style=" border-radius: 100%"/>

**Nasr Al-Rahbi [@abom_me](https://twitter.com/abom_me)**

## 👨🏻‍💻 Find me in  :
[![Twitter](https://img.shields.io/badge/Twitter-%231DA1F2.svg?logo=Twitter&logoColor=white)](https://twitter.com/abom_me)
[![Instagram](https://img.shields.io/badge/Instagram-%23E4405F.svg?logo=Instagram&logoColor=white)](https://instagram.com/abom.me)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-%230077B5.svg?logo=linkedin&logoColor=white)](https://linkedin.com/in/nasr-al-rahbi-08a573245)
[![Stack Overflow](https://img.shields.io/badge/-Stackoverflow-FE7A16?logo=stack-overflow&logoColor=white)](https://stackoverflow.com/users/19994059/nasr-al-rahbi)

---------------
<br>


## Install

Use the `dart pub global` command to install this into your system.

```console
$ dart pub global activate auto_local
```

## Use

If you have [modified your PATH][path], you can run this server from any
local directory.

```console
$ auto_local
```

Otherwise, you can run it using the `pub global` command.

```console

$ dart pub global run auto_local
```

#### After running the tool you will listen to any changes in the json file and generate a dart class with the name lang.dart in lib/auto_local/ directory.



