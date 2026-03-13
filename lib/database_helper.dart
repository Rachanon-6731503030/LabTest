import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CheckInData {
  int? id;
  String type; // 'checkin' or 'checkout'
  double latitude;
  double longitude;
  String timestamp;
  String? qrData;
  String? previousTopic;
  String? expectedTopic;
  int? mood;
  String? learnedToday;
  String? feedback;

  CheckInData({
    this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.qrData,
    this.previousTopic,
    this.expectedTopic,
    this.mood,
    this.learnedToday,
    this.feedback,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'qrData': qrData,
      'previousTopic': previousTopic,
      'expectedTopic': expectedTopic,
      'mood': mood,
      'learnedToday': learnedToday,
      'feedback': feedback,
    };
  }

  factory CheckInData.fromMap(Map<String, dynamic> map) {
    return CheckInData(
      id: map['id'],
      type: map['type'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      timestamp: map['timestamp'],
      qrData: map['qrData'],
      previousTopic: map['previousTopic'],
      expectedTopic: map['expectedTopic'],
      mood: map['mood'],
      learnedToday: map['learnedToday'],
      feedback: map['feedback'],
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'checkin_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE checkins(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        latitude REAL,
        longitude REAL,
        timestamp TEXT,
        qrData TEXT,
        previousTopic TEXT,
        expectedTopic TEXT,
        mood INTEGER,
        learnedToday TEXT,
        feedback TEXT
      )
    ''');
  }

  Future<int> insertCheckIn(CheckInData checkIn) async {
    Database db = await database;
    return await db.insert('checkins', checkIn.toMap());
  }

  Future<List<CheckInData>> getCheckIns() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('checkins');
    return List.generate(maps.length, (i) {
      return CheckInData.fromMap(maps[i]);
    });
  }
}
