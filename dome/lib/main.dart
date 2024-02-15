import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:dome/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenUtilInit(
      designSize: Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        title: 'DoMe',
        home: MyHomePage(title: 'Task'),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Db myDb = Db();
  String? selectedDate;
  Future<List<Map>> readData() async {
    List<Map> response = await myDb.readData("SELECT * FROM tasks");
    return response;
  }

  TextEditingController nController = TextEditingController();
  TextEditingController dController = TextEditingController();
  TextEditingController taskName = TextEditingController();
  TextEditingController taskDescription = TextEditingController();

  @override
  Widget build(BuildContext context) {
    dynamic size = MediaQuery.of(context).size;
    double screenWidth = size.width;
    double screenHeight = size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () async {
                await myDb.deleteDataBase();
              },
              icon: Icon(
                Icons.delete,
                size: 25.sp,
              ),
            ),
          ],
          backgroundColor: Colors.teal,
          title: Text(widget.title),
        ),
        body: ListView(
          children: [
            FutureBuilder(
                future: readData(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!.length != 0 ? ListView.builder(
                      itemCount: snapshot.data!.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onDoubleTap: () async{
                            int response = await myDb.updateData('''
                        isDone = "TRUE"
                        WHERE id = ${snapshot.data![index]['id']}
                        ''');
                    print(response);
                          },
                          onLongPress: () {
                            delete(context, snapshot, index);
                          },
                          onTap: () {
                            edit(context, snapshot, index);
                          },
                          child: Container(
                            height: 100.h,
                            decoration: BoxDecoration(
                                border: Border(
                              bottom:
                                  BorderSide(width: 0.5.sp, color: Colors.grey),
                            )),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: screenWidth / 40,
                                  ),
                                  Container(
                                    height: 60.w,
                                    width: 60.w,
                                    decoration: BoxDecoration(
                                      color: Colors.teal,
                                      borderRadius: BorderRadius.circular(60.w),
                                    ),
                                    child: Center(
                                        child: Text(
                                      "${snapshot.data![index]['title'][0]}",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 17.sp),
                                    )),
                                  ),
                                  SizedBox(
                                    width: screenWidth / 20,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "${snapshot.data![index]['title']}.....${snapshot.data![index]['id']}....",
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colors.black)),
                                      dateOrDone(snapshot, index),
                                      Text(
                                          "${snapshot.data![index]['subtitle']}",
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              color: Colors.black)),
                                    ],
                                  ),
                                ]),
                          ),
                        );
                      },
                    ) : Center(child: Text("Add some tasks"),);
                  }
                  return const CircularProgressIndicator();
                })
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal,
          onPressed: () async {
            await madeOne(context);
            setState(() {
              Future<List<Map>> readData() async {
                List<Map> response = await myDb.readData("SELECT * FROM tasks");
                return response;
              }
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Text dateOrDone(
      AsyncSnapshot<List<Map<dynamic, dynamic>>> snapshot, int index) {
    return "${snapshot.data![index]['isDone']}" == "TRUE"
        ? Text("Completed",
            style: TextStyle(
                fontSize: 12.sp, color: const Color.fromARGB(255, 1, 88, 23)))
        : Text("${snapshot.data![index]['date']}",
            style: TextStyle(
                fontSize: 12.sp, color: const Color.fromARGB(255, 142, 17, 8)));
  }

  Future<dynamic> delete(BuildContext context,
      AsyncSnapshot<List<Map<dynamic, dynamic>>> snapshot, int index) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(
                  "Would you like to delete this task?",
                  style: TextStyle(fontSize: 12.sp),
                ),
                actions: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal),
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal),
                      child: Text('OK'),
                      onPressed: () async {
                        int response = await myDb.insertData(
                            "DELETE FROM tasks WHERE id = ${snapshot.data![index]['id']}");
                        print(response);
                        setState(() {
                          Future<List<Map>> readData() async {
                            List<Map> response =
                                await myDb.readData("SELECT * FROM tasks");
                            return response;
                          }
                        });
                        Navigator.of(context).pop();
                      })
                ]));
  }

  Future<dynamic> edit(BuildContext context,
      AsyncSnapshot<List<Map<dynamic, dynamic>>> snapshot, int index) {
    taskName.text = snapshot.data![index]['title'];
    taskDescription.text = snapshot.data![index]['subtitle'];
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("edit Task"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                        child: TextField(
                      controller: taskName,
                      autofocus: true,
                      decoration: InputDecoration(hintText: "Name"),
                    )),
                    SizedBox(height: 15),
                    SizedBox(
                        height: 200,
                        child: TextField(
                          controller: taskDescription,
                          maxLines: null,
                          decoration: InputDecoration(hintText: "Description"),
                        )),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: Text('OK'),
                  onPressed: () async {
                    int response = await myDb.updateData('''
                        UPDATE tasks SET title = "${taskName.text}" ,
                        subtitle = "${taskDescription.text}" ,
                        isDone = "TRUE"
                        WHERE id = ${snapshot.data![index]['id']}
                        ''');
                    print(response);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  Future<dynamic> madeOne(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Make Task"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                        child: TextField(
                      controller: nController,
                      autofocus: true,
                      decoration: const InputDecoration(
                          focusColor: Colors.teal, hintText: "Name"),
                    )),
                    SizedBox(height: 10.h),
                    SizedBox(
                        height: 50,
                        child: TextField(
                          controller: dController,
                          maxLines: null,
                          decoration: const InputDecoration(
                              fillColor: Colors.teal,
                              hoverColor: Colors.teal,
                              focusColor: Colors.teal,
                              hintText: "Description"),
                        )),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () {
                        datePicker(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        height: 35.h,
                        decoration:
                            BoxDecoration(border: Border.all(width: .2.w)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Set Your Deadline:",
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            Icon(
                              Icons.date_range,
                              size: 13.sp,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: Text('OK'),
                  onPressed: () async {
                    int response = await myDb.insertData(
                        "INSERT INTO 'tasks' ('title','subtitle','date','isDone') VALUES ('${nController.text}','${dController.text}','${selectedDate.toString()}','FALSE')",);
                    print(response);
                    nController.clear();
                    dController.clear();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  void datePicker(BuildContext context) {
    return BottomPicker.date(
      title: "Set deadline",
      displayCloseIcon: false,
      minDateTime: DateTime.now(),
      initialDateTime: DateTime.now(),
      titleStyle: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 15.sp, color: Colors.black),
      onChange: (picked) {
        selectedDate = DateFormat(picked);
        print("$picked >>>>>> $selectedDate");
      },
      onSubmit: (picked) {
        selectedDate = DateFormat(picked);
        print("$picked ############ $selectedDate");
      },
      bottomPickerTheme: BottomPickerTheme.plumPlate,
    ).show(context);
  }
}

String DateFormat(DateTime date) {
  int year, day, month;
  year = date.year;
  day = date.day;
  month = date.month;
  return "$day/$month/$year";
}
