import 'package:flutter_music_player_plugin/flutter_music_player_plugin.dart';
import 'package:flutter/material.dart';
import '../database/database_client.dart';
import '../util/lastplay.dart';
import 'now_playing.dart';

class SearchSong extends StatelessWidget {
  final DatabaseClient db;
  final List<Song> songs;

  const SearchSong(this.db, this.songs, {super.key});

  @override
  Widget build(BuildContext context) {
    // Controller to handle text input
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // TextField for search input
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search songs',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  // Trigger rebuild on text change
                  (context as Element).markNeedsBuild();
                },
              ),
            ),
            // Display search results
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (context, value, child) {
                  // Filter songs based on search query
                  final query = value.text.toLowerCase();
                  final filteredSongs = query.isEmpty
                      ? songs
                      : songs
                      .where((song) =>
                      song.title!.toLowerCase().contains(query))
                      .toList();

                  return ListView.builder(
                    itemCount: filteredSongs.length,
                    itemBuilder: (context, index) {
                      final song = filteredSongs[index];
                      return ListTile(
                        leading: const Icon(Icons.headset),
                        title: Text(song.title!),
                        onTap: () async {
                          // Handle song selection
                          final results = [song]; // Single song selected
                          print('Selected: ${song.title}');
                          MyQueue.songs = results;
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  NowPlaying(db, results, 0, 0),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}