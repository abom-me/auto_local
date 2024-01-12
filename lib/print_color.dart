

import 'package:ansicolor/ansicolor.dart';

class Print{

   white(String text){
    AnsiPen white = AnsiPen()..white();
    print(white(text));
  }
   green(String text){
    AnsiPen green = AnsiPen()..green();
    print(green(text));
  }

   red(String text){
    AnsiPen red = AnsiPen()..red();
    print(red(text));
  }

   yellow(String text){
    AnsiPen yellow = AnsiPen()..yellow();
    print(yellow(text));
  }

   blue(String text){
    AnsiPen blue = AnsiPen()..blue();
    print(blue(text));
  }

   magenta(String text){
    AnsiPen magenta = AnsiPen()..magenta();
    print(magenta(text));
  }

}