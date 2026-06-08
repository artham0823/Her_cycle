import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppColors.error),
      );
      auth.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [BoxShadow(color: AppColors.primaryPink.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(Icons.local_florist_rounded, size: 40, color: AppColors.white),
                ),
                const SizedBox(height: 12),
                Text('HerCycle', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primaryPink)),
                const SizedBox(height: 4),
                Text(l.translate('register_subtitle'), style: GoogleFonts.poppins(fontSize: 13, color: AppColors.mediumGrey)),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: AppColors.primaryPink.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    children: [
                      Text(l.translate('create_account'), style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primaryPink)),
                      const SizedBox(height: 24),
                      CustomTextField(
                        label: l.translate('name'), hint: 'Sarah', controller: _nameCtrl,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: l.translate('email'), hint: 'example@email.com', controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: l.translate('password'), hint: '••••••••', controller: _passCtrl,
                        obscureText: true, prefixIcon: Icons.lock_outline_rounded,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          if (v.length < 6) return 'Min 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: l.translate('confirm_password'), hint: '••••••••', controller: _confirmCtrl,
                        obscureText: true, prefixIcon: Icons.lock_outline_rounded,
                        validator: (v) {
                          if (v != _passCtrl.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) => CustomButton(
                          text: l.translate('register'),
                          isLoading: auth.isLoading,
                          onPressed: _register,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l.translate('already_have_account'), style: GoogleFonts.poppins(fontSize: 13, color: AppColors.mediumGrey)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(l.translate('login'), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryPink)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
