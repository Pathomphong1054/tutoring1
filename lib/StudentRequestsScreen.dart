import 'package:apptutor_2/TutorProfileScreen.dart';
import 'package:apptutor_2/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentRequestsScreen extends StatefulWidget {
  final String userName;

  StudentRequestsScreen({required this.userName, required String userRole});

  @override
  _StudentRequestsScreenState createState() => _StudentRequestsScreenState();
}

class _StudentRequestsScreenState extends State<StudentRequestsScreen> {
  List<dynamic> requests = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse(
        'http://192.168.56.193/tutoring_app/fetch_requests.php?recipient=${widget.userName}');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            requests = data['requests'];
          });
        } else {
          _showErrorSnackBar('Failed to load requests: ${data['message']}');
        }
      } else {
        _showErrorSnackBar(
            'Failed to load requests. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorSnackBar('An error occurred while fetching requests: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _respondToRequest(int requestId, bool isAccepted,
      String tutorName, String tutorProfileImage) async {
    var response = await http.post(
      Uri.parse('http://192.168.56.193/tutoring_app/respond_request.php'),
      body: json.encode({
        'request_id': requestId,
        'is_accepted': isAccepted ? 1 : 0,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request responded successfully')),
        );
        _fetchRequests();
        if (isAccepted && responseData['sessionId'] != null) {
          _navigateToChatScreen(
              tutorName, tutorProfileImage, responseData['sessionId']);
        }
      } else {
        _showErrorSnackBar(
            'Failed to respond to request: ${responseData['message']}');
      }
    } else {
      _showErrorSnackBar('Failed to respond to request');
    }
  }

  void _navigateToChatScreen(
      String recipient, String recipientImage, String sessionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          currentUser: widget.userName,
          recipient: recipient,
          recipientImage: recipientImage,
          currentUserImage:
              '', // Add the current user's profile image URL here if available
          sessionId: sessionId,
          currentUserRole: 'student', // Adjust this based on the user's role
        ),
      ),
    );
  }

  void _viewTutorProfile(String tutorName, String tutorProfileImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorProfileScreen(
          userName: tutorName,
          userRole: 'tutor',
          canEdit: false,
          currentUser: widget.userName,
          currentUserImage:
              '', // Add the current user's profile image URL here if available
          onProfileUpdated: () {},
          username: tutorName,
          profileImageUrl: tutorProfileImage, userId: '', tutorId: '',
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Requests'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                final tutorName = request['sender'];
                final tutorProfileImage = request['profileImage'];
                final isAccepted = request['is_accepted'] == 1;

                return ListTile(
                  leading: GestureDetector(
                    onTap: () =>
                        _viewTutorProfile(tutorName, tutorProfileImage),
                    child: CircleAvatar(
                      backgroundImage: tutorProfileImage != null &&
                              tutorProfileImage.isNotEmpty
                          ? NetworkImage(
                              'http://192.168.56.193/tutoring_app/uploads/$tutorProfileImage')
                          : AssetImage('images/default_profile.jpg')
                              as ImageProvider,
                    ),
                  ),
                  title: Text(request['sender']),
                  subtitle: Text(request['message']),
                  trailing: isAccepted
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                int requestId = int.parse(request['id']);
                                _respondToRequest(requestId, true, tutorName,
                                    tutorProfileImage);
                              },
                              child: Text('Accept'),
                            ),
                            TextButton(
                              onPressed: () {
                                int requestId = int.parse(request['id']);
                                _respondToRequest(requestId, false, tutorName,
                                    tutorProfileImage);
                              },
                              child: Text('Decline'),
                            ),
                          ],
                        ),
                );
              },
            ),
    );
  }
}
