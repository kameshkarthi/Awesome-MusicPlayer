import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database/database_client.dart';
import 'musichome.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _mainState();
  }
}

class _mainState extends State<MyApp> {
  var isLoading = true;
  ThemeData? theme;
  static BarStyle? barStyle;
  DatabaseClient? db;
  int? index;
  @override
  void initState() {
    super.initState();
    getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isLoading ? lightTheme : theme,
      title: "awsome",
      debugShowCheckedModeBanner: false,
      home: isLoading ? Container() : MusicHome(barStyle,index,db),
    );
  }

  getTheme() async {
    var pref = await SharedPreferences.getInstance();
    var val = pref.getInt("theme");
    print("theme=$val");
    if (val == null) {
      theme = lightTheme;
    } else if (val == 1) {
      theme = darktheme;
    } else {
      theme = lightTheme;
    }
    setState(() {
      isLoading = false;
    });
  }

  ThemeData darktheme = new ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF303030),
    fontFamily: 'Raleway',
    dialogBackgroundColor: Colors.black,
  );
  ThemeData lightTheme = new ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Raleway',
    primaryColor: Colors.white,
    dialogBackgroundColor: Colors.white,
  );
}
