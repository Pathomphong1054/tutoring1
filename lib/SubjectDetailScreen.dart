// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';
// import 'chat_screen.dart';
// import 'StudentProfileScreen.dart';
// import 'TutorProfileScreen.dart';

// class SubjectDetailScreen extends StatefulWidget {
//   final Map<String, dynamic> subject;
//   final String userName;
//   final String userRole;
//   final String profileImageUrl;

//   const SubjectDetailScreen({
//     Key? key,
//     required this.subject,
//     required this.userName,
//     required this.userRole,
//     required this.profileImageUrl,
//   }) : super(key: key);

//   @override
//   _SubjectDetailScreenState createState() => _SubjectDetailScreenState();
// }

// class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
//   List<dynamic> tutors = [];
//   bool isLoading = false;
//   final TextEditingController _postController = TextEditingController();
//   final TextEditingController _locationController = TextEditingController();
//   final TextEditingController _dateTimeController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _fetchTutorsBySubject();
//   }

//   Future<void> _fetchTutorsBySubject() async {
//     setState(() {
//       isLoading = true;
//     });

//     var url = Uri.parse(
//         'http://192.168.56.193/tutoring_app/fetch_tutors_by_subject.php?subject=${widget.subject['name']}');
//     try {
//       var response = await http.get(url);

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         setState(() {
//           tutors = data['tutors'];
//           _fetchAndFilterTutorsByLocation();
//         });
//       } else {
//         _showErrorSnackBar('Failed to load tutors');
//       }
//     } catch (e) {
//       _showErrorSnackBar('An error occurred while fetching tutors');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   Future<void> _checkLocationPermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return Future.error(
//           'Location permissions are permanently denied, we cannot request permissions.');
//     }

//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return Future.error(
//           'Location services are disabled. Please enable the services');
//     }
//   }

//   Future<Position> _getCurrentPosition() async {
//     await _checkLocationPermission();

//     return await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//   }

//   void _filterTutorsByLocation(Position currentPosition) {
//     setState(() {
//       tutors = tutors.where((tutor) {
//         final double tutorLatitude = double.tryParse(tutor['latitude']) ?? 0.0;
//         final double tutorLongitude =
//             double.tryParse(tutor['longitude']) ?? 0.0;

//         double distanceInMeters = Geolocator.distanceBetween(
//             currentPosition.latitude,
//             currentPosition.longitude,
//             tutorLatitude,
//             tutorLongitude);

//         return distanceInMeters <= 5000; // Filter tutors within 5 km radius
//       }).toList();
//     });
//   }

//   void _fetchAndFilterTutorsByLocation() async {
//     try {
//       Position position = await _getCurrentPosition();
//       _filterTutorsByLocation(position);
//     } catch (e) {
//       _showErrorSnackBar('Error getting location: $e');
//     }
//   }

//   Future<void> _postMessage() async {
//     String message = _postController.text.trim();
//     String location = _locationController.text.trim();
//     String dateTime = _dateTimeController.text.trim();

//     if (message.isNotEmpty && location.isNotEmpty && dateTime.isNotEmpty) {
//       var messageObject = {
//         'message': message,
//         'dateTime': dateTime,
//         'location': location,
//         'userName': widget.userName,
//         'profileImageUrl': widget.profileImageUrl,
//         'subject': widget.subject['name'],
//       };

//       print('Posting message: $messageObject');

//       var url =
//           Uri.parse('http://192.168.56.193/tutoring_app/post_message.php');
//       var response =
//           await http.post(url, body: json.encode(messageObject), headers: {
//         'Content-Type': 'application/json',
//       });

//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         try {
//           var responseData = json.decode(response.body);
//           if (responseData['status'] == 'success') {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Message posted successfully')),
//             );
//             _postController.clear();
//             _locationController.clear();
//             _dateTimeController.clear();
//           } else {
//             _showErrorSnackBar(
//                 'Failed to post message: ${responseData['message']}');
//           }
//         } catch (e) {
//           _showErrorSnackBar('An error occurred while parsing response');
//         }
//       } else {
//         _showErrorSnackBar('Failed to post message');
//       }
//     } else {
//       _showErrorSnackBar('Message, location, and date/time cannot be empty');
//     }
//   }

//   void _navigateToChatScreen(
//       String recipient, String recipientImage, String sessionId) {
//     if (sessionId.isEmpty) {
//       print('Error: sessionId is empty');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: sessionId is empty')),
//       );
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ChatScreen(
//           currentUser: widget.userName,
//           recipient: recipient,
//           recipientImage: recipientImage,
//           currentUserImage: widget.profileImageUrl,
//           sessionId: sessionId,
//           currentUserRole: widget.userRole,
//         ),
//       ),
//     );
//   }

//   void _viewProfile(String userName) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) {
//           if (widget.userRole == 'tutor') {
//             return StudentProfileScreen(
//               userName: userName,
//               onProfileUpdated: () {},
//             );
//           } else {
//             return TutorProfileScreen(
//               userName: userName,
//               userRole: 'tutor',
//               canEdit: false,
//               currentUser: widget.userName,
//               currentUserImage: widget.profileImageUrl,
//               onProfileUpdated: () {},
//               username: '',
//               profileImageUrl: '',
//               userId: '',
//               tutorId: '',
//             );
//           }
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.subject['name']),
//         backgroundColor: Colors.blue[800],
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.subject['description'],
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 20),
//                   Container(
//                     padding: const EdgeInsets.all(16.0),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Post a new message:',
//                           style: TextStyle(
//                               fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                         TextField(
//                           controller: _postController,
//                           decoration: InputDecoration(
//                             hintText: 'Enter your message',
//                           ),
//                           maxLines: 3,
//                         ),
//                         SizedBox(height: 10),
//                         TextField(
//                           controller: _locationController,
//                           decoration: InputDecoration(
//                             hintText: 'Enter location',
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         TextField(
//                           controller: _dateTimeController,
//                           decoration: InputDecoration(
//                             hintText: 'Enter date and time',
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         Center(
//                           child: ElevatedButton.icon(
//                             onPressed: _postMessage,
//                             icon: Icon(Icons.send),
//                             label: Text('Post Message'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     'Tutors for ${widget.subject['name']}:',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: NeverScrollableScrollPhysics(),
//                     itemCount: tutors.length,
//                     itemBuilder: (context, index) {
//                       final tutor = tutors[index];
//                       final name = tutor['name'] ?? 'No Name';
//                       final category = tutor['category'] ?? 'No Category';
//                       final subject = tutor['subject'] ?? 'No Subject';
//                       final profileImageUrl = tutor['profile_images'] != null &&
//                               tutor['profile_images'].isNotEmpty
//                           ? 'http://192.168.56.193/tutoring_app/uploads/' +
//                               tutor['profile_images']
//                           : 'images/default_profile.jpg';
//                       final username = tutor['name'] ?? 'No Username';

//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => TutorProfileScreen(
//                                 userName: username,
//                                 userRole: 'Tutor',
//                                 canEdit: false,
//                                 onProfileUpdated: () {},
//                                 currentUser: widget.userName,
//                                 currentUserImage: widget.profileImageUrl,
//                                 username: '',
//                                 profileImageUrl: '',
//                                 userId: '',
//                                 tutorId: '',
//                               ),
//                             ),
//                           );
//                         },
//                         child: Card(
//                           color: Colors.white.withOpacity(0.8),
//                           child: ListTile(
//                             leading: GestureDetector(
//                               onTap: () {
//                                 _viewProfile(username);
//                               },
//                               child: CircleAvatar(
//                                 backgroundImage:
//                                     profileImageUrl.contains('http')
//                                         ? NetworkImage(profileImageUrl)
//                                         : AssetImage(profileImageUrl)
//                                             as ImageProvider,
//                               ),
//                             ),
//                             title: Text(name,
//                                 style: TextStyle(
//                                     color: Colors.black, fontSize: 18)),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('Subjects: $subject',
//                                     style: TextStyle(
//                                         color: Colors.black, fontSize: 16)),
//                                 Text('Category: $category',
//                                     style: TextStyle(
//                                         color: Colors.black, fontSize: 16)),
//                               ],
//                             ),
//                             trailing: Icon(Icons.star, color: Colors.yellow),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
