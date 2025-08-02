import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'todo_model.dart';
import 'database_helper.dart';

void main() {
  runApp(MaterialApp(home: Homepage()));
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  DateTime date = DateTime.now();
  TextEditingController _controller = TextEditingController();
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),

      // AppBar
      appBar: AppBar(
        toolbarHeight: 150, // اذيد طول الاب بار
        backgroundColor: const Color(0xFF2196F3),
        title: Text(
          'Tasker',
          style: GoogleFonts.aBeeZee(
            color: Colors.white,
            fontSize: 45,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              DateTime? newDate = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(1960),
                lastDate: DateTime(2050),
              );
              if (newDate != null) {
                setState(() {
                  date = newDate;
                });
              }
            },
            icon: const Icon(Icons.calendar_month, color: Colors.white, size: 35),
            label: Text( // بيعرض اليوم والاسم المختصر للشهر بستخدام  ديت فورمات
              '${date.day} ${DateFormat.MMM().format(date)}', // بيظهر التاريخ الحالي للجهاز
              style: GoogleFonts.aBeeZee(
                color: Colors.white,
                fontSize: 30,
              ),
            ),
          ),
        ],
      ),

      //  Body
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Todo>>(
              future: DatabaseHelper.instance.getTodos(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final todos = snapshot.data!;

                if (todos.isEmpty) {
                  return const Center(child: Text("No tasks added yet."));
                }

                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, i) {
                    final todo = todos[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Colors.black12),
                      ),
                      elevation: 2,
                      color: Colors.white,
                      child: ListTile(
                        title: Text(todo.title),
                        subtitle: Text(todo.time),
                        leading: GestureDetector(
                          onTap: () async {
                            await DatabaseHelper.instance.toggleDone(
                                todo.id!, !todo.isDone);
                            setState(() {});
                          },
                          child: Icon(
                            todo.isDone
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: todo.isDone ? Color(0xFF6003B3) : Color(0xFFB19090),
                            size: 40,
                          ),
                        ),

                        //  trailing لإضافة Edit مع Delete
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(
                                  0xFFB3B003)),
                              onPressed: () {
                                _controller.text = todo.title;
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Edit Task"),
                                      content: TextField(
                                        controller: _controller,
                                        decoration: const InputDecoration(
                                          hintText: "Enter new task title",
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            if (_controller.text.trim().isNotEmpty) {
                                              final updatedTodo = Todo(
                                                id: todo.id,
                                                title: _controller.text.trim(),
                                                time: todo.time,
                                                isDone: todo.isDone,
                                              );
                                              await DatabaseHelper.instance.updateTodo(updatedTodo);
                                              setState(() {});
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          child: const Text("Save", style: TextStyle(color: Colors.blue)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Center(
                                        child: Text(
                                          "Delete!",
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      content: Text(
                                        "Are you sure you want to delete this task?",
                                        style: GoogleFonts.inter(
                                          color: Colors.brown,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            await DatabaseHelper.instance
                                                .deleteTodo(todo.id!);
                                            setState(() {});
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            "Yes",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            "Cancel",
                                            style: TextStyle(color: Colors.green),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.delete_forever,
                                  color: Colors.red, size: 30),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      //  Floating Action Button لإضافة مهمة جديدة
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.clear();
          selectedTime = null;
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Enter your note here",
                        border: UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      child: Text(
                        selectedTime == null
                            ? 'Pick Time'
                            : 'Picked: ${selectedTime!.format(context)}',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel",
                            style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (_controller.text.trim().isNotEmpty) {
                            final now = DateTime.now();
                            final finalTime = selectedTime != null
                                ? selectedTime!.format(context)
                                : DateFormat.jm().format(now);

                            await DatabaseHelper.instance.insertTodo(Todo(
                              title: _controller.text.trim(),
                              time: finalTime,
                              isDone: false,
                            ));
                            setState(() {});
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text("Ok",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  )
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF2196F3),
        shape: const CircleBorder(),
      ),
    );
  }
}
