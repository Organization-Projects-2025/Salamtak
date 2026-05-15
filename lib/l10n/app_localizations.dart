import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ar', ''),
  ];

  bool get isArabic => locale.languageCode == 'ar';

  // Common
  String get appName => isArabic ? 'سلامتك' : 'Salamtak';
  String get tagline =>
      isArabic ? 'أبلغ. تتبع. حل.' : 'Report. Track. Resolve.';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get close => isArabic ? 'إغلاق' : 'Close';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get delete => isArabic ? 'حذف' : 'Delete';
  String get edit => isArabic ? 'تعديل' : 'Edit';
  String get submit => isArabic ? 'إرسال' : 'Submit';
  String get required => isArabic ? 'مطلوب' : 'Required';
  String get loading => isArabic ? 'جاري التحميل...' : 'Loading...';
  String get error => isArabic ? 'خطأ' : 'Error';
  String get success => isArabic ? 'نجح' : 'Success';
  String get refresh => isArabic ? 'تحديث' : 'Refresh';

  // Login
  String get welcomeBack => isArabic ? 'مرحباً بعودتك' : 'Welcome back';
  String get signInWithNationalId =>
      isArabic
          ? 'تسجيل الدخول برقم الهوية الوطنية'
          : 'Sign in with your National ID';
  String get nationalId => isArabic ? 'رقم الهوية الوطنية' : 'National ID';
  String get enterNationalId =>
      isArabic
          ? 'أدخل رقم الهوية المكون من 14 رقماً'
          : 'Enter your 14-digit National ID';
  String get password => isArabic ? 'كلمة المرور' : 'Password';
  String get enterPassword =>
      isArabic ? 'أدخل كلمة المرور' : 'Enter your password';
  String get signIn => isArabic ? 'تسجيل الدخول' : 'Sign In';
  String get dontHaveAccount =>
      isArabic ? 'ليس لديك حساب؟ سجل الآن' : "Don't have an account? Sign Up";
  String get invalidCredentials =>
      isArabic
          ? 'رقم الهوية أو كلمة المرور غير صحيحة'
          : 'Invalid National ID or password.';
  String get somethingWentWrong =>
      isArabic
          ? 'حدث خطأ ما. حاول مرة أخرى.'
          : 'Something went wrong. Please try again.';

  // Signup
  String get createAccount => isArabic ? 'إنشاء حساب' : 'Create Account';
  String get fullName => isArabic ? 'الاسم الكامل' : 'Full Name';
  String get address => isArabic ? 'العنوان' : 'Address';
  String get email => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get phoneNumber => isArabic ? 'رقم الهاتف' : 'Phone Number';
  String get confirmPassword =>
      isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password';
  String get passwordsDoNotMatch =>
      isArabic ? 'كلمات المرور غير متطابقة' : 'Passwords do not match.';
  String get signUpFailed =>
      isArabic
          ? 'فشل التسجيل. قد يكون رقم الهوية مسجلاً بالفعل.'
          : 'Sign up failed. National ID may already be registered.';
  String get mustBe14Digits =>
      isArabic ? 'يجب أن يكون 14 رقماً' : 'Must be 14 digits';
  String get mustContainOnlyNumbers =>
      isArabic ? 'يجب أن يحتوي على أرقام فقط' : 'Must contain only numbers';
  String get nameMinLength =>
      isArabic
          ? 'الاسم يجب أن يكون 3 أحرف على الأقل'
          : 'Name must be at least 3 characters';
  String get nameLettersOnly =>
      isArabic
          ? 'الاسم يمكن أن يحتوي على حروف ومسافات فقط'
          : 'Name can only contain letters and spaces';
  String get addressMinLength =>
      isArabic
          ? 'العنوان يجب أن يكون 5 أحرف على الأقل'
          : 'Address must be at least 5 characters';
  String get enterValidEmail =>
      isArabic ? 'أدخل بريد إلكتروني صحيح' : 'Enter a valid email address';
  String get phoneNumbersOnly =>
      isArabic
          ? 'رقم الهاتف يجب أن يحتوي على أرقام فقط'
          : 'Phone must contain only numbers';
  String get phoneLength =>
      isArabic
          ? 'رقم الهاتف يجب أن يكون 10-15 رقماً'
          : 'Phone must be 10-15 digits';
  String get passwordMinLength =>
      isArabic ? 'على الأقل 6 أحرف' : 'At least 6 characters';
  String get passwordMaxLength =>
      isArabic ? 'الحد الأقصى 50 حرفاً' : 'Maximum 50 characters';

  // Account
  String get myAccount => isArabic ? 'حسابي' : 'My Account';
  String get salamtakUser => isArabic ? 'مستخدم سلامتك' : 'Salamtak User';
  String get preferences => isArabic ? 'التفضيلات' : 'Preferences';
  String get notifications => isArabic ? 'الإشعارات' : 'Notifications';
  String get language => isArabic ? 'اللغة' : 'Language';
  String get appearance => isArabic ? 'المظهر' : 'Appearance';
  String get support => isArabic ? 'الدعم' : 'Support';
  String get helpAndSupport => isArabic ? 'المساعدة والدعم' : 'Help & Support';
  String get aboutSalamtak => isArabic ? 'عن سلامتك' : 'About Salamtak';
  String get signOut => isArabic ? 'تسجيل الخروج' : 'Sign Out';
  String get signOutConfirm =>
      isArabic
          ? 'هل أنت متأكد من تسجيل الخروج؟'
          : 'Are you sure you want to sign out?';
  String get aboutDescription =>
      isArabic
          ? 'الإبلاغ عن مشاكل البنية التحتية المجتمعية وتتبعها. الإصدار 1.0.0'
          : 'Report and track community infrastructure issues. Version 1.0.0';

  // Language Selection
  String get selectLanguage => isArabic ? 'اختر اللغة' : 'Select Language';
  String get english => isArabic ? 'الإنجليزية' : 'English';
  String get arabic => isArabic ? 'العربية' : 'Arabic';

  // Home/Navigation
  String get home => isArabic ? 'الرئيسية' : 'Home';
  String get reportProblem => isArabic ? 'الإبلاغ عن مشكلة' : 'Report Problem';
  String get myReports => isArabic ? 'بلاغاتي' : 'My Reports';
  String get reports => isArabic ? 'البلاغات' : 'Reports';
  String get account => isArabic ? 'الحساب' : 'Account';

  // User Home
  String get welcomeUser => isArabic ? 'مرحباً' : 'Hello';
  String get whatProblem =>
      isArabic
          ? 'ما المشكلة التي تريد الإبلاغ عنها؟'
          : 'What problem do you want to report?';
  String get selectProblemType =>
      isArabic ? 'اختر نوع المشكلة' : 'Select Problem Type';
  String get pothole => isArabic ? 'حفرة في الطريق' : 'Pothole';
  String get brokenPipe => isArabic ? 'أنبوب مكسور' : 'Broken Pipe';
  String get other => isArabic ? 'أخرى' : 'Other';
  String get potholeDesc =>
      isArabic ? 'حفر أو تلف في الطريق' : 'Road damage or holes';
  String get brokenPipeDesc =>
      isArabic ? 'تسرب مياه أو أنابيب مكسورة' : 'Water leaks or broken pipes';
  String get otherDesc =>
      isArabic ? 'مشاكل أخرى في البنية التحتية' : 'Other infrastructure issues';

  // Reports Status
  String get pending => isArabic ? 'قيد الانتظار' : 'Pending';
  String get inProgress => isArabic ? 'قيد المعالجة' : 'In Progress';
  String get resolved => isArabic ? 'تم الحل' : 'Resolved';
  String get status => isArabic ? 'الحالة' : 'Status';
  String get all => isArabic ? 'الكل' : 'All';
  String get noReports => isArabic ? 'لا توجد بلاغات' : 'No reports found';
  String get noReportsYet =>
      isArabic
          ? 'لم تقم بإنشاء أي بلاغات بعد'
          : "You haven't created any reports yet";
  String get startReporting =>
      isArabic
          ? 'ابدأ بالإبلاغ عن المشاكل في مجتمعك'
          : 'Start reporting issues in your community';

  // Report Details
  String get reportDetails => isArabic ? 'تفاصيل البلاغ' : 'Report Details';
  String get description => isArabic ? 'الوصف' : 'Description';
  String get location => isArabic ? 'الموقع' : 'Location';
  String get severity => isArabic ? 'الخطورة' : 'Severity';
  String get reportedOn => isArabic ? 'تم الإبلاغ في' : 'Reported on';
  String get photo => isArabic ? 'الصورة' : 'Photo';
  String get viewOnMap => isArabic ? 'عرض على الخريطة' : 'View on Map';

  // Severity Levels
  String get low => isArabic ? 'منخفضة' : 'Low';
  String get medium => isArabic ? 'متوسطة' : 'Medium';
  String get high => isArabic ? 'عالية' : 'High';
  String get critical => isArabic ? 'حرجة' : 'Critical';

  // Report Problem Screen
  String get report => isArabic ? 'إبلاغ' : 'Report';
  String get fillDetails =>
      isArabic ? 'املأ التفاصيل أدناه' : 'Fill in the details below';
  String get tapToUpload =>
      isArabic ? 'اضغط لتحميل صورة' : 'Tap to upload a photo';
  String get jpgPngSupported =>
      isArabic ? 'JPG, PNG مدعومة' : 'JPG, PNG supported';
  String get change => isArabic ? 'تغيير' : 'Change';
  String get setLocationOnMap =>
      isArabic ? 'تحديد الموقع على الخريطة' : 'Set Location on Map';
  String get tapToOpenMaps =>
      isArabic
          ? 'اضغط لفتح خرائط جوجل وتحديد موقع المشكلة'
          : 'Tap to open Google Maps and pin the issue location';
  String get locationSelected =>
      isArabic ? 'تم تحديد الموقع' : 'Location selected';
  String get describeTheProblem =>
      isArabic
          ? 'صف المشكلة - الخطورة، الموقع الدقيق، إلخ.'
          : 'Describe the problem — severity, exact spot, etc.';
  String get descriptionMinLength =>
      isArabic ? 'الرجاء إدخال وصف' : 'Please enter a description';
  String get descriptionTooShort =>
      isArabic
          ? 'يجب أن يكون 10 أحرف على الأقل'
          : 'At least 10 characters required';
  String get pleaseSelectLocation =>
      isArabic
          ? 'الرجاء تحديد موقع على الخريطة'
          : 'Please select a location on the map';
  String get submitReport => isArabic ? 'إرسال البلاغ' : 'Submit Report';
  String get reportSubmittedSuccess =>
      isArabic ? 'تم إرسال البلاغ بنجاح' : 'Report submitted successfully';
  String get errorSubmittingReport =>
      isArabic ? 'خطأ في إرسال البلاغ' : 'Error submitting report';

  // Admin
  String get admin => isArabic ? 'مدير' : 'Admin';
  String get controlPanel => isArabic ? 'لوحة التحكم' : 'Control Panel';
  String get total => isArabic ? 'الإجمالي' : 'Total';
  String get active => isArabic ? 'نشط' : 'Active';
  String get done => isArabic ? 'تم' : 'Done';
  String get updateStatus => isArabic ? 'تحديث الحالة' : 'Update Status';
  String get statusUpdated => isArabic ? 'تم تحديث الحالة' : 'Status updated';
  String get user => isArabic ? 'مستخدم' : 'User';

  // Products & Shopping
  String get products => isArabic ? 'المنتجات' : 'Products';
  String get shoppingCart => isArabic ? 'عربة التسوق' : 'Shopping Cart';
  String get productDetails => isArabic ? 'تفاصيل المنتج' : 'Product Details';
  String get addToCart => isArabic ? 'أضف إلى السلة' : 'Add to Cart';
  String get addedToCart =>
      isArabic ? 'تمت الإضافة إلى السلة' : 'Added to cart';
  String get add => isArabic ? 'إضافة' : 'Add';
  String get clearCart => isArabic ? 'إفراغ السلة' : 'Clear Cart';
  String get removeAllItems =>
      isArabic ? 'إزالة جميع العناصر من السلة؟' : 'Remove all items from cart?';
  String get browseProducts => isArabic ? 'تصفح المنتجات' : 'Browse Products';
  String get continueShopping =>
      isArabic ? 'متابعة التسوق' : 'Continue Shopping';
  String get submitReview => isArabic ? 'إرسال التقييم' : 'Submit Review';
  String get orderHistory => isArabic ? 'سجل الطلبات' : 'Order History';
  String get orderInvoice => isArabic ? 'فاتورة الطلب' : 'Order Invoice';
  String get goToHome => isArabic ? 'العودة للرئيسية' : 'Go to Home';
  String get pleaseLoginToViewOrders =>
      isArabic
          ? 'الرجاء تسجيل الدخول لعرض الطلبات'
          : 'Please log in to view orders';

  // Location Picker
  String get pickLocation => isArabic ? 'اختر الموقع' : 'Pick Location';
  String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  String get tapMapOrDragPin =>
      isArabic
          ? 'اضغط على الخريطة أو اسحب الدبوس لتحديد الموقع'
          : 'Tap map or drag pin to set location';
  String get invalidCoordinates =>
      isArabic ? 'إحداثيات غير صالحة' : 'Invalid coordinates';
  String get googleMapsApiKeyRequired =>
      isArabic ? 'مطلوب مفتاح Google Maps API' : 'Google Maps API Key Required';
  String get enterCoordinatesManually =>
      isArabic ? 'أدخل الإحداثيات يدوياً' : 'Enter Coordinates Manually';
  String get latitude => isArabic ? 'خط العرض' : 'Latitude';
  String get longitude => isArabic ? 'خط الطول' : 'Longitude';
  String get applyCoordinates =>
      isArabic ? 'تطبيق الإحداثيات' : 'Apply Coordinates';
  String get quickSelectEgyptianCities =>
      isArabic
          ? 'اختيار سريع - المدن المصرية'
          : 'Quick Select — Egyptian Cities';
  String get selectedLocation =>
      isArabic ? 'الموقع المحدد' : 'Selected Location';
  String get useThis => isArabic ? 'استخدم هذا' : 'Use This';
  String get coordinatesHelp =>
      isArabic
          ? 'يمكنك العثور على الإحداثيات من خرائط جوجل بالنقر بزر الماوس الأيمن على أي موقع.'
          : 'You can find coordinates from Google Maps by right-clicking any location.';

  // Problem Type Change Dialog
  String get changeProblemType =>
      isArabic ? 'تغيير نوع المشكلة؟' : 'Change Problem Type?';
  String get imageAppearsToBeType =>
      isArabic ? 'تبدو الصورة أنها' : 'The image appears to be a';
  String get wouldYouLikeToChange =>
      isArabic
          ? 'هل تريد تغيير نوع المشكلة؟'
          : 'Would you like to change the problem type?';
  String get noKeepCurrent =>
      isArabic ? 'لا، احتفظ بالحالي' : 'No, Keep Current';
  String get yesChange => isArabic ? 'نعم، غير' : 'Yes, Change';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
