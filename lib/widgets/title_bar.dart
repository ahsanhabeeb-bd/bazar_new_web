// import 'package:bazar_new_mobile/pages/login.dart';
// import 'package:flutter/material.dart';

// class TitleBar extends StatelessWidget {
//   const TitleBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Image.asset('assets/images/logo.png', height: 50, width: 100),
//         Row(
//           children: [
//             PopupMenuButton<String>(
//               icon: Icon(Icons.group, size: 30, color: Colors.black),
//               onSelected: (String value) {
//                 // Handle selection
//               },
//               itemBuilder:
//                   (BuildContext context) => <PopupMenuEntry<String>>[
//                     PopupMenuItem<String>(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => LoginPage()),
//                         );
//                       },
//                       value: 'vendor',
//                       child: Text('Vendor Account'),
//                     ),
//                     PopupMenuItem<String>(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => LoginPage()),
//                         );
//                       },
//                       value: 'reseller',
//                       child: Text('Reseller Account'),
//                     ),
//                     PopupMenuItem<String>(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => LoginPage()),
//                         );
//                       },
//                       value: 'pipilika',
//                       child: Text('Pipilika Account'),
//                     ),
//                   ],
//             ),
//             IconButton(
//               icon: const Icon(Icons.person, size: 30, color: Colors.black),
//               onPressed: () {},
//             ),
//             Stack(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.shopping_cart, size: 24),
//                   onPressed: () {},
//                 ),
//                 Positioned(
//                   right: 0,
//                   child: CircleAvatar(
//                     backgroundColor: Colors.red,
//                     radius: 6,
//                     child: Text(
//                       "0",
//                       style: const TextStyle(fontSize: 8, color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
