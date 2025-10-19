import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = "http://10.76.185.48:8000";

  // ---------- HEALTH CHECK ----------
  static Future<Map<String, dynamic>> healthCheck() async {
    final res = await http.get(Uri.parse("$baseUrl/"));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Health check failed: ${res.statusCode}");
    }
  }

  // ---------- HAIR ANALYZER ----------
  static Future<Map<String, dynamic>> analyzeHair({
    File? file,
    Uint8List? webImage,
  }) async {
    final uri = Uri.parse('$baseUrl/analyze');
    final request = http.MultipartRequest('POST', uri);

    if (kIsWeb && webImage != null) {
      request.files.add(
        http.MultipartFile.fromBytes('file', webImage, filename: 'hair.png'),
      );
    } else if (file != null) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    } else {
      throw Exception("No image provided for analysis.");
    }

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final rawData = jsonDecode(respStr);
      
      return {
        'score': rawData['damage_score'] ?? 0.0,
        'damage_score': rawData['damage_score'] ?? 0.0,
        'detected_texture': rawData['detected_texture'] ?? 'Unknown',
        'primary_concern': rawData['primary_concern'] ?? 'N/A',
        'recommended_product': rawData['recommended_product'] ?? 'N/A',
        'level': rawData['level'] ?? 'Unknown',
        'care_level': rawData['care_level'] ?? 'Gentle',
        'key_ingredients': rawData['key_ingredients'],
        'benefit': rawData['benefit'],
        'hair_type': rawData['hair_type'] ?? 'Unknown',
        'message': rawData['message'] ?? '',
      };
    } else {
      throw Exception("Failed to analyze hair: $respStr");
    }
  }

  // ---------- SAVE SCAN ----------
  static Future<Map<String, dynamic>> saveScan(Map<String, dynamic> scanData) async {
    final dataToSend = {
      'damage_score': scanData['score'] ?? scanData['damage_score'] ?? 0.0,
      'level': scanData['level'] ?? 'Unknown',
      'detected_texture': scanData['detected_texture'] ?? 'Unknown',
      'recommended_product': scanData['recommended_product'] ?? 'N/A',
      'primary_concern': scanData['primary_concern'] ?? 'N/A',
      'care_level': scanData['care_level'] ?? 'Gentle',
    };

    print('📤 Sending scan data to backend: $dataToSend');

    final res = await http.post(
      Uri.parse("$baseUrl/save_scan"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dataToSend),
    );

    if (res.statusCode == 200) {
      print('✅ Save scan response: ${res.body}');
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to save scan: ${res.body}");
    }
  }

  // ---------- HISTORY ----------
  static Future<List<dynamic>> getHistory() async {
    final res = await http.get(Uri.parse("$baseUrl/history"));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to fetch history");
    }
  }

  // ---------- INSIGHTS ----------
  static Future<Map<String, dynamic>> getInsights() async {
    final res = await http.get(Uri.parse("$baseUrl/insights"));
    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      print('📊 Insights received: $data');
      return data;
    } else {
      throw Exception("Failed to fetch insights");
    }
  }

  // ---------- MAYA GREET (NEW) ----------
  static Future<Map<String, dynamic>> mayaGreet() async {
    final res = await http.get(Uri.parse("$baseUrl/maya_greet"));
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes));
    } else {
      throw Exception("Maya greet failed: ${res.body}");
    }
  }

  // ---------- MAYA ANALYZE SCAN (NEW) ----------
  static Future<Map<String, dynamic>> mayaAnalyzeScan() async {
    final res = await http.get(Uri.parse("$baseUrl/maya_analyze_scan"));
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes));
    } else {
      throw Exception("Maya analyze failed: ${res.body}");
    }
  }

  // ---------- MAYA PROGRESS REPORT (NEW) ----------
  static Future<Map<String, dynamic>> mayaProgressReport() async {
    final res = await http.get(Uri.parse("$baseUrl/maya_progress"));
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes));
    } else {
      throw Exception("Maya progress failed: ${res.body}");
    }
  }

  // ---------- MAYA CHAT (AI) ----------
  static Future<Map<String, dynamic>> chatWithMaya({
    required String question,
    String hairType = "Medium",
    double damageScore = 5.0,
    String concern = "Dryness",
  }) async {
    final uri = Uri.parse(
      "$baseUrl/maya_chat?q=$question&hair_type=$hairType&damage_score=$damageScore&concern=$concern",
    );

    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes));
    } else {
      throw Exception("Maya chat failed: ${res.body}");
    }
  }

  // ---------- TEXT TO SPEECH ----------
  static Future<dynamic> getTTS(String text) async {
    final uri = Uri.parse("$baseUrl/tts");
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"text": text}),
    );

    if (res.statusCode == 200) {
      final bytes = res.bodyBytes;

      if (kIsWeb) {
        return base64Encode(bytes);
      } else {
        final file = File('${Directory.systemTemp.path}/maya_voice.mp3');
        await file.writeAsBytes(bytes);
        return file;
      }
    } else {
      throw Exception("TTS failed: ${res.body}");
    }
  }

  // ---------- Analyze Hair and Save ----------
  static Future<Map<String, dynamic>> analyzeAndSaveHair(File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/analyze"));
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    var response = await request.send();

    if (response.statusCode == 200) {
      var respStr = await response.stream.bytesToString();
      final rawResult = jsonDecode(respStr);
      
      final result = {
        'score': rawResult['damage_score'] ?? 0.0,
        'damage_score': rawResult['damage_score'] ?? 0.0,
        'detected_texture': rawResult['detected_texture'] ?? 'Unknown',
        'primary_concern': rawResult['primary_concern'] ?? 'N/A',
        'recommended_product': rawResult['recommended_product'] ?? 'N/A',
        'level': rawResult['level'] ?? 'Unknown',
        'care_level': rawResult['care_level'] ?? 'Gentle',
      };

      await saveScan(result);
      return result;
    } else {
      throw Exception("Failed to analyze hair");
    }
  }



  
}