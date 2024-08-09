import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:apptutor_2/TutorProfileScreen.dart';
import 'package:apptutor_2/StudentProfileScreen.dart';

class ChatScreen extends StatefulWidget {
  final String currentUser;
  final String recipient;
  final String recipientImage;
  final String currentUserImage;
  final String sessionId;
  final String currentUserRole; // Ensure this field is passed correctly

  const ChatScreen({
    required this.currentUser,
    required this.recipient,
    required this.recipientImage,
    required this.currentUserImage,
    required this.sessionId,
    required this.currentUserRole,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map<String, List<Map<String, dynamic>>> _allMessages = {};
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    setState(() {
      _isLoading = true;
      _messages = _allMessages[widget.sessionId] ?? [];
    });
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.56.193/tutoring_app/fetch_chat.php?sender=${widget.currentUser}&recipient=${widget.recipient}'));
      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        try {
          final responseData = json.decode(response.body);
          if (responseData['status'] == 'success') {
            setState(() {
              _messages =
                  List<Map<String, dynamic>>.from(responseData['messages']);
              _allMessages[widget.sessionId] = _messages;
              _isLoading = false;
            });
            _scrollToBottom();
          } else {
            throw Exception(
                'Failed to load messages: ${responseData['message']}');
          }
        } catch (e) {
          throw Exception('Failed to parse messages: $e');
        }
      } else {
        throw Exception('Failed to load messages: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _errorMessage = 'Failed to load messages: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://192.168.56.193/tutoring_app/send_message.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender': widget.currentUser,
          'recipient': widget.recipient,
          'message': message,
          'session_id': widget.sessionId,
        }),
      );

      print('Send Message Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            _messages.add({
              'sender': widget.currentUser,
              'recipient': widget.recipient,
              'message': message,
              'session_id': widget.sessionId,
            });
            _allMessages[widget.sessionId] = _messages;
            _controller.clear();
          });
          _scrollToBottom();

          // สร้างการแจ้งเตือนใหม่
          await createNotification(
              widget.currentUser, widget.recipient, message, 'chat');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to send message: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message cannot be empty')),
      );
    }
  }

  Future<void> createNotification(
      String sender, String recipient, String message, String type) async {
    print('Role being sent: ${widget.currentUserRole}');
    print(
        'Sending notification data: sender=$sender, recipient=$recipient, message=$message, role=${widget.currentUserRole}, type=$type');

    final response = await http.post(
      Uri.parse('http://192.168.56.193/tutoring_app/create_notification.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'sender': sender,
        'recipient': recipient,
        'message': message,
        'role': widget.currentUserRole,
        'type': type,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        print('Notification created successfully');
      } else {
        print('Failed to create notification: ${responseData['message']}');
      }
    } else {
      print('Failed to create notification: ${response.reasonPhrase}');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _viewProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (widget.currentUserRole == 'tutor') {
            return StudentProfileScreen(
              userName: widget.recipient,
              onProfileUpdated: () {},
            );
          } else {
            return TutorProfileScreen(
              userName: widget.recipient,
              userRole: 'tutor',
              currentUser: widget.currentUser,
              currentUserImage: widget.currentUserImage,
              username: widget.recipient,
              profileImageUrl: widget.recipientImage,
              userId: '',
              tutorId: '',
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.recipient}'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: _viewProfile,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          bool isCurrentUser =
                              message['sender'] == widget.currentUser;
                          return Row(
                            mainAxisAlignment: isCurrentUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              if (!isCurrentUser)
                                GestureDetector(
                                  onTap: _viewProfile,
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(widget.recipientImage),
                                    radius: 20,
                                  ),
                                ),
                              if (!isCurrentUser) SizedBox(width: 10),
                              Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.7),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? Colors.blue[100]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  message['message'],
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              if (isCurrentUser) SizedBox(width: 10),
                              if (isCurrentUser)
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(widget.currentUserImage),
                                  radius: 20,
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: 'Type a message',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: _sendMessage,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
