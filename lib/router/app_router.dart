import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_provider.dart';

import '../features/splash/splash_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/login_id_page.dart';

import '../features/home/home_page.dart';
import '../features/my/my_page.dart';

import '../features/sermon/sermon_page.dart';
import '../features/bulletin/bulletin_page.dart';
import '../features/bible/bible_page.dart';
import '../features/cafe/cafe_page.dart';
import '../features/cell/cell_page.dart';
import '../features/web/web_page.dart';

import '../features/sermon/sermon_live_page.dart';
import '../features/sermon/sermon_board_page.dart';

import '../features/boards/board_list_page.dart';
import '../features/boards/board_detail_page.dart';

import '../features/calendar/edu_calendar_page.dart';
import '../features/calendar/edu_event_detail_page.dart';

import '../features/bulletins/bulletin_gallery_page.dart';
import '../features/bulletins/bulletin_detail_page.dart';

import '../features/offering/online_offering_page.dart';
import '../features/offering/donation_receipt_page.dart';

import '../features/boards/fellow_board_page.dart';
import '../features/boards/fellow_board_detail_page.dart';

import '../features/auth/login_phone_page.dart';
import '../features/auth/phone_verify_page.dart';
import '../features/auth/signup_page.dart';
import '../features/auth/address_search_page.dart';
import '../features/settings/settings_page.dart';

import '../features/prayer/prayer_page.dart';
import '../features/prayer/prayer_detail_page.dart';
import '../features/prayer/prayer_write_page.dart';
import '../features/prayer/prayer_models.dart';
import '../features/prayer/my_prayer_detail_page.dart';
// ✅ 새 회원가입 플로우
import '../features/auth/signup/signup_terms_page.dart';
import '../features/auth/signup/signup_info_page.dart';
import '../features/auth/signup/signup_sms_verify_page.dart';

import '../features/ministry/ministry_page.dart';
import '../features/notice/presentation/pages/notice_list_page.dart';
import '../features/notifications/notification_page.dart';

// ✅ NavigatorKey는 “파일 전역에서 1번만” 생성 (중요)
final _rootNavKey = GlobalKey<NavigatorState>();
final _shellNavKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  bool isProtected(String loc) {
    final uri = Uri.parse(loc);

    final isPrayerPersonal =
        uri.path == '/prayer' && (uri.queryParameters['tab'] == '1');

    return loc.startsWith('/cafe') ||
        loc.startsWith('/cell') ||
        loc.startsWith('/offering/receipt') ||
        isPrayerPersonal; // ✅ 개인 탭은 로그인 필요
  }

  return GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: '/splash',

    // ✅ auth 변경 시 router를 “재생성”하지 말고 refresh만
    refreshListenable: _GoRouterRefresh(ref),

    redirect: (context, state) {
      // ✅ 여기서 auth를 “읽기”만 한다 (watch 금지!)
      final auth = ref.read(authProvider);

      final loc = state.uri.toString();
      final loggedIn = auth.isLoggedIn;

      // Splash는 무조건 허용
      if (loc.startsWith('/splash')) return null;

      // 로그인 상태인데 /login 접근하면 홈으로(또는 from으로)
      if (loggedIn && loc.startsWith('/login')) {
        final from = state.uri.queryParameters['from'];
        return (from != null && from.isNotEmpty) ? from : '/';
      }

      // 미로그인인데 보호 페이지 접근하면 로그인으로
      if (!loggedIn && isProtected(loc)) {
        final encoded = Uri.encodeComponent(loc);
        return '/login?from=$encoded';
      }

      return null;
    },

    routes: [
      // ✅ 탭 없는 페이지들(루트 Navigator)
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),

      GoRoute(
        path: '/login',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'];
          final decoded = from != null ? Uri.decodeComponent(from) : null;
          return LoginPage(from: decoded);
        },
      ),

      GoRoute(
        path: '/login/id',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'];
          final decoded = from != null ? Uri.decodeComponent(from) : null;
          return LoginIdPage(from: decoded);
        },
      ),

      GoRoute(
        path: '/login/phone',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'];
          final decoded = from != null ? Uri.decodeComponent(from) : null;
          return LoginPhonePage(from: decoded);
        },
      ),

      // ✅ 기존 회원가입 플로우(탭 밖 / 유지)
      GoRoute(
        path: '/phone-verify',
        builder: (context, state) => const PhoneVerifyPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) {
          final phone = state.extra as String?;
          if (phone == null || phone.isEmpty) return const PhoneVerifyPage();
          return SignupPage(verifiedPhone: phone);
        },
      ),
      GoRoute(
        path: '/address-search',
        builder: (context, state) => const AddressSearchPage(),
      ),

      // ✅ ✅ ✅ 새 회원가입 4단계 플로우 (중요: ShellRoute 밖으로 뺌)
      // 회원가입 - 정보이용동의
      GoRoute(
        path: '/signup/terms',
        builder: (context, state) => const SignupTermsPage(),
      ),

      // 회원가입 - 전화번호 인증(카카오톡)
      GoRoute(
        path: '/signup/phone',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return SignupSmsVerifyPage(
            agreedApp: extra['agreedApp'] == true,
            agreedPrivacy: extra['agreedPrivacy'] == true,
            agreedAlarm: extra['agreedAlarm'] == true,
          );
        },
      ),

      // 회원가입 - 정보입력
      GoRoute(
        path: '/signup/info',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return SignupInfoPage(
            verifiedPhone: (extra['verifiedPhone'] ?? '') as String,
            agreedApp: extra['agreedApp'] == true,
            agreedPrivacy: extra['agreedPrivacy'] == true,
            agreedAlarm: extra['agreedAlarm'] == true,
          );
        },
      ),

      // ✅ 하단 탭 고정 (ShellRoute)
      ShellRoute(
        navigatorKey: _shellNavKey,
        builder: (context, state, child) {
          final loc = state.uri.toString();
          final index = loc.startsWith('/my') ? 1 : 0;

          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: index,
              onTap: (i) {
                if (i == 0) context.go('/');
                if (i == 1) context.go('/my');
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'My'),
              ],
            ),
          );
        },
        routes: [

          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(path: '/my', builder: (context, state) => const MyPage()),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationPage(),
          ),
          GoRoute(path: '/sermon', builder: (context, state) => const SermonPage()),
          GoRoute(path: '/bulletin', builder: (context, state) => const BulletinPage()),
          GoRoute(path: '/bible', builder: (context, state) => const BiblePage()),
          GoRoute(
            path: '/cafe',
            builder: (context, state) {
              final tabStr = state.uri.queryParameters['tab'] ?? '0';
              final initialTab = int.tryParse(tabStr) ?? 0;
              return CafePage(initialTab: initialTab);
            },
          ),
          // 삭제하거나, 필요시 아래처럼 변경
          // GoRoute(
          //   path: '/cafe/order-complete',
          //   builder: (context, state) => CafeOrderCompletePage(
          //     order: /* order를 라우트로 넘길 방법이 없으면 여기선 쓰기 어려움 */,
          //   ),
          // ),
          GoRoute(
            path: '/cell',
            builder: (context, state) => const CellPage(),
            routes: [
              GoRoute(
                path: 'notices',
                builder: (context, state) => const CellNoticeListPage(),
              ),
              GoRoute(
                path: 'notices/write',
                builder: (context, state) => const CellNoticeWritePage(),
              ),
              GoRoute(
                path: 'notices/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CellNoticeDetailPage(noticeId: id);
                },
              ),
              GoRoute(
                path: 'prayers',
                builder: (context, state) => const CellPrayerTitlesPage(),
              ),
            ],
          ),
          GoRoute(path: '/web', builder: (context, state) => const WebPage()),

          GoRoute(path: '/sermon/live', builder: (context, state) => const SermonLivePage()),
          GoRoute(path: '/sermon/board', builder: (context, state) => const SermonBoardPage()),
          GoRoute(
            path: '/prayer',
            builder: (context, state) {
              final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
              return PrayerPage(initialTab: tab);
            },
          ),
          GoRoute(
            path: '/prayer/my/:id',
            builder: (context, state) => MyPrayerDetailPage(
              id: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/prayer/detail',
            builder: (context, state) {
              final item = state.extra as PrayerItem;
              return PrayerDetailPage(item: item);
            },
          ),
          GoRoute(
            path: '/prayer/write',
            builder: (context, state) {
              final extra = state.extra as MyPrayerItem?;
              return PrayerWritePage(initial: extra);
            },
          ),

          GoRoute(
            path: '/boards/fellow',
            builder: (context, state) => const FellowBoardPage(),
          ),
          GoRoute(
            path: '/boards/fellow/:id',
            builder: (context, state) => FellowBoardDetailPage(
              id: state.pathParameters['id']!,
            ),
          ),

          GoRoute(
            path: '/boards/:type',
            builder: (context, state) => BoardListPage(type: state.pathParameters['type']!),
          ),
          GoRoute(
            path: '/boards/:type/:id',
            builder: (context, state) => BoardDetailPage(
              type: state.pathParameters['type']!,
              id: int.parse(state.pathParameters['id']!),
            ),
          ),

          GoRoute(path: '/calendar/edu', builder: (context, state) => const EduCalendarPage()),
          GoRoute(
            path: '/calendar/edu/:id',
            builder: (context, state) => EduEventDetailPage(
              id: int.parse(state.pathParameters['id']!),
            ),
          ),

          GoRoute(path: '/bulletins', builder: (context, state) => const BulletinGalleryPage()),
          GoRoute(
            path: '/bulletins/:id',
            builder: (context, state) => BulletinDetailPage(
              id: int.parse(state.pathParameters['id']!),
            ),
          ),

          GoRoute(
            path: '/offering',
            builder: (context, state) => const OnlineOfferingPage(),
          ),
          GoRoute(
            path: '/offering/receipt',
            builder: (context, state) => const DonationReceiptPage(),
          ),

          GoRoute(
            path: '/ministry',
            builder: (context, state) {
              final tabStr = state.uri.queryParameters['tab'] ?? '0';
              final initialTab = int.tryParse(tabStr) ?? 0;
              return MinistryPage(initialTab: initialTab);
            },
          ),

          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),

          GoRoute(
            path: '/notices',
            builder: (context, state) => const NoticeListPage(),
          ),
        ],
      ),
    ],
  );
});

/// ✅ Riverpod 변화에 따라 GoRouter refresh를 트리거
class _GoRouterRefresh extends ChangeNotifier {
  _GoRouterRefresh(this.ref) {
    _sub = ref.listen<AuthState>(
      authProvider,
          (_, _) => notifyListeners(),
    );
  }

  final Ref ref;
  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
