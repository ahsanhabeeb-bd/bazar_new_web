import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PipilikaRegistration extends StatefulWidget {
  const PipilikaRegistration({super.key});

  @override
  State<PipilikaRegistration> createState() => _PipilikaRegistrationState();
}

class _PipilikaRegistrationState extends State<PipilikaRegistration> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _name = TextEditingController();
  final _father = TextEditingController();
  final _mother = TextEditingController();
  final _dob = TextEditingController();
  final _pin = TextEditingController();
  final _address = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _guardianPhone = TextEditingController();
  final _myPhone = TextEditingController();
  final _nomineeName = TextEditingController();
  final _nomineeRelation = TextEditingController();

  String _gender = "Male";
  String _country = "Bangladesh";

  Uint8List? _profilePic;
  Uint8List? _nidPic;
  bool _isLoading = false;
  final _referralId = TextEditingController();

  // 🌍 Country List
  final List<String> _countries = [
    "Afghanistan",
    "Albania",
    "Algeria",
    "Andorra",
    "Angola",
    "Argentina",
    "Armenia",
    "Australia",
    "Austria",
    "Azerbaijan",
    "Bahamas",
    "Bahrain",
    "Bangladesh",
    "Barbados",
    "Belarus",
    "Belgium",
    "Belize",
    "Benin",
    "Bhutan",
    "Bolivia",
    "Bosnia and Herzegovina",
    "Botswana",
    "Brazil",
    "Brunei",
    "Bulgaria",
    "Burkina Faso",
    "Burundi",
    "Cambodia",
    "Cameroon",
    "Canada",
    "Cape Verde",
    "Central African Republic",
    "Chad",
    "Chile",
    "China",
    "Colombia",
    "Comoros",
    "Congo",
    "Costa Rica",
    "Croatia",
    "Cuba",
    "Cyprus",
    "Czech Republic",
    "Denmark",
    "Djibouti",
    "Dominica",
    "Dominican Republic",
    "Ecuador",
    "Egypt",
    "El Salvador",
    "Equatorial Guinea",
    "Eritrea",
    "Estonia",
    "Eswatini",
    "Ethiopia",
    "Fiji",
    "Finland",
    "France",
    "Gabon",
    "Gambia",
    "Georgia",
    "Germany",
    "Ghana",
    "Greece",
    "Grenada",
    "Guatemala",
    "Guinea",
    "Guinea-Bissau",
    "Guyana",
    "Haiti",
    "Honduras",
    "Hungary",
    "Iceland",
    "India",
    "Indonesia",
    "Iran",
    "Iraq",
    "Ireland",
    "Israel",
    "Italy",
    "Jamaica",
    "Japan",
    "Jordan",
    "Kazakhstan",
    "Kenya",
    "Kiribati",
    "Kuwait",
    "Kyrgyzstan",
    "Laos",
    "Latvia",
    "Lebanon",
    "Lesotho",
    "Liberia",
    "Libya",
    "Liechtenstein",
    "Lithuania",
    "Luxembourg",
    "Madagascar",
    "Malawi",
    "Malaysia",
    "Maldives",
    "Mali",
    "Malta",
    "Marshall Islands",
    "Mauritania",
    "Mauritius",
    "Mexico",
    "Micronesia",
    "Moldova",
    "Monaco",
    "Mongolia",
    "Montenegro",
    "Morocco",
    "Mozambique",
    "Myanmar",
    "Namibia",
    "Nauru",
    "Nepal",
    "Netherlands",
    "New Zealand",
    "Nicaragua",
    "Niger",
    "Nigeria",
    "North Korea",
    "North Macedonia",
    "Norway",
    "Oman",
    "Pakistan",
    "Palau",
    "Panama",
    "Papua New Guinea",
    "Paraguay",
    "Peru",
    "Philippines",
    "Poland",
    "Portugal",
    "Qatar",
    "Romania",
    "Russia",
    "Rwanda",
    "Saint Kitts and Nevis",
    "Saint Lucia",
    "Saint Vincent",
    "Samoa",
    "San Marino",
    "Sao Tome and Principe",
    "Saudi Arabia",
    "Senegal",
    "Serbia",
    "Seychelles",
    "Sierra Leone",
    "Singapore",
    "Slovakia",
    "Slovenia",
    "Solomon Islands",
    "Somalia",
    "South Africa",
    "South Korea",
    "South Sudan",
    "Spain",
    "Sri Lanka",
    "Sudan",
    "Suriname",
    "Sweden",
    "Switzerland",
    "Syria",
    "Taiwan",
    "Tajikistan",
    "Tanzania",
    "Thailand",
    "Timor-Leste",
    "Togo",
    "Tonga",
    "Trinidad and Tobago",
    "Tunisia",
    "Turkey",
    "Turkmenistan",
    "Tuvalu",
    "Uganda",
    "Ukraine",
    "United Arab Emirates",
    "United Kingdom",
    "United States",
    "Uruguay",
    "Uzbekistan",
    "Vanuatu",
    "Vatican City",
    "Venezuela",
    "Vietnam",
    "Yemen",
    "Zambia",
    "Zimbabwe",
  ];

  Future<void> _pickImage(String type) async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          if (type == "profile") _profilePic = result.files.first.bytes;
          if (type == "nid") _nidPic = result.files.first.bytes;
        });
      }
    } else {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        Uint8List img = await pickedFile.readAsBytes();
        setState(() {
          if (type == "profile") _profilePic = img;
          if (type == "nid") _nidPic = img;
        });
      }
    }
  }

  Future<String?> _uploadToStorage(Uint8List? file, String path) async {
    if (file == null) return null;
    final ref = FirebaseStorage.instance.ref().child(path);
    final snapshot = await ref.putData(file);
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_profilePic == null || _nidPic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile picture and NID image are required."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final referredBy = _referralId.text.trim();
      int level = 1;

      if (referredBy.isNotEmpty) {
        // ✅ রেফার UID টি ডেটাবেজে আছে কিনা যাচাই করুন
        final refDoc =
            await FirebaseFirestore.instance
                .collection("pipilikas")
                .doc(referredBy)
                .get();

        if (!refDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid referral ID. Please enter a valid UID."),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
        level = (refDoc.data()?['level'] ?? 0) + 1;
      }

      // ✅ UID এবং loginId তৈরি করুন
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final uid = timestamp.substring(0, 8);
      final loginId = timestamp.substring(timestamp.length - 8);

      final profileUrl = await _uploadToStorage(
        _profilePic,
        "pipilikas/$uid/profile.jpg",
      );
      final nidUrl = await _uploadToStorage(_nidPic, "pipilikas/$uid/nid.jpg");

      final data = {
        "id": uid,
        "loginId": loginId,
        "name": _name.text,
        "fatherName": _father.text,
        "motherName": _mother.text,
        "dob": _dob.text,
        "gender": _gender,
        "country": _country,
        "pinCode": _pin.text,
        "address": _address.text,
        "email": _email.text,
        "password": _password.text,
        "guardianPhone": _guardianPhone.text,
        "phone": _myPhone.text,
        "profilePicture": profileUrl,
        "nidPicture": nidUrl,
        "nomineeName": _nomineeName.text,
        "nomineeRelation": _nomineeRelation.text,
        "status": "pending",
        "role": "pipilika",
        "referredBy": referredBy,
        "downlines": [],
        "uplines": referredBy,
        "level": level,
      };

      // ✅ নতুন pipilika অ্যাকাউন্ট তৈরি করুন
      await FirebaseFirestore.instance
          .collection("pipilikas")
          .doc(uid)
          .set(data);

      // ✅ রেফারার ইউজারের ডকুমেন্টে downlines এ uid যোগ করুন
      if (referredBy.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection("pipilikas")
            .doc(referredBy)
            .update({
              "downlines": FieldValue.arrayUnion([uid]),
            });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }

    setState(() => _isLoading = false);
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      obscureText: isPassword,
      validator: (value) => value!.isEmpty ? 'Enter $label' : null,
    );
  }

  Widget _imagePicker(String label, Uint8List? image, VoidCallback onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              image != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      image,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                  : Icon(Icons.image, size: 80, color: Colors.grey),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onPick,
                icon: Icon(Icons.upload),
                label: Text("Upload"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pipilika Registration"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_name, "Name"),
                _buildTextField(_father, "Father's Name"),
                _buildTextField(_mother, "Mother's Name"),
                _buildTextField(_dob, "Date of Birth"),
                _buildTextField(_referralId, "Referral ID (Sponsor UID)"),
                DropdownButtonFormField(
                  value: _gender,
                  items:
                      ["Male", "Female", "Other"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _gender = val!),
                  decoration: InputDecoration(labelText: "Gender"),
                ),
                DropdownButtonFormField(
                  value: _country,
                  items:
                      _countries
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _country = val!),
                  decoration: InputDecoration(labelText: "Country"),
                ),
                _buildTextField(_pin, "Post Code", isNumber: true),
                _buildTextField(_address, "Address"),
                _buildTextField(_email, "Email"),
                _buildTextField(_password, "Password", isPassword: true),
                _buildTextField(
                  _guardianPhone,
                  "Guardian Phone",
                  isNumber: true,
                ),
                _buildTextField(_myPhone, "My Phone", isNumber: true),
                _buildTextField(_nomineeName, "Nominee Name"),
                _buildTextField(_nomineeRelation, "Nominee Relation"),
                SizedBox(height: 20),
                _imagePicker(
                  "Upload Profile Picture",
                  _profilePic,
                  () => _pickImage("profile"),
                ),
                _imagePicker("Upload NID", _nidPic, () => _pickImage("nid")),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _isLoading ? null : _register,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.purple],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.4),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child:
                          _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                "Register",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
