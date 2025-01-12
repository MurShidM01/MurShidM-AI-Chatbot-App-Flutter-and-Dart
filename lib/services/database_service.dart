import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/chat_message.dart';
import '../models/user_stats.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'chat_database.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT,
            isUser INTEGER,
            timestamp TEXT,
            isFavorite INTEGER DEFAULT 0,
            category TEXT,
            isError INTEGER DEFAULT 0,
            chatTitle TEXT,
            conversationId TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE conversations(
            id TEXT PRIMARY KEY,
            title TEXT,
            lastMessageTimestamp TEXT,
            messageCount INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE user_stats(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            points INTEGER DEFAULT 100,
            messagesCount INTEGER DEFAULT 0,
            dailyLimit INTEGER DEFAULT 50,
            lastReset TEXT
          )
        ''');

        // Initialize user stats
        await db.insert('user_stats', {
          'points': 100,
          'messagesCount': 0,
          'dailyLimit': 50,
          'lastReset': DateTime.now().toIso8601String(),
        });
      },
      version: 1,
    );
  }

  Future<int> insertMessage(ChatMessage message) async {
    final db = await database;
    return db.insert('messages', message.toMap());
  }

  Future<List<ChatMessage>> getMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) => ChatMessage.fromMap(maps[i]));
  }

  Future<void> toggleFavorite(int messageId) async {
    final db = await database;
    final message = await db.query(
      'messages',
      where: 'id = ?',
      whereArgs: [messageId],
    );
    
    if (message.isNotEmpty) {
      final currentFavorite = message.first['isFavorite'] as int;
      await db.update(
        'messages',
        {'isFavorite': currentFavorite == 0 ? 1 : 0},
        where: 'id = ?',
        whereArgs: [messageId],
      );
    }
  }

  Future<void> deleteMessage(int messageId) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<void> clearAllMessages() async {
    final db = await database;
    await db.delete('messages');
  }

  Future<List<ChatMessage>> getFavoriteMessages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) => ChatMessage.fromMap(maps[i]));
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    final db = await database;
    return db.rawQuery('''
      SELECT 
        conversationId,
        chatTitle,
        MAX(timestamp) as lastMessageTimestamp,
        COUNT(*) as messageCount,
        GROUP_CONCAT(CASE WHEN isUser = 0 THEN text ELSE NULL END) as aiResponses
      FROM messages 
      WHERE conversationId IS NOT NULL 
      GROUP BY conversationId 
      ORDER BY lastMessageTimestamp DESC
    ''');
  }

  Future<List<ChatMessage>> getConversationMessages(String conversationId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'conversationId = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) => ChatMessage.fromMap(maps[i]));
  }

  Future<UserStats?> getUserStats() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_stats');
    if (maps.isEmpty) {
      // Create initial stats if none exist
      final initialStats = UserStats();
      final id = await db.insert('user_stats', initialStats.toMap());
      return initialStats.copyWith(id: id);
    }
    return UserStats.fromMap(maps.first);
  }

  Future<void> updateUserStats(UserStats stats) async {
    final db = await database;
    if (stats.id == null) {
      await db.insert('user_stats', stats.toMap());
    } else {
      await db.update(
        'user_stats',
        stats.toMap(),
        where: 'id = ?',
        whereArgs: [stats.id],
      );
    }
  }

  Future<void> resetDailyStats() async {
    final db = await database;
    final stats = await getUserStats();
    if (stats == null) return;

    final now = DateTime.now();
    final lastReset = DateTime.parse(stats.lastReset);
    
    if (now.difference(lastReset).inHours >= 24) {
      final newStats = stats.copyWith(
        points: 100,
        messagesCount: 0,
        lastReset: now.toIso8601String(),
      );
      await updateUserStats(newStats);
    }
  }
}
