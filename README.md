# auto_local:


####  A command-line tool to manage the assets in your app.
The tool will help you in:
- Manage languages in your app.
- Generate a dart class for each language.
- Add GPT to translate the text for all languages in your app.
- Convert Svg code to Svg file.
- Add class for all svg icons in your app with method to use it.
- Add class for all assets in your app with method to use it.
- Manage the .env file in your app and generate a class to use it.
- and more...

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

## Commands

- `auto_local` : To start the tool.
---
- `auto_local lang <arguments>` : To manage the languages in your app and will generate a dart class for keys in the json language.
  - `--adg`: Add new text to the language file using GPT for all languages automatically `<you have to provide API Key>`.
    <br>
    <br>
  - `--adm`: Add new text to the language file manually for all languages.
    <br>
    <br>
  - `--auto`: To listen for any changes in `language/path/<json files>` and update the dart class.
    <br>
    <br>
  - `--ref`: To refresh the dart class file.
    <br>
    <br>
  - `--ep`: To edit the path of the language file.
  <br>
  <br>
  - `--eapi`: To edit the API Key for the GPT.
------- 

- `auto_local icons <arguments>` : To manage your svg icons and convert SVG code to SVG file, and generate dart class for all icons by the name
  <br>
  <br>
  - `--add`: Add new SVG code and convert it to SVG file.
    <br>
    <br>
  - `--edit`: To edit the class name of the icons.
    <br>
    <br>
  - `--auto`: To listen for any changes in `icons/path/<svg files>` and update the dart class.
    <br>
    <br>
  - `--ep`: To edit the path of the icons folder.
    <br>
    <br>
  - `--ref`: To refresh the dart class file.
-------------
- `auto_local env <arguments> ` : This command is used to add environment variables to the .env file and use them in the project from a Dart class.
  - `--new` : Create a new environment variable.
    <br>
    <br>
  - `--ref`: Refresh the dart class file.
    <br>
    <br>
  - `--delete`: Delete the environment variable.
------
- `auto_local assets <arguments>` : Generate assets class and listen to the assets folder and call the assets path from the dart class directly.
  - `--generate`: Generate assets class.
    <br>
    <br>
  - `--auto`: To listen for any changes in `assets/` and update the dart class.
    <br>
    <br>
  - `--ignore`: To ignore any folder in the assets folder , so the tool will not add it in the dart class.




