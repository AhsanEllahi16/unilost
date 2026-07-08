// lib/routes/app_pages.dart
import 'package:get/get.dart';

import 'app_routes.dart';

// ========== STARTUP ==========
import '../modules/startup/splash_screen.dart';
import '../modules/startup/welcome_screen.dart';

// ========== AUTH ==========
import '../modules/auth/login/login_view.dart';
import '../modules/auth/login/login_binding.dart';
import '../modules/auth/signup/signup_view.dart';
import '../modules/auth/signup/signup_binding.dart';
import '../modules/auth/forgot/forgot_view.dart';
import '../modules/auth/forgot/forgot_binding.dart';

// ========== HOME ==========
import '../modules/home/home_screen.dart';

// ========== POSTS ==========
import '../modules/posts/post_item_screen.dart';
import '../modules/posts/my_posts_screen.dart';
import '../modules/posts/lost_list_screen.dart';
import '../modules/posts/found_list_screen.dart';
import '../modules/posts/item_detail_screen.dart';
import '../modules/posts/search_screen.dart';

// ========== MODELS ==========
import '../models/post_model.dart';

// ========== PROFILE / SETTINGS ==========
import '../modules/profile/profile_screen.dart';
import '../modules/profile/edit_profile_screen.dart';
import '../modules/profile/settings_screen.dart';
import '../modules/profile/notifications_screen.dart';

// ========== CHAT ==========
import '../modules/chat/chats_list_screen.dart';
import '../modules/chat/chat_screen.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[

    // STARTUP
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.welcome,
      page: () => const WelcomeScreen(),
    ),

    // AUTH
    GetPage(
      name: Routes.auth,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.signup,
      page: () => SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: Routes.forgot,
      page: () => ForgotView(),
      binding: ForgotBinding(),
    ),

    // HOME
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
    ),

    // POSTS
    GetPage(
      name: Routes.post,
      page: () => const PostItemScreen(),
    ),
    GetPage(
      name: Routes.myPosts,
      page: () => MyPostsScreen(),
    ),
    GetPage(
      name: Routes.lost,
      page: () => const LostListScreen(),
    ),
    GetPage(
      name: Routes.found,
      page: () => const FoundListScreen(),
    ),
    GetPage(
      name: Routes.detail,
      // ✅ Safe null cast — ItemDetailScreen handles null gracefully
      page: () => ItemDetailScreen(post: Get.arguments as PostModel?),
    ),
    GetPage(
      name: Routes.search,
      page: () => const SearchScreen(),
    ),

    // PROFILE + SETTINGS
    GetPage(
      name: Routes.profile,
      page: () => ProfileScreen(),
    ),
    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfileScreen(),
    ),
    GetPage(
      name: Routes.notifications,
      page: () => const NotificationsScreen(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsScreen(),
    ),

    // CHAT
    GetPage(
      name: Routes.chatsList,
      page: () => const ChatsListScreen(),
    ),
    GetPage(
      name: Routes.chat,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return ChatScreen(
          chatWith:    args['chatWith'] ?? 'User',
          // ✅ Now correctly passes uid for Firestore chat ID generation
          chatWithUid: args['uid'] ?? '',
        );
      },
    ),
  ];
}