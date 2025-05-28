import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';

class UpdateMangaPage extends StatefulWidget {
  final String mangaId; // ID манги для обновления

  UpdateMangaPage({required this.mangaId});

  @override
  _UpdateMangaPageState createState() => _UpdateMangaPageState();
}

class _UpdateMangaPageState extends State<UpdateMangaPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _viewsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadMangaData();
  }

  Future<void> loadMangaData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('manga')
            .doc(widget.mangaId)
            .get();
    if (doc.exists) {
      final data = doc.data();
      _titleController.text = data!['title'];
      _imageUrlController.text = data['imageUrl'];
      _authorController.text = data['author'];
      _rateController.text = data['rate'].toString();
      _viewsController.text = data['views'].toString();
      _descriptionController.text = data['description'];
      _tagsController.text = (data['tags'] as List).join(', ');
    }
  }

  Future<void> editManga() async {
    await updateManga(
      id: widget.mangaId,
      title: _titleController.text.isNotEmpty ? _titleController.text : null,
      imageUrl:
          _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
      author: _authorController.text.isNotEmpty ? _authorController.text : null,
      rate: double.tryParse(_rateController.text),
      views: int.tryParse(_viewsController.text),
      description:
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
      tags:
          _tagsController.text.isNotEmpty
              ? _tagsController.text
                  .split(',')
                  .map((tag) => tag.trim())
                  .toList()
              : null,
    );
    Navigator.pop(context); // Закрыть экран после обновления
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Обновить мангу')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Название'),
              ),
              TextField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'URL изображения'),
              ),
              TextField(
                controller: _authorController,
                decoration: InputDecoration(labelText: 'Автор'),
              ),
              TextField(
                controller: _rateController,
                decoration: InputDecoration(labelText: 'Рейтинг (0-10)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _viewsController,
                decoration: InputDecoration(labelText: 'Просмотры'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Описание'),
              ),
              TextField(
                controller: _tagsController,
                decoration: InputDecoration(labelText: 'Теги (через запятую)'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: editManga,
                child: Text('Обновить мангу'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
