import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_music_player_plugin/flutter_music_player_plugin.dart';
import 'package:flutter/cupertino.dart';
import '../database/database_client.dart';
import '../util/lastplay.dart';
import 'card_detail.dart';
import 'now_playing.dart';

class ArtistCard extends StatefulWidget {
  Song? song;
  DatabaseClient? db;

  ArtistCard(this.db, this.song);

  @override
  State<StatefulWidget> createState() {
    return  stateCardDetail();
  }
}

class stateCardDetail extends State<ArtistCard> {
  List<Song>? songs;
  List<Song>? albums;

  bool isLoading = true;
  var image;

  @override
  void initState() {

    super.initState();
    initAlbum();
  }

  dynamic getImage(Song song) {
    return song.albumArt == null
        ? null
        :  File.fromUri(Uri.parse(song!.albumArt!));
  }

  void initAlbum() async {
    image = widget.song!.albumArt! == null
        ? null
        :  File.fromUri(Uri.parse(widget.song!.albumArt!));

    songs = await widget.db!.fetchSongsByArtist(widget.song!.artist!);
    albums = await widget.db!.fetchAlbumByArtist(widget.song!.artist!);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Hero(
                    tag: "",
                    child:  Image.asset("images/artistbg.jpg", fit: BoxFit.cover),
                  ),
                 // blurFilter(),
                  Column(
                    children: <Widget>[
                      Container(
                        padding:
                        EdgeInsets.only(top: 70.0, left: 10.0, right: 10.0),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.person,
                              size: 33.0,
                              color: Colors.white,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text(
                                  widget.song!.artist!,
                                  style:  TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Quicksand"),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 0.0),
                        child: Center(
                          child: Text(
                            "ALBUMS",
                            style:  TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                                letterSpacing: 2.0,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 150.0),
                    child: CustomScrollView(
                      slivers: <Widget>[
                         SliverList(
                          delegate:  SliverChildListDelegate(<Widget>[
                            Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      child: GetArtistDetail(
                                        artist: widget.song!.artist!,
                                        artistSong: widget.song!,
                                        mode: 1,
                                      ),
                                    ),
                                    Container(
                                      //aspectRatio: 16/15,
                                      height: 330.0,
                                      child:  ListView.builder(
                                        itemCount: albums!.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, i) => Padding(
                                          padding: const EdgeInsets.only(bottom: 30.0),
                                          child:  InkResponse(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(right: 20.0),
                                                    child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(150),
                                                        child: Container(
                                                          width: 250,
                                                          height: 250,
                                                          child: image != null
                                                              ?  Image.file(
                                                            image,
                                                            fit: BoxFit.cover,
                                                          )
                                                              :  Image.asset("images/back.jpg", fit: BoxFit.cover),

                                                        )),
                                                  ),
                                                ),
                                                SizedBox(
                                                  child: Padding(
                                                    // padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                                                    padding: EdgeInsets.fromLTRB(70.0, 15.0, 0.0, 0.0),
                                                    child: Text(
                                                      albums![i].album!.toUpperCase(),
                                                      style:  TextStyle(
                                                          fontSize: 13.0,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.white),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              Navigator
                                                  .of(context)
                                                  .push( MaterialPageRoute(builder: (context) {
                                                return  CardDetail(widget.db!, albums![i]);
                                              }));
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                           top: 0.0, bottom: 10.0),
                                      child: Center(
                                        child: Text("Songs".toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: "Quicksand",
                                                color: Colors.white,
                                                letterSpacing: 1.8),
                                            maxLines: 1),
                                      ),
                                    ),

                                  ],
                                )),

                          ]),
                        ),
                        SliverList(
                          delegate:  SliverChildBuilderDelegate((builder, i) {
                            return Container(
                              color: Colors.white.withOpacity(0.0),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15.0, right: 15.0,bottom: 10.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.4),
                                    child:  ListTile(
                                      leading:ClipRRect(
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
                                            color: Colors.white, fontSize: 16.0),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Row(
                                        children: <Widget>[
                                          Text(
                                            songs![i].album!,
                                            style:  TextStyle(
                                                fontSize: 12.0, color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                      trailing:  Text(
                                         Duration(milliseconds: songs![i].duration)
                                            .toString()
                                            .split('.')
                                            .first
                                            .substring(3, 7),
                                        style:  TextStyle(
                                            fontSize: 12.0, color: Colors.black54),
                                        softWrap: true,
                                      ),
                                      onTap: () {
                                        MyQueue.songs = songs;
                                        Navigator.of(context).push( MaterialPageRoute(
                                            builder: (context) =>
                                             NowPlaying(widget.db!, songs!, i, 0)));
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }, childCount: songs!.length),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
      ),
      floatingActionButton:  FloatingActionButton(
        onPressed: () {
          MyQueue.songs = songs;
          Navigator.of(context).push( MaterialPageRoute(
              builder: (context) =>  NowPlaying(widget.db!, MyQueue.songs!,
                   Random().nextInt(songs!.length), 0)));
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey,
        child:  Icon(CupertinoIcons.shuffle_thick),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  GetArtistDetail({String? artist, Song? artistSong, int? mode}) {}
}


Widget blurFilter() {
  return  BackdropFilter(
    filter:  ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
    child:  Container(
      decoration:  BoxDecoration(color: Colors.black87.withOpacity(0.1)),
    ),
  );
}
