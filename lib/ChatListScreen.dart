import 'package:apptutor_2/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatListScreen extends StatefulWidget {
  final String currentUser;
  final String currentUserImage;
  final String currentUserRole; // Add this field

  const ChatListScreen({
    required this.currentUser,
    required this.currentUserImage,
    required this.currentUserRole, // Add this field
  });

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.56.193/tutoring_app/fetch_conversations.php?user=${widget.currentUser}'));
      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        try {
          final responseData = json.decode(response.body);
          if (responseData['status'] == 'success') {
            setState(() {
              _conversations = List<Map<String, dynamic>>.from(
                  responseData['conversations']);
              _isLoading = false;
            });
          } else {
            throw Exception(
                'Failed to load conversations: ${responseData['message']}');
          }
        } catch (e) {
          throw Exception('Failed to parse conversations: $e');
        }
      } else {
        throw Exception(
            'Failed to load conversations: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _errorMessage = 'Failed to load conversations: $e';
        _isLoading = false;
      });
    }
  }

  Future<String?> _fetchSessionId(String recipient) async {
    final response = await http.get(Uri.parse(
        'http://192.168.56.193/tutoring_app/fetch_session_id.php?recipient=$recipient&user=${widget.currentUser}'));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        return responseData['session_id'].toString();
      } else {
        throw Exception(
            'Failed to fetch session ID: ${responseData['message']}');
      }
    } else {
      throw Exception('Failed to fetch session ID: ${response.reasonPhrase}');
    }
  }

  void _navigateToChatScreen(String recipient, String recipientImage) async {
    try {
      String? sessionId = await _fetchSessionId(recipient);
      if (sessionId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              currentUser: widget.currentUser, // Fix this
              recipient: recipient,
              recipientImage: recipientImage,
              currentUserImage: widget.currentUserImage, // Fix this
              sessionId: sessionId,
              currentUserRole: widget.currentUserRole, // Fix this
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session ID not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch session ID: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _conversations.isNotEmpty
                  ? ListView.builder(
                      itemCount: _conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = _conversations[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: conversation[
                                          'recipient_image'] !=
                                      null
                                  ? NetworkImage(
                                      'http://192.168.56.193/tutoring_app/uploads/${conversation['recipient_image']}')
                                  : AssetImage('images/default_profile.jpg')
                                      as ImageProvider,
                            ),
                            title: Text(conversation['conversation_with'] ??
                                'unknown_user'),
                            subtitle: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width - 100,
                              ),
                              child: Text(
                                conversation['last_message'] ?? '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            trailing: Text(
                              conversation['timestamp'] != null
                                  ? _formatTimestamp(conversation['timestamp'])
                                  : '',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            onTap: () {
                              _navigateToChatScreen(
                                  conversation['recipient_username'] ??
                                      'unknown_user',
                                  conversation['recipient_image'] != null
                                      ? 'http://192.168.56.193/tutoring_app/uploads/${conversation['recipient_image']}'
                                      : 'images/default_profile.jpg');
                            },
                          ),
                        );
                      },
                    )
                  : Center(child: Text('No conversations found')),
    );
  }

  String _formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    final DateTime now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return '${dateTime.hour}:${dateTime.minute}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
