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

  // Artist
  static const String artistDashboard = '/artist-dashboard';

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

      // Artist
      GetPage(
        name: artistDashboard,
        page: () => const ArtistDashboardScreen(),
        transition: Transition.fadeIn,
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
  static void toArtistDashboard() => Get.toNamed(artistDashboard);
}
