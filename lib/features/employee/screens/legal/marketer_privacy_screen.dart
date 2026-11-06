import 'package:flutter/material.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:get/get.dart';
import 'legal_document_screen.dart';

class _DataRow {
  final String field;
  final String purpose;
  final String when;
  final String retention;
  final String visibleTo;
  const _DataRow(
      this.field, this.purpose, this.when, this.retention, this.visibleTo);
}

const List<_DataRow> _dataRows = [
  _DataRow(
      'بيانات الحساب (الاسم، الجوال، الرقم الوظيفي)',
      'إنشاء الحساب والتواصل',
      'عند التفعيل',
      'مدة العقد + 12 شهراً',
      'المشرف والموارد البشرية'),
  _DataRow('الموقع الجغرافي', 'إثبات الحضور والتواجد وحساب المسافة',
      'أثناء الدوام فقط', '12 شهراً', 'المشرف والموارد البشرية'),
  _DataRow('صورة السيلفي', 'الحضور والمظهر المهني', 'بدء الدوام',
      'مدة شهر، ما لم تكن محل اعتراض أو تحقيق', 'المشرف'),
  _DataRow('صور المتاجر', 'توثيق الزيارة', 'أثناء الزيارة',
      'مدة العلاقة مع التاجر وسنة بعدها', 'الإدارة والمبيعات'),
  _DataRow('سجل النشاط والتنبيهات والاعتراضات', 'ساعات العمل والتقييم',
      'أثناء الدوام', 'مدة العقد + 12 شهراً', 'المشرف والموارد البشرية'),
  _DataRow(
      'بيانات العقود والشبكة والعمولات',
      'حساب الحوافز والمستحقات ومكافحة التحايل',
      'عند كل عملية',
      'مدة العقد + [ ] سنوات للأغراض المالية',
      'المشرف والإدارة المالية'),
  _DataRow(
      'بيانات الجهاز (الطراز، النظام، المعرّف)',
      'أمان الحساب وكشف التحايل ومعالجة الأعطال',
      'عند الدخول',
      'مدة العقد',
      'الدعم الفني'),
];

/// سياسة الخصوصية -- تطبيق أخصائي النمو.
/// المصدر: الدليل الميداني 1.5 وقرارات الإدارة (راجعها قانونياً قبل النشر).
class MarketerPrivacyScreen extends StatelessWidget {
  const MarketerPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentScreen(
      title: 'سياسة الخصوصية',
      lastUpdated: '[يُحدَّد عند النشر]',
      intro:
          'يجمع التطبيق بيانات محددة لأغراض محددة، والتتبع أثناء الدوام فقط ويتوقف عند تسجيل الخروج. وتلتزم شلة بنظام حماية البيانات الشخصية في المملكة.',
      sections: [
        LegalSection(
          heading: '1. البيانات التي نجمعها',
          customBody: _DataTable(rows: _dataRows),
        ),
        const LegalSection(
          heading: '2. ما لا نجمعه',
          clauses: [
            LegalClause('لا يتتبع التطبيق موقعك خارج الدوام.', number: 53),
            LegalClause(
                'لا يصل التطبيق إلى صورك أو رسائلك أو ملفاتك الشخصية في الجوال، والكاميرا تُستخدم للتصوير الحي فقط.',
                number: 54),
            LegalClause(
                'لا يجمع التطبيق من صورتك أي بصمة حيوية، ولا يستخدمها في التعرف الآلي على الوجه إلا بموافقة كتابية منفصلة منك، ورفضك لا يؤثر على عقدك.',
                number: 55),
          ],
        ),
        const LegalSection(
          heading: '3. كيف نستخدم البيانات',
          clauses: [
            LegalClause(
                'تُستخدم بياناتك لأغراض العمل فقط: إثبات الحضور وساعات العمل، وتوثيق الزيارات والعقود، وحساب الراتب والحوافز والعمولات، وتقييم الأداء، والفصل في الاعتراضات، وكشف التحايل وحماية الحسابات. ولا تُستخدم لأي غرض تسويقي أو تُباع لأي جهة.'),
          ],
        ),
        const LegalSection(
          heading: '4. مشاركة البيانات',
          clauses: [
            LegalClause(
                'داخل شلة: مشرفك والموارد البشرية والإدارة المالية والدعم الفني، كل في حدود اختصاصه.',
                number: 56),
            LegalClause(
                'مزودو الخدمات التقنية (الاستضافة، الرسائل النصية، الخرائط) بالقدر اللازم لتشغيل التطبيق، وبموجب اتفاقيات تلزمهم بالسرية.',
                number: 57),
            LegalClause(
                'الجهات الحكومية المختصة عند الطلب النظامي، ومنها منصات قوى والتأمينات الاجتماعية لأغراض التوظيف.',
                number: 58),
            LegalClause(
                'لا يرى التجار والمسوقون من بياناتك إلا اسمك ورقم العمل.',
                number: 59),
          ],
        ),
        const LegalSection(
          heading: '5. أمان البيانات',
          clauses: [
            LegalClause(
                'تُحفظ البيانات على خوادم مؤمنة [موقع الاستضافة]، وتُنقل مشفّرة، والوصول إليها بصلاحيات محددة لكل دور ومسجّل في سجل تدقيق. وتُحذف البيانات آلياً بانتهاء مدد الحفظ المذكورة، ما لم يلزم النظام بحفظها مدة أطول.'),
          ],
        ),
        const LegalSection(
          heading: '6. حقوقك',
          clauses: [
            LegalClause('الاطلاع على بياناتك الشخصية والحصول على نسخة منها.',
                number: 60),
            LegalClause('طلب تصحيح أي بيان غير دقيق أو إكماله.', number: 61),
            LegalClause(
                'طلب إتلاف بياناتك بعد انتهاء الغرض منها، في غير ما يلزم النظام بحفظه.',
                number: 62),
            LegalClause(
                'الاعتراض على أي قرار بُني على بياناتك، ومنها التنبيهات وساعات العمل.',
                number: 63),
            LegalClause(
                'سحب موافقتك على أي معالجة اختيارية (مثل التعرف على الوجه) في أي وقت.',
                number: 64),
            LegalClause(
                'تقديم شكوى إلى الجهة المختصة بحماية البيانات الشخصية في المملكة.',
                number: 65),
            LegalClause(
                'تُقدَّم الطلبات إلى info@shellafood.com، ويُرد عليها خلال [ ] يوماً.'),
          ],
        ),
        const LegalSection(
          heading: '7. التعديلات والتواصل',
          clauses: [
            LegalClause(
                'نبلغك بأي تعديل جوهري على هذه السياسة عبر التطبيق قبل تطبيقه. وللاستفسار: شله للخدمات التجارية، [العنوان]، info@shellafood.com.'),
          ],
        ),
      ],
    );
  }
}

/// Mobile-friendly stand-in for the desktop data-collection table: each row
/// becomes a labeled card instead of cramming 5 columns into a phone width.
class _DataTable extends StatelessWidget {
  final List<_DataRow> rows;
  const _DataTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        final isDark = themeCtrl.darkTheme;
        final cardBg =
            isDark ? const Color(0xFF1C2028) : const Color(0xFFF6F5F8);
        final borderColor =
            isDark ? const Color(0xFF2B3240) : const Color(0xFFE5E7EB);
        final headingText = isDark ? Colors.white : const Color(0xFF111B18);
        final labelColor =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
        final valueColor =
            isDark ? const Color(0xFFCBD5E1) : const Color(0xFF374151);

        Widget field(String label, String value) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: labelColor,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      height: 1.7,
                      color: valueColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            for (final row in rows)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.field,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: headingText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    field('الغرض', row.purpose),
                    field('متى يُجمع', row.when),
                    field('مدة الحفظ', row.retention),
                    field('من يطّلع عليه', row.visibleTo),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
