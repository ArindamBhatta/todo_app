import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/features/vault/data/models/vault_item.dart';
import 'package:uuid/uuid.dart';

class VaultStorage {
  VaultStorage._();
  static final VaultStorage instance = VaultStorage._();

  static const _pinKey = 'vault_pin_hash';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'vault_database.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE vault_items(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            file_path TEXT,
            secret_note TEXT,
            file_size INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            file_extension TEXT
          )
        ''');
      },
    );
  }

  // --- Security Helpers ---

  String _hashPin(String pin) {
    final bytes = utf8.encode('salt_vault_app_$pin');
    return sha256.convert(bytes).toString();
  }

  Future<bool> isPinSet() async {
    final pinHash = await _secureStorage.read(key: _pinKey);
    return pinHash != null && pinHash.isNotEmpty;
  }

  Future<bool> setPin(String newPin) async {
    final hashed = _hashPin(newPin);
    await _secureStorage.write(key: _pinKey, value: hashed);
    return true;
  }

  Future<bool> verifyPin(String inputPin) async {
    final storedHash = await _secureStorage.read(key: _pinKey);
    if (storedHash == null) return false;
    return storedHash == _hashPin(inputPin);
  }

  Future<bool> canCheckBiometrics() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canAuthenticateWithBiometrics && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateBiometrics() async {
    try {
      final available = await canCheckBiometrics();
      if (!available) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to open your Private Vault',
      );
    } catch (_) {
      return false;
    }
  }

  // --- File Storage Helpers ---

  Future<Directory> _getVaultDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory(p.join(appDir.path, 'app_vault'));
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }
    return vaultDir;
  }

  // --- Items Database Operations ---

  Future<List<VaultItem>> getVaultItems({String? category}) async {
    final db = await database;
    final List<Map<String, Object?>> maps;
    if (category != null && category != 'all') {
      maps = await db.query(
        'vault_items',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'created_at DESC',
      );
    } else {
      maps = await db.query('vault_items', orderBy: 'created_at DESC');
    }

    return maps.map((map) => VaultItem.fromJson(map)).toList();
  }

  Future<VaultItem> addSecretNote({
    required String title,
    required String content,
  }) async {
    final db = await database;
    final item = VaultItem(
      id: const Uuid().v4(),
      title: title,
      category: 'note',
      secretNote: content,
      fileSize: utf8.encode(content).length,
      createdAt: DateTime.now(),
    );

    await db.insert('vault_items', item.toJson());
    return item;
  }

  Future<VaultItem> addFileItem({
    required String title,
    required String category,
    required String sourceFilePath,
  }) async {
    final db = await database;
    final sourceFile = File(sourceFilePath);

    final vaultDir = await _getVaultDirectory();
    final extension = p.extension(sourceFilePath).replaceFirst('.', '');
    final newFileName = '${const Uuid().v4()}.${extension.isEmpty ? "bin" : extension}';
    final targetPath = p.join(vaultDir.path, newFileName);

    // Copy file into app vault storage
    if (await sourceFile.exists()) {
      await sourceFile.copy(targetPath);
    }

    final fileSize = await File(targetPath).exists() ? await File(targetPath).length() : 0;

    final item = VaultItem(
      id: const Uuid().v4(),
      title: title,
      category: category,
      filePath: targetPath,
      fileSize: fileSize,
      createdAt: DateTime.now(),
      fileExtension: extension,
    );

    await db.insert('vault_items', item.toJson());
    return item;
  }

  Future<void> deleteVaultItem(String id) async {
    final db = await database;
    final results = await db.query(
      'vault_items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      final item = VaultItem.fromJson(results.first);
      if (item.filePath != null) {
        final file = File(item.filePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await db.delete('vault_items', where: 'id = ?', whereArgs: [id]);
    }
  }
}
