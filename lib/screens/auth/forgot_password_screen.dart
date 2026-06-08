import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.forgotPassword(_emailCtrl.text.trim());
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.translate('reset_sent')), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      } else if (auth.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error!), backgroundColor: AppColors.error),
        );
        auth.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(l.translate('reset_password')),
        backgroundColor: AppColors.primaryPink,
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.lock_reset_rounded, size: 80, color: AppColors.primaryPink),
              const SizedBox(height: 16),
              Text(l.translate('reset_subtitle'), textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.mediumGrey)),
              const SizedBox(height: 32),
              CustomTextField(
                label: l.translate('email'), hint: 'example@email.com', controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (context, auth, _) => CustomButton(
                  text: l.translate('send_reset_link'),
                  isLoading: auth.isLoading,
                  onPressed: _reset,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
