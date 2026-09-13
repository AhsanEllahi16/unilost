// lib/services/verification_service.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class VerificationService {
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const int maxAttemptsPerQuestion = 2;

  static Future<Map<String, dynamic>> startClaim({
    required String foundPostId,
    required String finderUid,
    required String claimantUid,
    required String custody,
    String? matchId,
    String? lostPostId,
  }) async {
    final verificationId = '${foundPostId}_$claimantUid';
    final docRef = _db.collection('verifications').doc(verificationId);
    final existing = await docRef.get();

    if (existing.exists) {
      return existing.data()!;
    }

    final initialData = {
      'verificationId':       verificationId,
      'matchId':              matchId,
      'foundPostId':          foundPostId,
      'lostPostId':           lostPostId,
      'claimantUid':          claimantUid,
      'finderUid':            finderUid,
      'custody':              custody,
      'layer1Status':         'pending',
      'layer1Questions':      [],
      'layer1RequiredCorrect': 1,
      'layer1CorrectCount':   0,
      'layer1CurrentIndex':   0,
      'layer2Status':         'pending',
      'layer3Status':         'pending',
      'overallStatus':        'in_progress',
      'createdAt':            FieldValue.serverTimestamp(),
    };

    await docRef.set(initialData);

    final secretDoc =
    await _db.collection('post_secrets').doc(foundPostId).get();

    final rawQuestions =
        secretDoc.data()?['questions'] as List<dynamic>? ?? [];

    final questionStates = rawQuestions
        .map((q) => {
      'question': (q as Map)['question'],
      'status': 'pending',
      'attempts': 0,
    })
        .toList();

    final int totalQuestions = questionStates.length;
    final int requiredCorrect =
    totalQuestions <= 2 ? totalQuestions : (totalQuestions / 2).ceil() + 1;

    final updateData = {
      'layer1Questions': questionStates,
      'layer1RequiredCorrect':
      totalQuestions == 0 ? 1 : requiredCorrect,
    };

    await docRef.update(updateData);

    return {...initialData, ...updateData};
  }

  static Future<Map<String, dynamic>> submitLayer1Answer({
    required String foundPostId,
    required String claimantUid,
    required String claimantAnswer,
  }) async {
    final verificationId = '${foundPostId}_$claimantUid';
    final verifRef = _db.collection('verifications').doc(verificationId);
    final verifDoc = await verifRef.get();

    if (!verifDoc.exists) {
      throw Exception('Verification record not found.');
    }

    final data = verifDoc.data()!;
    final List<dynamic> questions =
    List<dynamic>.from(data['layer1Questions'] ?? []);
    final int currentIndex = (data['layer1CurrentIndex'] as int?) ?? 0;
    final int requiredCorrect =
        (data['layer1RequiredCorrect'] as int?) ?? questions.length;
    int correctCount = (data['layer1CorrectCount'] as int?) ?? 0;

    if (currentIndex >= questions.length) {
      return {'overallPassed': correctCount >= requiredCorrect};
    }

    final currentQ = Map<String, dynamic>.from(questions[currentIndex]);
    final int attemptsSoFar = (currentQ['attempts'] as int?) ?? 0;

    final secretDoc =
    await _db.collection('post_secrets').doc(foundPostId).get();
    final rawQuestions =
        secretDoc.data()?['questions'] as List<dynamic>? ?? [];
    final correctAnswer = currentIndex < rawQuestions.length
        ? (rawQuestions[currentIndex] as Map)['answer'] as String? ?? ''
        : '';

    final bool passed = await _compareAnswersWithGroq(
      correctAnswer: correctAnswer,
      claimantAnswer: claimantAnswer,
    );

    final int newAttempts = attemptsSoFar + 1;
    final bool giveUpOnThisQuestion =
        !passed && newAttempts >= maxAttemptsPerQuestion;

    currentQ['attempts'] = newAttempts;
    if (passed) {
      currentQ['status'] = 'correct';
      correctCount += 1;
    } else if (giveUpOnThisQuestion) {
      currentQ['status'] = 'incorrect';
    }

    questions[currentIndex] = currentQ;

    final bool movingToNext = passed || giveUpOnThisQuestion;
    final int nextIndex = movingToNext ? currentIndex + 1 : currentIndex;
    final bool allQuestionsDone = nextIndex >= questions.length;

    String overallLayer1Status = 'pending';
    String overallStatus = 'in_progress';

    if (allQuestionsDone) {
      final bool overallPassed = correctCount >= requiredCorrect;
      overallLayer1Status = overallPassed ? 'passed' : 'failed';
      overallStatus = overallPassed ? 'in_progress' : 'rejected';
    }

    await verifRef.update({
      'layer1Questions': questions,
      'layer1CorrectCount': correctCount,
      'layer1CurrentIndex': nextIndex,
      'layer1Status': overallLayer1Status,
      'overallStatus': overallStatus,
    });

    return {
      'passedThisQuestion': passed,
      'movingToNext': movingToNext,
      'allQuestionsDone': allQuestionsDone,
      'overallPassed': allQuestionsDone && correctCount >= requiredCorrect,
      'attemptsRemainingThisQuestion':
      maxAttemptsPerQuestion - newAttempts,
      'nextIndex': nextIndex,
      'correctCount': correctCount,
      'requiredCorrect': requiredCorrect,
      'totalQuestions': questions.length,
    };
  }

  // Strips a Groq "reasoning model" <think>...</think> preamble and
  // any ```json code fences, leaving just the raw JSON body. Without
  // this, qwen/qwen3.6-27b's chain-of-thought output breaks JSON
  // parsing on every single call.
  static String _extractJson(String raw) {
    String cleaned = raw;
    final thinkPattern = RegExp(r'<think>[\s\S]*?<\/think>',
        multiLine: true, caseSensitive: false);
    cleaned = cleaned.replaceAll(thinkPattern, '');
    cleaned = cleaned.replaceAll('```json', '').replaceAll('```', '');
    return cleaned.trim();
  }

  static Future<bool> _compareAnswersWithGroq({
    required String correctAnswer,
    required String claimantAnswer,
  }) async {
    if (_apiKey.isEmpty) {
      debugPrint('❌ GROQ_API_KEY not set for verification comparison.');
      return false;
    }

    try {
      final prompt = '''
You are checking if a person answering a secret ownership question
gave an answer that MEANS THE SAME THING as the correct answer, even
if worded differently.

CORRECT ANSWER: "$correctAnswer"
CLAIMANT'S ANSWER: "$claimantAnswer"

Do these mean the same thing, referring to the same specific detail?
Minor wording differences are fine. Vague or generic answers that
could apply to many items should NOT count as a match.

Do not show any reasoning or thinking. Reply ONLY with the JSON
object below, nothing else, no explanation:
{ "match": true or false, "score": 0 to 100 }''';

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type':  'application/json',
        },
        body: jsonEncode({
          'model': 'qwen/qwen3.6-27b',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.1,
          'max_tokens':  200,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Groq verification API error: ${response.body}');
        return false;
      }

      final data = jsonDecode(response.body);
      final text = data['choices'][0]['message']['content'] as String;
      final cleaned = _extractJson(text);

      if (cleaned.isEmpty) {
        debugPrint('Groq returned no usable content after cleanup.');
        return false;
      }

      final parsed = jsonDecode(cleaned);
      final int score = (parsed['score'] as num?)?.toInt() ?? 0;
      return score >= 70;
    } catch (e) {
      debugPrint('Verification comparison error: $e');
      return false;
    }
  }
}