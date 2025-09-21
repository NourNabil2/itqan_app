import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/widgets/member_card.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:provider/provider.dart';

import 'add_member_screen.dart';


class MemberLibraryScreen extends StatefulWidget {
  const MemberLibraryScreen({super.key});

  @override
  State<MemberLibraryScreen> createState() => _MemberLibraryScreenState();
}

class _MemberLibraryScreenState extends State<MemberLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('مكتبة الأعضاء'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddGlobalMemberScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث عن عضو...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                Provider.of<MemberLibraryProvider>(context, listen: false)
                    .searchMembers(query);
              },
            ),
          ),

          // Stats Bar
          Container(
            color: const Color(0xFF2196F3).withOpacity(0.05),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Consumer<MemberLibraryProvider>(
              builder: (context, provider, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'إجمالي الأعضاء',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${provider.globalMembers.length}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Members List
          Expanded(
            child: Consumer<MemberLibraryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.globalMembers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80.sp,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'لا يوجد أعضاء في المكتبة',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const AddGlobalMemberScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('إضافة أول عضو'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: provider.globalMembers.length,
                  itemBuilder: (context, index) {
                    return MemberCard(
                      member: provider.globalMembers[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

