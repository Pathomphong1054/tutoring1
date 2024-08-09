import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apptutor_2/StudentProfileScreen.dart';

class FavoriteStudentScreen extends StatefulWidget {
  final String userId;
  final String currentUser;
  final String currentUserImage;

  const FavoriteStudentScreen({
    required this.currentUser,
    required this.userId,
    required this.currentUserImage,
  });

  @override
  _FavoriteStudentScreenState createState() => _FavoriteStudentScreenState();
}

class _FavoriteStudentScreenState extends State<FavoriteStudentScreen> {
  List<Map<String, dynamic>> _favoriteStudents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStudents();
  }

  Future<void> _loadFavoriteStudents() async {
    final url =
        'http://192.168.56.193/tutoring_app/get_favorite_student.php?tutor_id=${widget.userId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _favoriteStudents =
              data.map((item) => item as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load favorite students';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to load favorite students';
        _isLoading = false;
      });
    }
  }

  void _viewStudentProfile(Map<String, dynamic> student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileScreen(
          userName: student['name'],
          onProfileUpdated: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Students'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _favoriteStudents.isNotEmpty
                  ? ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      itemCount: _favoriteStudents.length,
                      itemBuilder: (context, index) {
                        final student = _favoriteStudents[index];
                        final profileImageUrl = student['profile_images'] !=
                                    null &&
                                student['profile_images'].isNotEmpty
                            ? 'http://192.168.56.193/tutoring_app/uploads/' +
                                student['profile_images']
                            : 'images/default_profile.jpg';

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: profileImageUrl.contains('http')
                                  ? NetworkImage(profileImageUrl)
                                  : AssetImage(profileImageUrl)
                                      as ImageProvider,
                            ),
                            title: Text(student['name'] ?? 'Unknown'),
                            onTap: () => _viewStudentProfile(student),
                          ),
                        );
                      },
                    )
                  : Center(child: Text('No favorite students found')),
    );
  }
}
