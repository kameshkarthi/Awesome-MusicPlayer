import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_music_player_plugin/flutter_music_player_plugin.dart';
import '../database/database_client.dart';
import '../util/lastplay.dart';
import 'artistcard.dart';
import 'now_playing.dart';

class CardDetail extends StatefulWidget {
  Song song;
  DatabaseClient db;

  CardDetail(this.db, this.song);

  @override
  State<StatefulWidget> createState() {
    return  StateCardDetail();
  }
}

class StateCardDetail extends State<CardDetail> {
  List<Song>? songs;
  Song? song;

  bool isLoading = true;
  var image;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAlbum();
  }

  dynamic getImage(Song song) {
    return song.albumArt == null
        ? null
        :  File.fromUri(Uri.parse(song!.albumArt!));
  }

  void initAlbum() async {
    image = widget.song.albumArt == null
        ? null
        :  File.fromUri(Uri.parse(widget.song.albumArt!));
    songs = await widget.db.fetchSongsfromAlbum(widget.song.albumId);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    int length = songs!.length;
    return  Scaffold(
      backgroundColor: Colors.transparent,
      body: isLoading
          ?  Center(
        child:  CircularProgressIndicator(),
      )
          : Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Hero(
            tag: widget.song.album!,
            child: image != null
                ?  Image.file(
              image,
              fit: BoxFit.cover,
            )
                :  Image.asset("images/back.jpg", fit: BoxFit.cover),
          ),
          blurFilter(),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top:30.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: Container(
                      width: 300,
                      height: 300,
                      child: image != null
                          ?  Image.file(
                        image,
                        fit: BoxFit.cover,
                      )
                          :  Image.asset("images/back.jpg", fit: BoxFit.cover),

                    )),
              ),
              Container(
                padding: EdgeInsets.only(top: 30.0),
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                     Padding(
                      padding: const EdgeInsets.only(
                          left: 5.0, top: 5.0, right: 10.0),
                      child:  Text(
                        widget.song.album!,
                        style:  TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Quicksand"),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return ArtistCard(widget.db, widget.song);
                              }));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.person,
                              size: 33.0,
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 10.0),
                              child: Container(
                                width: 200.0,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                     Text(
                                      widget.song.artist!,
                                      style:  TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                    ),
                                    length != 1
                                        ?  Text(
                                      "${songs!.length} Songs",
                                      style: TextStyle(
                                          fontSize: 13.0),
                                    )
                                        :  Text(
                                      "${songs!.length} Song",
                                      style: TextStyle(
                                          fontSize: 13.0),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ListView.builder(
            padding: EdgeInsets.only(top: 500.0),
            itemCount: length,
            itemBuilder: ((builder ,i){
              return Container(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15.0,bottom: 10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                      child:  ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(37.0),
                          child: Container(
                            width: 50.0,
                            height: 50.0,
                            child: image != null
                                ?  Image.file(
                              image,
                              fit: BoxFit.cover,
                            )
                                :  Image.asset("images/back.jpg",
                                fit: BoxFit.cover),
                          )
                        ),

                        title:  Text(
                          songs![i].title!,
                          maxLines: 1,
                          style:  TextStyle(
                              fontSize: 16.0, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle:  Text(
                             Duration(milliseconds: songs![i].duration)
                                .toString()
                                .split('.')
                                .first
                                .substring(3, 7),
                            style:  TextStyle(
                                fontSize: 12.0, color: Colors.grey)),
                        //trailing:
                        onTap: () {
                          setState(() {
                            MyQueue.songs = songs;
                            Navigator.of(context).push( MaterialPageRoute(
                                builder: (context) =>
                                 NowPlaying(widget.db, songs!, i, 0)));
                          });
                        },
                      ),
                    ),
                  ),
                ),
              );
            }),

          ),
        ],
      ),
      floatingActionButton:  FloatingActionButton(
        onPressed: () {
          setState(() {
            MyQueue.songs = songs;
            Navigator.of(context).push( MaterialPageRoute(
                builder: (context) =>
                 NowPlaying(widget.db, MyQueue.songs!, 0, 0)));
          });
        },
        child:  Icon(CupertinoIcons.shuffle_thick),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey,
      ),
    );
  }
}

Widget blurFilter() {
  return  BackdropFilter(
    filter:  ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
    child:  Container(
      decoration:  BoxDecoration(color: Colors.black87.withOpacity(0.1)),
    ),
  );
}
