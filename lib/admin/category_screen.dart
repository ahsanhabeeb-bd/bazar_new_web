import 'dart:io';
import 'package:bazar_new_web/provider/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () => showAddCategoryDialog(context),
          ),
        ],
        backgroundColor: Colors.green,
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (categoryProvider.categories.isEmpty) {
            return Center(child: Text("No categories available"));
          }

          return ListView.builder(
            itemCount: categoryProvider.categories.length,
            itemBuilder: (context, index) {
              var category = categoryProvider.categories[index];
              return ListTile(
                leading: Image.network(
                  category['imageUrl'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(category['name']),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed:
                      () => showEditCategoryDialog(
                        context,
                        categoryProvider,
                        category,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 📌 Show Add Category Dialog
  void showAddCategoryDialog(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Add Category",
            style: GoogleFonts.poppins(color: Colors.green),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  File? pickedImage = await categoryProvider.pickImage();
                  if (pickedImage != null) {
                    categoryProvider.setSelectedImage(pickedImage);
                    (context as Element).markNeedsBuild(); // Refresh UI
                  }
                },
                child:
                    categoryProvider.selectedImage != null
                        ? Image.file(
                          categoryProvider.selectedImage!,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        )
                        : Container(
                          height: 80,
                          width: 80,
                          color: Colors.grey[300],
                          child: Icon(Icons.camera_alt),
                        ),
              ),

              SizedBox(height: 10),
              TextField(
                controller: categoryProvider.categoryController,
                decoration: InputDecoration(hintText: "Enter Category Name"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                await categoryProvider.saveCategory(
                  categoryProvider.categoryController.text,
                  categoryProvider.selectedImage,
                );
                Navigator.pop(context);
              },
              child: Text("Add", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  // 📌 Show Edit Category Dialog (✅ Added Now)
  void showEditCategoryDialog(
    BuildContext context,
    CategoryProvider categoryProvider,
    Map category,
  ) {
    TextEditingController editCategoryController = TextEditingController(
      text: category['name'],
    );
    File? newImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                "Edit Category",
                style: GoogleFonts.poppins(color: Colors.blue),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      File? pickedImage = await categoryProvider.pickImage();
                      if (pickedImage != null) {
                        setStateDialog(() {
                          newImage = pickedImage;
                        });
                      }
                    },
                    child:
                        newImage != null
                            ? Image.file(
                              newImage!,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            )
                            : categoryProvider.selectedImage != null
                            ? Image.file(
                              categoryProvider.selectedImage!,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            )
                            : Image.network(
                              category['imageUrl'],
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                  ),

                  SizedBox(height: 10),
                  TextField(
                    controller: editCategoryController,
                    decoration: InputDecoration(
                      hintText: "Enter Category Name",
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () async {
                    await categoryProvider.updateCategory(
                      category['id'],
                      editCategoryController.text,
                      newImage,
                    );
                    Navigator.pop(context);
                  },
                  child: Text("Save", style: TextStyle(color: Colors.green)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
