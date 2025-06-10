import 'package:bazar_new_web/pages/home.dart';
import 'package:bazar_new_web/pipilica/pipilika_home2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _controller =
        VideoPlayerController.asset('assets/audio/intro.mp4')
          ..setLooping(true)
          ..setVolume(0.0) // 🔇 Mute
          ..initialize().then((_) {
            setState(() {});
            _controller.play(); // ▶️ Autoplay
          });
  }

  // 🔹 Check SharedPreferences and Navigate
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString("role");
    // Retrieve all keys and values from SharedPreferences
    Set<String> keys = prefs.getKeys();
    for (String key in keys) {
      print('$key: ${prefs.get(key)}');
    }

    // Delay for splash screen effect
    await Future.delayed(Duration(seconds: 2));

    if (role == null || role.isEmpty) {
      // No Data - Go to Home()
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else if (role == "reseller") {
      // Resaler - Go to ResallerHome()
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else if (role == "vendor") {
      // Vendor - Go to VandorHome()
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else if (role == "client") {
      // Vendor - Go to VandorHome()
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else if (role == "pipilika") {
      // ✅ pipilika-specific navigation
      String? uid = prefs.getString("uid");
      String? name = prefs.getString("name");
      String? email = prefs.getString("email");
      String? profilePicture = prefs.getString("profilePicture");
      String? referredBy = prefs.getString("referredBy");

      Map<String, dynamic> userData = {
        "id": uid,
        "name": name,
        "email": email,
        "profilePicture": profilePicture,
        "referredBy": referredBy,
        "role": "pipilika",
      };

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PipilikaHome2()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:
          _controller.value.isInitialized
              ? Stack(
                fit: StackFit.expand,
                children: [
                  // 🔹 Fullscreen video
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),

                  // 🔹 Optional overlay (e.g., logo at top-center)
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset("assets/images/logo.png", height: 100),
                    ),
                  ),

                  // 🔹 Optional loading spinner if needed
                  if (!_controller.value.isPlaying)
                    const Center(child: CircularProgressIndicator()),
                ],
              )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}

//total line =10782;total =15,367lines
