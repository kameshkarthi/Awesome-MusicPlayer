import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_music_player_plugin/flutter_music_player_plugin.dart';
import 'package:flutter/cupertino.dart';
import '../database/database_client.dart';
import '../util/lastplay.dart';
import 'now_playing.dart';

class ListSongs extends StatefulWidget {
  DatabaseClient db;
  int mode;
  Orientation orientation;
  // mode =1=>recent, 2=>top, 3=>fav
  ListSongs(this.db, this.mode, this.orientation);
  @override
  State<StatefulWidget> createState() {
    return  _listSong();
  }
}

class _listSong extends State<ListSongs> {
  List<Song>? songs;
  bool isLoading = true;
  dynamic getImage(Song song) {
    return song.albumArt == null
        ? null
        :  File.fromUri(Uri.parse(song!.albumArt!));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSongs();
  }

  void initSongs() async {
    switch (widget.mode) {
      case 1:
        songs = await widget.db.fetchRecentSong();
        break;
      case 2:
        songs = await widget.db.fetchTopSong();
        break;
      case 3:
        songs = await widget.db.fetchFavSong();
        break;
      default:
        break;
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget getTitle(int mode) {
    switch (mode) {
      case 1:
        return  Text("Recently played",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontFamily: "Quicksand",
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0));
        break;
      case 2:
        return  Text("Top tracks",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontFamily: "Quicksand",
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0));
        break;
      case 3:
        return  Text("Favourites",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontFamily: "Quicksand",
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0));
        break;
      default:
        return SizedBox();
    }
  }

  GlobalKey<ScaffoldState> scaffoldState =  GlobalKey();
  @override
  Widget build(BuildContext context) {
    initSongs();
    return  Scaffold(
        appBar: widget.orientation == Orientation.portrait
            ?  AppBar(
                title: getTitle(widget.mode),
                backgroundColor: Colors.blueGrey[600],
                elevation: 8.0,
              )
            : null,
        body:  Container(
          child: isLoading
              ?  Center(
                  child:  CircularProgressIndicator(),
                )
              :  ListView.builder(
                  itemCount: songs!.length,
                  itemBuilder: (context, i) =>  Column(
                        children: <Widget>[
                           ListTile(
                            leading: Hero(
                              tag: songs![i].id,
                              child: Image.file(
                                getImage(songs![i]),
                                width: 55.0,
                                height: 55.0,
                              ),
                            ),
                            title:  Text(songs![i].title!,
                                maxLines: 1,
                                style:  TextStyle(
                                    fontSize: 16.0, color: Colors.black)),
                            subtitle:  Text(
                              songs![i].artist!,
                              maxLines: 1,
                              style:  TextStyle(
                                  fontSize: 12.0, color: Colors.grey),
                            ),
                            trailing: widget.mode == 2
                                ?  Text(
                                    (i + 1).toString(),
                                    style:  TextStyle(
                                        fontSize: 12.0, color: Colors.grey),
                                  )
                                :  Text(
                                     Duration(
                                            milliseconds: songs![i].duration)
                                        .toString()
                                        .split('.')
                                        .first
                                        .substring(3, 7),
                                    style:  TextStyle(
                                        fontSize: 12.0, color: Colors.grey)),
                            onTap: () {
                              MyQueue.songs = songs;
                              Navigator.of(context).push( MaterialPageRoute(
                                  builder: (context) =>  NowPlaying(
                                      widget.db, MyQueue.songs!, i, 0)));
                            },
                          ),
                        ],
                      ),
                ),
        ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            MyQueue.songs = songs;
            Navigator.of(context).push( MaterialPageRoute(
                builder: (context) =>
                 NowPlaying(widget.db, MyQueue.songs!,  Random().nextInt(songs!.length), 0)));
      },
      backgroundColor: Colors.white,
      foregroundColor: Colors.blueGrey,
      child: Icon(CupertinoIcons.shuffle_thick),),
    );
  }
}
