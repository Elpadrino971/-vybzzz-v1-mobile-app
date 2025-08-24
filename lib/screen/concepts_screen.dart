import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/widgets/concept_visual_widget.dart';
import '../models/concept_visual.dart';

class ConceptsScreen extends StatefulWidget {
  const ConceptsScreen({Key? key}) : super(key: key);

  @override
  State<ConceptsScreen> createState() => _ConceptsScreenState();
}

class _ConceptsScreenState extends State<ConceptsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'UI/UX',
    'Branding',
    'Marketing',
    'Development',
    'Innovation',
    'Design',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // App Bar
          _buildSliverAppBar(),
          
          // Search Bar
          _buildSearchBar(),
          
          // Category Tabs
          _buildCategoryTabs(),
          
          // Concepts Grid
          _buildConceptsGrid(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddConceptDialog(),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          'Add Concept',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Concept Visuals',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.purple.shade50,
                Colors.orange.shade50,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showFilterDialog(),
          icon: Icon(
            Icons.filter_list,
            color: Colors.blue.shade600,
          ),
        ),
        IconButton(
          onPressed: () => _showSortDialog(),
          icon: Icon(
            Icons.sort,
            color: Colors.blue.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search concepts...',
            hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
            border: InputBorder.none,
            icon: Icon(
              Icons.search,
              color: Colors.blue.shade600,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey.shade400,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.blue.shade600,
          indicatorWeight: 3,
          labelColor: Colors.blue.shade600,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          tabs: _categories.map((category) => Tab(text: category)).toList(),
          onTap: (index) {
            setState(() {
              _selectedCategory = _categories[index];
            });
          },
        ),
      ),
    );
  }

  Widget _buildConceptsGrid() {
    final filteredConcepts = _getFilteredConcepts();
    
    if (filteredConcepts.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No concepts found',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'Try adjusting your search or filters',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 1.2,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final concept = filteredConcepts[index];
            return ConceptVisualWidget(
              title: concept.title,
              description: concept.description,
              imageUrl: concept.imageUrl,
              localImagePath: concept.localImagePath,
              category: concept.category,
              tags: concept.tags,
              isFeatured: concept.isFeatured,
              onTap: () => _showConceptDetail(concept),
            );
          },
          childCount: filteredConcepts.length,
        ),
      ),
    );
  }

  List<ConceptVisual> _getFilteredConcepts() {
    List<ConceptVisual> concepts = _getSampleConcepts();
    
    // Filter by category
    if (_selectedCategory != 'All') {
      concepts = concepts.where((c) => c.category == _selectedCategory).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      concepts = concepts.where((c) =>
        c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        c.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        c.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }
    
    return concepts;
  }

  List<ConceptVisual> _getSampleConcepts() {
    return [
      ConceptVisual(
        title: 'Modern Social Media Dashboard',
        description: 'A sleek and intuitive dashboard design for social media management with real-time analytics and user engagement metrics.',
        category: 'UI/UX',
        tags: ['dashboard', 'social', 'analytics', 'modern'],
        isFeatured: true,
        localImagePath: 'assets/images/concepts/ui_ux/dashboard_concept.svg',
      ),
      ConceptVisual(
        title: 'Brand Identity for Tech Startup',
        description: 'Complete brand identity package including logo design, color palette, typography, and brand guidelines for a cutting-edge tech company.',
        category: 'Branding',
        tags: ['branding', 'logo', 'identity', 'tech'],
        isFeatured: false,
        localImagePath: 'assets/images/concepts/branding/brand_identity.svg',
      ),
      ConceptVisual(
        title: 'Mobile App User Flow',
        description: 'Comprehensive user journey mapping and wireframes for a mobile banking application with focus on security and ease of use.',
        category: 'Development',
        tags: ['mobile', 'banking', 'wireframes', 'userflow'],
        isFeatured: true,
        localImagePath: 'assets/images/concepts/development/mobile_app_flow.svg',
      ),
      ConceptVisual(
        title: 'Marketing Campaign Visuals',
        description: 'Creative marketing materials including social media posts, banners, and promotional graphics for seasonal campaigns.',
        category: 'Marketing',
        tags: ['marketing', 'campaign', 'social', 'graphics'],
        isFeatured: false,
        localImagePath: 'assets/images/concepts/marketing/campaign_visuals.svg',
      ),
      ConceptVisual(
        title: 'AI-Powered Chat Interface',
        description: 'Innovative chat interface design incorporating artificial intelligence features, natural language processing, and smart responses.',
        category: 'Innovation',
        tags: ['AI', 'chat', 'interface', 'innovation'],
        isFeatured: true,
        localImagePath: 'assets/images/concepts/innovation/ai_chat_interface.svg',
      ),
    ];
  }

  void _showConceptDetail(ConceptVisual concept) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                concept.title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                concept.description,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('Close'),
                  ),
                  ElevatedButton(
                    onPressed: () => _editConcept(concept),
                    child: Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddConceptDialog() {
    // TODO: Implement add concept dialog
    Get.snackbar(
      'Coming Soon',
      'Add concept functionality will be implemented soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showFilterDialog() {
    // TODO: Implement filter dialog
    Get.snackbar(
      'Coming Soon',
      'Advanced filters will be implemented soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showSortDialog() {
    // TODO: Implement sort dialog
    Get.snackbar(
      'Coming Soon',
      'Sorting options will be implemented soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _editConcept(ConceptVisual concept) {
    // TODO: Implement edit concept
    Get.back();
    Get.snackbar(
      'Coming Soon',
      'Edit functionality will be implemented soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
