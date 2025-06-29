import 'dart:async';
import 'dart:ui';
import 'package:awesome/pages/customize.dart';
import 'package:awesome/pages/now_playing.dart';
import 'package:awesome/pages/settings.dart';
import 'package:awesome/util/lastplay.dart';
import 'package:awesome/views/album.dart';
import 'package:awesome/views/artists.dart';
import 'package:awesome/views/home.dart';
import 'package:awesome/views/songs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_music_player_plugin/flutter_music_player_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database/database_client.dart';


class MusicHome extends StatefulWidget {
  final BarStyle? barStyle;
  int? index;
  DatabaseClient? db;
  List<Song>? songs;
  
  MusicHome(this.barStyle,this.index,this.db, {super.key});
  final List<BarItem> bottomItems = [
    BarItem(
      title: "Home",
      icon: Icons.home,
      color: Colors.yellow.shade900,
    ),
    BarItem(
      title: "Albums",
      icon: Icons.album,
      color: Colors.pinkAccent,
    ),
    BarItem(
      title: "Songs",
      icon: Icons.music_note,
      color: Colors.indigo,    ),
    BarItem(
      title: "Artists",
      icon: Icons.person_outline,
      color: Colors.teal,
    ),
  ];
  @override
  State<StatefulWidget> createState() {
    return  MusicState();
  }
}

class MusicState extends State<MusicHome> {
  int _selectedDrawerIndex = 0;
  List<Song>? songs;
  String title = "Music player";
  DatabaseClient? db;
  int? mode;
  int? isfav;
  Orientation? orientation;
  bool isLoading = true;
  bool isPlaying = false;
  MusicFinder? player;
  int? repeatOn;
  Song? last;
  int? index;
  Color color = Colors.deepPurple;
  var themeLoading = true;

  getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return  Home(db!);
      case 2:
        return  Songs(db!);
      case 3:
        return  Artists(db!);
      case 1:
        return  Album(db!);
      default:
        return  Text("Error");
    }
  }


  @override
  void initState() {
    super.initState();
    initPlayer();
    getSharedData();
  }

  getSharedData() async {
    const platform = const MethodChannel('app.channel.shared.data');
    Map sharedData = await platform.invokeMethod("getSharedData");
    if (sharedData != null) {
      if (sharedData["albumArt"] == "null") {
        sharedData["albumArt"] = null;
      }
      Song song =  Song(
          9999 /*random*/,
          sharedData["artist"],
          sharedData["title"],
          sharedData["album"],
          0,
          int.parse(sharedData["duration"]),
          sharedData["uri"],
          sharedData["albumArt"],0);
      List<Song> list =  [];
      list.add((song));
      MyQueue.songs = list;
      Navigator.of(context).push( MaterialPageRoute(builder: (context) {
        return  NowPlaying(db!, list, 0, 0);
      }));
    }
  }

  void initPlayer() async {
    db =  DatabaseClient();
    await db!.create();
    if (await db!.alreadyLoaded()) {
      setState(() {
        isLoading = false;
        getLast();
      });
    } else {
      var songs;
      try {
        songs = await MusicFinder.allSongs();
      } catch (e) {
        print("failed to get songs");
      }
      List<Song> list =  List.from(songs);
      for (Song song in list) {
        db!.upsertSOng(song);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        isLoading = false;
        getLast();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getLast() async {
    last = await db!.fetchLastSong();
    songs = await db!.fetchSongs();
    setState(() {
      songs = songs;
    });
  }

  Future<Null> refreshData() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = true;
    });
    var db =  DatabaseClient();
    var res = await db.insertSongs();
    if (!res) {
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;

      });
    }
  }
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  GlobalKey<ScaffoldState> scaffoldState =  GlobalKey();
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      key: scaffoldState,
      floatingActionButton: RawMaterialButton(
          fillColor: Colors.teal,
          shape: StadiumBorder(),
          splashColor: Colors.pink,
          onPressed: () async {
            var pref = await SharedPreferences.getInstance();
            var fp = pref.getBool("played");
            if (fp == null) {

            } else {
              Navigator.of(context)
                  .push( MaterialPageRoute(builder: (context) {
                return  NowPlaying(db!, MyQueue.songs!, MyQueue.index!, 1);
              }));
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const <Widget>[
                Icon(Icons.headset,color: Colors.white,),
                SizedBox(width: 5.0,),
                Text("Now Playing",style: TextStyle(color: Colors.white),),
              ],
            ),
          )),
      drawer: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0,bottom: 30.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
            child:  Drawer(
              child:  Column(
                children: <Widget>[
                   Container(
                    color: Colors.black,
                    height: 195.0,
                    width: 350,
                    child: Stack(

                      children: <Widget>[
                        Image.asset("images/dimage.jpg"),
                        Padding(
                          padding: const EdgeInsets.only(left:10.0,top: 150.0),
                          child: Text("Awsome..!!",style: TextStyle(fontSize: 20.0, color: Colors.white,
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w700,)),
                        )

                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.black,
                      child:  Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0,left: 10.0,right: 10.0),
                            child:  ListTile(
                                leading:  Icon(Icons.settings,size: 25.0,
                                    color: Colors.teal),
                                title:  Text("Settings",style: TextStyle(fontSize: 15.0, color: Colors.white,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w700,)),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context)
                                      .push( MaterialPageRoute(builder: (context) {
                                    return Settings();
                                  }));
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0,left: 10.0,right: 10.0),
                            child: ListTile(
                                leading:  Icon(Icons.color_lens,size: 25.0,
                                    color: Colors.teal),
                                title:  Text("Customize",style: TextStyle(fontSize: 15.0, color: Colors.white,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w700,)),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context)
                                      .push( MaterialPageRoute(builder: (context) {
                                    return Customize();
                                  }));
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0,left: 10.0,right: 10.0),
                            child: ListTile(
                                leading:  Icon(Icons.person,size: 25.0,
                                    color: Colors.teal),
                                title:  Text("About",style: TextStyle(fontSize: 15.0, color: Colors.white,
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w700,)),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context)
                                      .push( MaterialPageRoute(builder: (context) {
                                    return About();
                                  }));
                                }),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(child: isLoading
          ?  Center(
        child:  CircularProgressIndicator(),
      )
          : getDrawerItemWidget(_selectedDrawerIndex)),
      bottomNavigationBar: SafeArea(
        child: AnimatedBottomBar(
            barItems: widget.bottomItems,
            animationDuration: const Duration(milliseconds: 350),
            barStyle: BarStyle(
                fontSize: 14.0,
                iconSize: 20.0
            ),
            onBarTap: (index) {
              setState(() {
                _selectedDrawerIndex = index;
              });
            }),
      ),
    );
  }

  void lastscreen(){
    Navigator.pop(context);
  }
}


class BarItem {
  String? title;
  IconData? icon;
  Color? color;

  BarItem({this.title, this.icon, this.color});
}
class BarStyle {
  final double fontSize, iconSize;
  final FontWeight fontWeight;

  BarStyle({this.fontSize = 18.0, this.iconSize = 32, this.fontWeight = FontWeight.w600});
}

class AnimatedBottomBar extends StatefulWidget {
  final List<BarItem>? barItems;
  final Duration? animationDuration;
  final Function? onBarTap;
  final BarStyle? barStyle;

  AnimatedBottomBar(
      {this.barItems,
        this.animationDuration = const Duration(milliseconds: 500),
        this.onBarTap, this.barStyle});

  @override
  _AnimatedBottomBarState createState() => _AnimatedBottomBarState();
}

class _AnimatedBottomBarState extends State<AnimatedBottomBar>
    with TickerProviderStateMixin {
  int selectedBarIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      // elevation: 10.0,
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 15.0,
          top: 16.0,
          left: 16.0,
          right: 16.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _buildBarItems(),
        ),
      ),
    );
  }

  List<Widget> _buildBarItems() {
    List<Widget> _barItems = [];
    for (int i = 0; i < widget.barItems!.length; i++) {
      BarItem item = widget.barItems![i];
      bool isSelected = selectedBarIndex == i;
      _barItems.add(InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          setState(() {
            selectedBarIndex = i;
            widget.onBarTap!(selectedBarIndex);
          });
        },
        child: AnimatedContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          duration: widget.animationDuration!,
          decoration: BoxDecoration(
              color: isSelected
                  ? item.color!.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: Row(
            children: <Widget>[
              Icon(
                item.icon,
                color: isSelected ? item.color : Theme.of(context).shadowColor,
                size: widget.barStyle!.iconSize,
              ),
              SizedBox(
                width: 10.0,
              ),
              AnimatedSize(
                duration: widget.animationDuration!,
                curve: Curves.easeInOut,
                child: Text(
                  isSelected ? item.title! : "",
                  style: TextStyle(
                      color: item.color,
                      fontWeight: widget.barStyle!.fontWeight,
                      fontSize: widget.barStyle!.fontSize),
                ),
              )
            ],
          ),
        ),
      ));
    }
    return _barItems;
  }
}

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  void lastscreen(){
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.black.withOpacity(1.0),Colors.deepPurple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 35.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
                          onPressed: lastscreen),
                        SizedBox(width: 100.0,),
                        Text("about",style: TextStyle(fontSize: 40.0, color: Colors.white,
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w700,),),
                      ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Center(
                  child: Column(
                    children: <Widget>[
                          ClipRRect(
                          borderRadius: BorderRadius.circular(150),
                          child: Container(
                            width: 120,
                            height: 120,
                            child: Image.asset("images/author.jpg", fit: BoxFit.cover),

                          )),
                      SizedBox(height: 30.0,),
                       Text(" Awsome",style: TextStyle(color: Colors.white,fontSize: 20.0)),
                      Text("Developed By Kamesh V",style: TextStyle(color: Colors.white,fontSize: 20.0),),
                      TextButton(onPressed: myprofile,
                        child: Text("Follow on Twitter",style: TextStyle(color: Colors.black),),),
                      SizedBox(height: 20.0,),
                      Text("Thanks to Amangautam",style: TextStyle(fontSize:15.0,color: Colors.white),),
                        ],

                  ),
                ),
              ),


            ],
          ),
        )

    );

  }

  launchUrl() async {
    const url = "https://github.com/amangautam1";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not open';
    }
  }

  myprofile() async {
    const url = "https://twitter.com/kamesh_vkamesh?s=08";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'could not open';
    }
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
