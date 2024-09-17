import 'package:flutter/material.dart';
import 'package:habit_tracker/components/homeTracker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class HomePageState extends State<HomeTracker> {
  final List<String> _taskList = [];
  final Map<String, int> _taskDurations =
      {}; // Almacena el tiempo de cada tarea
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _timeController =
      TextEditingController(); // Controlador para el tiempo
  int _taskCount = 0; // Contador de tareas
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); // Para las notificaciones
  final Map<String, Timer> _timers =
      {}; // Map para asociar tareas con temporizadores

  // Inicializar las notificaciones
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  // Configuración de las notificaciones
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Mostrar notificación
  Future<void> _showNotification(String task) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'task_channel',
      'Tarea vencida',
      channelDescription: 'Notificaciones de tarea vencida',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Tarea vencida',
      'El tiempo para la tarea "$task" ha terminado.',
      platformChannelSpecifics,
    );
  }

  // Añadir tarea con tiempo
  void _addTask() {
    if (_taskController.text.isNotEmpty && _timeController.text.isNotEmpty) {
      setState(() {
        String task = _taskController.text;
        int taskDuration = int.tryParse(_timeController.text) ??
            0; // Convertir el tiempo a número

        if (taskDuration > 0) {
          _taskList.add(task);
          _taskDurations[task] =
              taskDuration; // Guardar la duración de la tarea
          _taskController.clear();
          _timeController.clear();
          _taskCount++;

          // Iniciar temporizador para la tarea con el tiempo especificado
          _timers[task] = Timer(Duration(minutes: taskDuration), () {
            _showNotification(
                task); // Mostrar notificación cuando el tiempo expire
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Por favor, ingresa un tiempo válido.'),
          ));
        }
      });
    }
  }

  // Eliminar tarea y detener el temporizador asociado
  void _removeTask(int index) {
    setState(() {
      String task = _taskList[index];
      _timers[task]?.cancel(); // Cancelar el temporizador si existe
      _timers.remove(task);
      _taskList.removeAt(index);
      _taskDurations.remove(task); // Eliminar duración
      _taskCount--;
    });
  }

  // Confirmación de eliminación
  void _confirmDeleteTask(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Eliminar tarea"),
          content:
              const Text("¿Estás seguro de que deseas eliminar esta tarea?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo sin eliminar
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                _removeTask(index); // Eliminar tarea
                Navigator.of(context).pop(); // Cerrar diálogo
              },
              child: const Text("Sí"),
            ),
          ],
        );
      },
    );
  }

  // Imagen evolutiva basada en el número de tareas
  String _getImageForTaskCount() {
    if (_taskCount < 3) {
      return 'assets/image1.png'; // Imagen para pocas tareas
    } else if (_taskCount < 6) {
      return 'assets/image2.png'; // Imagen para un número moderado de tareas
    } else {
      return 'assets/image3.png'; // Imagen para muchas tareas
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children:  [
            Icon(Icons.track_changes), // Icono de tracker
            SizedBox(width: 10),
            Text('Habit Tracker'), // Título del tracker
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                _getImageForTaskCount(),
                height: 150,
                width: 150,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _taskController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nueva tarea',
                  prefixIcon: Icon(Icons.task), // Icono de tareas
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _timeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Tiempo en minutos',
                  prefixIcon: Icon(Icons.timer), // Icono de temporizador
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addTask,
              icon: const Icon(Icons.add), // Icono de agregar tarea
              label: const Text('Agregar Tarea'),
            ),
            // Mostrar contador de tareas
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Tareas creadas: $_taskCount',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _taskList.length,
                itemBuilder: (context, index) {
                  String task = _taskList[index];
                  int taskDuration = _taskDurations[task] ?? 0;
                  return ListTile(
                    title: Text('$task - $taskDuration minutos'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteTask(index),
                    ),
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
