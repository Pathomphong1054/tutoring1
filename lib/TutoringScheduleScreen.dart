import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_screen.dart';

class TutoringScheduleScreen extends StatefulWidget {
  final String tutorName;
  final String tutorImage;
  final String currentUser;
  final String currentUserImage;

  TutoringScheduleScreen({
    required this.tutorName,
    required this.tutorImage,
    required this.currentUser,
    required this.currentUserImage,
  });

  @override
  _TutoringScheduleScreenState createState() => _TutoringScheduleScreenState();
}

class _TutoringScheduleScreenState extends State<TutoringScheduleScreen> {
  DateTime? selectedDay;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int selectedRate = 1;
  String selectedLevel = 'ประถม1-3';
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  double hourlyRate = 100.0;

  List<Map<String, dynamic>> rates = [];

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  List<Map<String, dynamic>> _scheduledSessions = [];

  @override
  void initState() {
    super.initState();
    _fetchScheduledSessions();
    _updateRates();
  }

  Future<void> _fetchScheduledSessions() async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.56.193/tutoring_app/fetch_scheduled_sessions.php?tutor=${widget.tutorName}'),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          _scheduledSessions =
              List<Map<String, dynamic>>.from(responseData['sessions']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to load scheduled sessions: ${responseData['message']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to load scheduled sessions: ${response.body}')),
      );
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final timePicked = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? startTime ?? TimeOfDay(hour: 13, minute: 0)
          : endTime ?? TimeOfDay(hour: 15, minute: 0),
    );

    if (timePicked != null) {
      setState(() {
        if (isStartTime) {
          startTime = timePicked;
          startTimeController.text = startTime!.format(context);
        } else {
          endTime = timePicked;
          endTimeController.text = endTime!.format(context);
        }
        _updateRates();
      });
    }
  }

  bool _isDayScheduled(DateTime day) {
    for (var session in _scheduledSessions) {
      if (isSameDay(DateTime.parse(session['date']), day)) {
        return true;
      }
    }
    return false;
  }

  void _updateRates() {
    if (startTime != null && endTime != null) {
      final startMinutes = startTime!.hour * 60 + startTime!.minute;
      final endMinutes = endTime!.hour * 60 + endTime!.minute;
      final durationMinutes = endMinutes - startMinutes;
      final durationHours = (durationMinutes / 60).ceil();
      double baseRate;
      switch (selectedLevel) {
        case 'ประถม1-3':
          baseRate = 100.0;
          break;
        case 'ประถม4-6':
          baseRate = 120.0;
          break;
        case 'มัธยม1-3':
          baseRate = 140.0;
          break;
        case 'มัธยม4-6':
          baseRate = 160.0;
          break;
        case 'ปวช':
          baseRate = 180.0;
          break;
        case 'ปวส':
          baseRate = 200.0;
          break;
        case 'ป.ตรี':
        default:
          baseRate = 180.0;
          break;
      }
      setState(() {
        rates = [
          {'people': 1, 'price': durationHours * baseRate},
          {'people': 2, 'price': durationHours * baseRate * 2},
          {'people': 3, 'price': durationHours * baseRate * 3},
        ];
      });
    }
  }

  Future<void> _scheduleSession() async {
    if (selectedDay != null && startTime != null && endTime != null) {
      final response = await http.post(
        Uri.parse('http://192.168.56.193/tutoring_app/schedule_session.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'student': widget.currentUser,
          'tutor': widget.tutorName,
          'date': selectedDay.toString(),
          'startTime': startTime!.format(context),
          'endTime': endTime!.format(context),
          'rate': selectedRate,
        }),
      );

      print('Schedule Session Response: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          if (responseData['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Session scheduled successfully')),
            );
            await _sendMessageToTutor(responseData['session_id']
                .toString()); // Send message to tutor with session_id
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Failed to schedule session: ${responseData['message']}')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to parse response: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to schedule session: ${response.body}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a day and time')),
      );
    }
  }

  Future<void> _sendMessageToTutor(String sessionId) async {
    final price =
        rates.firstWhere((rate) => rate['people'] == selectedRate)['price'];
    final message =
        '''A new tutoring session has been scheduled with you on ${selectedDay.toString()}
  from ${startTime!.format(context)} to ${endTime!.format(context)}.
  The rate is $selectedRate people at ${price.toStringAsFixed(2)} THB.''';

    final payload = json.encode({
      'sender': widget.currentUser,
      'recipient': widget.tutorName,
      'message': message,
      'session_id': sessionId,
    });

    print('Sending message payload: $payload');

    final response = await http.post(
      Uri.parse('http://192.168.56.193/tutoring_app/send_message.php'),
      headers: {'Content-Type': 'application/json'},
      body: payload,
    );

    print('Send Message Response: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Message sent to tutor')),
          );
          // Navigate to ChatScreen with the tutor
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                currentUser: widget.currentUser,
                recipient: widget.tutorName,
                recipientImage: widget.tutorImage,
                currentUserImage: widget.currentUserImage,
                sessionId: sessionId,
                currentUserRole: 'student', // Pass currentUserRole as 'student'
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to send message: ${responseData['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to parse response: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutoring Schedule'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tutor: ${widget.tutorName}'),
            SizedBox(height: 20),
            TableCalendar(
              calendarFormat: _calendarFormat,
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2024, 12, 31),
              selectedDayPredicate: (day) {
                return isSameDay(selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (_isDayScheduled(selectedDay)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'This day is already scheduled. Please choose another day.')),
                  );
                } else {
                  setState(() {
                    this.selectedDay = selectedDay;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  if (_isDayScheduled(day)) {
                    return Container(
                      margin: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle().copyWith(color: Colors.white),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Start Time: '),
                Expanded(
                  child: TextField(
                    controller: startTimeController,
                    readOnly: true,
                    onTap: () {
                      _selectTime(context, true);
                    },
                    decoration: InputDecoration(
                      hintText: 'Select Start Time',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text('End Time: '),
                Expanded(
                  child: TextField(
                    controller: endTimeController,
                    readOnly: true,
                    onTap: () {
                      _selectTime(context, false);
                    },
                    decoration: InputDecoration(
                      hintText: 'Select End Time',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text('Level of Education'),
            DropdownButton<String>(
              value: selectedLevel,
              onChanged: (String? newValue) {
                setState(() {
                  selectedLevel = newValue!;
                  _updateRates();
                });
              },
              items: <String>[
                'ประถม1-3',
                'ประถม4-6',
                'มัธยม1-3',
                'มัธยม4-6',
                'ปวช',
                'ปวส',
                'ป.ตรี',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Text('Price rate'),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: rates.length,
              itemBuilder: (context, index) {
                return RadioListTile<int>(
                  title: Text(
                      '${rates[index]['people']} คน | ราคา ${rates[index]['price'].toStringAsFixed(2)} บาท'),
                  value: rates[index]['people'],
                  groupValue: selectedRate,
                  onChanged: (int? value) {
                    setState(() {
                      selectedRate = value!;
                    });
                  },
                );
              },
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _scheduleSession,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                child: Text('Schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
