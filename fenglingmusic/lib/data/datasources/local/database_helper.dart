import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite database helper for FengLingMusic
/// Manages database initialization, versioning, and schema migrations
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  // Database configuration
  static const String _databaseName = 'fengling_music.db';
  static const int _databaseVersion = 1;

  DatabaseHelper._internal();

  /// Get database instance (lazy initialization)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Configure database settings before opening
  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _createIndexes(db);
  }

  /// Create all database tables
  Future<void> _createTables(Database db) async {
    // Songs table - stores music file information
    await db.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT,
        album TEXT,
        album_artist TEXT,
        duration INTEGER NOT NULL DEFAULT 0,
        file_path TEXT NOT NULL UNIQUE,
        file_size INTEGER NOT NULL DEFAULT 0,
        mime_type TEXT,
        bit_rate INTEGER,
        sample_rate INTEGER,
        track_number INTEGER,
        disc_number INTEGER,
        year INTEGER,
        genre TEXT,
        cover_path TEXT,
        lyrics_path TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        play_count INTEGER NOT NULL DEFAULT 0,
        skip_count INTEGER NOT NULL DEFAULT 0,
        rating REAL DEFAULT 0,
        date_added INTEGER NOT NULL,
        date_modified INTEGER NOT NULL,
        last_played INTEGER
      )
    ''');

    // Artists table - stores artist information
    await db.execute('''
      CREATE TABLE artists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        cover_path TEXT,
        song_count INTEGER NOT NULL DEFAULT 0,
        album_count INTEGER NOT NULL DEFAULT 0,
        date_added INTEGER NOT NULL
      )
    ''');

    // Albums table - stores album information
    await db.execute('''
      CREATE TABLE albums (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT,
        album_artist TEXT,
        year INTEGER,
        genre TEXT,
        cover_path TEXT,
        song_count INTEGER NOT NULL DEFAULT 0,
        total_duration INTEGER NOT NULL DEFAULT 0,
        date_added INTEGER NOT NULL,
        UNIQUE(title, album_artist)
      )
    ''');

    // Playlists table - stores user-created playlists
    await db.execute('''
      CREATE TABLE playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        cover_path TEXT,
        song_count INTEGER NOT NULL DEFAULT 0,
        total_duration INTEGER NOT NULL DEFAULT 0,
        date_created INTEGER NOT NULL,
        date_modified INTEGER NOT NULL
      )
    ''');

    // PlaylistSongs table - links songs to playlists
    await db.execute('''
      CREATE TABLE playlist_songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlist_id INTEGER NOT NULL,
        song_id INTEGER NOT NULL,
        position INTEGER NOT NULL,
        date_added INTEGER NOT NULL,
        FOREIGN KEY (playlist_id) REFERENCES playlists (id) ON DELETE CASCADE,
        FOREIGN KEY (song_id) REFERENCES songs (id) ON DELETE CASCADE,
        UNIQUE(playlist_id, song_id)
      )
    ''');

    // PlayHistory table - tracks song play history
    await db.execute('''
      CREATE TABLE play_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id INTEGER NOT NULL,
        play_timestamp INTEGER NOT NULL,
        play_duration INTEGER NOT NULL DEFAULT 0,
        completion_rate REAL NOT NULL DEFAULT 0,
        source TEXT,
        FOREIGN KEY (song_id) REFERENCES songs (id) ON DELETE CASCADE
      )
    ''');

    // Settings table - stores application settings
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        type TEXT NOT NULL,
        date_modified INTEGER NOT NULL
      )
    ''');

    // DownloadQueue table - manages download queue
    await db.execute('''
      CREATE TABLE download_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT,
        album TEXT,
        source_url TEXT NOT NULL,
        target_path TEXT NOT NULL,
        file_size INTEGER,
        downloaded_size INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'pending',
        error_message TEXT,
        quality TEXT,
        date_added INTEGER NOT NULL,
        date_started INTEGER,
        date_completed INTEGER
      )
    ''');
  }

  /// Create indexes for better query performance
  Future<void> _createIndexes(Database db) async {
    // Songs table indexes
    await db.execute('CREATE INDEX idx_songs_title ON songs (title)');
    await db.execute('CREATE INDEX idx_songs_artist ON songs (artist)');
    await db.execute('CREATE INDEX idx_songs_album ON songs (album)');
    await db.execute('CREATE INDEX idx_songs_is_favorite ON songs (is_favorite)');
    await db.execute('CREATE INDEX idx_songs_date_added ON songs (date_added DESC)');
    await db.execute('CREATE INDEX idx_songs_last_played ON songs (last_played DESC)');
    await db.execute('CREATE INDEX idx_songs_play_count ON songs (play_count DESC)');

    // Artists table indexes
    await db.execute('CREATE INDEX idx_artists_name ON artists (name)');

    // Albums table indexes
    await db.execute('CREATE INDEX idx_albums_title ON albums (title)');
    await db.execute('CREATE INDEX idx_albums_artist ON albums (album_artist)');
    await db.execute('CREATE INDEX idx_albums_year ON albums (year DESC)');

    // Playlists table indexes
    await db.execute('CREATE INDEX idx_playlists_name ON playlists (name)');
    await db.execute('CREATE INDEX idx_playlists_date_created ON playlists (date_created DESC)');

    // PlaylistSongs table indexes
    await db.execute('CREATE INDEX idx_playlist_songs_playlist_id ON playlist_songs (playlist_id)');
    await db.execute('CREATE INDEX idx_playlist_songs_song_id ON playlist_songs (song_id)');
    await db.execute('CREATE INDEX idx_playlist_songs_position ON playlist_songs (playlist_id, position)');

    // PlayHistory table indexes
    await db.execute('CREATE INDEX idx_play_history_song_id ON play_history (song_id)');
    await db.execute('CREATE INDEX idx_play_history_timestamp ON play_history (play_timestamp DESC)');

    // DownloadQueue table indexes
    await db.execute('CREATE INDEX idx_download_queue_status ON download_queue (status)');
    await db.execute('CREATE INDEX idx_download_queue_date_added ON download_queue (date_added)');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration strategy for future versions
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE songs ADD COLUMN new_field TEXT');
    // }
    // if (oldVersion < 3) {
    //   // More migrations...
    // }
  }

  /// Close database connection
  Future<void> close() async {
    final Database? db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Delete database (for testing or reset purposes)
  Future<void> deleteDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, _databaseName);
    await close();
    await databaseFactory.deleteDatabase(path);
  }

  /// Execute raw query
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final Database db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Execute raw insert/update/delete
  Future<int> rawExecute(String sql, [List<dynamic>? arguments]) async {
    final Database db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  /// Begin transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final Database db = await database;
    return await db.transaction(action);
  }
}
