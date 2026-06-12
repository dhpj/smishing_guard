import 'package:flutter/material.dart';

import 'legal_document_sections.dart';
import 'legal_section_card.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('이용약관')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '경남 안심링크 서비스 이용약관',
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
              const SizedBox(height: 16),
              for (final section in LegalDocumentSections.terms)
                LegalSectionCard(title: section.title, body: section.body),
              Text(
                '운영: ${LegalDocumentSections.operatorName} · '
                '${LegalDocumentSections.operatorContact}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
