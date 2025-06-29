
import 'package:flutter/material.dart';
import '../database/database_client.dart';
import '../pages/list_songs.dart';


class PlayList extends StatefulWidget {
  DatabaseClient db;
  PlayList(this.db);

  @override
  State<StatefulWidget> createState() {
    return  _statePlaylist();
  }
}

class _statePlaylist extends State<PlayList> {
  var mode;
  var selected;
   Orientation? orientation;

  @override
  void initState() {
    setState(() {
      mode=1;
      selected=1;
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    orientation = MediaQuery.of(context).orientation;
    return  Container(
      child: orientation == Orientation.portrait ? potrait() : landscape(),
    );
  }

  Widget potrait() {
    return  ListView(
      children: <Widget>[
         ListTile(                   
          leading:  Icon(Icons.call_received,size: 28.0,),
          title:  Text("Recently played",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.w500,letterSpacing: 1.0,fontFamily: "Quicksand"),),
          subtitle:  Text("Songs"),
          onTap: () {
            Navigator
                .of(context)
                .push( MaterialPageRoute(builder: (context) {
              return  ListSongs(widget.db, 1,orientation!);
            }));
          },
        ),
         ListTile(
          leading:  Icon(Icons.insert_chart,size: 28.0,),
          title:  Text("Top tracks",style: TextStyle(fontSize: 20.0,letterSpacing: 1.0,fontFamily: "Quicksand",fontWeight: FontWeight.w500),),
          subtitle:  Text("Songs"),
          onTap: () {
            Navigator
                .of(context)
                .push( MaterialPageRoute(builder: (context) {
              return  ListSongs(widget.db, 2,orientation!);
            }));
          },
        ),
         ListTile(
          leading:  Icon(Icons.favorite,size: 28.0,),
          title:  Text("Favourites",style: TextStyle(fontSize: 20.0,letterSpacing: 1.0,fontFamily: "Quicksand",fontWeight: FontWeight.w500),),
          subtitle:  Text("Songs"),
          onTap: () {
            Navigator
                .of(context)
                .push( MaterialPageRoute(builder: (context) {
              return  ListSongs(widget.db, 3,orientation!);
            }));
          },
        ),
      ],
    );
  }

  Widget landscape() {
    return  Row(
      children: <Widget>[
         Container(
          width:300.0,
    child: ListView(
          children: <Widget>[
             ListTile(
              leading:  Icon(Icons.call_received),
              title:  Text("Recently played",style:  TextStyle(color: selected==1?Colors.blue:Colors.black)),
              subtitle:  Text("songs"),
              onTap: () {
                setState(() {
                  mode=1;
                  selected=1;
                });
              },
            ),
             ListTile(
              leading:  Icon(Icons.show_chart),
              title:  Text("Top tracks",style:  TextStyle(color: selected==2?Colors.blue:Colors.black)),
              subtitle:  Text("songs"),
              onTap: () {
               setState(() {
                 mode=2;
                 selected=2;
               });
              },
            ),
             ListTile(
              leading:  Icon(Icons.favorite),
              title:  Text("Favourites",style:  TextStyle(color: selected==3?Colors.blue:Colors.black)),
              subtitle:  Text("Songs"),
              onTap: (){
                setState(() {
                  mode=3;
                  selected=3;
                });
              },
            ),
          ],
        ),
        ),
         Expanded(
          child: Container(
            child:  ListSongs(widget.db, mode,orientation!),
        )
        )
      ],
    );
  }
}
