import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_music_player_plugin/flutter_music_player_plugin.dart';
import 'package:path_provider/path_provider.dart';

dynamic getImage(Song song) {
  return song.albumArt == null
      ? null
      :  File.fromUri(Uri.parse(song.albumArt!));
}

Widget avatar(context,File f, String title) {
  return  Material(
    borderRadius:  BorderRadius.circular(30.0),
    elevation: 2.0,
    child: f != null
        ?  CircleAvatar(
      backgroundImage:  FileImage(f,
      ),
    )
        :  CircleAvatar(
      child:  Text(title[0].toUpperCase()),
    ),
  );
}
class Repeat {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/repeat.txt');
  }

  Future<int> read() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If we encounter an error, return 0
      return 0;
    }
  }

  Future<File> write(int counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$counter');
  }
}