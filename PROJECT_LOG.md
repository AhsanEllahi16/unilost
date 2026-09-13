# UniLost — Project Log

## Stack
Flutter + Firebase (Firestore, Auth) + Groq API (qwen/qwen3.6-27b, multimodal)
Run with: flutter run --dart-define-from-file=dart_define.json
Blaze/Cloud Functions: DEFERRED — everything currently runs client-side

## Done ✅
- Auth: roll-number-gated signup (valid_students), login via roll_lookup
- Posts: lost/found, urgency (lost only), custody choice (finder/admin)
- Admin: role-based, drop-off confirmation handshake
- AI matching: multimodal via Groq, Firestore-rules protected
- Ownership Verification Layer 1 (Knowledge Challenge): multi-question,
  semantic comparison, 2 attempts, "pass most" logic — fixed <think>
  tag bug, retesting now

## In Progress 🔧
- Confirming Layer 1 fix works correctly (Groq <think> tag stripping)

## Next Up (in order)
1. Layer 2 (Proof submission): image auto-verified by AI, text-only
   routed to whoever holds the item (finder or admin) for manual review
2. Layer 3: identity record (automatic)
3. Chat unlocks only after all 3 layers pass
4. Meetup scheduling (locked to admin office location when custody=admin)
5. QR code handover
6. Trust score / strike system
7. AI chatbot
8. Post reporting / fake post detection
9. Department urgency broadcast
10. Admin Dashboard
11. Make Privacy & Safety and Blocked Users features actually functional

## Deferred (revisit later)
- Blaze plan / Cloud Functions — needed for: server-side matching,
  cascading delete on account removal
- Gemini billing — blocked by Pakistani card error (OR_BACR2_31),
  revisit after bank call about international transactions
- Voice notes/calls — polish-pass item, not SDD scope
- Dead code cleanup: NotificationRepository, ChatModel,
  ChatRepository.createChat() — all unused, safe to delete later

## Known bugs fixed (don't reintroduce these)
- Groq reasoning models wrap output in <think>...</think> tags —
  must strip this before JSON.parse in matching_service.dart AND
  verification_service.dart
- Firestore rules: referencing resource.data.x crashes (not just
  denies) when the document doesn't exist yet — always add
  `resource == null ||` as a guard for any collection your code
  reads before that document is created (e.g. verifications/{id})
- material_color_utilities in pubspec.yaml must stay at ^0.13.0 to
  match the Flutter SDK version
- Model names on Groq get deprecated — if you see "model not found"
  errors again, check console.groq.com for current model names