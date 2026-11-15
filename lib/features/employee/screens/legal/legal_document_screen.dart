import 'package:flutter/material.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:get/get.dart';
import '../../../marketer/widgets/marketer_header.dart';

/// One numbered clause (or a plain paragraph if [number] is null).
class LegalClause {
  final int? number;
  final String text;
  const LegalClause(this.text, {this.number});
}

/// A titled block of clauses, e.g. "1. التعريفات".
class LegalSection {
  final String? heading;
  final List<LegalClause> clauses;
  final Widget? customBody;

  const LegalSection({this.heading, this.clauses = const [], this.customBody});
}

/// Shared renderer for the Terms & Conditions and Privacy Policy screens --
/// both are long, numbered legal documents with the same typography needs,
/// so they share one layout instead of duplicating it.
class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final String? intro;
  final List<LegalSection> sections;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.sections,
    this.intro,
  });

  static const Color _primaryGreen = Color(0xFF30913F);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final scaffoldBg = isDark ? const Color(0xFF121418) : Colors.white;
        final headingText = isDark ? Colors.white : const Color(0xFF111B18);
        final bodyText =
            isDark ? const Color(0xFFCBD5E1) : const Color(0xFF374151);
        final subText =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
        final dividerColor =
            isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: SafeArea(
            child: Column(
              children: [
                MarketerHeader(title: title),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    children: [
                      Text(
                        'آخر تحديث: $lastUpdated',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          color: subText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (intro != null) ...[
                        Text(
                          intro!,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14.5,
                            height: 1.9,
                            color: bodyText,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      for (final section in sections) ...[
                        if (section.heading != null) ...[
                          Text(
                            section.heading!,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: headingText,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (section.customBody != null) section.customBody!,
                        for (final clause in section.clauses)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (clause.number != null) ...[
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    width: 22,
                                    height: 22,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF163E20)
                                          : const Color(0xFFEBFEEB),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${clause.number}',
                                      style: const TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: _primaryGreen,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                                Expanded(
                                  child: Text(
                                    clause.text,
                                    style: TextStyle(
                                      fontFamily: 'Tajawal',
                                      fontSize: 14.5,
                                      height: 1.9,
                                      color: bodyText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 14),
                      ],
                      Divider(color: dividerColor, height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
