import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

class LockScreen extends StatefulWidget {
  final Widget child;

  const LockScreen({super.key, required this.child});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isPrivacyLockEnabled) {
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isChecking = false;
        });
      }
      return;
    }

    final unlockReason = context.l10n.translate('unlock_reason');

    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (canAuthenticate) {
        final bool didAuthenticate = await auth.authenticate(
          localizedReason: unlockReason,
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );

        if (mounted) {
          setState(() {
            _isAuthenticated = didAuthenticate;
            _isChecking = false;
          });
        }
      } else {
        // Device doesn't support auth, fallback to unlocked
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
            _isChecking = false;
          });
        }
      }
    } catch (e, st) {
      debugPrint('LockScreen auth error: $e');
      debugPrintStack(stackTrace: st);
      // Jangan biarkan loading terus
      if (mounted) {
        setState(() {
          _isAuthenticated = true; // fallback agar UI tetap tampil
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryPink),
        ),
      );
    }

    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_rounded,
                size: 80,
                color: AppColors.primaryPink,
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.translate('app_locked'),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _checkAuth,
                icon: const Icon(Icons.fingerprint_rounded),
                label: Text(context.l10n.translate('unlock')),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
