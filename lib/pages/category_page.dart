import 'package:app_uangku/model/database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool isExpense = true;
  final AppDb database = AppDb();
  final TextEditingController categoryNameController = TextEditingController();
  int type = 2;

  Future<void> insert(String name, int type) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.categories).insertReturning(
        CategoriesCompanion.insert(
            name: name, type: type, createdAt: now, updateAt: now));

    print(row);
  }

  Future<List<Category>> getAllCategories(int type) async {
    return await database.getAllCategoriesRepo(type);
  }

  Future<int> updateCategory(int id, String name) async {
    return await database.updateCategory(id, name);
  }

  void openDialog(Category? category) {
    if (category != null) {
      categoryNameController.text = category.name;
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Text(
                      (isExpense) ? "Add Expense" : "Add Income",
                      style: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: (isExpense) ? Colors.red : Colors.green),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: categoryNameController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), hintText: "Name"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (category == null) {
                            insert(
                                categoryNameController.text, isExpense ? 2 : 1);
                          } else {
                            updateCategory(
                                category.id, categoryNameController.text);
                          }

                          Navigator.of(context, rootNavigator: true)
                              .pop('dialog');
                          setState(() {});
                          categoryNameController.clear();
                        },
                        child: const Text("Save"))
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Switch(
                value: isExpense,
                onChanged: (bool value) {
                  setState(() {
                    isExpense = value;
                    type = value ? 2 : 1;
                  });
                },
                inactiveTrackColor: Colors.green[200],
                inactiveThumbColor: Colors.green,
                activeColor: Colors.red,
              ),
              IconButton(
                  onPressed: () {
                    openDialog(null);
                  },
                  icon: const Icon(Icons.add))
            ],
          ),
        ),
        FutureBuilder(
            future: getAllCategories(type),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.hasData) {
                  if (snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              elevation: 5,
                              child: ListTile(
                                leading: (isExpense)
                                    ? const Icon(
                                        Icons.upload,
                                        color: Colors.red,
                                      )
                                    : const Icon(
                                        Icons.download,
                                        color: Colors.green,
                                      ),
                                title: Text(snapshot.data![index].name),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          database.deleteCategoryRepo(
                                              snapshot.data![index].id);
                                          setState(() {});
                                        },
                                        icon: const Icon(Icons.delete)),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          openDialog(snapshot.data![index]);
                                        },
                                        icon: const Icon(Icons.edit))
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  } else {
                    return const Center(
                      child: Text("Tida ada data!"),
                    );
                  }
                } else {
                  return const Center(
                    child: Text("Tidak ada data!"),
                  );
                }
              }
            }),
      ],
    ));
  }
}
