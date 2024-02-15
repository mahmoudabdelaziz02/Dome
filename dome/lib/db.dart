import'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Db {
  static Database? _database;
  //to check if the database exists or not
  Future<Database?> get database async {
    if (_database == null){
      _database = await initialDb();
      return _database;
    }
    else {
      return _database;
    }

  }
 // to initialize the database
  initialDb() async {
    // a string which geting my path
    String dbPath = await getDatabasesPath();
    // a string which linking name with the database path
    String dbName = await join(dbPath,'tasks.db');
    Database myDatabase = await openDatabase(dbName,onCreate: _onCreate,version: 1);
    return myDatabase;

  }
  _onCreate(Database myDatabase , int version) async{
    //Create a table
    await myDatabase.execute('''
    CREATE TABLE "tasks" (
      "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      "title" TEXT NOT NULL,
      "subtitle" TEXT NOT NULL,
      "isDone" BOOLEAN NOT NULL,
      "date" TEXT NOT NULL
    )
  ''');
  print("CREATE TABLE tasks********************************");
  }
  //SELECT
  readData(String sql) async{
  Database? myDatabase = await database;
  List<Map> response = await myDatabase!.rawQuery(sql);
  return response;
  }
  //INSERT
  insertData(String sql) async{
  Database? myDatabase = await database;
  int response = await myDatabase!.rawInsert(sql);
  return response;
  }
  //UPDATE
  updateData(String sql) async{
  Database? myDatabase = await database;
  int response = await myDatabase!.rawUpdate(sql);
  return response;
  }
  //DELETE
  deleteData(String sql) async{
  Database? myDatabase = await database;
  int response = await myDatabase!.rawDelete(sql);
  return response;
  }

  deleteDataBase()async{
    // a string which geting my path
    String dbPath = await getDatabasesPath();
    // a string which linking name with the database path
    String dbName = await join(dbPath,'tasks.db');
    await deleteDatabase(dbName);
    print("deleted");
  }
}

