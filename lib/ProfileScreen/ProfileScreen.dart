import 'package:client/AppColors/AppColors.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _headerSection(),
              const SizedBox(height: 20),
              _contactButtons(),
              const SizedBox(height: 25),
              _resumeCard(),
              const SizedBox(height: 30),
              _skillSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------
  // HEADER
  // ------------------------------
  Widget _headerSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 230,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/avatar.png"), // your bg image
              fit: BoxFit.cover,
            ),
          ),
        ),

        Positioned(
          top: 50,
          child: Column(
            children: [
              const Text(
                "Account",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        Positioned(
          bottom: -40,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: const CircleAvatar(
              radius: 46,
              backgroundImage: AssetImage("assets/avatar.png"), // your image
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------
  // CONTACT BUTTONS
  // ------------------------------
  Widget _contactButtons() {
    return Column(
      children: [
        const SizedBox(height: 55),
        const Text("Henry Kanwil",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const Text("Programmer",
            style: TextStyle(color: Colors.grey, fontSize: 15)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Text(
            "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 10),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _iconButton(Icons.phone),
            const SizedBox(width: 20),
            _iconButton(Icons.email),
            const SizedBox(width: 20),
            _iconButton(Icons.location_on),
          ],
        )
      ],
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(.2),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Icon(icon, color: Colors.deepPurple),
    );
  }

  // ------------------------------
  // RESUME CARD
  // ------------------------------
  Widget _resumeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff5a19d6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.picture_as_pdf, color: Colors.white),
          SizedBox(width: 15),
          Expanded(
            child: Text("My Resume\ndavid_resume.pdf",
                style: TextStyle(color: Colors.white)),
          ),
          Icon(Icons.more_vert, color: Colors.white),
        ],
      ),
    );
  }

  // ------------------------------
  // SKILL SECTION
  // ------------------------------
  Widget _skillSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("Skill",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 15),

        Wrap(
          spacing: 15,
          runSpacing: 15,
          alignment: WrapAlignment.center,
          children: [
            _skillCard("PHP", 86, Colors.orange),
            _skillCard("Java", 48, Colors.green),
            _skillCard("MySQL", 56, Colors.blue),
            _skillCard("React N", 34, Colors.pink),
            _skillCard("CSS", 86, Colors.deepPurple),
          ],
        ),
      ],
    );
  }

  Widget _skillCard(String title, int percent, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 90,
            width: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 7,
                  color: color,
                  backgroundColor: color.withOpacity(.2),
                ),
                Center(
                  child: Text("$percent%",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  // ------------------------------
  // BOTTOM NAVIGATION
  // ------------------------------
  Widget _bottomNavBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined), label: "Interviews"),
        BottomNavigationBarItem(
            icon: Icon(Icons.email_outlined), label: "Messages"),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: "Account"),
      ],
    );
  }
}

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background, // Deep brown background
//       appBar: AppBar(
//         backgroundColor: AppColors.background, // Olive color),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.green),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         title: const Text(
//           'Profile',
//           style: TextStyle(color: Colors.green),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Center(
//           child:  SingleChildScrollView(
//               child: Column(
//                 children: [
//                   // --- TOP OLIVE SECTION ---
//                   Container(
//                     height: 250,
//                     width: double.infinity,
//                     decoration: const BoxDecoration(
//                       color: Color.fromARGB(255, 107, 237, 149), // Olive color
//                       borderRadius: BorderRadius.vertical(
//                         top: Radius.circular(40),
//                       ),
//                     ),
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
                       
//                         // NAME AND TITLE
//                         Positioned(
//                           bottom: 20,
//                           child: Column(
//                             children: const [
//                               SizedBox(height: 60),
//                               Text(
//                                 "Sudhakar Mannam",
//                                 style: TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 "Sr. User Interface Designer\nHyderabad, India",
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
              
//                   // Profile image overlapping
//                   Transform.translate(
//                     offset: const Offset(0, -65),
//                     child: CircleAvatar(
//                       radius: 55,
//                       backgroundColor: Colors.white,
//                       child: CircleAvatar(
//                         radius: 50,
//                         backgroundImage: const AssetImage("assets/avatar.png"),
//                       ),
//                     ),
//                   ),
              
//                   // --- STATS SECTION ---
//                   Transform.translate(
//                     offset: const Offset(0, -50),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 20),
//                       margin: const EdgeInsets.symmetric(horizontal: 40),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF2B1E1E),
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: const [
//                           StatItem(count: "5", label: "Shots"),
//                           StatItem(count: "125", label: "Followers"),
//                           StatItem(count: "180", label: "Following"),
//                         ],
//                       ),
//                     ),
//                   ),
              
//                   // --- SKILLS SECTION ---
//                   Transform.translate(
//                     offset: const Offset(0, -40),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 20),
//                           child: Text(
//                             "Skills I have",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
              
//                         const SizedBox(height: 12),
              
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 14),
//                           child: Wrap(
//                             spacing: 10,
//                             runSpacing: 10,
//                             children: const [
//                               SkillChip("user interface design"),
//                               SkillChip("user experience design"),
//                               SkillChip("art direction"),
//                               SkillChip("visual design"),
//                               SkillChip("prototyping"),
//                               SkillChip("usability testing"),
//                               SkillChip("wireframes"),
//                             ],
//                           ),
//                         ),
              
//                         const SizedBox(height: 25),
              
//                         const Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 20),
//                           child: Text(
//                             "Tools I expertise",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
              
//                         const SizedBox(height: 18),
              
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: const [
//                             ToolIcon("💎"),
//                             ToolIcon("Ps"),
//                             ToolIcon("Ai"),
//                             ToolIcon("Xd"),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
      
//     );
//   }
// }

// // ------------------ COMPONENTS ------------------

// class StatItem extends StatelessWidget {
//   final String count;
//   final String label;

//   const StatItem({super.key, required this.count, required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           count,
//           style: const TextStyle(
//               color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         Text(
//           label,
//           style: const TextStyle(color: Colors.white70),
//         ),
//       ],
//     );
//   }
// }

// class SkillChip extends StatelessWidget {
//   final String text;

//   const SkillChip(this.text, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Chip(
//       backgroundColor: const Color(0xFFEFECEC), // light gray
//       label: Text(
//         text,
//         style: const TextStyle(fontSize: 13),
//       ),
//     );
//   }
// }

// class ToolIcon extends StatelessWidget {
//   final String text;

//   const ToolIcon(this.text, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(
//           color: const Color(0xFFA3A719), // olive stroke
//           width: 2,
//         ),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 18),
//       ),
//     );
//   }
// }

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         title: const Text(
//           'Profile',
//           style: TextStyle(color: Colors.black),
//         ),
//         centerTitle: true,
//       ),
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           /// -------------------------
//           /// TOP FULL IMAGE
//           /// -------------------------
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.55,
//             width: double.infinity,
//             child: Image.asset(
//               "assets/avatar.png",
//               fit: BoxFit.fitHeight,
//             ),
//           ),

          
//           /// -------------------------
//           /// BOTTOM CONTAINER WITH CURVE
//           /// -------------------------
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.fromLTRB(25, 30, 25, 30),
//               decoration: const BoxDecoration(
//                 color: Color(0xffF3F5F7),
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(40),
//                   topRight: Radius.circular(40),
//                 ),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [

//                   /// NAME
//                   const Text(
//                     "Sophia Martinez",
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),

//                   const SizedBox(height: 6),

//                   /// DESIGNATION
//                   Text(
//                     "Head of Design",
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   /// SKILL CHIPS WITH ICONS
//                   Wrap(
//                     spacing: 10,
//                     children: const [
//                       SkillChip(
//                         icon: Icons.brush,
//                         label: "Figma",
//                         iconColor: Colors.orange,
//                       ),
//                       SkillChip(
//                         icon: Icons.photo,
//                         label: "Photoshop",
//                         iconColor: Colors.blue,
//                       ),
//                       SkillChip(
//                         icon: Icons.palette,
//                         label: "Illustrator",
//                         iconColor: Colors.red,
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 30),

//                   /// STATS ROW
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: const [
//                       StatTile(label: "Experience", value: "1256"),
//                       StatTile(label: "Skills", value: "352"),
//                       StatTile(label: "Testing", value: "682"),
//                       StatTile(label: "Interview", value: "584"),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Floating circular white icon button
//   Widget _circleIcon(IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.95),
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 8,
//           ),
//         ],
//       ),
//       child: Icon(icon, size: 22),
//     );
//   }
// }

/// -------------------------
/// SKILL CHIP
/// -------------------------
// class SkillChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color iconColor;

//   const SkillChip({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.iconColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Chip(
//       backgroundColor: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       avatar: Icon(icon, color: iconColor, size: 18),
//       label: Text(
//         label,
//         style: TextStyle(
//           fontSize: 14,
//           color: Colors.grey.shade800,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }
// }

/// -------------------------
/// STAT TILE
/// -------------------------
class StatTile extends StatelessWidget {
  final String label;
  final String value;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          )
        ],
      ),
    );
  }
}
