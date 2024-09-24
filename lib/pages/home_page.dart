// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_interpolation_to_compose_strings

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_todo_app/data/local_storage.dart';
import 'package:flutter_todo_app/helper/translations_helper.dart';
import 'package:flutter_todo_app/main.dart';
import 'package:flutter_todo_app/models/task_model.dart';
import 'package:flutter_todo_app/widgets/custom_search_delegate.dart';
import 'package:flutter_todo_app/widgets/task_list_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Task> _allTasks;
  late LocalStorage _localStorage;

  @override
  void initState() {
    super.initState();
    _localStorage = locator<LocalStorage>();
    _allTasks = <Task>[];
    _getAllTaskFromDb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: GestureDetector(
          onTap: () {
            _showAddTaskBottomSheet();
          },
          child: const Text(
            'title',
            style: TextStyle(color: Colors.black),
          ).tr(),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              _showSearchPage();
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              _showAddTaskBottomSheet();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _allTasks.isNotEmpty
          ? ListView.builder(
              itemBuilder: (context, index) {
                var _currentListElement = _allTasks[index];
                return Dismissible(
                  background: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete),
                      const SizedBox(width: 8),
                      const Text('remove_task').tr(),
                    ],
                  ),
                  key: Key(_currentListElement.id),
                  onDismissed: (direction) {
                    _allTasks.removeAt(index);
                    _localStorage.deleteTask(task: _currentListElement);
                    setState(() {});
                  },
                  child: TaskItem(task: _currentListElement),
                );
              },
              itemCount: _allTasks.length,
            )
          : Center(
              child: const Text('empty_task_list').tr(),
            ),
    );
  }

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          width: MediaQuery.of(context).size.width,
          child: ListTile(
            title: TextField(
              autofocus: true,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                  hintText: 'add_task'.tr(), border: InputBorder.none),
              onSubmitted: (value) {
                Navigator.of(context).pop();
                if (value.length > 3) {
                  DatePicker.showTimePicker(
                    context,
                    locale: TranslationsHelper.getDeviceLanguage(context),
                    showSecondsColumn: false,
                    onConfirm: (time) async {
                      var newTaskAdd =
                          Task.create(name: value, createdAt: time);
                      _allTasks.insert(0, newTaskAdd);
                      await _localStorage.addTask(task: newTaskAdd);
                      setState(() {});
                    },
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _getAllTaskFromDb() async {
    _allTasks = await _localStorage.getAllTask();
    setState(() {});
  }

  void _showSearchPage() async {
    await showSearch(
        context: context, delegate: CustomSearchDelegate(allTasks: _allTasks));
    _getAllTaskFromDb();
  }
}
