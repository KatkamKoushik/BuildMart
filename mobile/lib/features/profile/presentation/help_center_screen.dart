import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.helpCenter),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            AppLocalizations.of(context)!.faqTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFaqTile(
            AppLocalizations.of(context)!.faq1Q,
            AppLocalizations.of(context)!.faq1A,
          ),
          _buildFaqTile(
            AppLocalizations.of(context)!.faq2Q,
            AppLocalizations.of(context)!.faq2A,
          ),
          _buildFaqTile(
            AppLocalizations.of(context)!.faq3Q,
            AppLocalizations.of(context)!.faq3A,
          ),
          _buildFaqTile(
            AppLocalizations.of(context)!.faq4Q,
            AppLocalizations.of(context)!.faq4A,
          ),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.contactSupport,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.border),
            ),
            child: ListTile(
              leading:
                  const Icon(Icons.support_agent, color: AppColors.primary),
              title: Text(AppLocalizations.of(context)!.chatSupport),
              subtitle: Text(
                AppLocalizations.of(context)!.chatSupportSub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                context.push('/support-chat');
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.border),
            ),
            child: ListTile(
              leading:
                  const Icon(Icons.email_outlined, color: AppColors.primary),
              title: Text(AppLocalizations.of(context)!.emailUs),
              subtitle: const Text('support@buildmart.com'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email app will open soon.')),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.border),
            ),
            child: ListTile(
              leading:
                  const Icon(Icons.phone_outlined, color: AppColors.primary),
              title: Text(AppLocalizations.of(context)!.callUs),
              subtitle: const Text('+91 1800 123 4567'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone dialer will open soon.')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: const TextStyle(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
