import 'dart:convert';

import 'package:album_viewer_client/util/util.dart';
import 'package:http/http.dart' as http;

final String baseUrl =
    Uri.base.origin.contains("localhost")
        ? "http://localhost:8000"
        : Uri.base.origin;

class Tag {
  final int id;
  final String name;
  final DateTime addedAt;

  Tag({required this.id, required this.name, required this.addedAt});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] ?? 0,
      name: json['name'],
      addedAt: DateTime.parse(json['added_at']),
    );
  }
}

class Photo {
  final int id;
  final String name;
  final DateTime addedAt;
  final String link;

  Photo({
    required this.id,
    required this.name,
    required this.addedAt,
    required this.link,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] ?? 0,
      name: json['name'],
      addedAt: DateTime.parse(json['added_at']),
      link: "$baseUrl/images/${json['id']}/view",
    );
  }
}

class ASession {
  final String id;
  final int lifetime;
  final DateTime createdAt;

  ASession({required this.id, required this.lifetime, required this.createdAt});

  factory ASession.fromJson(Map<String, dynamic> json) {
    return ASession(
      id: json['id'],
      lifetime: json['lifetime'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class Stats {
  final int photoCount;
  final int tagCount;
  final int albumSize;

  Stats({
    required this.photoCount,
    required this.tagCount,
    required this.albumSize,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      albumSize: json['albumSize'],
      photoCount: json['photoCount'],
      tagCount: json['tagCount'],
    );
  }
}

Future<ASession> createSession(int duration) async {
  final res = await http.post(
    Uri.parse("$baseUrl/session/create?lifetime=$duration"),
    headers: {"Admin-Session": getPassword() ?? ""},
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to create session ${res.body}");
  }

  return ASession.fromJson(jsonDecode(res.body));
}

Future<Stats> fetchStats() async {
  final res = await http.get(Uri.parse("$baseUrl/stats${getSmid()}"));

  if (res.statusCode != 200) {
    throw Exception("Failed to fetch stats: ${res.body}");
  }

  return Stats.fromJson(jsonDecode(res.body));
}

Future<Photo> getRandom() async {
  final res = await http.get(Uri.parse("$baseUrl/random${getSmid()}"));

  if (res.statusCode != 200) {
    throw Exception("Failed to get random image: ${res.body}");
  }

  return Photo.fromJson(jsonDecode(res.body));
}

Future<Map<String, dynamic>> getExif(int photo) async {
  final res = await http.get(
    Uri.parse("$baseUrl/images/$photo/exif/${getSmid()}"),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to fetch exif: ${res.body}");
  }

  return jsonDecode(res.body);
}

Future<List<ASession>> getSessions() async {
  final res = await http.get(Uri.parse("$baseUrl/session/all"));

  if (res.statusCode != 200) {
    throw Exception("Failed to fetch all sessions: ${res.body}");
  }

  final List<dynamic> data = jsonDecode(res.body);

  return data.map((json) => ASession.fromJson(json)).toList();
}

Future<List<Photo>> fetchPhotos() async {
  final res = await http.get(Uri.parse("$baseUrl/images${getSmid()}"));

  if (res.statusCode != 200) {
    throw Exception("Failed to load albums");
  }

  final List<dynamic> data = jsonDecode(res.body);

  return data.map((json) => Photo.fromJson(json)).toList();
}

Future<List<Photo>> fetchPhotosByTag(String tag) async {
  final res = await http.get(Uri.parse("$baseUrl/images/$tag${getSmid()}"));

  if (res.statusCode != 200) {
    throw Exception("Failed to load albums: ${res.body}");
  }

  final List<dynamic> data = jsonDecode(res.body);

  return data.map((json) => Photo.fromJson(json)).toList();
}

Future<List<Tag>> fetchTags() async {
  final res = await http.get(Uri.parse("$baseUrl/tags${getSmid()}"));

  if (res.statusCode != 200) {
    throw Exception("Failed to load tags");
  }

  final List<dynamic> data = jsonDecode(res.body);

  return data.map((json) => Tag.fromJson(json)).toList();
}

Future<void> deletePhotos(List<int> imageIds) async {
  final res = await http.delete(
    Uri.parse("$baseUrl/images"),
    headers: {
      "Admin-Session": getPassword() ?? "",
      "Content-Type": "application/json",
    },
    body: jsonEncode({'images': imageIds}),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to delete file: ${res.body}");
  }
}

Future<void> manageImageTags(List<int> imageIds, int tagId, int op) async {
  final fn = op == 0 ? http.post : http.delete;

  final res = await fn(
    Uri.parse("$baseUrl/images/tags/$tagId"),
    headers: {
      'Content-Type': 'application/json',
      "Admin-Session": getPassword() ?? "",
    },
    body: jsonEncode({'images': imageIds}),
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to add tag to images ${res.body}");
  }
}

Future<void> createTag(String name) async {
  final res = await http.post(
    Uri.parse("$baseUrl/tags/$name${getSmid()}"),
    headers: {"Admin-Session": getPassword() ?? ""},
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to create tag ${res.body}");
  }
}

String getSmid() {
  return "?smid=${Uri.base.queryParameters["smid"]}";
}
