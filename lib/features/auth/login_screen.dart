import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_router.dart';
import '../../shared/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword     = true;
  bool _isLoading           = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    setState(() => _isLoading = true);
    // TODO: 실제 API 연동 전 임시 딜레이
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 64),

              // 로고
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'KIP',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'KIP 2026',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'BEAUTY BEYOND TIME',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSub,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 52),

              // 아이디 입력
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.body1,
                decoration: const InputDecoration(
                  hintText: '아이디를 입력해주세요',
                ),
              ),
              const SizedBox(height: 12),

              // 비밀번호 입력
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: AppTextStyles.body1,
                decoration: InputDecoration(
                  hintText: '비밀번호를 입력해주세요',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSub,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // 로그인 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('로그인'),
                ),
              ),

              const SizedBox(height: 20),

              // 보조 링크
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '아이디/비밀번호 찾기',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSub,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 12,
                    color: AppColors.border,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.signup),
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSub,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // 소셜 로그인 구분선
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '간편 로그인',
                      style: AppTextStyles.caption,
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),

              const SizedBox(height: 24),

              // 소셜 로그인 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialButton(
                    label: 'K',
                    color: const Color(0xFFFEE500),
                    textColor: const Color(0xFF191919),
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  _SocialButton(
                    label: 'N',
                    color: const Color(0xFF03C75A),
                    textColor: AppColors.white,
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  _SocialButton(
                    label: 'G',
                    color: AppColors.white,
                    textColor: AppColors.textMain,
                    onTap: () {},
                    hasBorder: true,
                  ),
                ],
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final bool hasBorder;

  const _SocialButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: hasBorder
              ? Border.all(color: AppColors.border, width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
