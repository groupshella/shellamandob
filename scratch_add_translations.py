import json

translations = {
    "work_zone_locked": {
        "ar": "تم قفل منطقة العمل",
        "en": "Work zone locked",
        "bn": "কাজের এলাকা লক করা হয়েছে",
        "es": "Zona de trabajo bloqueada"
    },
    "choose_zone_before_tour": {
        "ar": "اختر المنطقة قبل بدء الجولة",
        "en": "Select area before starting tour",
        "bn": "ট্যুর শুরু করার আগে এলাকা নির্বাচন করুন",
        "es": "Seleccione el área antes de comenzar el recorrido"
    },
    "must_be_within_specified_range": {
        "ar": "يجب أن تكون داخل النطاق المحدد لبدء الدوام.",
        "en": "You must be within the specified range to start work.",
        "bn": "কাজ শুরু করতে আপনাকে নির্ধারিত পরিসরের মধ্যে থাকতে হবে।",
        "es": "Debe estar dentro del rango especificado para comenzar a trabajar."
    },
    "planned_visits": {
        "ar": "زيارات مخططة",
        "en": "planned visits",
        "bn": "পরিকল্পিত পরিদর্শন",
        "es": "visitas planificadas"
    },
    "continue_to_attendance": {
        "ar": "متابعة إلى تسجيل الحضور",
        "en": "Continue to attendance",
        "bn": "উপস্থিতি রেকর্ডিং চালিয়ে যান",
        "es": "Continuar con el registro de asistencia"
    },
    "confirm_work_zone": {
        "ar": "تأكيد منطقة العمل",
        "en": "Confirm work zone",
        "bn": "কাজের এলাকা নিশ্চিত করুন",
        "es": "Confirmar zona de trabajo"
    },
    "confirm_zone_lock_notice": {
        "ar": "بعد التأكيد سيتم قفل منطقة العمل لهذه الجولة، ولن تتمكن من تغييرها إلا بموافقة المشرف.",
        "en": "After confirmation, the work zone will be locked for this tour and cannot be changed without supervisor approval.",
        "bn": "নিশ্চিতকরণের পরে, এই ট্যুরের জন্য কাজের এলাকা লক করা হবে এবং সুপারভাইজারের অনুমোদন ছাড়া পরিবর্তন করা যাবে না।",
        "es": "Tras la confirmación, la zona de trabajo quedará bloqueada para este recorrido y no se podrá cambiar sin la aprobación del supervisor."
    },
    "confirm_zone_btn": {
        "ar": "تأكيد المنطقة",
        "en": "Confirm Zone",
        "bn": "এলাকা নিশ্চিত করুন",
        "es": "Confirmar zona"
    },
    "back_to_selection": {
        "ar": "العودة للاختيار",
        "en": "Back to selection",
        "bn": "নির্বাচনে ফিরে যান",
        "es": "Volver a la selección"
    },
    "confirm_your_location": {
        "ar": "تأكيد موقعك",
        "en": "Confirm your location",
        "bn": "আপনার অবস্থান নিশ্চিত করুন",
        "es": "Confirme su ubicación"
    },
    "you_are_inside_geofence": {
        "ar": "أنت داخل النطاق",
        "en": "You are inside the geofence",
        "bn": "আপনি জিওফেন্সের ভিতরে আছেন",
        "es": "Está dentro del rango delimitado"
    },
    "outside_geofence_error": {
        "ar": "حدث خطأ ما (خارج النطاق)",
        "en": "Something went wrong (outside range)",
        "bn": "কিছু ভুল হয়েছে (পরিসরের বাইরে)",
        "es": "Algo salió mal (fuera de rango)"
    },
    "request_change_zone": {
        "ar": "طلب تغيير المنطقة",
        "en": "Request zone change",
        "bn": "এলাকা পরিবর্তনের অনুরোধ",
        "es": "Solicitar cambio de zona"
    },
    "take_verification_photo": {
        "ar": "التقاط صورة التحقق",
        "en": "Take verification photo",
        "bn": "যাচাইকরণ ছবি তুলুন",
        "es": "Tomar foto de verificación"
    },
    "take_verification_photo_desc": {
        "ar": "التقط صورة مباشرة للتحقق من حضورك ومظهرك المهني.",
        "en": "Take a live photo to verify your attendance and professional appearance.",
        "bn": "আপনার উপস্থিতি এবং পেশাদার চেহারা যাচাই করতে একটি লাইভ ছবি তুলুন।",
        "es": "Tome una foto en vivo para verificar su asistencia y apariencia profesional."
    },
    "front_camera": {
        "ar": "كاميرا أمامية",
        "en": "Front camera",
        "bn": "সামনের ক্যামেরা",
        "es": "Cámara frontal"
    },
    "tap_to_capture_selfie": {
        "ar": "اضغط للالتقاط بكاميرا السيلفي",
        "en": "Tap to capture with selfie camera",
        "bn": "সেলফি ক্যামেরা দিয়ে তুলতে ট্যাপ করুন",
        "es": "Toque para capturar con la cámara frontal"
    },
    "photo_captured": {
        "ar": "تم التقاط الصورة",
        "en": "Photo captured",
        "bn": "ছবি তোলা হয়েছে",
        "es": "Foto capturada"
    },
    "retake_photo": {
        "ar": "إعادة التقاط الصورة",
        "en": "Retake photo",
        "bn": "পুনরায় ছবি তুলুন",
        "es": "Volver a tomar la foto"
    },
    "capture_photo": {
        "ar": "التقاط الصورة",
        "en": "Take photo",
        "bn": "ছবি তুলুন",
        "es": "Tomar foto"
    },
    "choose_from_gallery": {
        "ar": "أو اختيار صورة من المعرض",
        "en": "Or choose a photo from gallery",
        "bn": "অথবা গ্যালারি থেকে ছবি নির্বাচন করুন",
        "es": "O elija una foto de la galería"
    },
    "work_start_confirmed_title": {
        "ar": "تم تأكيد بداية العمل",
        "en": "Shift start confirmed",
        "bn": "কাজের শুরু নিশ্চিত করা হয়েছে",
        "es": "Inicio de turno confirmado"
    },
    "work_start_confirmed_subtitle": {
        "ar": "تم تأكيد بداية العمل، نلفت انتباهك أن سبب التقاط الصورة هو التأكد من المظهر العام والمهنية.",
        "en": "Work start confirmed. Please note that the selfie is used to verify overall presentation and professionalism.",
        "bn": "কাজের শুরু নিশ্চিত করা হয়েছে। অনুগ্রহ করে লক্ষ্য করুন যে সেলফির উদ্দেশ্য পেশাদার উপস্থিতি যাচাই করা।",
        "es": "Inicio de trabajo confirmado. Tenga en cuenta que la foto se utiliza para verificar la presentación profesional."
    },
    "explore_field_visits": {
        "ar": "استكشاف الزيارات الميدانية",
        "en": "Explore field visits",
        "bn": "ফিল্ড পরিদর্শন অন্বেষণ করুন",
        "es": "Explorar visitas de campo"
    },
    "change_request_supervisor_notice": {
        "ar": "سيتم إرسال الطلب للمشرف للموافقة.",
        "en": "Request will be sent to supervisor for approval.",
        "bn": "অনুরোধটি অনুমোদনের জন্য সুপারভাইজারের কাছে পাঠানো হবে।",
        "es": "La solicitud se enviará al supervisor para su aprobación."
    },
    "reason_for_change": {
        "ar": "سبب التغيير",
        "en": "Reason for change",
        "bn": "পরিবর্তনের কারণ",
        "es": "Motivo del cambio"
    },
    "send_request_to_supervisor": {
        "ar": "إرسال الطلب للمشرف",
        "en": "Send request to supervisor",
        "bn": "সুপারভাইজারকে অনুরোধ পাঠান",
        "es": "Enviar solicitud al supervisor"
    },
    "wrong_zone_selected": {
        "ar": "خطأ في اختيار المنطقة",
        "en": "Error in selecting area",
        "bn": "এলাকা নির্বাচনে ভুল",
        "es": "Error al seleccionar la zona"
    },
    "redistribute_visits": {
        "ar": "إعادة توزيع الزيارات",
        "en": "Redistribute visits",
        "bn": "পরিদর্শন পুনর্বন্টন",
        "es": "Redistribuir visitas"
    },
    "supervisor_request": {
        "ar": "طلب من المشرف",
        "en": "Supervisor request",
        "bn": "সুপারভাইজারের অনুরোধ",
        "es": "Solicitud del supervisor"
    },
    "other_reason": {
        "ar": "سبب آخر",
        "en": "Other reason",
        "bn": "অন্যান্য কারণ",
        "es": "Otra razón"
    },
    "additional_note_optional": {
        "ar": "ملاحظة إضافية (اختياري)",
        "en": "Additional note (optional)",
        "bn": "অতিরিক্ত নোট (ঐচ্ছিক)",
        "es": "Nota adicional (opcional)"
    },
    "request_sent_title": {
        "ar": "تم إرسال الطلب",
        "en": "Request sent",
        "bn": "অনুরোধ পাঠানো হয়েছে",
        "es": "Solicitud enviada"
    },
    "request_sent_waiting_supervisor": {
        "ar": "بانتظار موافقة المشرف، سيتم إشعارك فور الاعتماد.",
        "en": "Awaiting supervisor approval, you will be notified upon confirmation.",
        "bn": "সুপারভাইজারের অনুমোদনের অপেক্ষায়, অনুমোদনের সাথে সাথে আপনাকে জানানো হবে।",
        "es": "Esperando la aprobación del supervisor, se le notificará tras la confirmación."
    },
    "critical_fourth_warning_title": {
        "ar": "الإنذار الرابع الحرج (مخالفة نظامية)",
        "en": "Fourth Critical Warning (Policy Violation)",
        "bn": "চতুর্থ গুরুত্বপূর্ণ সতর্কতা (নীতি লঙ্ঘন)",
        "es": "Cuarta advertencia crítica (violación de política)"
    },
    "critical_warning_desc": {
        "ar": "تم رصد خمول ميداني متواصل وتجاوز المهلة المسموحة للزيارة دون استقرار أو تحرك",
        "en": "Continuous field inactivity detected exceeding allowable visit time without motion or settlement",
        "bn": "কোনো গতিবিধি ছাড়াই অনুমোদিত সময় অতিক্রম করে অবিচ্ছিন্ন নিষ্ক্রিয়তা সনাক্ত করা হয়েছে",
        "es": "Inactividad de campo continua detectada superando el tiempo permitido sin movimiento"
    },
    "operational_action_taken": {
        "ar": "الإجراء التشغيلي المتخذ:",
        "en": "Operational action taken:",
        "bn": "গৃহীত অপারেশনাল পদক্ষেপ:",
        "es": "Acción operativa tomada:"
    },
    "start_counting_off_duty": {
        "ar": "بدء احتساب الوقت كـ \"خارج الدوام\"",
        "en": "Time is now being counted as \"Off Duty\"",
        "bn": "সময় এখন \"কাজের বাইরের সময়\" হিসেবে গণ্য হচ্ছে",
        "es": "El tiempo ahora se cuenta como \"Fuera de turno\""
    },
    "violation_logged_notice": {
        "ar": "تم توثيق المخالفة في سجل الامتثال وإشعار المشرف المباشر تلقائياً.",
        "en": "Violation logged in compliance records and direct supervisor notified automatically.",
        "bn": "সম্মতি রেকর্ডে লঙ্ঘন নথিভুক্ত হয়েছে এবং সরাসরি সুপারভাইজারকে স্বয়ংক্রিয়ভাবে অবহিত করা হয়েছে।",
        "es": "Infracción registrada en cumplimiento y supervisor directo notificado automáticamente."
    },
    "submit_justification_optional": {
        "ar": "تقديم تبرير للمشرف (اختياري / موثق):",
        "en": "Submit justification to supervisor (optional / logged):",
        "bn": "সুপারভাইজারকে ব্যাখ্যা জমা দিন (ঐচ্ছিক / নথিভুক্ত):",
        "es": "Presentar justificación al supervisor (opcional / registrada):"
    },
    "resume_field_activity": {
        "ar": "استئناف النشاط الميداني والعودة للدوام",
        "en": "Resume field activity and return to shift",
        "bn": "ফিল্ড কার্যক্রম পুনরায় শুরু করুন এবং কাজে ফিরুন",
        "es": "Reanudar actividad de campo y volver al turno"
    },
    "convert_to_authorized_break": {
        "ar": "تحويل إلى \"طلب راحة مصرحة\"",
        "en": "Convert to \"Authorized Break Request\"",
        "bn": "\"অনুমোদিত বিরতির অনুরোধ\"-এ রূপান্তর করুন",
        "es": "Convertir a \"Solicitud de descanso autorizado\""
    },
    "work_resumed_title": {
        "ar": "تم استئناف العمل",
        "en": "Work resumed",
        "bn": "কাজ পুনরায় শুরু হয়েছে",
        "es": "Trabajo reanudado"
    },
    "work_resumed_desc": {
        "ar": "تم تسجيل استئناف النشاط وإرسال التبرير إلى المشرف.",
        "en": "Activity resumption logged and justification sent to supervisor.",
        "bn": "কার্যক্রম পুনরায় শুরু নথিভুক্ত হয়েছে এবং ব্যাখ্যা সুপারভাইজারকে পাঠানো হয়েছে।",
        "es": "Reanudación de actividad registrada y justificación enviada al supervisor."
    },
    "back_to_visits_list": {
        "ar": "العودة لقائمة الزيارات",
        "en": "Back to visits list",
        "bn": "পরিদর্শন তালিকায় ফিরে যান",
        "es": "Volver a la lista de visitas"
    },
    "paying_customers_completed": {
        "ar": "العملاء الدافعون (أتموا الشراء)",
        "en": "Paying customers (completed purchase)",
        "bn": "অর্থপ্রদানকারী গ্রাহক (ক্রয় সম্পন্ন)",
        "es": "Clientes de pago (compra completada)"
    },
    "total_registered": {
        "ar": "إجمالي المسجلين",
        "en": "Total registered",
        "bn": "মোট নিবন্ধিত",
        "es": "Total registrados"
    },
    "not_paid_yet": {
        "ar": "لم يدفعوا بعد",
        "en": "Not paid yet",
        "bn": "এখনও অর্থপ্রদান করেনি",
        "es": "Aún no han pagado"
    },
    "customer_unit": {
        "ar": "عميل",
        "en": "customer",
        "bn": "গ্রাহক",
        "es": "cliente"
    },
    "new_client_commission": {
        "ar": "عمولة انضمام عميل جديدة",
        "en": "New customer onboarding commission",
        "bn": "নতুন গ্রাহক যোগদান কমিশন",
        "es": "Comisión por nuevo cliente"
    },
    "pending_days_remaining": {
        "ar": "معلّقة – متبقي @days أيام",
        "en": "Pending – @days days left",
        "bn": "মুলতুবি – @days দিন বাকি",
        "es": "Pendiente – quedan @days días"
    },
    "registered_successfully": {
        "ar": "تم تسجيل بنجاح",
        "en": "Registered successfully",
        "bn": "সফলভাবে নিবন্ধিত হয়েছে",
        "es": "Registrado con éxito"
    },
    "track_application_status": {
        "ar": "متابعة حالة الطلب",
        "en": "Track application status",
        "bn": "আবেদনের স্থিতি ট্র্যাক করুন",
        "es": "Seguir estado de solicitud"
    },
    "client_label": {
        "ar": "عميل",
        "en": "Client",
        "bn": "গ্রাহক",
        "es": "Cliente"
    },
    "client_commission": {
        "ar": "عمولة عميل",
        "en": "Client commission",
        "bn": "গ্রাহক কমিশন",
        "es": "Comisión del cliente"
    },
    "this_week": {
        "ar": "هذا الأسبوع",
        "en": "This week",
        "bn": "এই সপ্তাহ",
        "es": "Esta semana"
    },
    "approved_tab": {
        "ar": "معتمدة",
        "en": "Approved",
        "bn": "অনুমোদিত",
        "es": "Aprobado"
    },
    "pending_tab": {
        "ar": "معلقة",
        "en": "Pending",
        "bn": "মুলতুবি",
        "es": "Pendiente"
    },
    "today_time_example": {
        "ar": "اليوم، 2:30 م",
        "en": "Today, 2:30 PM",
        "bn": "আজ, ২:৩০ অপরাহ্ন",
        "es": "Hoy, 2:30 PM"
    },
    "failed_to_start_shift": {
        "ar": "فشل في بدء الدوام",
        "en": "Failed to start shift",
        "bn": "শিফট শুরু করতে ব্যর্থ",
        "es": "Error al iniciar turno"
    },
    "error_starting_shift": {
        "ar": "حدث خطأ أثناء بدء الدوام",
        "en": "Error occurred while starting shift",
        "bn": "শিফট শুরু করার সময় ত্রুটি হয়েছে",
        "es": "Ocurrió un error al iniciar turno"
    },
    "failed_to_request_break": {
        "ar": "فشل في طلب الراحة",
        "en": "Failed to request break",
        "bn": "বিরতির অনুরোধ করতে ব্যর্থ",
        "es": "Error al solicitar descanso"
    },
    "error_requesting_break": {
        "ar": "حدث خطأ أثناء طلب الراحة",
        "en": "Error occurred while requesting break",
        "bn": "বিরতির অনুরোধ করার সময় ত্রুটি হয়েছে",
        "es": "Ocurrió un error al solicitar descanso"
    },
    "failed_to_resume_work": {
        "ar": "فشل في استئناف العمل",
        "en": "Failed to resume work",
        "bn": "কাজ পুনরায় শুরু করতে ব্যর্থ",
        "es": "Error al reanudar el trabajo"
    },
    "error_resuming_work": {
        "ar": "حدث خطأ أثناء استئناف العمل",
        "en": "Error occurred while resuming work",
        "bn": "কাজ পুনরায় শুরু করার সময় ত্রুটি হয়েছে",
        "es": "Ocurrió un error al reanudar el trabajo"
    },
    "shift_ended_successfully": {
        "ar": "تم إنهاء الدوام بنجاح",
        "en": "Shift ended successfully",
        "bn": "শিফট সফলভাবে শেষ হয়েছে",
        "es": "Turno finalizado con éxito"
    },
    "failed_to_end_shift": {
        "ar": "فشل في إنهاء الدوام",
        "en": "Failed to end shift",
        "bn": "শিফট শেষ করতে ব্যর্থ",
        "es": "Error al finalizar turno"
    },
    "error_ending_shift": {
        "ar": "حدث خطأ أثناء إنهاء الدوام",
        "en": "Error occurred while ending shift",
        "bn": "শিফট শেষ করার সময় ত্রুটি হয়েছে",
        "es": "Ocurrió un error al finalizar turno"
    },
    "select_zone_first": {
        "ar": "يرجى اختيار منطقة أولاً",
        "en": "Please select a zone first",
        "bn": "অনুগ্রহ করে প্রথমে একটি এলাকা নির্বাচন করুন",
        "es": "Por favor seleccione una zona primero"
    },
    "failed_to_lock_zone": {
        "ar": "فشل في قفل منطقة العمل",
        "en": "Failed to lock work zone",
        "bn": "কাজের এলাকা লক করতে ব্যর্থ",
        "es": "Error al bloquear la zona de trabajo"
    },
    "zone_change_request_submitted": {
        "ar": "تم إرسال طلب تغيير المنطقة بنجاح",
        "en": "Zone change request submitted successfully",
        "bn": "এলাকা পরিবর্তনের অনুরোধ সফলভাবে জমা দেওয়া হয়েছে",
        "es": "Solicitud de cambio de zona enviada con éxito"
    },
    "failed_to_send_request": {
        "ar": "فشل في إرسال الطلب",
        "en": "Failed to send request",
        "bn": "অনুরোধ পাঠাতে ব্যর্থ",
        "es": "Error al enviar la solicitud"
    },
    "work_zone_label": {
        "ar": "منطقة العمل",
        "en": "Work Zone",
        "bn": "কাজের এলাকা",
        "es": "Zona de trabajo"
    },
    "geofence_radius": {
        "ar": "نطاق العمل",
        "en": "Work range",
        "bn": "কাজের পরিসর",
        "es": "Rango de trabajo"
    },
    "meter_unit": {
        "ar": "متر",
        "en": "m",
        "bn": "মিটার",
        "es": "m"
    },
    "your_current_location": {
        "ar": "موقعك الحالي",
        "en": "Your current location",
        "bn": "আপনার বর্তমান অবস্থান",
        "es": "Su ubicación actual"
    },
    "scheduled_label": {
        "ar": "مجدولة",
        "en": "Scheduled",
        "bn": "নির্ধারিত",
        "es": "Programada"
    },
    "follow_up_label": {
        "ar": "متابعة",
        "en": "Follow-up",
        "bn": "অনুসরণ",
        "es": "Seguimiento"
    },
    "request_zone_change": {
        "ar": "طلب تغيير المنطقة",
        "en": "Request zone change",
        "bn": "এলাকা পরিবর্তনের অনুরোধ",
        "es": "Solicitar cambio de zona"
    },
    "no_visits_found": {
        "ar": "لا توجد زيارات في هذه الفئة",
        "en": "No visits found in this category",
        "bn": "এই বিভাগে কোনো পরিদর্শন পাওয়া যায়নি",
        "es": "No se encontraron visitas en esta categoría"
    },
    "distance_km": {
        "ar": "كم",
        "en": "km",
        "bn": "কিমি",
        "es": "km"
    },
    "view_report": {
        "ar": "عرض التقرير",
        "en": "View Report",
        "bn": "প্রতিবেদন দেখুন",
        "es": "Ver informe"
    },
    "follow_up_action": {
        "ar": "متابعة الزيارة",
        "en": "Follow Up",
        "bn": "অনুসরণ করুন",
        "es": "Hacer seguimiento"
    },
    "resume_visit": {
        "ar": "استئناف الزيارة",
        "en": "Resume Visit",
        "bn": "পরিদর্শন পুনরায় শুরু করুন",
        "es": "Reanudar visita"
    },
    "start_visit_action": {
        "ar": "بدء الزيارة",
        "en": "Start Visit",
        "bn": "পরিদর্শন শুরু করুন",
        "es": "Iniciar visita"
    },
    "start_visit_confirm_title": {
        "ar": "بدء زيارة @store الآن؟",
        "en": "Start visit to @store now?",
        "bn": "এখনই @store পরিদর্শন শুরু করবেন?",
        "es": "¿Iniciar visita a @store ahora?"
    },
    "start_visit_confirm_subtitle": {
        "ar": "سيتم تفعيل عداد الزيارة ومتابعة موقعك الميداني داخل المتجر.",
        "en": "Visit timer will be activated and your location tracked inside store.",
        "bn": "পরিদর্শন টাইমার সক্রিয় হবে এবং দোকানের ভিতরে আপনার অবস্থান ট্র্যাক করা হবে।",
        "es": "Se activará el temporizador de visita y se rastreará su ubicación dentro de la tienda."
    },
    "upcoming_single": {
        "ar": "قادمة",
        "en": "Upcoming",
        "bn": "আসন্ন",
        "es": "Próxima"
    },
    "in_progress_single": {
        "ar": "جارية",
        "en": "In Progress",
        "bn": "চলমান",
        "es": "En progreso"
    },
    "completed_single": {
        "ar": "مكتملة",
        "en": "Completed",
        "bn": "সম্পন্ন",
        "es": "Completada"
    },
    "first_alert_title": {
        "ar": "الإنذار الأول: تنبيه خمول مبدئي",
        "en": "First Warning: Initial Inactivity Alert",
        "bn": "প্রথম সতর্কতা: প্রাথমিক নিষ্ক্রিয়তা সতর্কতা",
        "es": "Primera advertencia: Alerta inicial de inactividad"
    },
    "second_alert_title": {
        "ar": "الإنذار الثاني: عدم رصد حركة ميدانية",
        "en": "Second Warning: No Field Movement Detected",
        "bn": "দ্বিতীয় সতর্কতা: কোনো গতিবিধি সনাক্ত করা যায়নি",
        "es": "Segunda advertencia: No se detecta movimiento en el campo"
    },
    "third_alert_title": {
        "ar": "الإنذار الثالث: تحذير متقدم قبل الخصم",
        "en": "Third Warning: Advanced Warning Before Penalty",
        "bn": "তৃতীয় সতর্কতা: কাটার আগে অগ্রিম সতর্কতা",
        "es": "Tercera advertencia: Advertencia avanzada antes de sanción"
    },
    "critical_fourth_title": {
        "ar": "الإنذار الرابع الحرج: احتساب خارج الدوام",
        "en": "Fourth Critical Warning: Counting Off Duty",
        "bn": "চতুর্থ গুরুত্বপূর্ণ সতর্কতা: কাজের বাইরের সময় গণনা",
        "es": "Cuarta advertencia crítica: Contabilización fuera de turno"
    },
    "third_alert_advanced": {
        "ar": "الإنذار الثالث (تحذير متقدم)",
        "en": "Third Warning (Advanced Warning)",
        "bn": "তৃতীয় সতর্কতা (অগ্রিম সতর্কতা)",
        "es": "Tercera advertencia (Advertencia avanzada)"
    },
    "one_minute_remaining_penalty": {
        "ar": "تبقى دقيقة واحدة فقط قبل بدء احتساب وقتك كـ \"خارج الدوام\".",
        "en": "Only one minute remaining before your time is counted as \"Off Duty\".",
        "bn": "আপনার সময় \"কাজের বাইরের সময়\" হিসাবে গণ্য হওয়ার আগে মাত্র এক মিনিট বাকি।",
        "es": "Solo queda un minuto antes de que su tiempo se cuente como \"Fuera de turno\"."
    },
    "alert1_message": {
        "ar": "تنبيه خفيف: تم رصد توقف عن الحركة لأكثر من 10 دقائق داخل الزيارة. يرجى استئناف النشاط الميداني لتفادي تسجيل مخالفة.",
        "en": "Gentle alert: Inactivity detected for more than 10 minutes inside visit. Please resume field activity to avoid logging a violation.",
        "bn": "মৃদু সতর্কতা: পরিদর্শনের মধ্যে ১০ মিনিটের বেশি নিষ্ক্রিয়তা সনাক্ত করা হয়েছে। লঙ্ঘন এড়াতে দয়া করে ফিল্ড কার্যক্রম পুনরায় শুরু করুন।",
        "es": "Alerta leve: Inactividad detectada por más de 10 minutos en la visita. Reanude la actividad para evitar registrar una infracción."
    },
    "alert2_message": {
        "ar": "تنبيه ثانٍ: عدم استقرار أو حركة نحو المتجر. اضغط \"طلب راحة\" إذا كنت في فترة توقف مصرح بها.",
        "en": "Second alert: No stability or motion toward store. Tap \"Request Break\" if you are on an authorized break.",
        "bn": "দ্বিতীয় সতর্কতা: দোকানের দিকে কোনো গতিবিধি নেই। অনুমোদিত বিরতিতে থাকলে \"বিরতির অনুরোধ\" চাপুন।",
        "es": "Segunda alerta: Sin movimiento hacia la tienda. Toque \"Solicitar descanso\" si se encuentra en un descanso autorizado."
    },
    "alert3_message": {
        "ar": "تحذير متقدم: أنت على وشك تجاوز المدة القصوى المسموحة للخمول. الإنذار القادم سيؤدي إلى الخصم واحتساب وقت خارج الدوام!",
        "en": "Advanced warning: You are about to exceed the maximum allowed inactivity. The next warning will trigger penalties and off-duty time!",
        "bn": "অগ্রিম সতর্কতা: আপনি অনুমোদিত সর্বোচ্চ নিষ্ক্রিয়তার সীমা অতিক্রম করতে চলেছেন। পরবর্তী সতর্কতায় জরিমানা হতে পারে!",
        "es": "Advertencia avanzada: Está a punto de exceder el tiempo máximo de inactividad permitido. ¡La próxima advertencia causará penalizaciones!"
    },
    "alert4_message": {
        "ar": "تم تفعيل الإنذار الرابع الحرج: بدء احتساب الوقت كـ \"خارج الدوام\" وتوثيق مخالفة خمول بنظام الرقابة والامتثال.",
        "en": "Fourth critical warning activated: Time is now counted as \"Off Duty\" and an inactivity violation is logged in compliance records.",
        "bn": "চতুর্থ গুরুত্বপূর্ণ সতর্কতা সক্রিয়: সময় এখন \"কাজের বাইরের সময়\" হিসাবে গণ্য এবং লঙ্ঘন নথিভুক্ত হয়েছে।",
        "es": "Cuarta advertencia crítica activada: El tiempo se cuenta ahora como \"Fuera de turno\" y se registra la infracción."
    },
    "inactivity_warning_reason": {
        "ar": "خمول مستمر وتجاوز مهلة الـ 10 دقائق في الزيارة الميدانية",
        "en": "Continuous inactivity exceeding 10 minutes threshold during field visit",
        "bn": "ফিল্ড পরিদর্শনের সময় ১০ মিনিটের বেশি অবিচ্ছিন্ন নিষ্ক্রিয়তা",
        "es": "Inactividad continua superando los 10 minutos durante la visita de campo"
    },
    "active_alert4_subtitle": {
        "ar": "تم احتساب هذا الوقت خارج الدوام.",
        "en": "This time is now counted as off duty.",
        "bn": "এই সময়টি কাজের বাইরের সময় হিসাবে গণ্য করা হয়েছে।",
        "es": "Este tiempo ahora se cuenta como fuera de turno."
    },
    "active_alert4_desc": {
        "ar": "تم تسجيل مستوى الخمول الرابع وفق سياسة التشغيل. يمكنك رفع طلب للمشرف إذا كان هناك سبب يستدعي المراجعة.",
        "en": "Level 4 inactivity logged under operational policy. You can submit a request to supervisor if review is required.",
        "bn": "অপারেশনাল নীতি অনুযায়ী স্তর ৪ নিষ্ক্রিয়তা নথিভুক্ত। পর্যালোচনার প্রয়োজন হলে সুপারভাইজারের কাছে আবেদন করতে পারেন।",
        "es": "Inactividad de nivel 4 registrada. Puede solicitar una revisión al supervisor si corresponde."
    },
    "active_alert3_subtitle": {
        "ar": "تم تسجيل عدم نشاط مستمر أثناء الجولة.",
        "en": "Continuous inactivity logged during the tour.",
        "bn": "ট্যুরের সময় ক্রমাগত নিষ্ক্রিয়তা নথিভুক্ত করা হয়েছে।",
        "es": "Inactividad continua registrada durante el recorrido."
    },
    "active_alert3_desc": {
        "ar": "قد يؤثر تكرار هذه الحالة على احتساب وقت العمل.",
        "en": "Recurrence of this status may affect your counted work hours.",
        "bn": "এই পরিস্থিতির পুনরাবৃত্তি আপনার কাজের সময় গণনাকে প্রভাবিত করতে পারে।",
        "es": "La recurrencia de esta situación puede afectar el cómputo de sus horas de trabajo."
    },
    "active_alert2_subtitle": {
        "ar": "لم يتم رصد تقدم كافٍ نحو المتجر.",
        "en": "Insufficient progress detected toward store.",
        "bn": "দোকানের দিকে পর্যাপ্ত অগ্রগতি সনাক্ত করা যায়নি।",
        "es": "No se detectó suficiente progreso hacia la tienda."
    },
    "active_alert2_desc": {
        "ar": "يرجى التوجه إلى موقع الزيارة أو تحديث حالة الزيارة.",
        "en": "Please head to visit location or update visit status.",
        "bn": "অনুগ্রহ করে পরিদর্শনের স্থানে যান অথবা অবস্থা আপডেট করুন।",
        "es": "Diríjase a la ubicación de la visita o actualice el estado de la visita."
    },
    "active_alert1_subtitle": {
        "ar": "يبدو أنك لم تتحرك نحو المتجر المستهدف.",
        "en": "It looks like you have not moved toward the target store.",
        "bn": "মনে হচ্ছে আপনি লক্ষ্যযুক্ত দোকানের দিকে এগিয়ে যাননি।",
        "es": "Parece que no se ha desplazado hacia la tienda de destino."
    },
    "active_alert1_desc": {
        "ar": "تحقق من موقعك واستعد لبدء الزيارة.",
        "en": "Check your location and prepare to start the visit.",
        "bn": "আপনার অবস্থান পরীক্ষা করুন এবং পরিদর্শন শুরু করার জন্য প্রস্তুত হন।",
        "es": "Compruebe su ubicación y prepárese para iniciar la visita."
    }
}

languages = ['ar', 'en', 'bn', 'es']

for lang in languages:
    path = f'assets/language/{lang}.json'
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    added_count = 0
    for key, values in translations.items():
        if key not in data or not data[key]:
            data[key] = values[lang]
            added_count += 1

    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"[{lang}.json] Added {added_count} new keys. Total keys: {len(data)}")
