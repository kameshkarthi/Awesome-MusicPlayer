import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Customize extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return  _settingState();
  }
}

class _settingState extends State<Customize> {
  var isLoading = false;
  var selected = 0;
  void getheme() async {
    var pref = await SharedPreferences.getInstance();
    setState(() {
      selected = (pref.getInt("theme") ?? 0);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getheme();
  }

  @override
  GlobalKey<ScaffoldState> scaffoldState =  GlobalKey();
  Widget build(BuildContext context) {
    return  Scaffold(
      key: scaffoldState,
      appBar:  AppBar(
        title:  Text("Customize"),
        centerTitle: true,
      ),
      body:  Container(
        child: Column(
          children: <Widget>[
             ListTile(
                leading:
                 Icon(Icons.style, color: Theme.of(context).shadowColor),
                title:  Text(("Theme")),
                onTap: () async {
                  var result= showDialog(
                      context: context,
                      builder: (context) {
                        return  SimpleDialog(
                          title:  Text("Select theme"),
                          children: <Widget>[
                             RadioListTile(
                              value: 0,
                              groupValue: selected,
                              onChanged: (value) {
                                selected = value!;
                                Navigator.pop(context,value);
                              },
                              title:  Text("Light"),
                            ),
                             RadioListTile(
                              value: 1,
                              groupValue: selected,
                              onChanged: (value) {
                                selected = value!;
                                Navigator.pop(context,value);
                              },
                              title:  Text("Dark"),
                            )
                          ],
                        );
                      });
                  var pref = await SharedPreferences.getInstance();

                  if (await result == null) {
                    return;
                  } else
                    switch (await result) {
                      case 1:
                        {
                          pref.setInt("theme", 1);
                         
                          break;
                        }
                      case 0:
                        {
                          pref.setInt("theme", 0);
                          
                          break;
                        }
                    }
                }),

          ],
        ),
      ),
    );
  }
}
