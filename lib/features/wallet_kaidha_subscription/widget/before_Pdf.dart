// ignore_for_file: camel_case_types, file_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/features/wallet_kaidha_subscription/controllers/kaidhaSub_controller.dart';
import 'package:sixam_mart/util/app_colors.dart';
import 'package:sixam_mart/util/images.dart';

class Befor_Pdf_Screen extends StatefulWidget {
  final String time;
  final String day;
  final String name;
  final String identityNumber;
  final String nationality;
  final String neighborhood;
  final String house_type;

  const Befor_Pdf_Screen({
    super.key,
    required this.time,
    required this.day,
    required this.name,
    required this.identityNumber,
    required this.nationality,
    required this.neighborhood,
    required this.house_type,
  });

  factory Befor_Pdf_Screen.fromArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    return Befor_Pdf_Screen(
      time: args['time']?.toString() ?? '',
      day: args['day']?.toString() ?? '',
      name: args['name']?.toString() ?? '',
      identityNumber: args['identityNumber']?.toString() ?? '',
      nationality: args['nationality']?.toString() ?? '',
      neighborhood: args['neighborhood']?.toString() ?? '',
      house_type: args['house_type']?.toString() ?? '',
    );
  }

  @override
  State<Befor_Pdf_Screen> createState() => _Befor_Pdf_ScreenState();
}

class _Befor_Pdf_ScreenState extends State<Befor_Pdf_Screen> {
  final List<bool> _checkboxes = [false, false, false, false];

  bool get _allChecked => _checkboxes.every((checked) => checked);

  final List<_ContractClause> _clauses = [
    const _ContractClause(
      number: '1',
      title: 'أطراف الاتفاقية',
      content:
          'تُبرم هذه الاتفافية بين شركة شله التجارية [المالكه لمنصه شله] ("المنصة") وبين العميل الفرد الموضّحة بياناته أدناه ("العميل") استناداً إلى أحكام نظام التجارة الإلكترونية ولوائحه التنفيذية الصادرة في المملكة العربية السعودية، حيث توفّر المنصة خدمة "قيدها" التي تُمكّن العميل من تكوين ملف ائتماني تعريفي (يشبه السيرة الذاتية المالية) يُرسَل — بموافقته — إلى التجار المشاركين الذين يتيحون البيع الآجل، ليدرسوا طلبه ويقرروا قبوله أو رفضه؛ وحيث يرغب العميل في الاشتراك في الخدمة وتكوين ملفه وتوثيق موافقته.',
    ),
    const _ContractClause(
      number: '2',
      title: 'الغرض من الاتفاقية',
      content:
          'تنظيم علاقة العميل بالمنصة عند تكوين ملفه الائتماني التعريفي في خدمة قيدها، وموافقته على مشاركة بياناته مع التجار لغرض دراسة طلب البيع الآجل. هذه الاتفاقية لا تُنشئ بذاتها أي دين أو التزام مالي على العميل، ولا تمنحه سقفاً ائتمانياً؛ فالسقف والدين ينشآن لاحقاً عند قبول تاجر معيّن وتحرير سند لأمر مستقل عبر نافذ. المنصة وسيط تقني يوفّر أدوات تكوين الملف وإرساله؛ وقرار القبول أو الرفض يعود للتاجر وحده وعلى مسؤوليته.',
    ),
    const _ContractClause(
      number: '3',
      title: 'بيانات الملف الائتماني',
      content:
          'تُوثَّق بيانات الهوية (الاسم، رقم الهوية، تاريخ الميلاد) آلياً عبر النفاذ الوطني الموحد، وتظهر مقفلة غير قابلة للتعديل. يُقر العميل بأن أي بيان غير صحيح مسؤوليته الشخصية، وقد يترتب عليه رفض الطلب أو إيقاف الخدمة.',
    ),
    const _ContractClause(
      number: '4',
      title: 'معالجة البيانات والخصوصية',
      content:
          'تلتزم المنصة بمعالحة ببانات العميل وفق نظام حماية البيانات الشخصية السعودي ولوائحه التنفيذية. لن تُشارك البيانات مع أي جهة خارجية دون موافقة صريحة من العميل أو بموجب إلزام قانوني. أوافق على مشاركة ملفي مع التجار الذين أتقدّم إليهم بطلب، بالقدر اللازم لدراسة الطلب. أوافق على التحقق من هويتي عبر نفاذ. أعلم بحقوقي وفق النظام: الاطلاع على بياناتي، وتصحيحها، وطلب إتلافها بعد انتهاء الغرض، وسحب موافقته على المعالجات الاختيارية.',
    ),
    const _ContractClause(
      number: '5',
      title: 'التزامات المنصة',
      content:
          'توثيق هوية العميل عبر نفاذ وحفظ ملفه بأمان وفق نظام حماية البيانات الشخصية. عدم مشاركة الملف إلا مع التجار الذين يتقدّم إليهم العميل، وعدم بيعه أو استخدامه خارج الغرض. عدم تفعيل أي سقف قبل اكتمال توثيق السند لأمر مع التاجر عبر نافذ.',
    ),
    const _ContractClause(
      number: '6',
      title: 'مدة الاتفاقية وإنهاؤها',
      content:
          'تسري هذه الاتفاقية من تاريخ توثيقها وتبقى سارية طوال استخدام العميل للخدمة. يحق للعميل إغلاق ملفه وسحب موافقته في أي وقت، مع بقاء التزاماته القائمة تجاه التجار (الديون والسندات النافذة) سارية حتى تسويتها.',
    ),
    const _ContractClause(
      number: '7',
      title: 'أحكام عامة',
      content:
          'تخضع هذه الاتفاقية لأنظمة المملكة العربية السعودية. تُعد الموافقة الإلكترونية الموثّقة عبر نافذ/صادق توقيعاً معتبراً وفق نظام التعاملات الإلكترونية.',
    ),
    const _ContractClause(
      number: '8',
      title: 'التوقيع والمصادقة الإلكترونية',
      content:
          'يُتمّ العميل الموافقة على هذه الاتفاقية إلكترونياً، وتُوثَّق عبر منصة نافذ ويُصدر بها ختم الحجية من "صادق"، وفق الإجراءات النظامية المعتمدة.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KaidhaSubscriptionController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'اتفاقية الاشتراك في خدمة قيدها',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(Images.logo, height: 90, width: 300),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'عقد خدمة قيدها - اشتر الآن وادفع مع الراتب',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF707070),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildAgreementIntroCard(),
                  const SizedBox(height: 16),

                  _buildSectionHeader('بنود الاتفاقية', '${_clauses.length} بنود'),
                  const SizedBox(height: 12),

                  ..._clauses.map((clause) => _ClauseAccordion(
                        number: clause.number,
                        title: clause.title,
                        content: clause.content,
                      )),

                  const SizedBox(height: 24),

                  _buildSectionHeader('ملخص الملف الائتماني', ''),
                  const SizedBox(height: 12),
                  _buildCreditFileSummaryCard(controller),
                  const SizedBox(height: 24),

                  _buildSectionHeader('الموافقة والإقرار', ''),
                  const SizedBox(height: 12),

                  _consentCard(0,
                      'أُقر بأن جميع البيانات التي أدخلتها صحيحة وحديثة، وأتحمّل مسؤولية صحّتها'),
                  _consentCard(1,
                      'أُقر بعلمي أن ملفي سيُعرض على التجار الذين أتقدّم إليهم بطلب، لغرض دراسة أهليتي للبيع الآجل حصراً.'),
                  _consentCard(2,
                      'أُقر بأن موافقة التاجر — إن تمت — لا تُفعّل حسابي إلا بعد توقيعي سنداً لأمر ،'),
                  _consentCard(3,
                      'أُقر بأنني أتقدّم بهذا الطلب بمحض إرادتي دون إكراه، وأنني على علم بطبيعة البيع الآجل والتزاماته.'),

                  const SizedBox(height: 24),

                  _electronicSignatureCard(controller),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBFEEB),
                      border: Border.all(color: const Color(0xFF30913F)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FDD2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.verified_user_outlined,
                                color: Color(0xFF30913F),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'توقيع إلكتروني معتمد قانونياً',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111B18),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'وفق نظام التوقيعات الإلكترونية - المملكة العربية السعودية',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111B18),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  CustomButton(
                    buttonText: 'الموافقة والمتابعة',
                    color: _allChecked
                        ? const Color(0xFF30913F)
                        : const Color(0xFFE5E5E8),
                    textColor:
                        _allChecked ? Colors.white : const Color(0xFF707070),
                    onPressed: _allChecked
                        ? () {
                            controller.setHasAgreedToContract(true);
                            Get.back();
                          }
                        : null,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgreementIntroCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEBFEEB),
        border: Border.all(color: const Color(0xFF30913F)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FDD2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF30913F),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'اتفاقية تكوين الملف الائتماني',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111B18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'تنظّم هذه الاتفاقية استخدامك لخدمة قيدها ومشاركة ملفك الائتماني مع التجار المعتمدين، وذلك فقط بعد موافقتك الصريحة على كل طلب.',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111B18),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (trailing.isNotEmpty)
          Text(
            trailing,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF555555),
            ),
          ),
        const Spacer(),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111B18),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditFileSummaryCard(KaidhaSubscriptionController controller) {
    final String phone = '${controller.selectedCountryDialCode} ${controller.phoneController.text}';
    final String employer = controller.name_of_employer.text;
    final String jobTitle = controller.jobSpecification;
    final String monthlyIncome = controller.monthlyIncome.text.isNotEmpty
        ? '${controller.monthlyIncome.text} ريال'
        : controller.total_salary.text.isNotEmpty
            ? '${controller.total_salary.text} ريال'
            : '—';
    final String obligations = controller.installment_amount.text.isNotEmpty
        ? '${controller.installment_amount.text} ريال'
        : '—';
    final String familyCount = controller.number_of_family_members.text;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 25),
            blurRadius: 50,
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Color(0xFF3EC856), Color(0xFF30913F)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBFEEB),
                    border: Border.all(color: const Color(0xFFB9F8CF), width: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'موثق عبر نفاذ',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF008236),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.verified, color: Color(0xFF008236), size: 12),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'مقدم من',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.name.isNotEmpty ? widget.name : '—',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                _summaryRow('رقم الهوية / الإقامة', widget.identityNumber.isNotEmpty ? widget.identityNumber : '—'),
                _summaryDivider(),
                _summaryRow('تاريخ الميلاد', controller.birthDate.isNotEmpty ? controller.birthDate : '—'),
                _summaryDivider(),
                _summaryRow('رقم الجوال', controller.phoneController.text.isNotEmpty ? phone : '—'),
                _summaryDivider(),
                _summaryRow('المدينة / الحي', widget.neighborhood.isNotEmpty
                    ? widget.neighborhood
                    : controller.city.isNotEmpty
                        ? controller.city
                        : '—'),
                _summaryDivider(),
                _summaryRow('جهة العمل', employer.isNotEmpty ? employer : '—'),
                _summaryDivider(),
                _summaryRow('المسمى الوظيفي', jobTitle.isNotEmpty ? jobTitle : '—'),
                _summaryDivider(),
                _summaryRow('الدخل الشهري', monthlyIncome),
                _summaryDivider(),
                _summaryRow('الالتزامات الشهرية', obligations),
                if (familyCount.isNotEmpty) ...[
                  _summaryDivider(),
                  _summaryRow('عدد أفراد الأسرة (اختياري)', familyCount),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111B18),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF707784),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0));
  }

  Widget _consentCard(int index, String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _checkboxes[index] = !_checkboxes[index];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: const Color(0xFFEBFEEB),
          border: Border.all(color: const Color(0xFF30913F)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _checkboxes[index],
                activeColor: AppColors.greenColor,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                side: const BorderSide(color: Color(0xFF30913F), width: 1.5),
                onChanged: (val) {
                  setState(() {
                    _checkboxes[index] = val ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF000000),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _electronicSignatureCard(KaidhaSubscriptionController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 25),
            blurRadius: 50,
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Color(0xFF3EC856), Color(0xFF30913F)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      'التوقيع الإلكتروني',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'نفاذ - معتمد رسمياً',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                _summaryRow('طريقة التوثيق', 'تحقّق عن طريق نفاذ'),
                _summaryDivider(),
                _summaryRow('رقم المعاملة', 'يُنشأ تلقائياً عند التوقيع'),
                _summaryDivider(),
                _summaryRow('أُنشئ بواسطة', 'تطبيق شلة'),
                _summaryDivider(),
                _summaryRow('اسم الموقّع', widget.name.isNotEmpty ? widget.name : '—'),
                _summaryDivider(),
                _summaryRow('رقم الهوية', widget.identityNumber.isNotEmpty ? widget.identityNumber : '—'),
                _summaryDivider(),
                _summaryRow(
                    'تاريخ التحقق من نفاذ',
                    widget.day.isNotEmpty && widget.time.isNotEmpty
                        ? 'يوم ${widget.day} الساعة ${widget.time}'
                        : '—'),
                _summaryDivider(),
                _summaryRow('حجية الملف', 'صادق — ملف صالح'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClauseAccordion extends StatefulWidget {
  final String number;
  final String title;
  final String content;

  const _ClauseAccordion({
    required this.number,
    required this.title,
    required this.content,
  });

  @override
  State<_ClauseAccordion> createState() => _ClauseAccordionState();
}

class _ClauseAccordionState extends State<_ClauseAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3EC856)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF30913F).withValues(alpha: 0.25),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
              child: Row(
                children: [
                  // Arrow icon on left side
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF707070),
                    size: 16,
                  ),
                  const Spacer(),
                  // Title on right side
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111B18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Number badge
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEBFEEB),
                    ),
                    child: Text(
                      widget.number,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF30913F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(height: 1, thickness: 1, color: Color(0xFFF6F5F8)),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, bottom: 17, top: 8),
                  child: Text(
                    widget.content,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111B18),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _ContractClause {
  final String number;
  final String title;
  final String content;

  const _ContractClause({
    required this.number,
    required this.title,
    required this.content,
  });
}
