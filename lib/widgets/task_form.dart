import 'package:flutter/material.dart';

class TaskForm extends StatefulWidget {
  final Function(String, String, String, DateTime?) onSave;
  final String? initialTitle;
  final String? initialDescription;
  final String? initialPriority;
  final DateTime? initialDueDate;

  const TaskForm({
    super.key,
    required this.onSave,
    this.initialTitle,
    this.initialDescription,
    this.initialPriority,
    this.initialDueDate,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedPriority;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
    _selectedPriority = widget.initialPriority ?? 'Low';
    _dueDate = widget.initialDueDate;
  }

  void _saveTask() {
    if (_titleController.text.isEmpty) return;

    widget.onSave(
      _titleController.text,
      _descriptionController.text,
      _selectedPriority,
      _dueDate,
    );

    Navigator.pop(context);
  }

  void _selectDueDate() async {
    DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() {
        _dueDate = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Task Form'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Task Description'),
            ),
            DropdownButtonFormField(
              value: _selectedPriority,
              items: const [
                DropdownMenuItem(value: 'Low', child: Text('Low')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'High', child: Text('High')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value as String;
                });
              },
              decoration: const InputDecoration(labelText: 'Priority'),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dueDate == null
                        ? 'No due date selected'
                        : 'Due: ${_dueDate!.toLocal().toString().split(' ')[0]}',
                  ),
                ),
                TextButton(
                  onPressed: _selectDueDate,
                  child: const Text('Select Date'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
