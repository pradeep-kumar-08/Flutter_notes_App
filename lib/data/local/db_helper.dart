import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  //singleton
  DbHelper._(); //privatize ho jata he,is packege je bahar bahar iska object crste nhi hoga

  static final DbHelper getInstance = DbHelper._();
  // table note
  static final String TABLE_NOTE = "note";
  static final String COLUMN_NOTE_sno = "s_no";
  static final String COLUMN_NOTE_title = "title";
  static final String COLUMN_NOTE_desc = "desc";

  // we need to databse object
  Database? myDB; //nullable banana pdega inis=tiali initilize nahi he

  // Db open(path ->if exist than open else create)
  Future<Database> getDb() async {
    // ?? If it is null
    myDB ??=
        await openDB(); // Agar myDB null nahi he to db hi rahega usme if agam null he to oprDB myDB me assing hi jayege
    return myDB!;

    /* if (myDB != null) {
      return myDB!;
    } else {
      myDB = await openDB();
      return myDB!;
    }*/
  }

  Future<Database> openDB() async {
    // create path
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "note.db");

    return await openDatabase(
      dbPath,
      onCreate: (db, version) {
        // yaha vo kam krenege jo init mode me chahate he
        // create all table here
        db.execute(
          "create table $TABLE_NOTE($COLUMN_NOTE_sno integer primary key autoincrement,$COLUMN_NOTE_title text,$COLUMN_NOTE_desc text)",
        );
      },
      version: 1,
    );
  }

  //all query
  // insert
  Future<bool> addNote({required String mTitle, required String mDesc}) async {
    var db = await getDb();
    int rowsEffected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_title: mTitle,
      COLUMN_NOTE_desc: mDesc,
    });
    return rowsEffected > 0;
  }

  //reading all data
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDb();
    //Select * from note
    List<Map<String, dynamic>> mData = await db.query(
      TABLE_NOTE,
    ); //sara record list of map me ayega
    return mData;
  }

  //Update data
  Future<bool> updateNote({
    required String mTitle,
    required String mDesc,
    required int sno,
  }) async {
    var db = await getDb();
    int rowseffected = await db.update(TABLE_NOTE, {
      COLUMN_NOTE_title: mTitle,
      COLUMN_NOTE_desc: mDesc,
    }, where: "$COLUMN_NOTE_sno=$sno");
    return rowseffected > 0;
  }

  // Delete
  Future<bool> deleteNote({required int sno}) async {
    var db = await getDb();
    int rowsEffected =
        await db.delete(
          TABLE_NOTE,
          where: "$COLUMN_NOTE_sno=?",
          whereArgs: ["$sno"],
        );
    return rowsEffected > 0;
  }
}
