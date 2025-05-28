import 'package:flutter/material.dart';
import 'package:manga_catalog_app/services/firestore_service.dart';
import 'package:provider/provider.dart';

import '../core/models/manga.dart';
import '../providers/global_state.dart';
import 'edit_manga_page.dart';

class MangaPage extends StatelessWidget {
  const MangaPage({super.key, required this.manga});

  final Manga manga;

  @override
  Widget build(BuildContext context) {
    GlobalAppState().addMangaToRecentlyViewed(manga);

    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(manga.imageUrl, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    manga.title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Author: ${manga.author}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Rate: ${manga.rate}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Views: ${manga.views}'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    manga.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 6,
                    children:
                        manga.tags.map((tag) {
                          return Chip(label: Text(tag));
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (GlobalAppState().uid != null)
            ElevatedButton(
              onPressed:
                  () => updateBookmark(
                    Provider.of<GlobalAppState>(context, listen: false).uid ??
                        '',
                    manga.id,
                  ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.grey[800]),
              ),
              child: Text(
                'Add to bookmark',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (GlobalAppState().role == 'admin' ||
              GlobalAppState().role == 'moderator' ||
              GlobalAppState().role == 'editor')
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateMangaPage(mangaId: manga.id),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.grey[800]),
              ),
              child: Text('Edit manga', style: TextStyle(color: Colors.white)),
            ),
          if (GlobalAppState().role == 'admin' ||
              GlobalAppState().role == 'editor')
            ElevatedButton(
              onPressed: () {
                deleteManga(manga.id);
                Navigator.pop(context);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.grey[800]),
              ),
              child: Text(
                'Delete manga',
                style: TextStyle(color: Colors.white),
              ),
            ),
          Card(child: CommentsSection(mangaId: manga.id)),
        ],
      ),
    );
  }
}

class CommentsSection extends StatefulWidget {
  final String mangaId;

  const CommentsSection({super.key, required this.mangaId});

  @override
  _CommentsSectionState createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  late Future<List<Map<String, dynamic>>> _commentsFuture;
  final TextEditingController _controller = TextEditingController();
  bool _isInputVisible = false;
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _commentsFuture = CommentService().getComments(widget.mangaId);
  }

  void _refreshComments() {
    setState(() {
      _commentsFuture = CommentService().getComments(widget.mangaId);
    });
  }

  void _toggleInput() {
    setState(() {
      _isInputVisible = !_isInputVisible;
      _controller.clear(); // Очистка текстового поля
    });
  }

  Future<void> _submitComment() async {
    final String text = _controller.text.trim();
    if (text.isNotEmpty) {
      final userId = GlobalAppState().uid; // Получите текущий uid
      await CommentService().addComment(userId!, widget.mangaId, text);
      _toggleInput(); // Закрываем поле ввода
      _refreshComments(); // Обновляем список комментариев
    }
  }

  @override
  Widget build(BuildContext context) {
    if (GlobalAppState().uid != null) {
      _isUserLoggedIn = true;
    }

    return Column(
      children: [
        Text(
          'Comments',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _commentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text('No comments yet', style: TextStyle(fontSize: 16)),
              );
            }

            List<Map<String, dynamic>> comments = snapshot.data!;
            final String? currentUserId = GlobalAppState().uid;
            final String? currentUserRole = GlobalAppState().role;

            return SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  final bool canDelete =
                      currentUserId == comment['uid'] ||
                      currentUserRole == 'admin' ||
                      currentUserRole == 'moderator';
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(comment['text']),
                      subtitle: Text('User: ${comment['uid']}'),
                      trailing:
                          canDelete
                              ? IconButton(
                                icon: Icon(Icons.delete, color: Colors.black54),
                                onPressed: () async {
                                  await CommentService().deleteComment(
                                    comment['id'],
                                  );
                                  _refreshComments();
                                },
                              )
                              : null,
                    ),
                  );
                },
              ),
            );
          },
        ),
        if (_isInputVisible)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter comment',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.cancel), onPressed: _toggleInput),
                IconButton(icon: Icon(Icons.send), onPressed: _submitComment),
              ],
            ),
          ),
        if (_isUserLoggedIn)
          ElevatedButton(
            onPressed: _toggleInput,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.grey[800]),
            ),
            child: Text(
              _isInputVisible ? 'Hide text field' : 'Add comment',
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }
}
