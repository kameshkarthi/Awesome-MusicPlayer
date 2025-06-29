import 'package:flutter/material.dart';
import 'package:flutter_music_player_plugin/flutter_music_player_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_client.dart';


class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return  _settingState();
  }
}

class _settingState extends State<Settings> {
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
    super.initState();
    getheme();
  }

  @override
  GlobalKey<ScaffoldState> scaffoldState =  GlobalKey();
  Widget build(BuildContext context) {
    return  Scaffold(
      key: scaffoldState,
      appBar:  AppBar(
        title:  Text("Settings"),
      ),
      body:  Container(
        child: Column(
          children: <Widget>[
             ListTile(
              leading:  Icon(
                Icons.build,
                color: Theme.of(context).shadowColor,
              ),
              title:  Text("Rebuild database"),
              onTap: () async {
                setState(() {
                  isLoading = true;
                });
                var db =  DatabaseClient();
                await db.create();
                var songs;
                try {
                  songs = await MusicFinder.allSongs();
                } catch (e) {
                  print("failed to get songs");
                }
                List<Song> list =  List.from(songs);
                for (Song song in list) db.upsertSOng(song);
                setState(() {
                  isLoading = false;
                });
              },
            ),
             Divider(),
             Container(
                child: isLoading
                    ?  Center(
                  child:  Column(
                    children: <Widget>[
                       CircularProgressIndicator(),
                       Text("Loading Songs"),
                    ],
                  ),
                )
                    :  Container()),
          ],
        ),
      ),
    );
  }
}


