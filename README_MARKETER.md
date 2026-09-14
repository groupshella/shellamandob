# مسوق شله — Shela Marketer App

تطبيق **المسوّق** (مندوب تسويق قسائم الشراء) — مبني من قاعدة كود تطبيق شله للعميل
(Flutter) عبر علم بناء واحد. نفس تسجيل الدخول ونفس الخادم (shellafood.com)،
ويفتح مباشرة على خدمة المسوّق.

## البناء

نسخة المسوّق (package `com.food.shala.marketer`، الاسم "مسوق شله"):

```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17   # JDK 17
export APP_MODE=marketer
flutter build apk --release \
  --dart-define=ENV=production \
  --dart-define=APP_MODE=marketer
```

iOS / محاكي:

```bash
flutter run -d <device> --dart-define=ENV=production --dart-define=APP_MODE=marketer
```

## كيف يعمل الفصل (بدون التأثير على تطبيق العميل)

- `AppConstants.isMarketerApp` = ثابت وقت التجميع من `APP_MODE=marketer`.
- `DashboardScreen.build`: في وضع المسوّق يفتح `MarketerScreen` مباشرة بدل داشبورد العميل.
- Android: `applicationIdSuffix ".marketer"` + الاسم "مسوق شله" (مبوّبان على متغيّر البيئة `APP_MODE`).
- في نسخة العميل تُحذف كل مسارات المسوّق تلقائيًّا (dead-code) — صفر أثر وصفر زيادة حجم.

## ملاحظات

- `android/app/google-services.json` يحوي عميل `com.food.shala.marketer` (يعيد استخدام
  إعداد Firebase الخاص بـ com.food.shala للمراجعة). قبل الرفع الرسمي على Play يُسجَّل
  الـ package في Firebase Console رسميًّا.
- مفاتيح التوقيع (keystore) **غير مضمّنة** — تُضاف محليًّا عبر `android/key.properties`.
