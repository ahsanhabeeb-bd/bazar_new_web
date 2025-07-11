import 'package:bazar_new_web/clients/client_login.dart';
import 'package:bazar_new_web/clients/clients_home.dart';
import 'package:bazar_new_web/pages/cart_page.dart';
import 'package:bazar_new_web/pages/detailes.dart';
import 'package:bazar_new_web/pages/product_description.dart';
import 'package:bazar_new_web/pages/search.dart';
import 'package:bazar_new_web/pages/trending_product.dart';
import 'package:bazar_new_web/pipilica/pipilick_login.dart';
import 'package:bazar_new_web/providers/sliders_provider.dart';
import 'package:bazar_new_web/reselar/login_reselar.dart';
import 'package:bazar_new_web/reselar/resaller_home.dart';
import 'package:bazar_new_web/vendor/login_vendor.dart';
import 'package:bazar_new_web/vendor/vendor_homelist.dart';
import 'package:bazar_new_web/widgets/banner.dart';
import 'package:bazar_new_web/widgets/brand_scroll.dart';
import 'package:bazar_new_web/widgets/events.dart';
import 'package:bazar_new_web/widgets/events2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final SliderProvider sliderProvider = SliderProvider();
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  List<Map<String, dynamic>> _subcategories = [];
  String _selectedCategory = "All Categories";
  String? _catagoryImage;
  String? _selectedSubcategory;
  String? profilePictureUrl;
  String? userRole;
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchSlidersAndCategories();
    fetchCategories();
    _loadUserProfile();
  }

  void fetchSlidersAndCategories() async {
    // await categoriesProvider.fetchCategories();
    await sliderProvider.slide1();
    await sliderProvider.slide2();
    await sliderProvider.slide3();
    await sliderProvider.slide4();
    await sliderProvider.slide5();
    setState(() {});
  }

  /// ✅ **Load Profile Picture & Role from SharedPreferences**
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profilePictureUrl = prefs.getString("profilePicture") ?? "";
      userRole = prefs.getString("role") ?? "";
    });
  }

  /// ✅ **Load User Profile (Profile Picture & Role)**
  Future<void> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profilePictureUrl = prefs.getString("profilePicture");
      userRole = prefs.getString("role"); // Load role from SharedPreferences
      userId = prefs.getString("id"); // Load user ID
    });

    print("🟢 Loaded Role: $userRole"); // Debugging
  }

  /// ✅ **Handle Profile Navigation**
  void _navigateToHome(BuildContext context) {
    if (userRole == null) {
      print("🚨 No role found in SharedPreferences!");
      return;
    }

    print("🔹 Navigating to Home for Role: $userRole"); // Debugging

    if (userRole == "reseller") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResellerHome()),
      );
    } else if (userRole == "vendor") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VendorHomelist()),
      );
    } else if (userRole == "client") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ClientHome()),
      );
    } else {
      print("🚨 Unknown role: $userRole"); // Debugging
    }
  }

  /// ✅ **Load Profile Picture from SharedPreferences**
  Future<void> _loadProfilePicture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profilePictureUrl = prefs.getString("profilePicture") ?? "";
    });
  }

  /// ✅ Fetch Categories and Their Subcategories from Firestore
  Future<void> fetchCategories() async {
    try {
      QuerySnapshot categorySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      List<Map<String, dynamic>> categories = [];

      for (var categoryDoc in categorySnapshot.docs) {
        var categoryData = categoryDoc.data() as Map<String, dynamic>;

        // Fetch subcategories for each category
        QuerySnapshot subcategorySnapshot =
            await FirebaseFirestore.instance
                .collection('categories')
                .doc(categoryDoc.id)
                .collection('subcategories')
                .get();

        List<Map<String, dynamic>> subcategories =
            subcategorySnapshot.docs.map((subDoc) {
              var subData = subDoc.data() as Map<String, dynamic>;
              return {
                'id': subData['id'] ?? '',
                'name': subData['name'] ?? 'No Name',
                'imageUrl': subData['imageUrl'] ?? '',
              };
            }).toList();

        categories.add({
          'id': categoryData['id'] ?? '',
          'name': categoryData['name'] ?? 'No Name',
          'imageUrl': categoryData['imageUrl'] ?? '',
          'subcategories': subcategories,
        });
      }

      setState(() {
        _categories = categories;
        _selectedCategory = "All Categories"; // Default selection
        _fetchAllSubcategories();
      });
    } catch (e) {
      print("🚨 Error fetching categories: $e");
    }
  }

  /// ✅ Fetch All Subcategories (For "All Categories" Selection)
  void _fetchAllSubcategories() {
    _subcategories =
        _categories
            .expand((category) => category['subcategories'] ?? [])
            .cast<Map<String, dynamic>>()
            .toList();
    setState(() {
      _selectedSubcategory = null;
    });
  }

  /// ✅ Fetch Subcategories of a Specific Category
  void _fetchSubcategories(String categoryId) async {
    print("🟡 Fetching subcategories for Category ID: $categoryId");

    // 🔹 Set state to clear subcategories before fetching
    setState(() {
      _subcategories = []; // Clear old subcategories
      _selectedSubcategory = null; // Reset subcategory selection
    });

    try {
      QuerySnapshot subcategorySnapshot =
          await FirebaseFirestore.instance
              .collection('categories')
              .doc(categoryId)
              .collection('subcategories')
              .get();

      List<Map<String, dynamic>> subcategories =
          subcategorySnapshot.docs.map((subDoc) {
            var subData = subDoc.data() as Map<String, dynamic>;
            return {
              'id': subData['id'] ?? '',
              'name': subData['name'] ?? 'No Name',
              'imageUrl': subData['imageUrl'] ?? '',
            };
          }).toList();

      // 🔹 Update state after fetching subcategories
      setState(() {
        _subcategories = subcategories;
        _selectedSubcategory =
            subcategories.isNotEmpty ? subcategories[0]['id'] : null;
      });

      print("🟢 Successfully fetched ${_subcategories.length} subcategories");
    } catch (e) {
      print("🚨 Error fetching subcategories: $e");
    }
  }

  /// ✅ Handle Subcategory Selection
  void _onSubcategorySelected(String? subcategoryId) {
    if (subcategoryId == null) {
      print("🚨 No subcategory selected!");
      return;
    }

    var selectedSubcategory = _subcategories.firstWhere(
      (sub) => sub['id'] == subcategoryId,
      orElse: () => {},
    );

    print("🟢 Selected Subcategory: ${selectedSubcategory['name']}");

    setState(() {
      _selectedSubcategory =
          selectedSubcategory['id']; // Update selected subcategory
    });

    // Perform additional actions, e.g., update UI, filter products, etc.
  }

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('products')
              .where(
                "status",
                isEqualTo: "accepted",
              ) // Only show accepted products
              .get(); // Get all accepted products first

      // ✅ **Manually Filter Products Based on Name**
      List<Map<String, dynamic>> filteredResults =
          snapshot.docs
              .map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return {
                  "id": doc.id,
                  "name": data["name"] ?? "",
                  "image": data["images"]?["main"] ?? "",
                };
              })
              .where(
                (product) =>
                    product["name"].toLowerCase().contains(query.toLowerCase()),
              ) // ✅ Case-insensitive search
              .toList();

      setState(() {
        _searchResults = filteredResults;
      });
    } catch (e) {
      print("❌ Error searching products: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png', height: 50, width: 250),
        backgroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.group, size: 30, color: Colors.black),
            onSelected: (String value) {
              // Handle selection
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ClientLogin()),
                      );
                    },
                    value: 'User Account',
                    child: Text('User Account'),
                  ),
                  PopupMenuItem<String>(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginVendor()),
                      );
                    },
                    value: 'vendor',
                    child: Text('Vendor Account'),
                  ),
                  PopupMenuItem<String>(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginResaler()),
                      );
                    },
                    value: 'reseller',
                    child: Text('Reseller Account'),
                  ),
                  PopupMenuItem<String>(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PipilikaLogin(),
                        ),
                      );
                    },
                    value: 'pipilika',
                    child: Text('Pipirica Subscription'),
                  ),
                ],
          ),

          IconButton(
            icon:
                profilePictureUrl != null && profilePictureUrl!.isNotEmpty
                    ? CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(profilePictureUrl!),
                    )
                    : const Icon(Icons.person, size: 30, color: Colors.black),
            onPressed: () => _navigateToHome(context),
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                (userId != null && userRole != null)
                    ? FirebaseFirestore.instance
                        .collection(
                          userRole == "reseller"
                              ? "resellers"
                              : userRole == "pipilika"
                              ? "pipilikas"
                              : "clients",
                        )
                        .doc(userId)
                        .collection("cart")
                        .snapshots()
                    : null,
            builder: (context, snapshot) {
              int cartItemCount = 0;
              if (snapshot.hasData) {
                cartItemCount = snapshot.data!.docs.length;
              }

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, size: 24),
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String? id = prefs.getString("id");

                      if (id == null || id.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please login to view cart"),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return CartPage();
                          },
                        ),
                      );
                    },
                  ),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 8,
                        child: Text(
                          cartItemCount.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.more_vert, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DetailsPage()),
              );
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      drawer: Container(
        width: 250, // Adjust width for better UI
        child: Drawer(
          child: Column(
            children: [
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.category, color: Colors.green),
                title: Text(
                  "Categories",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(),
              // 🔹 "All Categories" Option
              ListTile(
                leading: Icon(Icons.list, color: Colors.blue),
                title: Text("All Categories"),
                onTap: () {
                  setState(() {
                    _selectedCategory = "All Categories";
                    _selectedCategoryId = null; // ✅ Clear Category Filter
                    _selectedSubcategoryId = null; // ✅ Clear Subcategory Filter
                    _fetchAllSubcategories(); // ✅ Refresh subcategories (optional)
                    _catagoryImage = null;
                  });
                  Navigator.pop(context);
                },
              ),
              // 🔹 Display List of Categories
              Expanded(
                child: StreamBuilder(
                  stream:
                      FirebaseFirestore.instance
                          .collection('categories')
                          .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("No categories found"));
                    }

                    return ListView(
                      children:
                          snapshot.data!.docs.map((document) {
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;

                            //   _catagoryImage = data['imageUrl'];

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    data['imageUrl'] != null &&
                                            data['imageUrl'].isNotEmpty
                                        ? NetworkImage(data['imageUrl'])
                                        : AssetImage(
                                              'assets/images/default_category.png',
                                            )
                                            as ImageProvider,
                              ),
                              title: Text(data['name'] ?? "Unnamed Category"),
                              onTap: () {
                                setState(() {
                                  _selectedCategory = data['name'];
                                  _fetchSubcategories(data['id']);
                                  _catagoryImage = data['imageUrl'];
                                  _selectedCategoryId = data['id'];
                                });
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Stack(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      // 🔹 Search Field
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: () async {
                            final selectedProductId = await showDialog(
                              context: context,
                              builder: (context) => SearchProductDialog(),
                            );

                            if (selectedProductId != null) {
                              // ✅ Navigate to Product Description Page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => NewProductDescription(
                                        productId: selectedProductId,
                                      ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            height: 48,
                            width: 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 10),
                                Icon(
                                  Icons.search,
                                  color: Colors.black,
                                  size: 30,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Search...",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // 🔹 Subcategory Dropdown
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                          items:
                              _categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category['id'],
                                  child: Row(
                                    children: [
                                      category['imageUrl'] != null &&
                                              category['imageUrl'].isNotEmpty
                                          ? Image.network(
                                            category['imageUrl'],
                                            width: 30,
                                            height: 30,
                                          )
                                          : Icon(
                                            Icons.image,
                                            size: 30,
                                            color: Colors.grey,
                                          ),
                                      SizedBox(width: 10),
                                      Text(category['name']),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              final selected = _categories.firstWhere(
                                (cat) => cat['id'] == newValue,
                              );

                              setState(() {
                                _selectedCategory =
                                    selected['name']; // নাম আপডেট
                                _catagoryImage =
                                    selected['imageUrl']; // ছবি আপডেট
                                _selectedCategoryId = selected['id']; // ID সেভ
                                _fetchSubcategories(
                                  selected['id'],
                                ); // সাব-ক্যাটাগরি লোড
                              });
                            }
                          },
                          hint: Text("Select Category"),
                        ),
                      ),
                    ],
                  ),

                  // 🔽 Full-Width Search Results Overlay
                  if (_searchResults.isNotEmpty)
                    Positioned(
                      top: 55, // Position below the search field
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 300, // Set a reasonable height limit
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final product = _searchResults[index];
                            return ListTile(
                              leading:
                                  product["image"].isNotEmpty
                                      ? Image.network(
                                        product["image"],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                      : const Icon(Icons.image_not_supported),
                              title: Text(product["name"]),
                              onTap: () {
                                // Navigate to product description when selected
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => NewProductDescription(
                                          productId: product["id"],
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                  SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 800) {
                        // Mobile layout
                        return Column(
                          children: [
                            banner(imageUrls1: sliderProvider.imageUrls1),
                            const SizedBox(height: 8),
                            events1(
                              imageUrls2: sliderProvider.imageUrls2,
                              imageUrls3: sliderProvider.imageUrls3,
                            ),
                            const SizedBox(height: 8),
                            events2(
                              imageUrls4: sliderProvider.imageUrls4,
                              imageUrls5: sliderProvider.imageUrls5,
                            ),
                          ],
                        );
                      } else {
                        // Desktop layout
                        return Row(
                          children: [
                            banner(imageUrls1: sliderProvider.imageUrls1),

                            // Right side with events1 & events2 stacked in a column
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    events1(
                                      imageUrls2: sliderProvider.imageUrls2,
                                      imageUrls3: sliderProvider.imageUrls3,
                                    ),
                                    SizedBox(height: 8),
                                    events2(
                                      imageUrls4: sliderProvider.imageUrls4,
                                      imageUrls5: sliderProvider.imageUrls5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),

                  Brand_Scroll(),
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Container(
                        width: 30, // Set width
                        height: 30, // Set height
                        decoration: BoxDecoration(
                          //   border: Border.all(color: Colors.grey, width: 2), // Border
                          borderRadius: BorderRadius.circular(
                            5,
                          ), // Rounded corners
                          image:
                              _catagoryImage != null &&
                                      _catagoryImage!.isNotEmpty
                                  ? DecorationImage(
                                    image: NetworkImage(_catagoryImage!),
                                    fit: BoxFit.cover, // Cover the container
                                  )
                                  : DecorationImage(
                                    image: AssetImage(
                                      'assets/images/catagory.png',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        _selectedCategory,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Trending_Product(
                    selectedCategoryId: _selectedCategoryId,
                    selectedSubcategoryId: _selectedSubcategoryId,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
