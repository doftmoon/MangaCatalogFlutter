import 'package:flutter/material.dart';

class CompactFilterWidget extends StatefulWidget {
  final List<String> types;
  final List<String> tags;
  final List<String> stags;
  final Function(String?) onTypeSelected;
  final Function(List<String>) onTagsSelected;
  final Function(double?) onRateSelected;
  final Function(String?) onTitleChanged;
  final Function() onApply;
  final Function() onReset;

  const CompactFilterWidget({
    super.key,
    required this.types,
    required this.tags,
    required this.onTypeSelected,
    required this.onTagsSelected,
    required this.onRateSelected,
    required this.onTitleChanged,
    required this.onApply,
    required this.onReset,
    required this.stags,
  });

  @override
  _CompactFilterWidgetState createState() => _CompactFilterWidgetState();
}

class _CompactFilterWidgetState extends State<CompactFilterWidget> {
  String? selectedType;
  List<String> selectedTags = [];
  double? selectedRate;
  String? searchTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Column(
        children: [
          // Фильтр по типу
          DropdownButton<String>(
            value: selectedType,
            hint: Text('Choose'),
            onChanged: (String? newType) {
              setState(() {
                selectedType = newType;
                widget.onTypeSelected(newType);
              });
            },
            items:
                widget.types.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
          ),

          // Фильтр по рейтингу
          Slider(
            value: selectedRate ?? 0,
            min: 0,
            max: 10,
            divisions: 10,
            label: selectedRate?.toStringAsFixed(1),
            onChanged: (double value) {
              setState(() {
                selectedRate = value;
                widget.onRateSelected(value);
              });
            },
          ),

          // Фильтр по тегам
          Wrap(
            spacing: 8.0,
            children:
                widget.tags.map((String tag) {
                  return FilterChip(
                    label: Text(tag),
                    selected: widget.stags.contains(tag),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedTags.add(tag);
                        } else {
                          selectedTags.remove(tag);
                        }
                        widget.onTagsSelected(selectedTags);
                      });
                    },
                  );
                }).toList(),
          ),
          SizedBox(height: 8),

          // Поиск по названию
          TextField(
            onChanged: (String? title) {
              setState(() {
                searchTitle = title;
                widget.onTitleChanged(title);
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by title',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          // Кнопки управления фильтрами
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedType = null;
                    selectedTags.clear();
                    selectedRate = null;
                    searchTitle = null;
                    widget.onReset(); // Сброс фильтров
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.grey[800]),
                ),
                child: Text(
                  'Clear filters',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onApply(); // Применить фильтры
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.grey[800]),
                ),
                child: Text('Apply', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
