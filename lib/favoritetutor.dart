import 'package:apptutor_2/TutorProfileScreen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FavoriteTutorsScreen extends StatefulWidget {
  final String userId;
  final String currentUser;
  final String currentUserImage;

  const FavoriteTutorsScreen(
      {required this.currentUser,
      required this.userId,
      required this.currentUserImage});

  @override
  _FavoriteTutorsScreenState createState() => _FavoriteTutorsScreenState();
}

class _FavoriteTutorsScreenState extends State<FavoriteTutorsScreen> {
  List<Map<String, dynamic>> _favoriteTutors = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavoriteTutors();
  }

  Future<void> _loadFavoriteTutors() async {
    final url =
        'http://192.168.56.193/tutoring_app/get_favorite_tutors.php?student_id=${widget.userId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _favoriteTutors =
              data.map((item) => item as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load favorite tutors';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to load favorite tutors';
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Tutors'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _favoriteTutors.isNotEmpty
                  ? ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      itemCount: _favoriteTutors.length,
                      itemBuilder: (context, index) {
                        final tutor = _favoriteTutors[index];
                        final id = tutor['id']?.toString() ?? 'No ID';
                        final profileImageUrl = tutor['profile_images'] !=
                                    null &&
                                tutor['profile_images'].isNotEmpty
                            ? 'http://192.168.56.193/tutoring_app/uploads/' +
                                tutor['profile_images']
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
                            title: Text(tutor['name'] ?? 'Unknown'),
                            subtitle: Text(
                                '${tutor['category'] ?? 'No category'} - ${tutor['subject'] ?? 'No subject'}'),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                // Implement favorite toggle functionality
                              },
                            ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TutorProfileScreen(
                                    userId: widget.userId,
                                    tutorId: id,
                                    userName: tutor['name'] ?? 'Unknown',
                                    userRole: 'Tutor',
                                    canEdit: false,
                                    onProfileUpdated: () {},
                                    currentUser: widget.currentUser,
                                    currentUserImage: widget.currentUserImage,
                                    username: tutor['name'] ?? '',
                                    profileImageUrl:
                                        tutor['profile_images'] ?? '',
                                  ),
                                ),
                              );
                              // Refresh data when coming back
                              _loadFavoriteTutors();
                            },
                          ),
                        );
                      },
                    )
                  : Center(child: Text('No favorite tutors found')),
    );
  }
}
