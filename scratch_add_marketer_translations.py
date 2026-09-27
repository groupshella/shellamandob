import json

new_keys = {
    'paying_customers_completed': {
        'ar': 'العملاء الدافعون (أتموا الشراء)',
        'en': 'Paying Customers (Completed Purchase)',
        'bn': 'অর্থপ্রদানকারী গ্রাহক (ক্রয় সম্পন্ন)',
        'es': 'Clientes de pago (Compra completada)',
    },
    'total_registered': {
        'ar': 'إجمالي المسجلين',
        'en': 'Total Registered',
        'bn': 'মোট নিবন্ধিত',
        'es': 'Total registrados',
    },
    'haven_not_paid_yet': {
        'ar': 'لم يدفعوا بعد',
        'en': "Haven't Paid Yet",
        'bn': 'এখনও অর্থপ্রদান করেনি',
        'es': 'Aún no han pagado',
    },
    'new_client_join_commission': {
        'ar': 'عمولة انضمام عميل جديدة',
        'en': 'New Client Join Commission',
        'bn': 'নতুন ক্লায়েন্ট যোগদানের কমিশন',
        'es': 'Comisión de unión de nuevo cliente',
    },
    'today_sample_time': {
        'ar': 'اليوم، 2:30 م',
        'en': 'Today, 2:30 PM',
        'bn': 'আজ, দুপুর ২:৩০',
        'es': 'Hoy, 2:30 PM',
    },
    'pending_days_remaining_sample': {
        'ar': 'معلّقة – متبقي 3 أيام',
        'en': 'Pending – 3 days remaining',
        'bn': 'মুলতবি – ৩ দিন বাকি',
        'es': 'Pendiente – 3 días restantes',
    },
    'registered_successfully': {
        'ar': 'تم تسجيل بنجاح',
        'en': 'Registered Successfully',
        'bn': 'সফলভাবে নিবন্ধিত',
        'es': 'Registrado con éxito',
    },
    'new_passenger_referral_reward': {
        'ar': 'مكافأة إحالة راكب جديدة',
        'en': 'New Passenger Referral Reward',
        'bn': 'নতুন যাত্রী রেফারেল পুরস্কার',
        'es': 'Recompensa de referencia de nuevo pasajero',
    },
    'pending_days_remaining_7_sample': {
        'ar': 'معلّقة – متبقي 7 أيام',
        'en': 'Pending – 7 days remaining',
        'bn': 'মুলতবি – ৭ দিন বাকি',
        'es': 'Pendiente – 7 días restantes',
    },
    'referral_commission_title': {
        'ar': 'عمولة إحالة',
        'en': 'Referral Commission',
        'bn': 'রেফারেল কমিশন',
        'es': 'Comisión de referencia',
    },
    'filter_paid': {
        'ar': 'دافعون',
        'en': 'Paid',
        'bn': 'পরিশোধিত',
        'es': 'Pagados',
    },
    'filter_registered_only': {
        'ar': 'مسجلون فقط',
        'en': 'Registered Only',
        'bn': 'শুধুমাত্র নিবন্ধিত',
        'es': 'Solo registrados',
    },
    'filter_completed': {
        'ar': 'مكتملة',
        'en': 'Completed',
        'bn': 'সম্পন্ন',
        'es': 'Completada',
    },
    'filter_pending': {
        'ar': 'معلّقة',
        'en': 'Pending',
        'bn': 'মুলতবি',
        'es': 'Pendiente',
    },
    'completed_status': {
        'ar': 'مكتملة',
        'en': 'Completed',
        'bn': 'সম্পন্ন',
        'es': 'Completada',
    },
    'whatsapp_marketer_support_message': {
        'ar': 'مرحباً، أحتاج مساعدة بخصوص حسابي كمسوق في تطبيق شلة',
        'en': 'Hello, I need assistance regarding my marketer account on Shella app',
        'bn': 'হ্যালো, শেলা অ্যাপে আমার মার্কেটার অ্যাকাউন্ট সম্পর্কিত সহায়তা প্রয়োজন',
        'es': 'Hola, necesito ayuda con respecto a mi cuenta de comercializador en la aplicación Shella',
    },
}

langs = ['ar', 'en', 'bn', 'es']
for lang in langs:
    path = f'assets/language/{lang}.json'
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    added = 0
    for k, trans in new_keys.items():
        if k not in data:
            data[k] = trans[lang]
            added += 1
        else:
            # Overwrite if exists to be sure
            data[k] = trans[lang]
            
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Updated {lang}.json with {added} new keys. Total keys: {len(data)}")
