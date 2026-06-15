import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/product/product_list_screen.dart';
import '../features/product/product_detail_screen.dart';
import '../features/search/search_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/order/order_screen.dart';
import '../features/order/order_complete_screen.dart';
import '../features/mypage/mypage_screen.dart';
import '../features/mypage/order_history_screen.dart';
import '../data/models/product_model.dart';
import '../shared/widgets/main_scaffold.dart';

// ─────────────────────────────────────────
//  라우트 경로 상수
// ─────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static const String splash        = '/';
  static const String login         = '/login';
  static const String signup        = '/signup';
  static const String home          = '/home';
  static const String productList   = '/products';
  static const String productDetail = '/products/:id';
  static const String search        = '/search';
  static const String cart          = '/cart';
  static const String order         = '/order';
  static const String orderComplete = '/order/complete';
  static const String mypage        = '/mypage';
  static const String orderHistory  = '/mypage/orders';

  /// 카테고리 필터가 적용된 상품 목록 경로 생성
  static String productListWithCategory(ProductCategory category) {
    return '$productList?category=${category.name}';
  }
}

// ─────────────────────────────────────────
//  GoRouter 설정
// ─────────────────────────────────────────
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    // 스플래시
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // 로그인 / 회원가입
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.orderComplete,
      builder: (context, state) => const OrderCompleteScreen(),
    ),

    // 검색
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const SearchScreen(),
    ),

    // 메인 탭 (하단 네비 있음)
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.productList,
          builder: (context, state) {
            // 쿼리 파라미터로 전달된 카테고리 (예: /products?category=medicalDevice)
            final categoryParam = state.uri.queryParameters['category'];
            ProductCategory? initialCategory;
            if (categoryParam != null) {
              initialCategory = ProductCategory.values.firstWhere(
                (c) => c.name == categoryParam,
                orElse: () => ProductCategory.medicalDevice,
              );
            }
            return ProductListScreen(initialCategory: initialCategory);
          },
        ),
        GoRoute(
          path: AppRoutes.cart,
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: AppRoutes.mypage,
          builder: (context, state) => const MypageScreen(),
        ),
      ],
    ),

    // 상세 페이지
    GoRoute(
      path: AppRoutes.productDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ProductDetailScreen(productId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.order,
      builder: (context, state) => const OrderScreen(),
    ),
    GoRoute(
      path: AppRoutes.orderHistory,
      builder: (context, state) => const OrderHistoryScreen(),
    ),
  ],
);
