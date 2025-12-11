import 'package:flutter/material.dart';

void main() {
  runApp(const SirajApp());
}

class SirajApp extends StatelessWidget {
  const SirajApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سِراج - البلاغات',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050A0F),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: NewReportStartScreen(),
      ),
    );
  }
}

///
/// الشاشة 1: بلاغ جديد (بسيطة في المنتصف)
///
class NewReportStartScreen extends StatelessWidget {
  const NewReportStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.4,
              colors: [
                Color(0xFF0B141B),
                Color(0xFF050A0F),
                Color(0xFF020509),
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              const _AppHeader(
                title: 'البلاغات',
                subtitle: 'توكلنا • بلاغات',
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: 260,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1219),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0x1F00C79C),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '⚡',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'بلاغ جديد',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'اضغط لبدء بلاغ جديد عبر سِراج، وسيتم مشاركة موقعك مع الجهات المختصة.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _PrimaryButton(
                          label: 'بدء بلاغ جديد',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: NewReportDetailsScreen(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///
/// الشاشة 2: تفاصيل البلاغ (صوتي + كتابي + إرسال)
///
class NewReportDetailsScreen extends StatefulWidget {
  const NewReportDetailsScreen({super.key});

  @override
  State<NewReportDetailsScreen> createState() => _NewReportDetailsScreenState();
}

class _NewReportDetailsScreenState extends State<NewReportDetailsScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  // هنا ممكن لاحقًا تضيف منطق التسجيل الصوتي الحقيقي
  bool isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.4,
              colors: [
                Color(0xFF0B141B),
                Color(0xFF050A0F),
                Color(0xFF020509),
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              _AppHeader(
                title: 'بلاغ جديد',
                subtitle: 'توكلنا • بلاغات',
                showBack: true,
                onBack: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1219),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.04),
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'تفاصيل البلاغ',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // TODO: ربط التسجيل الصوتي لاحقًا
                                    setState(() {
                                      isRecording = !isRecording;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: const Color(0xE600C79C),
                                      ),
                                      color: const Color(0x1F00C79C),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: isRecording
                                                ? const Color(0xFFFF4B6A)
                                                : const Color(0xFFAAAAAA),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isRecording
                                              ? 'جاري التسجيل...'
                                              : 'بدء تسجيل صوتي',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFA9FBE4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'يمكنك شرح ما يحدث الآن بصوتك (اختياري).',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF050A0F),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: TextField(
                                controller: _descriptionController,
                                maxLines: 5,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFCFE6FF),
                                ),
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                  hintText:
                                      'اكتب وصفًا مختصرًا لما يحدث الآن… عدد المصابين، نوع الحادث، وأي معلومات قد تساعد الفرق الميدانية (اختياري).',
                                  hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.36),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'يمكنك استخدام التسجيل الصوتي، الكتابة، أو كليهما. سِراج سيتولى تحليل البلاغ وتوجيهه للجهات المناسبة.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _PrimaryButton(
                label: 'إرسال البلاغ الآن',
                onTap: () {
                  // TODO: هنا لاحقًا تستدعي API وتبعث الصوت + النص
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const Directionality(
                        textDirection: TextDirection.rtl,
                        child: ReportSentScreen(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              Text(
                'لن يتم إرسال موقعك أو بياناتك إلا للجهات المختصة فقط.',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.56),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

///
/// الشاشة 3: تم إرسال البلاغ + الجهات + متابعة البلاغ
///
class ReportSentScreen extends StatelessWidget {
  const ReportSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.4,
              colors: [
                Color(0xFF0B141B),
                Color(0xFF050A0F),
                Color(0xFF020509),
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              _AppHeader(
                title: 'تم إرسال البلاغ',
                subtitle: 'توكلنا • بلاغات',
                showBack: true,
                onBack: () {
                  // رجوع لأول شاشة البلاغات
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const Directionality(
                        textDirection: TextDirection.rtl,
                        child: NewReportStartScreen(),
                      ),
                    ),
                    (route) => false,
                  );
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1219),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0x2600C79C),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '✔️',
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'تم إرسال بلاغك للجهات المختصة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'تم استلام البلاغ ومعالجته عبر سِراج، وتم توجيهه تلقائيًا لأقرب الفرق الميدانية بناءً على موقعك ونوع البلاغ.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF050A0F),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'موقعك التقريبي:',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'حي النرجس، الرياض • تم مشاركة موقعك الدقيق بشكل آمن مع غرفة العمليات.',
                                style: TextStyle(
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF050A0F),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الجهات التي تم إشعارها:',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: const [
                                  _TagPill(label: 'الدفاع المدني', main: true),
                                  _TagPill(label: 'الهلال الأحمر', main: true),
                                  _TagPill(label: 'التجمع الصحي'),
                                  _TagPill(label: 'الأمانة'),
                                  _TagPill(label: 'الدوريات الأمنية'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'يمكنك متابعة حالة البلاغ ومعرفة وقت استجابة الفرق من خلال صفحة المتابعة في توكلنا.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _PrimaryButton(
                          label: 'متابعة حالة البلاغ',
                          onTap: () {
                            // TODO: لاحقًا تربطها بصفحة متابعة البلاغ
                          },
                        ),
                        const SizedBox(height: 8),
                        _SecondaryButton(
                          label: 'العودة للبلاغات',
                          onTap: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: NewReportStartScreen(),
                                ),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///
/// ويدجيت الهيدر المشترك
///
class _AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBack;
  final VoidCallback? onBack;

  const _AppHeader({
    required this.title,
    required this.subtitle,
    this.showBack = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xE50F1923),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
              ),
            ),
          )
        else
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xE50F1923),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            child: const Icon(
              Icons.menu,
              size: 16,
            ),
          ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF00C79C),
                Color(0xFF1FD1AE),
              ],
            ),
          ),
          child: const Text(
            'سِراج',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF021010),
            ),
          ),
        ),
      ],
    );
  }
}

/// زر أساسي
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF00C79C),
              Color(0xFF27E0BD),
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF021010),
          ),
        ),
      ),
    );
  }
}

/// زر ثانوي
class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withOpacity(0.18),
          ),
          color: const Color(0xE5050A0F),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Tag صغير للجهات
class _TagPill extends StatelessWidget {
  final String label;
  final bool main;

  const _TagPill({required this.label, this.main = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: main
            ? const Color(0x1F00C79C)
            : const Color(0xFF050C12),
        border: Border.all(
          color: main
              ? const Color(0xD800C79C)
              : Colors.white.withOpacity(0.12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
        ),
      ),
    );
  }
}
