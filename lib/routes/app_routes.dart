abstract class Routes {
  Routes._();

  // startup
  static const splash = '/splash';
  static const welcome = '/welcome';

  // auth
  static const auth = '/auth';
  static const signup = '/signup';
  static const forgot = '/forgot';

  // home + posts
  static const home = '/home';
  static const post = '/post';
  static const myPosts = '/my_posts';
  static const lost = '/lost';
  static const found = '/found';
  static const detail = '/detail';
  static const search = '/search';

  // profile / settings
  static const profile = '/profile';
  static const editProfile = '/edit_profile';
  static const notifications = '/notifications';
  static const settings = '/settings';

  // chat
  static const chatsList = '/chats';
  static const chat = '/chat';
  //verification
  static const verification = '/verification';
}
