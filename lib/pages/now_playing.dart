import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_music_player_plugin/flutter_music_player_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_client.dart';
import '../util/lastplay.dart';
import '../util/utility.dart';

class NowPlaying extends StatefulWidget {
  int mode;
  List<Song> songs;
  int index;
  DatabaseClient db;
  NowPlaying(this.db, this.songs, this.index, this.mode);
  @override
  State<StatefulWidget> createState() {
    return  StateNowPlaying();
  }
}

class StateNowPlaying extends State<NowPlaying>
    with SingleTickerProviderStateMixin {
  MusicFinder? player;
  Duration? duration;
  Duration? position;
  bool isPlaying = false;
  Song? song;
  int isfav = 1;
  int repeatOn = 0;
  Orientation? orientation;
  AnimationController? _animationController;
  Animation<Color>? _animateColor;
  bool isOpened = true;
  Animation<double>? _animateIcon;
  bool isMuted = false;
  @override
  void initState() {
    super.initState();
    initAnim();
    initPlayer();
  }

  initAnim() {
    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!);
    _animateColor = ColorTween(
      begin: Colors.teal,
      end: Colors.pink,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    )) as Animation<Color>?;
  }

  animateForward() {
    _animationController!.forward();
  }

  animateReverse() {
    _animationController!.reverse();
  }

  void initPlayer() async {
    if (player == null) {
      player = MusicFinder();
      MyQueue.player = player!;
      var pref = await SharedPreferences.getInstance();
      pref.setBool("played", true);
    }
    setState(() {
      if (widget.mode == 0) {
        player!.stop();
      }
      updatePage(widget.index);
      isPlaying = true;
    });
    player!.setDurationHandler((d) => setState(() {
      duration = d;
    }));
    player!.setPositionHandler((p) => setState(() {
      position = p;
    }));
    player!.setCompletionHandler(() {
      onComplete();
      setState(() {
        position = duration;
        int i = ++widget.index;
        song = widget.songs[i];
      });
    });
    player!.setCompletionHandler(() {
      onComplete();
      setState(() {
        position = duration;
        if (repeatOn != 1) ++widget.index;
        song = widget.songs[widget.index];
      });
    });
    player!.setErrorHandler((msg) {
      setState(() {
        player!.stop();
        duration =  Duration(seconds: 0);
        position =  Duration(seconds: 0);
      });
    });
  }

  void updatePage(int index) {
    MyQueue.index = index;
    song = widget.songs[index];
   
    if (widget.db != null && song!.id != 9999/*shared song id*/) widget.db.updateSong(song!);
    player!.play(song!.uri!);
    animateReverse();
    setState(() {
      isPlaying = true;
      // isOpened = !isOpened;
    });
  }

  void _playpause() {
    if (isPlaying) {
      player!.pause();
      animateForward();
      setState(() {
        isPlaying = false;
      });
    } else {
      player!.play(song!.uri!);
      animateReverse();
      setState(() {
        isPlaying = true;
      });
    }
  }

  Future next() async {
    player!.stop();
    setState(() {
      int i = ++widget.index;
      if (i >= widget.songs.length) {
        i = widget.index = 0;
      }
      updatePage(i);
    });
  }

  Future prev() async {
    player!.stop();
    setState(() {
      int i = --widget.index;
      if (i < 0) {
        widget.index = 0;
        i = widget.index;
      }
      updatePage(i);
    });
  }
  Future mute(bool muted) async {
    final result = await player!.mute(muted);
    if (result == 1) {
      setState(() {
        isMuted = muted;
      });
    }
  }

  Future<void> repeat1() async {
    setState(() {
      if (repeatOn == 0) {
        repeatOn = 1;
      } else {
        repeatOn = 0;
      }
    });
  }

  void onComplete() {
    setState(() {
      next();
      repeatOn = 1;
    });
  }

  GlobalKey<ScaffoldState> scaffoldState =  GlobalKey();
  @override
  Widget build(BuildContext context) {
    orientation = MediaQuery.of(context).orientation;
    return  Scaffold(
        key: scaffoldState,
        body: orientation == Orientation.portrait ? potrait() : landscape());
  }

  Widget potrait() {
    return  Container(
      color: Colors.black,
      child:  Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
               AspectRatio(
                aspectRatio: 15 / 17.5,
                child:  Hero(
                  tag: song!.id,
                  child: getImage(song!) != null
                      ?  Image.file(
                    getImage(song!),
                    fit: BoxFit.cover,
                  )
                      :  Image.asset(
                    "images/artistbg1.jpg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              AspectRatio(aspectRatio: 15/17.5,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.0),Colors.black.withOpacity(1.0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter),

                  ),
                ),),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(width: 50.0,),
                    Text(
                      'Now Playing',
                      style: TextStyle(
                          fontSize: 32.0,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w700,
                          color: Colors.white
                      ),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          size: 40.0,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          lastscreen();
                        }),
                    SizedBox(width: 0.0,)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 230.0),
                child: Center(
                  child:  IconButton(
                      icon: isfav == 0
                          ?  Icon(Icons.favorite_border,color: Colors.white.withOpacity(0.6),)
                          :  Icon(
                        Icons.favorite,
                        color: _animateColor!.value,
                      ),
                      onPressed: () {
                        setFav(song);
                      }),
                ),
              )

            ],
          ),
          duration == null
              ? Text("")
              : Slider(
            min: 0.0,
            value: position?.inMilliseconds.toDouble() ?? 0.0,
            max: song!.duration.toDouble() + 1000,
            onChanged: (double value) =>
                player!.seek((value / 1000).roundToDouble()),
            divisions: song!.duration,
            inactiveColor: Colors.white.withOpacity(0.7),
            activeColor: _animateColor!.value,
          ),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
               Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child:  Text(position.toString().split('.').first,style: TextStyle(color: Colors.white.withOpacity(0.7)),),
              ),
               Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child:  Text(
                     Duration(milliseconds: song!.duration)
                        .toString()
                        .split('.')
                        .first,
                    style: TextStyle(color: Colors.white.withOpacity(0.7))
                ),
              ),
            ],
          ),
           Expanded(
            child:  Center(
              child:  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                   Text(
                    song!.title!,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style:  TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold,color: Colors.white.withOpacity(0.7)),
                  ),
                   Text(
                    song!.artist!,
                    maxLines: 1,
                    style:  TextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ),
           Expanded(
            child:  Center(
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                   IconButton(
                    icon:  Icon(Icons.arrow_back_ios, size: 25.0),
                    onPressed: prev,
                    color: Colors.white.withOpacity(0.6),
                  ),
                   FloatingActionButton(
                    backgroundColor: _animateColor!.value,
                    onPressed: _playpause,
                    child:  AnimatedIcon(
                        icon: AnimatedIcons.pause_play, progress: _animateIcon!),
                  ),
                   IconButton(
                    icon:  Icon(Icons.arrow_forward_ios, size: 25.0),
                    onPressed: next,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
               IconButton(
                  icon:  Icon(Icons.shuffle),
                  color: Colors.white.withOpacity(0.6),
                  onPressed: () {
                    widget.songs.shuffle();
                    
                  }),
               IconButton(
                  icon: isMuted
                      ?  Icon(
                    Icons.headset,
                    color: Colors.white.withOpacity(0.6),
                  )
                      :  Icon(Icons.headset_off,
                    color: Colors.white.withOpacity(0.6),),
                  onPressed: () {
                    mute(!isMuted);
                  }),
            ],
          )
        ],
      ),
    );

  }

  Widget landscape() {
    return  Row(
      children: <Widget>[
         Container(
          width: 350.0,
          child:  AspectRatio(
              aspectRatio: 15 / 19,
              child:  Hero(
                tag: song!.id,
                child: getImage(song!) != null
                    ?  Image.file(
                  getImage(song!),
                  fit: BoxFit.cover,
                )
                    :  Image.asset(
                  "images/artistbg1.jpg",
                  fit: BoxFit.fitHeight,
                ),
              )),
        ),
         Expanded(
          child:  Column(
            children: <Widget>[
               Expanded(
                child:  Center(
                  child:  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                       Text(
                        song!.title!,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style:  TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                       Text(
                        song!.artist!,
                        maxLines: 1,
                        style:
                         TextStyle(fontSize: 14.0, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              duration == null
                  ?  Text("")
                  :  Slider(
                min: 0.0,
                value: position?.inMilliseconds?.toDouble() ?? 0.0,
                onChanged: (double value) =>
                    player!.seek((value / 1000).roundToDouble()),
                max: song!.duration.toDouble() + 1000,
              ),
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                   Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child:  Text(position.toString().split('.').first),
                  ),
                   Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child:  Text(
                       Duration(milliseconds: song!.duration)
                          .toString()
                          .split('.')
                          .first,
                    ),
                  ),
                ],
              ),
               Expanded(
                child:  Center(
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                       IconButton(
                        icon:  Icon(Icons.skip_previous, size: 40.0),
                        onPressed: prev,
                      ),
                      //fab,
                       FloatingActionButton(
                        backgroundColor: _animateColor!.value,
                        onPressed: _playpause,
                        child:  AnimatedIcon(
                            icon: AnimatedIcons.pause_play,
                            progress: _animateIcon!),
                      ),
                       IconButton(
                        icon:  Icon(Icons.skip_next, size: 40.0),
                        onPressed: next,
                      ),
                    ],
                  ),
                ),
              ),
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                   IconButton(
                      icon:  Icon(Icons.shuffle),
                      onPressed: () {
                        widget.songs.shuffle();
                        
                      }),
                   IconButton(
                      icon: isMuted
                          ?  Icon(
                        Icons.headset,
                        color: Colors.white.withOpacity(0.6),
                      )
                          :  Icon(Icons.headset_off,
                        color: Colors.white.withOpacity(0.6),),
                      onPressed: () {
                        mute(!isMuted);
                      }),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Future<void> setFav(song) async {
    int i = await widget.db.favSong(song);
    setState(() {
      if (isfav == 1)
        isfav = 0;
      else
        isfav = 1;
    });
  }
  void lastscreen(){
    Navigator.pop(context);
  }
}
