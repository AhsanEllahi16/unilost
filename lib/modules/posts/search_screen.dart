// lib/modules/posts/search_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme.dart';
import '../../widgets/item_card.dart';
import '../../viewmodels/search_controller.dart';
import 'item_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  final SearchControllerX searchC = Get.find<SearchControllerX>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UniLostTheme.primary,
        title: const Text('Search Items'),
        // ✅ Search field inside AppBar — same size as other screens
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            children: [
              // ✅ Search field compact inside AppBar
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search lost or found items...',
                    hintStyle: const TextStyle(
                      color: Colors.white70,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white70,
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Lost'),
                  Tab(text: 'Found'),
                ],
              ),
            ],
          ),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(searchC.search(_query)),
          _buildList(searchC.lostPosts(_query)),
          _buildList(searchC.foundPosts(_query)),
        ],
      ),
    );
  }

  Widget _buildList(List items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final post = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ItemCard(
            post: post,
            onTap: () => Get.to(() => ItemDetailScreen(post: post)),
          ),
        );
      },
    );
  }
}