import 'dart:convert';
import 'dart:io';
import 'package:apptutor_2/favoritestudent.dart';
import 'package:apptutor_2/favoritetutor.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:apptutor_2/TutoringScheduleScreen.dart';
import 'package:apptutor_2/ChatListScreen.dart';
import 'package:apptutor_2/StudentProfileScreen.dart';
import 'package:apptutor_2/StudentRequestsScreen.dart';
import 'package:apptutor_2/SubjectCategoryScreen.dart';
import 'package:apptutor_2/TutorProfileScreen.dart';
import 'package:apptutor_2/chat_screen.dart';
import 'package:apptutor_2/notification_screen.dart';
import 'package:apptutor_2/selection_screen.dart';

class HomePage2 extends StatefulWidget {
  final String userName;
  final String userRole;
  final String profileImageUrl;
  final String currentUserRole;
  final String idUser;

  const HomePage2({
    Key? key,
    required this.userName,
    required this.userRole,
    required this.profileImageUrl,
    required this.currentUserRole,
    required this.idUser,
  }) : super(key: key);

  @override
  _HomePage2State createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  List<dynamic> tutors = [];
  List<dynamic> topRatedTutors = [];
  List<dynamic> messages = [];
  bool isLoading = false;
  String? _profileImageUrl;
  String? _userName;
  String searchQuery = '';
  String tutorId = '';
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _profileImageUrl = widget.profileImageUrl;
    if (widget.userRole == 'student') {
      _fetchTutors();
    }
    _fetchProfileImage();
    _fetchMessages();
  }

  Future<void> _fetchTutors() async {
    _setLoadingState(true);
    var url = Uri.parse('http://192.168.56.193/tutoring_app/fetch_tutors.php');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            tutors = data['tutors'];
            _filterAndSortTutors();
          });
        } else {
          _showErrorSnackBar('Failed to load tutors');
        }
      } else {
        _showErrorSnackBar('Failed to load tutors');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred while fetching tutors');
    } finally {
      _setLoadingState(false);
    }
  }

  void _filterAndSortTutors() {
    setState(() {
      topRatedTutors = tutors.where((tutor) {
        final name = tutor['name'] ?? '';
        final subject = tutor['subject'] ?? '';
        final category = tutor['category'] ?? '';
        final topic = tutor['topic'] ?? '';
        final query = searchQuery.toLowerCase();
        final averageRatingStr = tutor['average_rating'] ?? '0';
        final averageRating = double.tryParse(averageRatingStr) ?? 0.0;

        return (name.toLowerCase().contains(query) ||
                subject.toLowerCase().contains(query) ||
                category.toLowerCase().contains(query) ||
                topic.toLowerCase().contains(query)) &&
            averageRating > 0;
      }).toList();

      topRatedTutors.sort((a, b) {
        final ratingA = double.tryParse(a['average_rating'] ?? '0') ?? 0.0;
        final ratingB = double.tryParse(b['average_rating'] ?? '0') ?? 0.0;
        return ratingB.compareTo(ratingA);
      });

      if (topRatedTutors.length > 10) {
        topRatedTutors = topRatedTutors.sublist(0, 10);
      }
    });
  }

  Future<void> _fetchProfileImage() async {
    var url = Uri.parse(
        'http://192.168.56.193/tutoring_app/get_user_profile.php?username=$_userName&role=${widget.userRole}');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _profileImageUrl = data['profile_image'];
            _userName = data['name'];
          });
        } else {
          _showErrorSnackBar(
              'Failed to load profile image: ${data['message']}');
        }
      } else {
        _showErrorSnackBar(
            'Failed to load profile image: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred while fetching profile image: $e');
    }
  }

  Future<void> _fetchMessages() async {
    _setLoadingState(true);
    var url =
        Uri.parse('http://192.168.56.193/tutoring_app/fetch_messages.php');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          messages = data['messages'];
        });
      } else {
        _showErrorSnackBar('Failed to load messages');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred while fetching messages');
    } finally {
      _setLoadingState(false);
    }
  }

  Future<void> _postMessage() async {
    String message = _postController.text.trim();
    String location = _locationController.text.trim();
    String dateTime = _dateTimeController.text.trim();

    if (message.isNotEmpty && location.isNotEmpty && dateTime.isNotEmpty) {
      var messageObject = {
        'message': message,
        'dateTime': dateTime,
        'location': location,
        'userName': widget.userName,
        'profileImageUrl': widget.profileImageUrl,
        'subject': 'N/A',
      };

      print('Posting message: $messageObject');

      var url =
          Uri.parse('http://192.168.56.193/tutoring_app/post_message.php');
      var response =
          await http.post(url, body: json.encode(messageObject), headers: {
        'Content-Type': 'application/json',
      });

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Message posted successfully')),
          );
          _postController.clear();
          _locationController.clear();
          _dateTimeController.clear();
          _fetchMessages();
        } else {
          _showErrorSnackBar(
              'Failed to post message: ${responseData['message']}');
        }
      } else {
        _showErrorSnackBar('Failed to post message');
      }
    } else {
      _showErrorSnackBar('Message, location, and date/time cannot be empty');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
          currentUserImage: widget.profileImageUrl,
          sessionId: sessionId,
          currentUserRole: widget.userRole,
        ),
      ),
    );
  }

  Future<void> _sendRequest(String recipient, String recipientImage) async {
    var response = await http.post(
      Uri.parse('http://192.168.56.193/tutoring_app/send_request.php'),
      body: json.encode({
        'sender': widget.userName,
        'recipient': recipient,
        'message': 'คุณมีคำขอติวใหม่',
        'role': widget.userRole,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      var responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('คำขอถูกส่งเรียบร้อย')),
        );
      } else {
        _showErrorSnackBar('ส่งคำขอไม่สำเร็จ: ${responseData['message']}');
      }
    } else {
      _showErrorSnackBar('ส่งคำขอไม่สำเร็จ');
    }
  }

  void _onProfileUpdated() {
    _fetchProfileImage();
  }

  void _viewProfile(String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widget.userRole == 'student'
            ? TutorProfileScreen(
                userName: userName,
                onProfileUpdated: _onProfileUpdated,
                canEdit: false,
                userRole: 'tutor',
                currentUser: widget.userName,
                currentUserImage: widget.profileImageUrl,
                username: '',
                profileImageUrl: '',
                userId: widget.idUser,
                tutorId: tutorId,
              )
            : StudentProfileScreen(
                userName: userName,
                onProfileUpdated: _onProfileUpdated,
              ),
      ),
    );
  }

  void _setLoadingState(bool state) {
    setState(() {
      isLoading = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.blue[800],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchField(),
            _buildCommonSection(),
            widget.userRole == 'student'
                ? _buildStudentBody()
                : _buildTutorBody(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: _userName != null && _userName!.isNotEmpty
                ? Text(_userName!, style: TextStyle(fontSize: 20))
                : Text('User', style: TextStyle(fontSize: 20)),
            accountEmail: Text(widget.userRole, style: TextStyle(fontSize: 16)),
            currentAccountPicture: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => widget.userRole == 'student'
                        ? StudentProfileScreen(
                            userName: _userName!,
                            onProfileUpdated: _onProfileUpdated,
                          )
                        : TutorProfileScreen(
                            userName: _userName!,
                            onProfileUpdated: _onProfileUpdated,
                            canEdit: true,
                            userRole: 'tutor',
                            currentUser: widget.userName,
                            currentUserImage: widget.profileImageUrl,
                            username: '',
                            profileImageUrl: '',
                            userId: widget.idUser,
                            tutorId: tutorId,
                          ),
                  ),
                );
                _onProfileUpdated();
              },
              child: CircleAvatar(
                backgroundImage: _profileImageUrl != null &&
                        _profileImageUrl!.isNotEmpty
                    ? NetworkImage(
                        'http://192.168.56.193/tutoring_app/uploads/$_profileImageUrl')
                    : AssetImage('images/default_profile.jpg') as ImageProvider,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue[800],
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings', style: TextStyle(fontSize: 18)),
            onTap: () {},
          ),
          if (widget.userRole == 'tutor')
            ListTile(
              leading: Icon(Icons.class_),
              title: Text('My Class', style: TextStyle(fontSize: 18)),
              onTap: () {},
            ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log Out', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SelectionScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.blue),
          hintText: 'Search by name, subject, category, or topic',
          hintStyle: TextStyle(fontSize: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (query) {
          setState(() {
            searchQuery = query;
            _filterAndSortTutors();
          });
        },
      ),
    );
  }

  Widget _buildCommonSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Subject Categories',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryIcon(Icons.language, 'Language', Colors.red),
              _buildCategoryIcon(Icons.calculate, 'Mathematics', Colors.green),
              _buildCategoryIcon(Icons.science, 'Science', Colors.blue),
              _buildCategoryIcon(
                  Icons.computer, 'Computer Science', Colors.orange),
              _buildCategoryIcon(Icons.business, 'Business', Colors.purple),
              _buildCategoryIcon(Icons.art_track, 'Arts', Colors.pink),
              _buildCategoryIcon(
                  Icons.sports, 'Physical Education', Colors.teal),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectCategoryScreen(
              category: label,
              userName: widget.userName,
              userRole: widget.userRole,
              profileImageUrl: widget.profileImageUrl,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 40, color: color),
              radius: 40,
            ),
            SizedBox(height: 5),
            Text(label, style: TextStyle(color: Colors.black, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Recommended Tutors',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        SizedBox(height: 10),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: topRatedTutors.length,
                itemBuilder: (context, index) {
                  final tutor = topRatedTutors[index];
                  final name = tutor['name'] ?? 'No Name';
                  final category = tutor['category'] ?? 'No Category';
                  final subject = tutor['subject'] ?? 'No Subject';
                  final profileImageUrl = tutor['profile_images'] != null &&
                          tutor['profile_images'].isNotEmpty
                      ? 'http://192.168.56.193/tutoring_app/uploads/' +
                          tutor['profile_images']
                      : 'images/default_profile.jpg';
                  final username = tutor['name'] ?? 'No Username';
                  final averageRatingStr = tutor['average_rating'] ?? '0';
                  final averageRating =
                      double.tryParse(averageRatingStr) ?? 0.0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TutorProfileScreen(
                            userName: username,
                            userRole: 'Tutor',
                            canEdit: false,
                            onProfileUpdated: () {},
                            currentUser: widget.userName,
                            currentUserImage: widget.profileImageUrl,
                            username: '',
                            profileImageUrl: '',
                            userId: widget.idUser,
                            tutorId: tutor['id'].toString(),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.white.withOpacity(0.8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: profileImageUrl.contains('http')
                              ? NetworkImage(profileImageUrl)
                              : AssetImage(profileImageUrl) as ImageProvider,
                        ),
                        title: Text(name,
                            style:
                                TextStyle(color: Colors.black, fontSize: 18)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Subjects: $subject',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16)),
                            Text('Category: $category',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16)),
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < averageRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.yellow,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
      ],
    );
  }

  Widget _buildTutorBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Welcome, ${_userName}!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Text(
            'You are logged in as a ${widget.userRole}.',
            style: TextStyle(fontSize: 18, color: Colors.blue[800]),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 20),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final userName = message['userName'] ?? '';
                  final userImageUrl = message['profileImageUrl'] != null &&
                          message['profileImageUrl'].isNotEmpty
                      ? 'http://192.168.56.193/tutoring_app/uploads/' +
                          message['profileImageUrl']
                      : 'images/default_profile.jpg';
                  final messageText = message['message'] ?? '';
                  final location = message['location'] ?? '';
                  final subject = message['subject'] ?? '';
                  final dateTime = message['dateTime'] ?? '';
                  final sessionId = message['session_id'] ?? '';

                  return GestureDetector(
                    onTap: () {
                      _viewProfile(userName);
                    },
                    child: _buildMessageCard(
                      userName,
                      userImageUrl,
                      messageText,
                      location,
                      subject,
                      dateTime,
                      sessionId,
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildMessageCard(
      String userName,
      String userImageUrl,
      String messageText,
      String location,
      String subject,
      String dateTime,
      String sessionId) {
    return Card(
      color: Colors.white.withOpacity(0.8),
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: () {
                  _viewProfile(userName);
                },
                child: CircleAvatar(
                  backgroundImage: userImageUrl.contains('http')
                      ? NetworkImage(userImageUrl)
                      : AssetImage(userImageUrl) as ImageProvider,
                  radius: 30,
                ),
              ),
              title: Text(userName,
                  style: TextStyle(color: Colors.black, fontSize: 18)),
              subtitle: Text(messageText,
                  style: TextStyle(color: Colors.black, fontSize: 16)),
            ),
            SizedBox(height: 8.0),
            Divider(color: Colors.grey),
            SizedBox(height: 8.0),
            Text('Location: $location',
                style: TextStyle(color: Colors.black, fontSize: 14)),
            Text('Subject: $subject',
                style: TextStyle(color: Colors.black, fontSize: 14)),
            Text('Date and Time: $dateTime',
                style: TextStyle(color: Colors.black, fontSize: 14)),
            SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  _sendRequest(userName, userImageUrl);
                },
                icon: Icon(Icons.send),
                label: Text('Send Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.blue), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.green), label: 'Chat'),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: Colors.red), label: 'Favorites'),
        BottomNavigationBarItem(
            icon: Icon(Icons.request_page, color: Colors.orange),
            label: 'Requests'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications, color: Colors.red),
            label: 'Notifications'),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatListScreen(
                  currentUser: widget.userName,
                  currentUserImage: widget.profileImageUrl,
                  currentUserRole: widget.userRole,
                ),
              ),
            );
            break;
          case 2:
            if (widget.userRole == 'student') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteTutorsScreen(
                    currentUser: widget.userName,
                    userId: widget.idUser,
                    currentUserImage: '',
                  ),
                ),
              );
            } else if (widget.userRole == 'tutor') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteStudentScreen(
                    currentUser: widget.userName,
                    userId: widget.idUser,
                    currentUserImage: '',
                  ),
                ),
              );
            }
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentRequestsScreen(
                  userName: widget.userName,
                  userRole: widget.userRole,
                ),
              ),
            );
            break;
          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationScreen(
                  userName: widget.userName,
                  userRole: widget.userRole,
                ),
              ),
            );

            break;
        }
      },
    );
  }
}
