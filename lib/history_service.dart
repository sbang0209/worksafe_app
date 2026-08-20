import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 하나의 분석 기록. [GeminiService.analyzeObject] 결과 Map 과
/// 사진 경로, 분석 시각을 함께 담는다.
class HistoryEntry {
  HistoryEntry({
    required this.id,
    required this.result,
    required this.imagePath,
    required this.timestamp,
  });

  final String id;
  final Map<String, dynamic> result;
  final String imagePath;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
    'id': id,
    'result': result,
    'imagePath': imagePath,
    'timestamp': timestamp.toIso8601String(),
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
    id: json['id'] as String,
    result: Map<String, dynamic>.from(json['result'] as Map),
    imagePath: json['imagePath'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  /// "2026-08-20 14:05" 형태로 사람이 읽기 좋게 표시한다.
  String get formattedTimestamp {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${timestamp.year}-${two(timestamp.month)}-${two(timestamp.day)} '
        '${two(timestamp.hour)}:${two(timestamp.minute)}';
  }
}

/// 분석 기록을 폰에 저장/조회/삭제하는 서비스.
///
/// - 기록 목록(메타데이터)은 shared_preferences 에 JSON 리스트로 저장한다.
/// - 사진 파일은 앱 문서 디렉토리 아래 history_images/ 에 복사해서 보관하고,
///   JSON 에는 그 파일 경로만 남긴다.
/// - 최근 [_maxEntries] 개만 유지하며, 넘치면 가장 오래된 기록과 그 사진을 함께 지운다.
class HistoryService {
  HistoryService._();

  static final HistoryService instance = HistoryService._();

  static const _prefsKey = 'history_entries';
  static const _maxEntries = 20;

  /// 기록을 추가한다. [imageFile] 은 앱 문서 디렉토리로 복사되어 보관된다.
  Future<void> add({
    required Map<String, dynamic> result,
    required File imageFile,
  }) async {
    final savedImagePath = await _copyImage(imageFile);
    final entry = HistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      result: result,
      imagePath: savedImagePath,
      timestamp: DateTime.now(),
    );

    final entries = await getAll();
    entries.insert(0, entry);

    final removed = <HistoryEntry>[];
    while (entries.length > _maxEntries) {
      removed.add(entries.removeLast());
    }
    for (final old in removed) {
      await _deleteImageFile(old.imagePath);
    }

    await _saveAll(entries);

    final name = (result['name'] as String?) ?? '알 수 없음';
    debugPrint('기록 저장됨: $name, 현재 기록 수: ${entries.length}');
  }

  /// 저장된 모든 기록을 최신순으로 돌려준다.
  Future<List<HistoryEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map(
            (e) => HistoryEntry.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (e) {
      debugPrint('HistoryService: 기록을 불러오지 못했습니다: $e');
      return [];
    }
  }

  /// 오늘(연-월-일 기준) 같은 [name] 으로 저장된 기록이 있으면 그 기록을 돌려준다.
  /// 없으면 null.
  Future<HistoryEntry?> findDuplicateToday(String name) async {
    final entries = await getAll();
    final today = DateTime.now();
    for (final entry in entries) {
      final t = entry.timestamp;
      final sameDay =
          t.year == today.year && t.month == today.month && t.day == today.day;
      if (sameDay && entry.result['name'] == name) {
        return entry;
      }
    }
    return null;
  }

  /// id 로 기록 하나를 지운다. 사진 파일도 함께 지운다.
  Future<void> delete(String id) async {
    final entries = await getAll();
    final index = entries.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final removed = entries.removeAt(index);
    await _deleteImageFile(removed.imagePath);
    await _saveAll(entries);
  }

  /// 모든 기록과 사진 파일을 지운다.
  Future<void> clear() async {
    final entries = await getAll();
    for (final entry in entries) {
      await _deleteImageFile(entry.imagePath);
    }
    await _saveAll([]);
  }

  Future<void> _saveAll(List<HistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  Future<String> _copyImage(File imageFile) async {
    final dir = await getApplicationDocumentsDirectory();
    final historyDir = Directory(p.join(dir.path, 'history_images'));
    if (!await historyDir.exists()) {
      await historyDir.create(recursive: true);
    }
    final fileName =
        '${DateTime.now().microsecondsSinceEpoch}${p.extension(imageFile.path)}';
    final savedPath = p.join(historyDir.path, fileName);
    final copied = await imageFile.copy(savedPath);
    return copied.path;
  }

  Future<void> _deleteImageFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('HistoryService: 사진 삭제 실패: $e');
    }
  }
}
