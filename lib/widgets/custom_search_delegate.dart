// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/data/local_storage.dart';
import 'package:flutter_todo_app/main.dart';
import 'package:flutter_todo_app/models/task_model.dart';
import 'package:flutter_todo_app/widgets/task_list_item.dart';

class CustomSearchDelegate extends SearchDelegate {

  final List<Task> allTasks;

  CustomSearchDelegate({required this.allTasks});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query.isEmpty ? null : query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return GestureDetector(
      onTap: () {
        close(context, null);
      },
      child: const Icon(
        Icons.arrow_back_ios,
        color: Colors.black,
        size: 24,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Task> filteredList = allTasks.where((task) => task.name.toLowerCase().contains(query.toLowerCase())).toList();
    return filteredList.isNotEmpty ? ListView.builder(
              itemBuilder: (context, index) {
                var _currentListElement = filteredList[index];
                return Dismissible(
                  background:  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete),
                      const SizedBox(width: 8),
                      const Text('remove_task').tr(),
                    ],
                  ),
                  key: Key(_currentListElement.id),
                  onDismissed: (direction) async{
                    filteredList.removeAt(index);
                    await locator<LocalStorage>().deleteTask(task: _currentListElement);
                    
                  },
                  child: TaskItem(task: _currentListElement),
                );
              },
              itemCount: filteredList.length,
            ) : Center(child: const Text('search_not_found').tr(),);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
