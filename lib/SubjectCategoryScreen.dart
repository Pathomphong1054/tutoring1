import 'package:flutter/material.dart';
import 'SubjectDetailScreen.dart';

class SubjectCategoryScreen extends StatelessWidget {
  final String category;
  final String userName;
  final String userRole;
  final String profileImageUrl;

  const SubjectCategoryScreen({
    Key? key,
    required this.category,
    required this.userName,
    required this.userRole,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> subjects = _getSubjectsByCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Text('$category Subjects'),
        backgroundColor: Colors.blue[800],
      ),
      body: ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return ListTile(
            leading: Icon(subject['icon'], color: Colors.blue),
            title: Text(subject['name']),
            // onTap: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => SubjectDetailScreen(
            //         subject: subject,
            //         userName: userName,
            //         userRole: userRole,
            //         profileImageUrl: profileImageUrl,
            //       ),
            //     ),
            //   );
            // },
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getSubjectsByCategory(String category) {
    switch (category) {
      case 'Language':
        return [
          {
            'name': 'Thai',
            'icon': Icons.language,
            'description': 'Thai language details',
          },
          {
            'name': 'English',
            'icon': Icons.language,
            'description': 'English language details',
          },
          {
            'name': 'Chinese',
            'icon': Icons.language,
            'description': 'Chinese language details',
          },
          {
            'name': 'French',
            'icon': Icons.language,
            'description': 'French language details',
          },
          {
            'name': 'German',
            'icon': Icons.language,
            'description': 'German language details',
          },
          {
            'name': 'Japanese',
            'icon': Icons.language,
            'description': 'Japanese language details',
          },
          {
            'name': 'Korean',
            'icon': Icons.language,
            'description': 'Korean language details',
          },
        ];
      case 'Mathematics':
        return [
          {
            'name': 'Algebra',
            'icon': Icons.calculate,
            'description': 'Algebra details',
          },
          {
            'name': 'Geometry',
            'icon': Icons.calculate,
            'description': 'Geometry details',
          },
          {
            'name': 'Calculus',
            'icon': Icons.calculate,
            'description': 'Calculus details',
          },
          {
            'name': 'Statistics',
            'icon': Icons.calculate,
            'description': 'Statistics details',
          },
        ];
      case 'Science':
        return [
          {
            'name': 'Physics',
            'icon': Icons.science,
            'description': 'Physics details',
          },
          {
            'name': 'Chemistry',
            'icon': Icons.biotech,
            'description': 'Chemistry details',
          },
          {
            'name': 'Biology',
            'icon': Icons.eco,
            'description': 'Biology details',
          },
          {
            'name': 'Environmental Science',
            'icon': Icons.eco,
            'description': 'Environmental Science details',
          },
          {
            'name': 'Earth Science',
            'icon': Icons.public,
            'description': 'Earth Science details',
          },
          {
            'name': 'Astronomy',
            'icon': Icons.star,
            'description': 'Astronomy details',
          },
        ];
      case 'Computer Science':
        return [
          {
            'name': 'Programming',
            'icon': Icons.computer,
            'description': 'Programming details',
          },
          {
            'name': 'Data Structures',
            'icon': Icons.storage,
            'description': 'Data Structures details',
          },
          {
            'name': 'Networking',
            'icon': Icons.code,
            'description': 'Networking details',
          },
          {
            'name': 'Algorithms',
            'icon': Icons.code,
            'description': 'Algorithms details',
          },
          {
            'name': 'Operating Systems',
            'icon': Icons.memory,
            'description': 'Operating Systems details',
          },
          {
            'name': 'Databases',
            'icon': Icons.storage,
            'description': 'Databases details',
          },
          {
            'name': 'Artificial Intelligence',
            'icon': Icons.smart_toy,
            'description': 'Artificial Intelligence details',
          },
        ];
      case 'Business':
        return [
          {
            'name': 'Economics',
            'icon': Icons.business,
            'description': 'Economics details',
          },
          {
            'name': 'Finance',
            'icon': Icons.account_balance,
            'description': 'Finance details',
          },
          {
            'name': 'Marketing',
            'icon': Icons.campaign,
            'description': 'Marketing details',
          },
          {
            'name': 'Management',
            'icon': Icons.manage_accounts,
            'description': 'Management details',
          },
          {
            'name': 'Accounting',
            'icon': Icons.receipt_long,
            'description': 'Accounting details',
          },
        ];
      case 'Arts':
        return [
          {
            'name': 'Drawing',
            'icon': Icons.brush,
            'description': 'Drawing details',
          },
          {
            'name': 'Painting',
            'icon': Icons.color_lens,
            'description': 'Painting details',
          },
          {
            'name': 'Music',
            'icon': Icons.music_note,
            'description': 'Music details',
          },
          {
            'name': 'Dance',
            'icon': Icons.accessibility_new,
            'description': 'Dance details',
          },
          {
            'name': 'Drama',
            'icon': Icons.theater_comedy,
            'description': 'Drama details',
          },
        ];
      case 'Physical Education':
        return [
          {
            'name': 'Sports',
            'icon': Icons.sports_basketball,
            'description': 'Sports details',
          },
          {
            'name': 'Health',
            'icon': Icons.health_and_safety,
            'description': 'Health details',
          },
          {
            'name': 'Fitness',
            'icon': Icons.fitness_center,
            'description': 'Fitness details',
          },
          {
            'name': 'Yoga',
            'icon': Icons.self_improvement,
            'description': 'Yoga details',
          },
          {
            'name': 'Martial Arts',
            'icon': Icons.sports_mma,
            'description': 'Martial Arts details',
          },
        ];
      default:
        return [];
    }
  }
}
