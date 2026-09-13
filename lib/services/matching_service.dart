// lib/services/matching_service.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MatchingService {
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const double _threshold = 0.75;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<MatchResult?> findMatches(
      Map<String, dynamic> newPost,
      String newPostId,
      ) async {
    try {
      if (_apiKey.isEmpty) {
        debugPrint(
          '❌ GROQ_API_KEY not set. Run with '
              '--dart-define-from-file=dart_define.json',
        );
        return null;
      }

      debugPrint('🔍 AI Matching started for: ${newPost['title']}');

      final String oppositeCategory =
      newPost['category'] == 'lost' ? 'found' : 'lost';

      final snapshot = await _db
          .collection('posts')
          .where('category', isEqualTo: oppositeCategory)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('No $oppositeCategory posts found');
        return null;
      }

      debugPrint(
          'Comparing with ${snapshot.docs.length} '
              '$oppositeCategory posts...'
      );

      double bestScore              = 0.0;
      String bestMatchId            = '';
      String bestReason             = '';
      Map<String, dynamic>? bestMatchPost;

      for (final doc in snapshot.docs) {
        final oppositePost   = doc.data();
        final oppositePostId = doc.id;

        if (oppositePost['postedByUid'] == newPost['postedByUid']) {
          continue;
        }

        final alreadyMatched = await _checkAlreadyMatched(
          newPostId, oppositePostId,
        );
        if (alreadyMatched) continue;

        final result = await _compareWithGroq(newPost, oppositePost);

        debugPrint(
            'Score with $oppositePostId: ${result['confidence']}'
        );

        if ((result['confidence'] as double) > bestScore) {
          bestScore     = result['confidence'] as double;
          bestMatchId   = oppositePostId;
          bestReason    = result['reason'] as String;
          bestMatchPost = oppositePost;
        }
      }

      if (bestMatchPost != null && bestScore >= _threshold) {
        debugPrint('✅ Match found! Score: $bestScore');
        await _handleMatch(
          newPost,       newPostId,
          bestMatchPost, bestMatchId,
          bestScore,     bestReason,
        );
        return MatchResult(
          isMatch:       true,
          confidence:    bestScore,
          reason:        bestReason,
          matchedPost:   bestMatchPost,
          matchedPostId: bestMatchId,
        );
      } else {
        debugPrint('❌ No match found. Best score: $bestScore');
        return MatchResult(
          isMatch:       false,
          confidence:    bestScore,
          reason:        'No matching item found yet.',
          matchedPost:   null,
          matchedPostId: '',
        );
      }
    } catch (e) {
      debugPrint('Error in findMatches: $e');
      return null;
    }
  }

  // Strips a Groq "reasoning model" <think>...</think> preamble and
  // any ```json code fences, leaving just the raw JSON body.
  static String _extractJson(String raw) {
    String cleaned = raw;
    final thinkPattern = RegExp(r'<think>[\s\S]*?<\/think>',
        multiLine: true, caseSensitive: false);
    cleaned = cleaned.replaceAll(thinkPattern, '');
    cleaned = cleaned.replaceAll('```json', '').replaceAll('```', '');
    return cleaned.trim();
  }

  static Future<Map<String, dynamic>> _compareWithGroq(
      Map<String, dynamic> post1,
      Map<String, dynamic> post2,
      ) async {
    try {
      final String? image1 =
      (post1['imageUrl'] as String?)?.isNotEmpty == true
          ? post1['imageUrl'] as String
          : null;
      final String? image2 =
      (post2['imageUrl'] as String?)?.isNotEmpty == true
          ? post2['imageUrl'] as String
          : null;

      final introText = '''
You are a lost and found item matching assistant 
for COMSATS University app.

Compare these two items and determine if they 
could be the same item. If images are attached below,
examine their visual appearance (color, shape, brand,
material, distinguishing marks) as part of your comparison,
not just the text.

ITEM 1 (${(post1['category'] as String).toUpperCase()}):
- Title: ${post1['title']}
- Description: ${post1['description']}
- Location: ${post1['location']}
${image1 == null ? '(No image provided for Item 1)' : ''}

ITEM 2 (${(post2['category'] as String).toUpperCase()}):
- Title: ${post2['title']}
- Description: ${post2['description']}
- Location: ${post2['location']}
${image2 == null ? '(No image provided for Item 2)' : ''}

Consider:
1. Are these the same type of item?
2. Do descriptions and images (if provided) suggest same item?
3. Are locations same or nearby campus areas?
4. Could this be same item reported as lost and found?

Do not show any reasoning or thinking. Reply ONLY with the JSON
object below, nothing else, no explanation:
{
  "match": true or false,
  "confidence": 0.0 to 1.0,
  "reason": "one sentence explanation"
}''';

      final List<Map<String, dynamic>> content = [
        {'type': 'text', 'text': introText},
      ];

      if (image1 != null) {
        content.add({'type': 'text', 'text': 'Image of ITEM 1:'});
        content.add({
          'type': 'image_url',
          'image_url': {'url': image1},
        });
      }

      if (image2 != null) {
        content.add({'type': 'text', 'text': 'Image of ITEM 2:'});
        content.add({
          'type': 'image_url',
          'image_url': {'url': image2},
        });
      }

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type':  'application/json',
        },
        body: jsonEncode({
          'model': 'qwen/qwen3.6-27b',
          'messages': [
            {
              'role':    'user',
              'content': content,
            }
          ],
          'temperature': 0.1,
          'max_tokens':  400,
        }),
      );

      if (response.statusCode == 200) {
        final data    = jsonDecode(response.body);
        final text    = data['choices'][0]['message']['content'] as String;
        final cleaned = _extractJson(text);

        if (cleaned.isEmpty) {
          debugPrint('Groq returned no usable content after cleanup.');
          return {'match': false, 'confidence': 0.0, 'reason': 'Empty response'};
        }

        final parsed = jsonDecode(cleaned);
        return {
          'match':      parsed['match']      ?? false,
          'confidence': (parsed['confidence'] as num).toDouble(),
          'reason':     parsed['reason']     ?? 'No reason',
        };
      } else {
        debugPrint('Groq API error: ${response.body}');
        return {
          'match':      false,
          'confidence': 0.0,
          'reason':     'API error',
        };
      }
    } catch (e) {
      debugPrint('Groq API error: $e');
      return {
        'match':      false,
        'confidence': 0.0,
        'reason':     'Error occurred',
      };
    }
  }

  static Future<String?> _getAdminUid() async {
    try {
      final snap = await _db
          .collection('profiles')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      return snap.docs.first.id;
    } catch (e) {
      return null;
    }
  }

  static Future<void> _handleMatch(
      Map<String, dynamic> post1,   String post1Id,
      Map<String, dynamic> post2,   String post2Id,
      double score,                 String reason,
      ) async {
    try {
      final bool isPost1Lost  = post1['category'] == 'lost';
      final lostPost          = isPost1Lost ? post1  : post2;
      final foundPost         = isPost1Lost ? post2  : post1;
      final String lostId     = isPost1Lost ? post1Id : post2Id;
      final String foundId    = isPost1Lost ? post2Id : post1Id;

      final bool heldByAdmin = foundPost['custody'] == 'admin';
      String? adminUid;
      if (heldByAdmin) {
        adminUid = await _getAdminUid();
      }

      final matchRef = await _db.collection('matches').add({
        'lostPostId':   lostId,
        'foundPostId':  foundId,
        'lostUserUid':  lostPost['postedByUid'],
        'foundUserUid': foundPost['postedByUid'],
        'confidence':   score,
        'reason':       reason,
        'status':       'pending',
        'heldByAdmin':  heldByAdmin,
        'createdAt':    FieldValue.serverTimestamp(),
      });

      debugPrint('Match saved: ${matchRef.id}');

      final List<String> baseUids = [
        lostPost['postedByUid']  as String,
        foundPost['postedByUid'] as String,
      ]..sort();

      final String finalChatId = baseUids.join('_');

      final List<String> participants = List<String>.from(baseUids);
      if (heldByAdmin && adminUid != null && !participants.contains(adminUid)) {
        participants.add(adminUid);
      }

      await _db.collection('chats').doc(finalChatId).set({
        'participants':  participants,
        'itemTitle':     lostPost['title'],
        'matchId':       matchRef.id,
        'lostPostId':    lostId,
        'foundPostId':   foundId,
        'confidence':    score,
        'heldByAdmin':   heldByAdmin,
        'lastMessage':   '🎉 AI found a possible match!',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'createdAt':     FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final String systemMessage = heldByAdmin
          ? '🎉 AI Match Found! (${(score * 100).round()}% confidence)\n'
          'Reason: $reason\n'
          'This item was dropped off with the Lost & Found admin — '
          'once verification is complete, admin will arrange handover.'
          : '🎉 AI Match Found! (${(score * 100).round()}% confidence)\n'
          'Reason: $reason\n'
          'Chat now to verify and arrange return!';

      await _db
          .collection('chats')
          .doc(finalChatId)
          .collection('messages')
          .add({
        'from':      'system',
        'fromName':  'UniLost AI',
        'text':      systemMessage,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Chat created: $finalChatId');

      await _db
          .collection('notifications')
          .doc(lostPost['postedByUid'] as String)
          .collection('items')
          .add({
        'title':     '🎉 Match Found for Your Lost Item!',
        'body':
        'We found a possible match for your '
            '${lostPost['title']}. '
            'Confidence: ${(score * 100).round()}%',
        'type':      'match',
        'matchId':   matchRef.id,
        'chatId':    finalChatId,
        'read':      false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _db
          .collection('notifications')
          .doc(foundPost['postedByUid'] as String)
          .collection('items')
          .add({
        'title':     '🎉 Owner Found for Item You Reported!',
        'body':
        'We found the possible owner of '
            '${foundPost['title']}. '
            'Confidence: ${(score * 100).round()}%',
        'type':      'match',
        'matchId':   matchRef.id,
        'chatId':    finalChatId,
        'read':      false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (heldByAdmin && adminUid != null) {
        await _db
            .collection('notifications')
            .doc(adminUid)
            .collection('items')
            .add({
          'title':     '🔎 Claim Started for a Dropped-Off Item',
          'body':
          'A possible owner was found for '
              '"${foundPost['title']}" that you are holding. '
              'Confidence: ${(score * 100).round()}%',
          'type':      'match',
          'matchId':   matchRef.id,
          'chatId':    finalChatId,
          'read':      false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      debugPrint('Notifications saved!');

      await _db
          .collection('profiles')
          .doc(lostPost['postedByUid'] as String)
          .set(
        {'matchCount': FieldValue.increment(1)},
        SetOptions(merge: true),
      );

      await _db
          .collection('profiles')
          .doc(foundPost['postedByUid'] as String)
          .set(
        {'matchCount': FieldValue.increment(1)},
        SetOptions(merge: true),
      );

      debugPrint('✅ Match handling complete!');
    } catch (e) {
      debugPrint('Error handling match: $e');
    }
  }

  static Future<bool> _checkAlreadyMatched(
      String postId1,
      String postId2,
      ) async {
    try {
      final existing = await _db
          .collection('matches')
          .where('lostPostId', whereIn: [postId1, postId2])
          .get();

      return existing.docs.any((doc) {
        final data = doc.data();
        return (data['lostPostId']  == postId1 &&
            data['foundPostId'] == postId2) ||
            (data['lostPostId']  == postId2 &&
                data['foundPostId'] == postId1);
      });
    } catch (e) {
      return false;
    }
  }
}

class MatchResult {
  final bool isMatch;
  final double confidence;
  final String reason;
  final Map<String, dynamic>? matchedPost;
  final String matchedPostId;

  MatchResult({
    required this.isMatch,
    required this.confidence,
    required this.reason,
    required this.matchedPost,
    required this.matchedPostId,
  });
}