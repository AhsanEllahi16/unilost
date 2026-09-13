// lib/modules/verification/verification_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme.dart';
import '../../services/verification_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late String foundPostId;
  late String finderUid;
  late String custody;
  String? matchId;
  String? lostPostId;

  final answerC = TextEditingController();

  bool loading = true;
  bool submitting = false;
  String? loadError;

  List<Map<String, dynamic>> questions = [];
  int currentIndex = 0;
  int requiredCorrect = 1;
  int correctCount = 0;
  String layer1Status = 'pending';
  int attemptsRemainingThisQuestion =
      VerificationService.maxAttemptsPerQuestion;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    foundPostId = args['foundPostId'];
    finderUid   = args['finderUid'];
    custody     = args['custody'] ?? 'finder';
    matchId     = args['matchId'];
    lostPostId  = args['lostPostId'];
    _init();
  }

  @override
  void dispose() {
    answerC.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        loading = false;
        loadError = 'You must be logged in to verify a claim.';
      });
      return;
    }

    try {
      final data = await VerificationService.startClaim(
        foundPostId: foundPostId,
        finderUid: finderUid,
        claimantUid: user.uid,
        custody: custody,
        matchId: matchId,
        lostPostId: lostPostId,
      );

      setState(() {
        questions = List<Map<String, dynamic>>.from(
            (data['layer1Questions'] as List<dynamic>? ?? [])
                .map((q) => Map<String, dynamic>.from(q)));
        currentIndex = (data['layer1CurrentIndex'] as int?) ?? 0;
        requiredCorrect = (data['layer1RequiredCorrect'] as int?) ?? 1;
        correctCount = (data['layer1CorrectCount'] as int?) ?? 0;
        layer1Status = data['layer1Status'] ?? 'pending';
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        loadError =
        'Could not start verification. Please check your connection '
            'and try again.\n\n($e)';
      });
    }
  }

  Future<void> _submitAnswer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (answerC.text.trim().isEmpty) {
      Get.snackbar('Required', 'Please enter an answer.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => submitting = true);

    try {
      final result = await VerificationService.submitLayer1Answer(
        foundPostId: foundPostId,
        claimantUid: user.uid,
        claimantAnswer: answerC.text.trim(),
      );

      setState(() {
        submitting = false;
        currentIndex = result['nextIndex'] ?? currentIndex;
        correctCount = result['correctCount'] ?? correctCount;
        attemptsRemainingThisQuestion =
            result['attemptsRemainingThisQuestion'] ??
                VerificationService.maxAttemptsPerQuestion;

        if (result['allQuestionsDone'] == true) {
          layer1Status =
          result['overallPassed'] == true ? 'passed' : 'failed';
        } else if (result['movingToNext'] == true) {
          attemptsRemainingThisQuestion =
              VerificationService.maxAttemptsPerQuestion;
        }

        answerC.clear();
      });

      if (result['allQuestionsDone'] == true) {
        if (result['overallPassed'] == true) {
          Get.snackbar('Verified!', 'Layer 1 passed.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.shade50);
        } else {
          Get.snackbar(
            'Verification Failed',
            'You didn\'t answer enough questions correctly. This item '
                'remains available for others to claim.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
          );
        }
      } else if (result['passedThisQuestion'] == true) {
        Get.snackbar('Correct!', 'Moving to the next question.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade50);
      } else if (result['movingToNext'] == true) {
        Get.snackbar('Not quite',
            'That wasn\'t right. Moving to the next question.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade50);
      } else {
        Get.snackbar(
          'Not quite',
          'That doesn\'t match. Attempts left on this question: '
              '$attemptsRemainingThisQuestion',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade50,
        );
      }
    } catch (e) {
      setState(() => submitting = false);
      Get.snackbar(
        'Error',
        'Could not submit your answer. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCurrentQuestion =
        layer1Status == 'pending' && currentIndex < questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ownership Verification'),
        backgroundColor: UniLostTheme.primary,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
          ? Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              loadError!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  loading = true;
                  loadError = null;
                });
                _init();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: UniLostTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'LAYER 1 OF 3 — KNOWLEDGE CHALLENGE '
                    '(${correctCount}/${requiredCorrect} needed)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (questions.isEmpty) ...[
              const Icon(Icons.help_outline, color: Colors.grey, size: 56),
              const SizedBox(height: 12),
              const Text(
                'This post has no verification questions set. Please '
                    'contact the finder directly through admin for manual '
                    'review.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ] else if (layer1Status == 'passed') ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 12),
              const Text('Layer 1 Passed!',
                  style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Proof submission (Layer 2) is coming next in this '
                    'build.',
                style: TextStyle(color: Colors.grey),
              ),
            ] else if (layer1Status == 'failed') ...[
              const Icon(Icons.cancel, color: Colors.red, size: 64),
              const SizedBox(height: 12),
              const Text('Verification Failed',
                  style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'The item remains active and can still be claimed by '
                    'you or someone else later.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Back'),
              ),
            ] else if (hasCurrentQuestion) ...[
              Text(
                'Question ${currentIndex + 1} of ${questions.length}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  questions[currentIndex]['question'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: answerC,
                decoration: const InputDecoration(labelText: 'Your Answer'),
                maxLines: 2,
              ),
              const SizedBox(height: 6),
              Text(
                'Attempts remaining on this question: '
                    '$attemptsRemainingThisQuestion',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitting ? null : _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UniLostTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: submitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Answer'),
                ),
              ),
            ] else
              const Text('No questions found for this item.'),
          ],
        ),
      ),
    );
  }
}