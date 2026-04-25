import 'package:flutter/material.dart';

class AppStrings {
  static const Map<String, Map<String, String>> _data = {
    'en': {
      // ── Navigation ──────────────────────────────────────────────────
      'nav_dashboard': 'Dashboard',
      'nav_schedule': 'Schedule',
      'nav_services': 'Services',
      'nav_staff': 'Staff',
      'nav_profile': 'Profile',
      'nav_home': 'Home',
      'nav_bookings': 'Bookings',

      // ── Common ──────────────────────────────────────────────────────
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'back': 'Back',
      'loading': 'Loading...',
      'available': 'Available',
      'error_generic': 'Something went wrong. Please try again.',

      // ── Auth ────────────────────────────────────────────────────────
      'logout': 'Log Out',
      'logout_title': 'Log Out?',
      'logout_confirm': 'Are you sure you want to log out of your account?',

      // ── Language ────────────────────────────────────────────────────
      'language': 'Language',
      'select_language': 'Select Language',
      'english': 'English',
      'russian': 'Russian',

      // ── Profile (shared) ────────────────────────────────────────────
      'profile_title': 'Profile',
      'edit_profile': 'Edit Profile',
      'name': 'Name',
      'phone': 'Phone',
      'title_label': 'Title',
      'app_version': 'App Version',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',

      // ── Notifications ───────────────────────────────────────────────
      'notifications': 'Notifications',
      'push_notifications': 'Push Notifications',
      'push_notifications_sub': 'New bookings & updates',
      'sms_reminders': 'SMS Reminders',
      'sms_reminders_sub': 'Appointment reminders',
      'email_notifications': 'Email Notifications',
      'email_notifications_sub': 'Reports & summaries',

      // ── Barber: Dashboard ────────────────────────────────────────────
      'dashboard_title': 'Dashboard',
      'welcome_back': 'Welcome back',
      'todays_appointments': "Today's Appointments",
      'pending': 'Pending',
      'todays_schedule': "Today's Schedule",
      'view_calendar': 'View Calendar',
      'no_bookings_today': 'No bookings today.',
      'complete_profile_prompt':
          'Complete your profile and link your shop to see bookings.',
      'appointment_details': 'Appointment Details',
      'customer': 'Customer',
      'service': 'Service',
      'time': 'Time',
      'confirm': 'Confirm',
      'mark_complete': 'Mark Complete',
      'booking_status': 'Booking is',

      // ── Barber: Schedule ─────────────────────────────────────────────
      'schedule_title': 'Schedule',

      // ── Barber: Services ─────────────────────────────────────────────
      'services_title': 'Services',
      'add_service': 'Add Service',
      'edit_service': 'Edit Service',
      'service_name': 'Service Name',
      'category': 'Category',
      'price': 'Price (\$)',
      'duration': 'Duration',
      'description_optional': 'Description (optional)',
      'no_services': 'No services added yet.',
      'add_service_prompt': 'Add a service to automatically create your shop.',
      'service_added': 'Service Added!',
      'service_updated': 'Service Updated!',
      'service_added_msg': 'New service has been added to your menu.',
      'service_updated_msg': 'Service has been updated successfully.',
      'back_to_services': 'Back to Services',

      // ── Barber: Staff ────────────────────────────────────────────────
      'staff_title': 'Team Management',
      'add_staff': 'Add Staff Member',
      'edit_staff': 'Edit Staff Member',
      'full_name': 'Full Name',
      'specialty': 'Specialty',
      'bio': 'Bio',
      'working_hours': 'Working Hours',
      'working_days': 'Working Days',
      'no_staff': 'No team members yet.',
      'add_staff_prompt':
          'Add a team member to automatically create your shop.',
      'staff_added': 'Staff Added!',
      'staff_updated': 'Staff Updated!',
      'staff_added_msg': 'New team member has been added successfully.',
      'staff_updated_msg': 'Team member has been updated successfully.',
      'back_to_team': 'Back to Team',

      // ── Barber: Profile ──────────────────────────────────────────────
      'shop_photos': 'Shop Photos',
      'add_photo': 'Add Photo',
      'business_hours': 'Business Hours',

      // ── Customer: Home ───────────────────────────────────────────────
      'good_morning': 'Good Morning,',
      'good_afternoon': 'Good Afternoon,',
      'good_evening': 'Good Evening,',
      'categories': 'Categories',
      'nearby_top_rated': 'Nearby Top-Rated',
      'search_hint': 'Search barbers, salons...',
      'clear': 'Clear',
      'see_all': 'See All',
      'no_shops_found': 'No shops found.',

      // ── Customer: Bookings / History ──────────────────────────────────
      'bookings_title': 'Bookings',
      'upcoming': 'Upcoming',
      'past': 'Past',
      'canceled': 'Canceled',
      'confirmed': 'Confirmed',
      'completed': 'Completed',
      'no_upcoming': 'No upcoming appointments.',
      'no_past': 'No past appointments.',
      'no_canceled': 'No canceled appointments.',
      'reschedule': 'Reschedule',
      'cancel_appointment': 'Cancel Appointment',
      'cancel_confirm': 'Are you sure you want to cancel this appointment?',
      'yes_cancel': 'Yes, Cancel',
      'no': 'No',
      'appointment_canceled': 'Appointment canceled.',
      'with_barber': 'with',

      // ── Customer: Booking flow ────────────────────────────────────────
      'book_appointment': 'Book Appointment',
      'select_service': 'Select Service',
      'select_specialist': 'Select Specialist',
      'select_date': 'Select Date',
      'available_slots': 'Available Slots',
      'select_specialist_first': 'Select a specialist to see available slots.',
      'booking_summary': 'Booking Summary',
      'services': 'Services',
      'specialist': 'Specialist',
      'date': 'Date',
      'total': 'Total',
      'confirm_booking': 'Confirm Booking',
      'booking_confirmed': 'Booking Confirmed',
      'booking_confirmed_msg': 'Your appointment is confirmed.',
      'view_bookings': 'View Bookings',
      'no_services_available': 'No services available.',
      'no_specialists_available': 'No specialists available.',
      'failed_load_shop': 'Failed to load shop.',
      'service_selected': 'service selected',
      'services_selected': 'services selected',

      // ── Customer: Profile ─────────────────────────────────────────────
      'gold_member': 'Gold Member',
      'points_to_tier': 'points to next tier',
      'payment_methods': 'Payment Methods',
      'favorites': 'Favorites',
      'privacy_security': 'Privacy & Security',
      'help_support': 'Help & Support',
    },

    'ru': {
      // ── Navigation ──────────────────────────────────────────────────
      'nav_dashboard': 'Главная',
      'nav_schedule': 'Расписание',
      'nav_services': 'Услуги',
      'nav_staff': 'Персонал',
      'nav_profile': 'Профиль',
      'nav_home': 'Главная',
      'nav_bookings': 'Записи',

      // ── Common ──────────────────────────────────────────────────────
      'save': 'Сохранить',
      'cancel': 'Отмена',
      'delete': 'Удалить',
      'edit': 'Изменить',
      'back': 'Назад',
      'loading': 'Загрузка...',
      'available': 'Свободно',
      'error_generic': 'Что-то пошло не так. Попробуйте снова.',

      // ── Auth ────────────────────────────────────────────────────────
      'logout': 'Выйти',
      'logout_title': 'Выйти?',
      'logout_confirm': 'Вы уверены, что хотите выйти из аккаунта?',

      // ── Language ────────────────────────────────────────────────────
      'language': 'Язык',
      'select_language': 'Выберите язык',
      'english': 'Английский',
      'russian': 'Русский',

      // ── Profile (shared) ────────────────────────────────────────────
      'profile_title': 'Профиль',
      'edit_profile': 'Редактировать профиль',
      'name': 'Имя',
      'phone': 'Телефон',
      'title_label': 'Должность',
      'app_version': 'Версия приложения',
      'privacy_policy': 'Политика конфиденциальности',
      'terms_of_service': 'Условия использования',

      // ── Notifications ───────────────────────────────────────────────
      'notifications': 'Уведомления',
      'push_notifications': 'Push-уведомления',
      'push_notifications_sub': 'Новые записи и обновления',
      'sms_reminders': 'SMS-напоминания',
      'sms_reminders_sub': 'Напоминания о записях',
      'email_notifications': 'Email-уведомления',
      'email_notifications_sub': 'Отчёты и сводки',

      // ── Barber: Dashboard ────────────────────────────────────────────
      'dashboard_title': 'Главная',
      'welcome_back': 'С возвращением',
      'todays_appointments': 'Записей на сегодня',
      'pending': 'Ожидают',
      'todays_schedule': 'Расписание на сегодня',
      'view_calendar': 'Открыть календарь',
      'no_bookings_today': 'Записей на сегодня нет.',
      'complete_profile_prompt':
          'Заполните профиль и подключите магазин, чтобы видеть записи.',
      'appointment_details': 'Детали записи',
      'customer': 'Клиент',
      'service': 'Услуга',
      'time': 'Время',
      'confirm': 'Подтвердить',
      'mark_complete': 'Отметить как выполнено',
      'booking_status': 'Статус записи:',

      // ── Barber: Schedule ─────────────────────────────────────────────
      'schedule_title': 'Расписание',

      // ── Barber: Services ─────────────────────────────────────────────
      'services_title': 'Услуги',
      'add_service': 'Добавить услугу',
      'edit_service': 'Редактировать услугу',
      'service_name': 'Название услуги',
      'category': 'Категория',
      'price': 'Цена (₽)',
      'duration': 'Длительность',
      'description_optional': 'Описание (необязательно)',
      'no_services': 'Услуги ещё не добавлены.',
      'add_service_prompt': 'Добавьте услугу, чтобы создать ваш магазин.',
      'service_added': 'Услуга добавлена!',
      'service_updated': 'Услуга обновлена!',
      'service_added_msg': 'Новая услуга добавлена в ваше меню.',
      'service_updated_msg': 'Услуга успешно обновлена.',
      'back_to_services': 'Назад к услугам',

      // ── Barber: Staff ────────────────────────────────────────────────
      'staff_title': 'Управление персоналом',
      'add_staff': 'Добавить сотрудника',
      'edit_staff': 'Редактировать сотрудника',
      'full_name': 'Полное имя',
      'specialty': 'Специализация',
      'bio': 'О себе',
      'working_hours': 'Рабочие часы',
      'working_days': 'Рабочие дни',
      'no_staff': 'Сотрудников пока нет.',
      'add_staff_prompt': 'Добавьте сотрудника, чтобы создать ваш магазин.',
      'staff_added': 'Сотрудник добавлен!',
      'staff_updated': 'Сотрудник обновлён!',
      'staff_added_msg': 'Новый сотрудник успешно добавлен.',
      'staff_updated_msg': 'Данные сотрудника обновлены.',
      'back_to_team': 'Назад к команде',

      // ── Barber: Profile ──────────────────────────────────────────────
      'shop_photos': 'Фото магазина',
      'add_photo': 'Добавить фото',
      'business_hours': 'Рабочие часы',

      // ── Customer: Home ───────────────────────────────────────────────
      'good_morning': 'Доброе утро,',
      'good_afternoon': 'Добрый день,',
      'good_evening': 'Добрый вечер,',
      'categories': 'Категории',
      'nearby_top_rated': 'Лучшие рядом',
      'search_hint': 'Поиск барберов, салонов...',
      'clear': 'Сбросить',
      'see_all': 'Все',
      'no_shops_found': 'Магазины не найдены.',

      // ── Customer: Bookings / History ──────────────────────────────────
      'bookings_title': 'Мои записи',
      'upcoming': 'Предстоящие',
      'past': 'Прошедшие',
      'canceled': 'Отменённые',
      'confirmed': 'Подтверждено',
      'completed': 'Завершено',
      'no_upcoming': 'Предстоящих записей нет.',
      'no_past': 'Прошедших записей нет.',
      'no_canceled': 'Отменённых записей нет.',
      'reschedule': 'Перенести',
      'cancel_appointment': 'Отменить запись',
      'cancel_confirm': 'Вы уверены, что хотите отменить эту запись?',
      'yes_cancel': 'Да, отменить',
      'no': 'Нет',
      'appointment_canceled': 'Запись отменена.',
      'with_barber': 'у',

      // ── Customer: Booking flow ────────────────────────────────────────
      'book_appointment': 'Записаться',
      'select_service': 'Выберите услугу',
      'select_specialist': 'Выберите специалиста',
      'select_date': 'Выберите дату',
      'available_slots': 'Доступное время',
      'select_specialist_first': 'Выберите специалиста, чтобы увидеть время.',
      'booking_summary': 'Итог записи',
      'services': 'Услуги',
      'specialist': 'Специалист',
      'date': 'Дата',
      'total': 'Итого',
      'confirm_booking': 'Подтвердить запись',
      'booking_confirmed': 'Запись подтверждена',
      'booking_confirmed_msg': 'Ваша запись подтверждена.',
      'view_bookings': 'Мои записи',
      'no_services_available': 'Услуги недоступны.',
      'no_specialists_available': 'Специалисты недоступны.',
      'failed_load_shop': 'Не удалось загрузить магазин.',
      'service_selected': 'услуга выбрана',
      'services_selected': 'услуг выбрано',

      // ── Customer: Profile ─────────────────────────────────────────────
      'gold_member': 'Золотой участник',
      'points_to_tier': 'очков до следующего уровня',
      'payment_methods': 'Способы оплаты',
      'favorites': 'Избранное',
      'privacy_security': 'Конфиденциальность',
      'help_support': 'Помощь и поддержка',
    },
  };

  static String tr(String key, String languageCode) {
    return _data[languageCode]?[key] ?? _data['en']?[key] ?? key;
  }
}

extension BuildContextTr on BuildContext {
  String tr(String key) {
    try {
      return AppStrings.tr(key, Localizations.localeOf(this).languageCode);
    } catch (_) {
      return AppStrings.tr(key, 'en');
    }
  }
}
