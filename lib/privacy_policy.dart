import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';

/// 개인정보 처리방침 시행일. 문구 갱신 시 갱신한다.
const privacyPolicyEffectiveDate = '2026-09-03';

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const PrivacyPolicyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.privacyPolicy),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.privacyBody1),
            const SizedBox(height: 12),
            Text(l10n.privacyBody2),
            const SizedBox(height: 12),
            Text(l10n.privacyBody3),
            const SizedBox(height: 12),
            Text(
              l10n.privacyBody4,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(l10n.privacyEffectiveDate(privacyPolicyEffectiveDate)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.ok),
        ),
      ],
    );
  }
}
