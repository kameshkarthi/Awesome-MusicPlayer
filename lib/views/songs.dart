import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_music_player_plugin/flutter_music_player_plugin.dart';
import '../database/database_client.dart';
import '../pages/material_search.dart';
import '../pages/now_playing.dart';
import '../util/lastplay.dart';

class Songs extends StatefulWidget {
  DatabaseClient db;
  Songs(this.db,{super.key});
  @override
  State<StatefulWidget> createState() {
    return  SongsState();
  }
}

class SongsState extends State<Songs> {
  List<Song>? songs;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initSongs();
  }

  void initSongs() async {
    songs = await widget.db.fetchSongs();
    setState(() {
      isLoading = false;
    });
  }

  dynamic getImage(Song song) {
    return song.albumArt == null
        ? null
        :  File.fromUri(Uri.parse(song!.albumArt!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
          child: isLoading
              ?  Center(
            child:  CircularProgressIndicator(),
          )
              : Scrollbar(
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child:  Container(
                      color: Colors.transparent,
                      child: Center(
                        child:
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: Row(
                            children: <Widget>[
                              Spacer(),
                               Text("songs",style: TextStyle(fontSize: 40.0, color: Colors.white,
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.w700,),),
                             // SizedBox(width: 80.0,),
                              Spacer(),
                              IconButton(icon: Icon(Icons.search,color: Colors.white,),
                                  onPressed: () {
                                    Navigator
                                        .of(context)
                                        .push( MaterialPageRoute(builder: (context) {
                                      return  SearchSong(widget.db, songs!);
                                    }));
                                  })
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child:   Container(
                      margin: EdgeInsets.only(top: 30.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(60.0),
                            topLeft: Radius.circular(60.0)),
                        gradient: LinearGradient(
                            colors: [Colors.black.withOpacity(0.2),Colors.teal],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter),
                      ),

                      child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(60.0),
                              topLeft: Radius.circular(60.0)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0,right: 10.0),
                            child: Container(child:  ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: songs!.length,
                              itemBuilder: (context, i) =>  Column(
                                children: <Widget>[
                                   ListTile(
                                    leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(37.0),
                                        child: Container(
                                          width: 50.0,
                                          height: 50.0,
                                          child: getImage(songs![i]) != null
                                              ?  Image.file(
                                            getImage(songs![i]),
                                            fit: BoxFit.cover,
                                          )
                                              :  Image.asset("images/back.jpg",
                                              fit: BoxFit.cover),
                                        )
                                    ),
                                    title:  Text(songs![i].title!,
                                        maxLines: 1,
                                        style:  TextStyle(color: Colors.white,fontSize: 16.0,)),
                                    subtitle:  Text(
                                      songs![i].artist!,
                                      maxLines: 1,
                                      style:  TextStyle(
                                          fontSize: 12.0, color: Colors.grey),
                                    ),
                                    trailing:  Text(
                                         Duration(milliseconds: songs![i].duration)
                                            .toString()
                                            .split('.')
                                            .first.substring(3,7),
                                        style:  TextStyle(
                                            fontSize: 12.0, color: Colors.white70)),
                                    onTap: () {
                                      MyQueue.songs = songs!;
                                      Navigator.of(context).push( MaterialPageRoute(
                                          builder: (context) =>  NowPlaying(
                                              widget.db, MyQueue.songs!, i, 0)));
                                    },
                                  ),
                                ],
                              ),
                            ),),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
