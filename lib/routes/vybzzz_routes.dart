import 'package:get/get.dart';
import 'package:vybzzz/screen/onboarding_screen/welcome_screen.dart';
import 'package:vybzzz/screen/onboarding_screen/user_type_selection_screen.dart';
import 'package:vybzzz/screen/auth_screen/login_screen.dart';
import 'package:vybzzz/screen/auth_screen/registration_screen.dart';
import 'package:vybzzz/screen/home_screen/event_feed_screen.dart';
import 'package:vybzzz/screen/event_details_screen/event_details_screen.dart';
import 'package:vybzzz/screen/create_event_screen/create_event_screen.dart';
import 'package:vybzzz/screen/my_tickets_screen/my_tickets_screen.dart';
import 'package:vybzzz/screen/artist_dashboard_screen/artist_dashboard_screen.dart';
import 'package:vybzzz/screen/main_navigation_screen/main_navigation_screen.dart';
import 'package:vybzzz/screen/qr_scanner_screen/qr_scanner_screen.dart';
import 'package:vybzzz/screen/live_concert_screen/live_concert_screen.dart';
import 'package:vybzzz/screen/artist_live_screen/artist_live_screen.dart';
import 'package:vybzzz/screen/stripe_onboarding_screen/stripe_onboarding_screen.dart';
import 'package:vybzzz/screen/vybz_shop_screen/vybz_shop_screen.dart';

/// Routes VyBzzZ
class VyBzzZRoutes {
  // Onboarding
  static const String welcome = '/welcome';
  static const String userTypeSelection = '/user-type-selection';

  // Auth
  static const String login = '/login';
  static const String register = '/register';

  // Main navigation
  static const String home = '/home';
  static const String mainNavigation = '/main';

  // Events
  static const String eventFeed = '/events';
  static const String eventDetails = '/event-details';
  static const String createEvent = '/create-event';

  // Tickets
  static const String myTickets = '/my-tickets';
  static const String qrScanner = '/qr-scanner';

  // Artist
  static const String artistDashboard = '/artist-dashboard';
  static const String stripeOnboarding = '/stripe-onboarding';

  // Live Streaming
  static const String liveConcert = '/live-concert';
  static const String artistLive = '/artist-live';

  // VyBzzZ Shop
  static const String vybzShop = '/vybz-shop';

  /// Get all VyBzzZ pages
  static List<GetPage> getPages() {
    return [
      // Onboarding
      GetPage(
        name: welcome,
        page: () => const WelcomeScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: userTypeSelection,
        page: () => const UserTypeSelectionScreen(),
        transition: Transition.rightToLeft,
      ),

      // Auth
      GetPage(
        name: login,
        page: () => const LoginScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: register,
        page: () => const RegistrationScreen(),
        transition: Transition.rightToLeft,
      ),

      // Main Navigation
      GetPage(
        name: mainNavigation,
        page: () => const MainNavigationScreen(),
        transition: Transition.fadeIn,
      ),

      // Home
      GetPage(
        name: home,
        page: () => const EventFeedScreen(),
        transition: Transition.fadeIn,
      ),

      // Events
      GetPage(
        name: eventFeed,
        page: () => const EventFeedScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: eventDetails,
        page: () => const EventDetailsScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: createEvent,
        page: () => const CreateEventScreen(),
        transition: Transition.upToDown,
      ),

      // Tickets
      GetPage(
        name: myTickets,
        page: () => const MyTicketsScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: qrScanner,
        page: () => const QRScannerScreen(),
        transition: Transition.downToUp,
      ),

      // Artist
      GetPage(
        name: artistDashboard,
        page: () => const ArtistDashboardScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: stripeOnboarding,
        page: () => const StripeOnboardingScreen(),
        transition: Transition.rightToLeft,
      ),

      // Live Streaming
      GetPage(
        name: liveConcert,
        page: () => const LiveConcertScreen(),
        transition: Transition.fadeIn,
      ),
      GetPage(
        name: artistLive,
        page: () => const ArtistLiveScreen(),
        transition: Transition.fadeIn,
      ),

      // VyBzzZ Shop
      GetPage(
        name: vybzShop,
        page: () => const VybzShopScreen(),
        transition: Transition.rightToLeft,
      ),
    ];
  }

  // Navigation methods
  static void toWelcome() => Get.offAllNamed(welcome);
  static void toUserTypeSelection() => Get.toNamed(userTypeSelection);
  static void toLogin() => Get.toNamed(login);
  static void toRegister() => Get.toNamed(register);
  static void toMainNavigation() => Get.offAllNamed(mainNavigation);
  static void toHome() => Get.toNamed(home);
  static void toEventFeed() => Get.toNamed(eventFeed);
  static void toEventDetails({Map<String, dynamic>? arguments}) =>
      Get.toNamed(eventDetails, arguments: arguments);
  static void toCreateEvent() => Get.toNamed(createEvent);
  static void toMyTickets() => Get.toNamed(myTickets);
  static void toQRScanner() => Get.toNamed(qrScanner);
  static void toArtistDashboard() => Get.toNamed(artistDashboard);
  static void toStripeOnboarding() => Get.toNamed(stripeOnboarding);
  static void toLiveConcert({Map<String, dynamic>? arguments}) =>
      Get.toNamed(liveConcert, arguments: arguments);
  static void toArtistLive({Map<String, dynamic>? arguments}) =>
      Get.toNamed(artistLive, arguments: arguments);
  static void toVybzShop() => Get.toNamed(vybzShop);
}
