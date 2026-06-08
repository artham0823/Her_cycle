import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/avatar_selector.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  int _selectedAvatarIndex = 0;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameCtrl.text = auth.user?.name ?? '';
    _selectedAvatarIndex = auth.user?.avatarIndex ?? 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.updateProfile(
      name: _nameCtrl.text.trim(),
      avatarIndex: _selectedAvatarIndex,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.translate('profile_updated')),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _changePassword() async {
    if (_currentPassCtrl.text.isEmpty || _newPassCtrl.text.isEmpty) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.changePassword(
      currentPassword: _currentPassCtrl.text,
      newPassword: _newPassCtrl.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.translate('password_changed')),
            backgroundColor: AppColors.success,
          ),
        );
        _currentPassCtrl.clear();
        _newPassCtrl.clear();
      } else if (auth.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error!),
            backgroundColor: AppColors.error,
          ),
        );
        auth.clearError();
      }
    }
  }

  Future<void> _deleteAccount() async {
    final l = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.translate('delete_account')),
        content: Text(l.translate('delete_account_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.translate('yes_delete'), style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.deleteAccount();
      if (success && mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else if (mounted && auth.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error!),
            backgroundColor: AppColors.error,
          ),
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
        title: Text(l.translate('edit_profile'), style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar selector section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.softPink.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.translate('select_avatar'),
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textColor),
                    ),
                    const SizedBox(height: 16),
                    AvatarSelector(
                      selectedIndex: _selectedAvatarIndex,
                      onSelected: (index) => setState(() => _selectedAvatarIndex = index),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Profile update fields
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.softPink.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    CustomTextField(
                      label: l.translate('name'),
                      controller: _nameCtrl,
                      validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: l.translate('update_profile'),
                      onPressed: _updateProfile,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Change Password section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.softPink.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.translate('change_password'),
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textColor),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: l.translate('current_password'),
                      controller: _currentPassCtrl,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: l.translate('new_password'),
                      controller: _newPassCtrl,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: l.translate('change_password'),
                      onPressed: _changePassword,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Danger Zone
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.translate('danger_zone'),
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.error),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.translate('delete_account_desc'),
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.mediumGrey),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: l.translate('delete_account'),
                      color: AppColors.error,
                      onPressed: _deleteAccount,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
