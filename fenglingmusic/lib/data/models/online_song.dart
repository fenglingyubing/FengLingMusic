import 'package:dio/dio.dart';
import '../../services/network/dio_client.dart';

/// 在线音乐搜索结果数据模型
class OnlineSong {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int duration;
  final String? coverUrl;
  final String platform; // 'netease', 'qq', 'kugou'

  OnlineSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    this.coverUrl,
    required this.platform,
  });

  factory OnlineSong.fromJson(Map<String, dynamic> json, String platform) {
    return OnlineSong(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? '',
      artist: json['artist'] ?? json['ar']?[0]?['name'] ?? '',
      album: json['album'] ?? json['al']?['name'] ?? '',
      duration: json['duration'] ?? json['dt'] ?? 0,
      coverUrl: json['coverUrl'] ?? json['al']?['picUrl'],
      platform: platform,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'coverUrl': coverUrl,
      'platform': platform,
    };
  }
}
