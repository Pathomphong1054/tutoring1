import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../home_pagetutor.dart';

class TutorRegistrationScreen extends StatefulWidget {
  @override
  _TutorRegistrationScreenState createState() =>
      _TutorRegistrationScreenState();
}

class _TutorRegistrationScreenState extends State<TutorRegistrationScreen> {
  late String userName = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _selectedCategory = 'Language';
  String? _selectedSubject;
  String? _selectedTopic;
  String _selectedProvince = 'Bangkok';
  File? _profileImage;
  File? _resumeFile;

  final Map<String, List<String>> subjectsByCategory = {
    'Language': [
      'English',
      'Thai',
      'Chinese',
      'Japanese',
      'French',
      'German',
      'Korean'
    ],
    'Math': ['Algebra', 'Geometry', 'Calculus', 'Statistics'],
    'Science': [
      'Physics',
      'Chemistry',
      'Biology',
      'Astronomy',
      'Environmental Science',
      'Earth Science'
    ],
    'Computer': ['Programming', 'Data Science', 'Networking', 'AI'],
    'Business': [
      'Economics',
      'Finance',
      'Marketing',
      'Management',
      'Accounting'
    ],
    'Arts': ['Drawing', 'Painting', 'Music', 'Dance', 'Drama'],
    'Physical Education': [
      'Sports',
      'Health',
      'Fitness',
      'Yoga',
      'Martial Arts'
    ],
  };

  final Map<String, List<String>> topicsBySubject = {
    'English': ['Grammar', 'Vocabulary', 'Speaking', 'Writing'],
    'Thai': ['Grammar', 'Vocabulary', 'Speaking', 'Writing'],
    'Chinese': ['Grammar', 'Vocabulary', 'Speaking', 'Writing'],
    'Japanese': ['Grammar', 'Vocabulary', 'Speaking', 'Writing'],
    'French': ['Grammar', 'Vocabulary', 'Speaking', 'Writing'],
    'German': ['Grammar', 'Vocabulary', 'Speaking', 'Writing'],
    'Korean': ['Grammar', 'Vocabulary', 'Speaking', 'Writing'],
    'Algebra': ['Equations', 'Inequalities', 'Polynomials', 'Functions'],
    'Geometry': ['Triangles', 'Circles', 'Polygons', 'Solid Geometry'],
    'Calculus': ['Limits', 'Derivatives', 'Integrals', 'Series'],
    'Statistics': [
      'Probability',
      'Distributions',
      'Hypothesis Testing',
      'Regression'
    ],
    'Physics': ['Mechanics', 'Thermodynamics', 'Electromagnetism', 'Optics'],
    'Chemistry': ['Organic', 'Inorganic', 'Physical', 'Analytical'],
    'Biology': ['Genetics', 'Evolution', 'Ecology', 'Anatomy'],
    'Astronomy': ['Planets', 'Stars', 'Galaxies', 'Cosmology'],
    'Environmental Science': ['Ecosystems', 'Pollution', 'Conservation'],
    'Earth Science': ['Geology', 'Meteorology', 'Oceanography', 'Astronomy'],
    'Programming': [
      'Syntax',
      'Data Structures',
      'Algorithms',
      'Debugging',
      'Python',
      'Java',
      'C++',
      'JavaScript'
    ],
    'Data Science': [
      'Data Analysis',
      'Machine Learning',
      'Big Data',
      'Data Visualization'
    ],
    'Networking': [
      'TCP/IP',
      'Network Security',
      'Wireless Networks',
      'Network Administration'
    ],
    'AI': [
      'Machine Learning',
      'Neural Networks',
      'Robotics',
      'Natural Language Processing'
    ],
    'Economics': [
      'Microeconomics',
      'Macroeconomics',
      'Market Structures',
      'Economic Policies'
    ],
    'Finance': [
      'Financial Markets',
      'Investment',
      'Corporate Finance',
      'Risk Management'
    ],
    'Marketing': [
      'Market Research',
      'Consumer Behavior',
      'Brand Management',
      'Digital Marketing'
    ],
    'Management': [
      'Leadership',
      'Strategic Planning',
      'Human Resources',
      'Operations'
    ],
    'Accounting': [
      'Financial Accounting',
      'Managerial Accounting',
      'Auditing',
      'Taxation'
    ],
    'Drawing': ['Techniques', 'Materials', 'Styles', 'Anatomy'],
    'Painting': ['Techniques', 'Materials', 'Styles', 'Color Theory'],
    'Music': ['Theory', 'Composition', 'Instruments', 'History'],
    'Dance': ['Techniques', 'Styles', 'Choreography', 'History'],
    'Drama': ['Acting', 'Directing', 'Playwriting', 'History'],
    'Sports': ['Rules', 'Techniques', 'Training', 'History'],
    'Health': ['Nutrition', 'Exercise', 'Mental Health', 'Wellness'],
    'Fitness': [
      'Exercise Programs',
      'Strength Training',
      'Cardio',
      'Flexibility'
    ],
    'Yoga': ['Poses', 'Breathing Techniques', 'Meditation', 'Philosophy'],
    'Martial Arts': ['Techniques', 'Styles', 'Training', 'History'],
  };

  Future<void> registerTutor(BuildContext context) async {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;
    final String category = _selectedCategory!;
    final String subject = _selectedSubject!;
    final String topic = _selectedTopic!;
    final String address = _selectedProvince;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.56.193/tutoring_app/register_tutor.php'),
    );
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['category'] = category;
    request.fields['subject'] = subject;
    request.fields['topic'] = topic;
    request.fields['address'] = address;

    if (_profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image',
          _profileImage!.path,
        ),
      );
    }

    if (_resumeFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'resume',
          _resumeFile!.path,
        ),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      print('Raw response: $responseBody');
      try {
        final responseData = json.decode(responseBody);
        if (responseData['status'] == 'success') {
          setState(() {
            userName = name;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage2(
                userName: userName,
                userRole: 'Tutor',
                profileImageUrl: responseData['profile_image'] != null
                    ? 'http://192.168.56.193/tutoring_app/uploads/' +
                        responseData['profile_image']
                    : 'images/default_profile.jpg',
                currentUserRole: 'Tutor',
                idUser: '',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
        }
      } catch (e) {
        print('Error decoding JSON: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing response')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickResume() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _resumeFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutor Registration'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Text(
                        'Fill in the details to register as a tutor:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : AssetImage('images/default_profile.jpg')
                                    as ImageProvider,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.blue[800],
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                            _selectedSubject = null;
                            _selectedTopic = null;
                          });
                        },
                        items: subjectsByCategory.keys
                            .map<DropdownMenuItem<String>>((dynamic value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedSubject,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedSubject = newValue;
                            _selectedTopic = null;
                          });
                        },
                        items: (_selectedCategory != null
                                ? subjectsByCategory[_selectedCategory]
                                : [])!
                            .map<DropdownMenuItem<String>>((dynamic value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.book),
                        ),
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedTopic,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedTopic = newValue;
                          });
                        },
                        items: (_selectedSubject != null
                                ? topicsBySubject[_selectedSubject]
                                : [])!
                            .map<DropdownMenuItem<String>>((dynamic value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Topic',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.topic),
                        ),
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedProvince,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedProvince = newValue!;
                          });
                        },
                        items: <String>[
                          'Bangkok',
                          'Krabi',
                          'Kanchanaburi',
                          'Kalasin',
                          'Kamphaeng Phet',
                          'Khon Kaen',
                          'Chanthaburi',
                          'Chachoengsao',
                          'Chon Buri',
                          'Chai Nat',
                          'Chaiyaphum',
                          'Chumphon',
                          'Chiang Mai',
                          'Chiang Rai',
                          'Trang',
                          'Trat',
                          'Tak',
                          'Nakhon Nayok',
                          'Nakhon Pathom',
                          'Nakhon Phanom',
                          'Nakhon Ratchasima',
                          'Nakhon Si Thammarat',
                          'Nakhon Sawan',
                          'Nonthaburi',
                          'Narathiwat',
                          'Nan',
                          'Bueng Kan',
                          'Buriram',
                          'Pathum Thani',
                          'Prachuap Khiri Khan',
                          'Prachinburi',
                          'Pattani',
                          'Phra Nakhon Si Ayutthaya',
                          'Phang Nga',
                          'Phatthalung',
                          'Phichit',
                          'Phitsanulok',
                          'Phetchaburi',
                          'Phetchabun',
                          'Phuket',
                          'Maha Sarakham',
                          'Mukdahan',
                          'Mae Hong Son',
                          'Yasothon',
                          'Yala',
                          'Roi Et',
                          'Ranong',
                          'Rayong',
                          'Lopburi',
                          'Lampang',
                          'Lamphun',
                          'Loei',
                          'Si Sa Ket',
                          'Sakon Nakhon',
                          'Songkhla',
                          'Satun',
                          'Samut Prakan',
                          'Samut Sakhon',
                          'Samut Songkhram',
                          'Saraburi',
                          'Sing Buri',
                          'Sukhothai',
                          'Suphan Buri',
                          'Surat Thani',
                          'Surin',
                          'Nong Khai',
                          'Nong Bua Lamphu',
                          'Amnat Charoen',
                          'Udon Thani',
                          'Uttaradit',
                          'Uthai Thani',
                          'Ubon Ratchathani',
                        ].map<DropdownMenuItem<String>>((dynamic value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Province',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_city),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _pickResume,
                          child: Text('Upload Resume'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => registerTutor(context),
                          child: Text('Register as Tutor'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
