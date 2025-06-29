import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_music_player_plugin/flutter_music_player_plugin.dart';
import '../database/database_client.dart';
import '../pages/card_detail.dart';
import '../pages/now_playing.dart';
import '../util/lastplay.dart';

class Home extends StatefulWidget {
  DatabaseClient db;
  Home(this.db);
  @override
  State<StatefulWidget> createState() {
    return  StateHome();
  }
}

class StateHome extends State<Home> {
  List<Song>? albums, recents, songs, favorites, topAlbum, topArtist;
  bool isLoading = true;
  int? noOfFavorites;
  Song? last;

  @override
  void initState() {
    super.initState();
    init();
  }

  dynamic getImage(Song song) {
    return song.albumArt == null
        ? null
        :  File.fromUri(Uri.parse(song.albumArt!));
  }

  void init() async {
    albums = await widget.db.fetchRandomAlbum();
    recents = await widget.db.fetchRecentSong();
    favorites = await widget.db.fetchFavSong();
    recents!.removeAt(0);
    last = await widget.db.fetchLastSong();
    songs = await widget.db.fetchSongs();
    print(last!.title);
    recents!.removeAt(0); // as it is showing in header
    print(last!.title);
    setState(() {
      isLoading = false;
    });
  }
  Future<Null> resfresh ()async{
    Future.delayed(Duration( seconds: 3));
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

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading ? CircularProgressIndicator() : Scaffold(
          body: Stack(
            children: <Widget>[

              ClipPath(
                clipper: Mclipper(),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0.0, 10.0),
                        blurRadius: 10.0)
                  ]),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Image.asset("images/banner1.jpg",
                          fit: BoxFit.cover, width: double.infinity),
                      Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  const Color(0x00000000),
                                  const Color(0xD9333333)
                                ],
                                stops: [
                                  0.0,
                                  0.9
                                ],
                                begin: FractionalOffset(0.0, 0.0),
                                end: FractionalOffset(0.0, 1.0))),
                        child: Padding(
                          padding: EdgeInsets.only(top: 120.0, left: 95.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "HEAR AND ENJOY",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontFamily: "Quicksand"),
                              ),
                              Text(
                                "awsome ",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 45.0,
                                    fontFamily: "Quicksand",
                                fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 300.0,
                right: -20.0,
                child: FractionalTranslation(
                  translation: Offset(0.0, -0.5),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 12.0,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),
                        child: TextButton(
                          onPressed: () {},
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Play Random",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    fontFamily: "SF-Pro-Display-Bold"),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              RefreshIndicator(
                onRefresh:resfresh,
                child: ListView(
                  padding: EdgeInsets.only(top: 270.0),
                  children: <Widget>
                  [
                    Padding(
                      padding: const EdgeInsets.only(right: 160.0),
                      child:  FloatingActionButton(
                        backgroundColor: Colors.white,
                        heroTag: "shuffle",
                        onPressed: () {
                          MyQueue.songs = songs!;
                          Navigator.of(context).push(
                               MaterialPageRoute(builder: (context) {
                                return  NowPlaying(widget.db!, songs!,
                                     Random().nextInt(songs!.length), 0);
                              }));
                        },
                        child:  Icon(Icons.shuffle,color: Color(0xFFE52020),),
                      ),
                    ),
                    SizedBox(height: 8.0,),
                    Center(
                      child: Text(
                        "Your Recents",
                        style: TextStyle(

                            fontSize: 15.0, fontFamily: "Quicksand"),
                      ),
                    ),
                    recentW(),
                    SizedBox(height: 8.0,),
                    Center(
                      child: Text(
                        "You May Like",
                        style: TextStyle(

                            fontSize: 15.0, fontFamily: "Quicksand"),
                      ),
                    ),
                    maylike(),
                    Center(
                      child: Text(
                        "Your Favorites",
                        style: TextStyle(
                            fontSize: 15.0, fontFamily: "Quicksand"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: favoritesList(),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget recentW() {
    return  Container(
      height: 235.0,
      child:  ListView.builder(
        itemCount: recents!.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child:  Padding(
            padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
            child: InkWell(
              onTap: () {
                MyQueue.songs = recents!;
                Navigator.of(context)
                    .push( MaterialPageRoute(builder: (context) {
                  return  NowPlaying(widget.db, recents!, i, 0);
                }));
              },
              child: Container(
                height: 230.0,
                width: 135.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10.0,
                          offset: Offset(0.0, 10.0))
                    ]),

                child: Column(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0)),
                      child: getImage(recents![i]) != null
                          ? Container(
                        height: 130.0,
                        //width: double.infinity,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(
                                getImage(recents![i]),
                              ),
                              fit: BoxFit.cover,
                            )),
                      )
                          :  Image.asset(
                        "images/back.jpg",
                        height: 130.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0, left: 8.0, right: 8.0),
                      child: Text(recents![i].title!,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12.0, fontFamily: "Quicksand",color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget maylike() {
    return  Container(
      height: 235.0,
      child:  ListView.builder(
        itemCount: albums!.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child:  Padding(
            padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
            child: InkWell(
              onTap: () {
                Navigator
                    .of(context)
                    .push( MaterialPageRoute(builder: (context) {
                  return  CardDetail(widget.db, albums![i]);
                }));
              },
              child: Container(
                height: 230.0,
                width: 135.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10.0,
                          offset: Offset(0.0, 10.0))
                    ]),

                child: Column(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0)),
                      child: getImage(albums![i]) != null
                          ? Container(
                        height: 130.0,
                        //width: double.infinity,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(
                                getImage(albums![i]),
                              ),
                              fit: BoxFit.cover,
                            )),
                      )
                          :  Image.asset(
                        "images/back.jpg",
                        height: 130.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0, left: 8.0, right: 8.0),
                      child: Text(albums![i].album!,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12.0, fontFamily: "Quicksand",color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget favoritesList() {
    return  Container(
      height: 180.0,
      child:  ListView.builder(
        itemCount: favorites!.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) => Padding(
          padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 11.0),
          child:  InkWell(
            onTap: () {
              MyQueue.songs = recents!;
              Navigator.of(context)
                  .push( MaterialPageRoute(builder: (context) {
                return  NowPlaying(widget.db, favorites!, i,0);
              }));
            },
            child: Container(
              height: 230.0,
              width: 135.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10.0,
                        offset: Offset(0.0, 10.0))
                  ]),
              child: Column(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0)),
                    child: getImage(favorites![i]) != null
                        ? Container(
                      height: 130.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(
                              getImage(favorites![i]),
                            ),
                            fit: BoxFit.cover,
                          )),
                    )
                        :  Image.asset(
                      "images/back.jpg",
                      height: 130.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0),
                    child: Text(favorites![i].title!,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12.0, fontFamily: "Quicksand",color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class Mclipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path =  Path();
    path.lineTo(0.0, size.height - 100.0);

    var controlpoint = Offset(35.0, size.height);
    var endpoint = Offset(size.width / 2, size.height);

    path.quadraticBezierTo(
        controlpoint.dx, controlpoint.dy, endpoint.dx, endpoint.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}


