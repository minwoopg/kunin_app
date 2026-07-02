import 'package:flutter/material.dart';

// ─────────────────────────────────────────
//  KIP 앱 컬러 팔레트
// ─────────────────────────────────────────
class AppColors {
  AppColors._();

  // 배경
  static const Color background     = Color(0xFFF8F4EC); // 메인 배경
  static const Color cardBackground = Color(0xFFFFFCF7); // 카드 배경
  static const Color white          = Color(0xFFFFFFFF);

  // 브랜드 (버튼 / 포인트)
  static const Color primary        = Color(0xFFB8956A); // 골드브라운 버튼
  static const Color primaryPressed = Color(0xFF9A7650); // 버튼 Pressed
  static const Color premiumPoint   = Color(0xFFD8C6A3); // 프리미엄 포인트

  // 텍스트
  static const Color textMain       = Color(0xFF2C2C2C); // 메인 텍스트
  static const Color textSub        = Color(0xFF777777); // 서브 텍스트
  static const Color textHint       = Color(0xFFAAAAAA); // 힌트 텍스트

  // 보더 / 구분선
  static const Color border         = Color(0xFFE4DCD0);
  static const Color divider        = Color(0xFFEEE8DE);

  // 상태
  static const Color error          = Color(0xFFD94F4F);
  static const Color success        = Color(0xFF4CAF82);
  static const Color warning        = Color(0xFFE8A838);
}

// ─────────────────────────────────────────
//  KIP 앱 스페이싱 토큰
//  화면마다 제각각이던 padding/margin 숫자를 여기 하나로 통일합니다.
// ─────────────────────────────────────────
class AppSpacing {
  AppSpacing._();

  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 20;  // 화면 좌우 기본 여백으로 주로 사용
  static const double xxl = 28;
}

// ─────────────────────────────────────────
//  KIP 앱 라운드 토큰
// ─────────────────────────────────────────
class AppRadius {
  AppRadius._();

  static const double sm   = 4;   // 뱃지, 작은 태그
  static const double md   = 8;   // 버튼, 인풋
  static const double lg   = 12;  // 카드
  static const double xl   = 16;  // 배너, 바텀시트
  static const double pill = 999; // 칩, 원형 버튼
}

// ─────────────────────────────────────────
//  KIP 앱 그림자 토큰
//  기존의 "보더만 있는 플랫" 톤은 유지하되, 상품 카드처럼
//  살짝 들뜬 느낌이 필요한 곳에만 아주 은은하게 사용합니다.
// ─────────────────────────────────────────
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.textMain.withOpacity(0.045),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];
}

// ─────────────────────────────────────────
//  KIP 앱 텍스트 스타일
// ─────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Pretendard';

  // 헤딩
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
    letterSpacing: -0.5,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
    letterSpacing: -0.3,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textMain,
  );

  // 바디
  static const TextStyle body1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textMain,
    height: 1.5,
  );
  static const TextStyle body2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSub,
    height: 1.5,
  );

  // 가격
  static const TextStyle price = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
    letterSpacing: -0.3,
  );
  static const TextStyle priceLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
    letterSpacing: -0.5,
  );

  // 버튼
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.3,
  );

  // 캡션
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSub,
  );

  // 라벨
  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSub,
    letterSpacing: 0.5,
  );
}

// ─────────────────────────────────────────
//  KIP 앱 ThemeData
// ─────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Pretendard',

      // 컬러 스킴
      colorScheme: ColorScheme.light(
        primary:          AppColors.primary,
        onPrimary:        AppColors.white,
        secondary:        AppColors.premiumPoint,
        onSecondary:      AppColors.textMain,
        surface:          AppColors.cardBackground,
        onSurface:        AppColors.textMain,
        error:            AppColors.error,
        outline:          AppColors.border,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor:  AppColors.background,
        foregroundColor:  AppColors.textMain,
        elevation:        0,
        scrolledUnderElevation: 0,
        centerTitle:      true,
        titleTextStyle:   TextStyle(
          fontFamily:     'Pretendard',
          fontSize:       17,
          fontWeight:     FontWeight.w600,
          color:          AppColors.textMain,
          letterSpacing:  -0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textMain, size: 22),
      ),

      // ElevatedButton (골드브라운 버튼)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:    AppColors.primary,
          foregroundColor:    AppColors.white,
          disabledBackgroundColor: AppColors.premiumPoint,
          elevation:          0,
          minimumSize:        const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTextStyles.button,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return AppColors.primaryPressed;
            if (states.contains(WidgetState.disabled)) return AppColors.premiumPoint;
            return AppColors.primary;
          }),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:    AppColors.primary,
          side:               const BorderSide(color: AppColors.primary, width: 1.2),
          minimumSize:        const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.body2.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // InputDecoration (TextField)
      inputDecorationTheme: InputDecorationTheme(
        filled:           true,
        fillColor:        AppColors.cardBackground,
        contentPadding:   const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle:        AppTextStyles.body1.copyWith(color: AppColors.textHint),
        border: OutlineInputBorder(
          borderRadius:   BorderRadius.circular(AppRadius.md),
          borderSide:     const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:   BorderRadius.circular(AppRadius.md),
          borderSide:     const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:   BorderRadius.circular(AppRadius.md),
          borderSide:     const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:   BorderRadius.circular(AppRadius.md),
          borderSide:     const BorderSide(color: AppColors.error),
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color:            AppColors.cardBackground,
        elevation:        0,
        shape: RoundedRectangleBorder(
          borderRadius:   BorderRadius.circular(AppRadius.lg),
          side:           const BorderSide(color: AppColors.border, width: 0.8),
        ),
        margin:           EdgeInsets.zero,
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:      AppColors.cardBackground,
        selectedItemColor:    AppColors.primary,
        unselectedItemColor:  AppColors.textSub,
        elevation:            0,
        type:                 BottomNavigationBarType.fixed,
        selectedLabelStyle:   TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color:     AppColors.divider,
        thickness: 1,
        space:     1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor:  AppColors.textMain,
        contentTextStyle: AppTextStyles.body2.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
