import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/Chat/ChatScreen.dart';
import 'package:client/Recruiter/RecruiterDetailPage.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Services/ChatService.dart';
import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:provider/provider.dart';

class RecruitersListScreen extends StatefulWidget {
  const RecruitersListScreen({super.key});

  @override
  State<RecruitersListScreen> createState() => _RecruitersListScreenState();
}

class _RecruitersListScreenState extends State<RecruitersListScreen> {
  final RecruiterRepository _repo = RecruiterRepository();
  late Future<List<Recruiter>> _recruitersFuture;
  List<Recruiter> _allRecruiters = [];
  List<Recruiter> _filteredRecruiters = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _recruitersFuture = _fetchRecruiters();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRecruiters = _allRecruiters.where((r) {
        return r.pharmacyName.toLowerCase().contains(query) ||
            r.pharmacistFirstName.toLowerCase().contains(query) ||
            r.pharmacistLastName.toLowerCase().contains(query) ||
            r.city.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<List<Recruiter>> _fetchRecruiters() async {
    final recruiters = await _repo.getAllFromCollection();
    _allRecruiters = recruiters;
    _filteredRecruiters = recruiters;
    return recruiters;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          "Recruiters",
          style: TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔹 Premium Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by pharmacy, name or city",
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.black.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),

          // 🔹 Recruiters list
          Expanded(
            child: FutureBuilder<List<Recruiter>>(
              future: _recruitersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (_filteredRecruiters.isEmpty) {
                  return const Center(child: Text("No recruiters found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredRecruiters.length,
                  itemBuilder: (context, index) {
                    final r = _filteredRecruiters[index];
                    return RecruiterCard(recruiter: r);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

 Widget _recruiterCard(Recruiter recruiter) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecruiterDetailPage(recruiter: recruiter),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Profile Avatar
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.teal.shade50,
            child: Text(
              recruiter.pharmacistFirstName.isNotEmpty
                  ? recruiter.pharmacistFirstName[0].toUpperCase()
                  : "R",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
          ),
          const SizedBox(height: 12),

          /// Pharmacy Name
          Text(
            recruiter.pharmacyName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),

          /// Pharmacist Name
          Text(
            "${recruiter.pharmacistFirstName} ${recruiter.pharmacistLastName}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),

          /// Location
          Text(
            "${recruiter.city}, ${recruiter.province}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 12),

          /// Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: recruiter.isActive
                  ? LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600])
                  : LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              recruiter.isActive ? "Verified" : "Unverified",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          /// Chat Button
          ElevatedButton.icon(
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              if (auth.user == null) return;

              final recruiterId = auth.user!.userId;
              final jobSeekerId = recruiter.userId;

              final chatService = ChatService();

              final chatId = await chatService.getOrCreateChat(
                recruiterId,
                jobSeekerId,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    chatId: chatId,
                    otherUserId: jobSeekerId,
                    personName:
                        "${recruiter.pharmacistFirstName} ${recruiter.pharmacistLastName}",
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.greenCeladon,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.chat, size: 18),
            label: const Text(
              "Chat",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

}


class RecruiterCard extends StatefulWidget {
  final Recruiter recruiter;

  const RecruiterCard({super.key, required this.recruiter});

  @override
  State<RecruiterCard> createState() => _RecruiterCardState();
}

class _RecruiterCardState extends State<RecruiterCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: premiumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.teal.shade50,
                child: Text(
                  widget.recruiter.pharmacistFirstName.isNotEmpty
                      ? widget.recruiter.pharmacistFirstName[0].toUpperCase()
                      : "R",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recruiter.pharmacyName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${widget.recruiter.pharmacistFirstName} ${widget.recruiter.pharmacistLastName}",
                      style: const TextStyle(
                        color: AppColors.darkGreen,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.recruiter.isActive ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.recruiter.isActive ? "Verified" : "Unverified",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// LOCATION
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text("${widget.recruiter.city}, ${widget.recruiter.province}",
                  style: const TextStyle(fontSize: 12)),
            ],
          ),

          const SizedBox(height: 34),

          /// ACTIONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () {
                          setState(() => _loading = true);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RecruiterDetailPage(recruiter: widget.recruiter),
                            ),
                          ).then((_) => setState(() => _loading = false));
                        },
                  child: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("View Profile"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final auth = context.read<AuthProvider>();
                    if (auth.user == null) return;

                    final recruiterId = auth.user!.userId;
                    final targetId = widget.recruiter.userId;

                    final chatService = ChatService();

                    final chatId = await chatService.getOrCreateChat(
                      recruiterId,
                      targetId,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          chatId: chatId,
                          otherUserId: targetId,
                          personName:
                              "${widget.recruiter.pharmacistFirstName} ${widget.recruiter.pharmacistLastName}",
                        ),
                      ),
                    );
                  },
                  child: const Text("Chat"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}