import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

class AddMangaPage extends StatefulWidget {
  const AddMangaPage({super.key});

  @override
  _AddMangaPageState createState() => _AddMangaPageState();
}

class _AddMangaPageState extends State<AddMangaPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _viewsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  Future<void> addManga({
    required String title,
    String? imageUrl,
    String? author,
    double? rate,
    int? views,
    String? description,
    String? type,
    required List<String> tags,
  }) async {
    await createManga(
      title: _titleController.text,
      imageUrl:
          _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
      author: _authorController.text.isNotEmpty ? _authorController.text : null,
      rate: double.tryParse(_rateController.text),
      views: int.tryParse(_viewsController.text),
      description:
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
      type: _typeController.text.isNotEmpty ? _typeController.text : null,
      tags: _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
    );
    Navigator.pop(context); // Закрыть экран после добавления
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Добавить мангу')),
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
                controller: _typeController,
                decoration: InputDecoration(labelText: 'Тип (например, Manga)'),
              ),
              TextField(
                controller: _tagsController,
                decoration: InputDecoration(labelText: 'Теги (через запятую)'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    () => addManga(
                      title: _titleController.text,
                      imageUrl: _imageUrlController.text,
                      author: _authorController.text,
                      rate: double.tryParse(_rateController.text),
                      views: int.tryParse(_viewsController.text),
                      description: _descriptionController.text,
                      type: _typeController.text,
                      tags:
                          _tagsController.text
                              .split(',')
                              .map((tag) => tag.trim())
                              .toList(),
                    ),
                child: Text('Add manga'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
