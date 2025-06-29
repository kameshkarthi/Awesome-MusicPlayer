import 'package:flutter/material.dart';
import 'package:flutter_music_player_plugin/flutter_music_player_plugin.dart';
import '../database/database_client.dart';
import '../pages/card_detail.dart';
import '../util/utility.dart';

class Album extends StatefulWidget {
  DatabaseClient db;

  Album(this.db);

  @override
  State<StatefulWidget> createState() {
    return  _stateAlbum();
  }
}

class _stateAlbum extends State<Album> {
  List<Song>? songs;
  var f;
  bool isLoading = true;

  @override
  initState() {
    super.initState();
    initAlbum();
  }

  void initAlbum() async {
    // songs=await widget.db.fetchSongs();
    songs = await widget.db.fetchAlbum();
    setState(() {
      isLoading = false;
    });
  }

  List<Card> _buildGridCards(BuildContext context) {
    return songs!.map((song) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        margin: EdgeInsets.fromLTRB(5.0, 25.0, 5.0, 0.0),
        elevation: 10.0,
        child:  InkResponse(
          child: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0)
                    ),
                child: AspectRatio(
                  aspectRatio: 23.2 / 27.52,
                  child: Hero(
                    tag: song.album!,
                    child: getImage(song) != null
                        ?  Image.file(
                      getImage(song),

                      height: 100.0,
                      fit: BoxFit.cover,
                    )
                        :  Image.asset(
                      "images/back.jpg",
                      height: 100.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Container(
                height: 250.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.6)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 140.0,left: 10.0),
                child: Center(
                  child: Text(song.album!,style: TextStyle(
                    fontFamily: 'CabinCondensed',fontWeight: FontWeight.w700,color: Colors.white,fontSize: 13.0
                  ),),
                ),
              )
            ],
          ),
          onTap: () {
            Navigator.of(context)
                .push( MaterialPageRoute(builder: (context) {
              return  CardDetail(widget.db, song);
            }));
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return  Container(
        child: isLoading
            ?  Center(
                child:  CircularProgressIndicator(),
              )
            : Scrollbar(
                child: Scaffold(
                  backgroundColor: Colors.black,
                  body: Column(
                    children: <Widget>[
                       Container(
                        padding: EdgeInsets.only(top: 5.0),
                        color: Colors.transparent,
                        child: Center(
                            child:
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child:  Text("albums",style: TextStyle(fontSize: 40.0, color: Colors.white,
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.w700,),),
                            ),
                        ),
                      ),
                      Expanded(
                        child:   Container(
                          margin: EdgeInsets.only(top: 30.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                //topRight: Radius.circular(60.0),
                                topLeft: Radius.circular(60.0)),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                //  topRight: Radius.circular(60.0),
                                  topLeft: Radius.circular(60.0)),
                              child: Container(child:  GridView.count(
                                crossAxisCount:
                                orientation == Orientation.portrait ? 2 : 4,
                                children: _buildGridCards(context),
                                padding: EdgeInsets.all(5.0),
                                childAspectRatio: 8.0 / 10.0,
                              ),)),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }
}
