class UserStats {
  final int? id;
  final int points;
  final int messagesCount;
  final int dailyLimit;
  final String lastReset;

  UserStats({
    this.id,
    this.points = 100,
    this.messagesCount = 0,
    this.dailyLimit = 50,
    String? lastReset,
  }) : lastReset = lastReset ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'points': points,
      'messagesCount': messagesCount,
      'dailyLimit': dailyLimit,
      'lastReset': lastReset,
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      id: map['id'] as int?,
      points: map['points'] as int,
      messagesCount: map['messagesCount'] as int,
      dailyLimit: map['dailyLimit'] as int,
      lastReset: map['lastReset'] as String,
    );
  }

  UserStats copyWith({
    int? id,
    int? points,
    int? messagesCount,
    int? dailyLimit,
    String? lastReset,
  }) {
    return UserStats(
      id: id ?? this.id,
      points: points ?? this.points,
      messagesCount: messagesCount ?? this.messagesCount,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      lastReset: lastReset ?? this.lastReset,
    );
  }
}
