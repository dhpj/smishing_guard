import 'package:flutter/material.dart';

import 'legal_document_sections.dart';
import 'legal_section_card.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('개인정보처리방침')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '경남 안심링크 개인정보처리방침',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '시행일: ${LegalDocumentSections.effectiveDate}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                LegalDocumentSections.operatorName,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              for (final section in LegalDocumentSections.privacy)
                LegalSectionCard(title: section.title, body: section.body),
            ],
          ),
        ),
      ),
    );
  }
}
