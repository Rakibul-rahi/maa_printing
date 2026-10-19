// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'মা প্রিন্টিং ফ্যাক্টরি';

  @override
  String get appNameCaps => 'মা প্রিন্টিং ফ্যাক্টরি';

  @override
  String get managementSystem => 'ম্যানেজমেন্ট সিস্টেম';

  @override
  String get cancel => 'বাতিল';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get delete => 'মুছুন';

  @override
  String get add => 'যোগ করুন';

  @override
  String get submit => 'জমা দিন';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get confirm => 'নিশ্চিত করুন';

  @override
  String get ok => 'ঠিক আছে';

  @override
  String get discard => 'বাদ দিন';

  @override
  String get requiredField => 'আবশ্যক';

  @override
  String get unknown => 'অজানা';

  @override
  String errorWithMessage(Object message) {
    return 'ত্রুটি: $message';
  }

  @override
  String failedToDelete(Object message) {
    return 'মুছতে ব্যর্থ: $message';
  }

  @override
  String unexpectedErrorWith(Object message) {
    return 'অপ্রত্যাশিত ত্রুটি: $message';
  }

  @override
  String get settings => 'সেটিংস';

  @override
  String get language => 'ভাষা';

  @override
  String get theme => 'থিম';

  @override
  String get themeSystem => 'সিস্টেম';

  @override
  String get themeLight => 'লাইট';

  @override
  String get themeDark => 'ডার্ক';

  @override
  String get roleOwner => 'মালিক';

  @override
  String get roleAdmin => 'অ্যাডমিন';

  @override
  String get roleEditor => 'এডিটর';

  @override
  String get welcomeOwner => 'স্বাগতম, মালিক! সম্পূর্ণ অ্যাক্সেস দেওয়া হয়েছে';

  @override
  String get welcomeAdmin => 'স্বাগতম, অ্যাডমিন! ব্যবস্থাপনা অ্যাক্সেস';

  @override
  String get welcomeEditor => 'স্বাগতম, শাদ';

  @override
  String get welcomeDefault => 'মা প্রিন্টিং ফ্যাক্টরিতে স্বাগতম!';

  @override
  String get viewNotifications => 'নোটিফিকেশন দেখুন';

  @override
  String get chat => 'চ্যাট';

  @override
  String get signOut => 'সাইন আউট';

  @override
  String get totalDueToParties => 'দানার পার্টিদের কাছে মোট বাকি';

  @override
  String get totalReceivableFromCustomers => 'গ্রাহকদের কাছে মোট পাওনা';

  @override
  String get errorFetchingParty => 'পার্টির তথ্য আনতে ত্রুটি';

  @override
  String get errorFetchingCustomer => 'গ্রাহকের তথ্য আনতে ত্রুটি';

  @override
  String get menuDanarParty => 'দানার পার্টি হিসাব';

  @override
  String get menuCustomer => 'গ্রাহক হিসাব';

  @override
  String get menuDailyProduction => 'দৈনিক উৎপাদন হিসাব';

  @override
  String get menuPowder => 'পাউডার হিসাব';

  @override
  String get menuReadyGoods => 'তৈরি মাল';

  @override
  String get notifications => 'নোটিফিকেশন';

  @override
  String get errorLoadingNotifications => '❌ নোটিফিকেশন লোড করতে ত্রুটি';

  @override
  String get noNotifications => 'এখনও কোনো নোটিফিকেশন নেই।';

  @override
  String get noMessage => 'কোনো বার্তা নেই';

  @override
  String get emailAddress => 'ইমেইল ঠিকানা';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get enterEmail => 'আপনার ইমেইল লিখুন';

  @override
  String get enterValidEmail => 'সঠিক ইমেইল লিখুন';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get enterPasswordHint => 'আপনার পাসওয়ার্ড লিখুন';

  @override
  String get enterPassword => 'আপনার পাসওয়ার্ড লিখুন';

  @override
  String get passwordMinLength => 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';

  @override
  String get forgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get signIn => 'সাইন ইন';

  @override
  String get noAccount => 'অ্যাকাউন্ট নেই? ';

  @override
  String get requestAccess => 'অ্যাক্সেসের অনুরোধ';

  @override
  String loginFailed(Object reason) {
    return '❌ লগইন ব্যর্থ: $reason';
  }

  @override
  String get unexpectedError => '❌ অপ্রত্যাশিত ত্রুটি ঘটেছে';

  @override
  String get errUserNotFound => 'এই ইমেইলে কোনো অ্যাকাউন্ট পাওয়া যায়নি';

  @override
  String get errWrongPassword => 'ভুল পাসওয়ার্ড';

  @override
  String get errInvalidEmail => 'ইমেইলের ফরম্যাট সঠিক নয়';

  @override
  String get errUserDisabled => 'অ্যাকাউন্টটি নিষ্ক্রিয় করা হয়েছে';

  @override
  String get errAuthFailed => 'প্রমাণীকরণ ব্যর্থ হয়েছে';

  @override
  String get errTooManyRequests =>
      'অনেকবার চেষ্টা করা হয়েছে। কিছুক্ষণ পরে আবার চেষ্টা করুন।';

  @override
  String get errNoInternet => 'ইন্টারনেট সংযোগ নেই';

  @override
  String errResetFailed(Object code) {
    return 'রিসেট ইমেইল পাঠানো যায়নি ($code)';
  }

  @override
  String get accessDenied => '❌ প্রবেশাধিকার নেই: অ্যাডমিনের সাথে যোগাযোগ করুন';

  @override
  String get resetPassword => 'পাসওয়ার্ড রিসেট';

  @override
  String get resetPasswordInfo =>
      'আপনার অ্যাকাউন্টের ইমেইল দিন, আমরা পাসওয়ার্ড রিসেট করার লিংক পাঠাব।';

  @override
  String get sendLink => 'লিংক পাঠান';

  @override
  String resetEmailSent(Object email) {
    return '✅ $email এ অ্যাকাউন্ট থাকলে পাসওয়ার্ড রিসেট লিংক পাঠানো হয়েছে। ইনবক্স ও স্প্যাম ফোল্ডার দেখুন।';
  }

  @override
  String get requestAccessInfo =>
      'আপনার তথ্য দিন। মালিক বা অ্যাডমিন আপনার অনুরোধ যাচাই করে অ্যাকাউন্ট তৈরি করবেন।';

  @override
  String get fullName => 'পূর্ণ নাম';

  @override
  String get enterName => 'আপনার নাম লিখুন';

  @override
  String get phoneNumber => 'ফোন নম্বর';

  @override
  String get enterValidPhone => 'সঠিক ফোন নম্বর লিখুন';

  @override
  String get requestedRole => 'যে পদের জন্য অনুরোধ';

  @override
  String get reasonOptional => 'কারণ (ঐচ্ছিক)';

  @override
  String get sendRequest => 'অনুরোধ পাঠান';

  @override
  String get requestSent => 'অনুরোধ পাঠানো হয়েছে';

  @override
  String get requestSentInfo =>
      'আপনার অনুরোধ মালিক ও অ্যাডমিনের কাছে পাঠানো হয়েছে। অ্যাকাউন্ট তৈরি হলে আপনার সাথে যোগাযোগ করা হবে।';

  @override
  String get requestFailed =>
      '❌ অনুরোধ পাঠানো যায়নি। ইন্টারনেট সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String get verifyEmail => 'ইমেইল যাচাই';

  @override
  String get checkYourEmail => 'আপনার ইমেইল দেখুন';

  @override
  String get verifyEmailInfo =>
      'আমরা আপনার ইমেইলে একটি যাচাই লিংক পাঠিয়েছি। অ্যাকাউন্ট যাচাই করতে লিংকে ক্লিক করুন।';

  @override
  String get resendVerification => 'যাচাই ইমেইল আবার পাঠান';

  @override
  String get iVerified => 'আমি ইমেইল যাচাই করেছি';

  @override
  String get verificationResent => 'যাচাই ইমেইল আবার পাঠানো হয়েছে!';

  @override
  String get searchCustomer => 'গ্রাহকের নাম দিয়ে খুঁজুন...';

  @override
  String get searchParty => 'পার্টির নাম দিয়ে খুঁজুন...';

  @override
  String contactLabel(Object name) {
    return 'যোগাযোগ: $name';
  }

  @override
  String phoneLabel(Object phone) {
    return 'ফোন: $phone';
  }

  @override
  String dueAmount(Object amount) {
    return 'বাকি: $amount';
  }

  @override
  String advanceAmount(Object amount) {
    return 'অগ্রিম: $amount';
  }

  @override
  String lastDate(Object date) {
    return 'সর্বশেষ: $date';
  }

  @override
  String get contactPerson => 'যোগাযোগকারী ব্যক্তি';

  @override
  String get phone => 'ফোন';

  @override
  String get description => 'বিবরণ';

  @override
  String get selectDate => 'তারিখ নির্বাচন করুন';

  @override
  String get amount => 'পরিমাণ';

  @override
  String get paid => 'পরিশোধ';

  @override
  String transactionsTitle(Object name) {
    return '$name - লেনদেন';
  }

  @override
  String get noTransactions => 'এখনও কোনো লেনদেন নেই।';

  @override
  String get errorLoadingTransactions => 'লেনদেন লোড করতে ত্রুটি।';

  @override
  String get addTransaction => 'লেনদেন যোগ করুন';

  @override
  String get deleteSelectedTransactions => 'নির্বাচিত লেনদেন মুছুন';

  @override
  String deleteTransactionsConfirm(Object count) {
    return 'আপনি কি $countটি লেনদেন মুছে ফেলতে চান?';
  }

  @override
  String get transactionsDeleted => 'লেনদেন মুছে ফেলা হয়েছে।';

  @override
  String deleteConfirmName(Object name) {
    return 'আপনি কি \"$name\" মুছে ফেলতে চান?';
  }

  @override
  String get enterValidNonNegative => 'সঠিক অ-ঋণাত্মক সংখ্যা লিখুন';

  @override
  String get recalculate => 'পুনরায় হিসাব করুন';

  @override
  String get balanceRecalculated =>
      'ব্যালেন্স পুনরায় হিসাব করে হালনাগাদ করা হয়েছে।';

  @override
  String get customerAccounts => 'গ্রাহক হিসাব';

  @override
  String get deleteCustomer => 'গ্রাহক মুছুন';

  @override
  String get customerDeleted => 'গ্রাহক মুছে ফেলা হয়েছে';

  @override
  String get noMatchingCustomers => 'কোনো গ্রাহক পাওয়া যায়নি।';

  @override
  String get addCustomer => 'গ্রাহক যোগ করুন';

  @override
  String get customerName => 'গ্রাহকের নাম';

  @override
  String totalSales(Object amount) {
    return 'মোট বিক্রি: $amount';
  }

  @override
  String totalReceived(Object amount) {
    return 'মোট প্রাপ্ত: $amount';
  }

  @override
  String get saleAmount => 'বিক্রির পরিমাণ';

  @override
  String get receivedAmount => 'প্রাপ্ত পরিমাণ';

  @override
  String saleReceivedLine(Object received, Object sale) {
    return 'বিক্রি: $sale, প্রাপ্ত: $received';
  }

  @override
  String get danarPartyHishab => 'দানার পার্টি হিসাব';

  @override
  String get deleteParty => 'পার্টি মুছুন';

  @override
  String get partyDeleted => 'পার্টি মুছে ফেলা হয়েছে';

  @override
  String get noPartyAccounts => 'কোনো পার্টি হিসাব পাওয়া যায়নি';

  @override
  String get addParty => 'পার্টি যোগ করুন';

  @override
  String get partyName => 'পার্টির নাম';

  @override
  String totalBill(Object amount) {
    return 'মোট বিল: $amount';
  }

  @override
  String totalPaid(Object amount) {
    return 'মোট পরিশোধ: $amount';
  }

  @override
  String amountPaidLine(Object amount, Object paid) {
    return 'পরিমাণ: $amount, পরিশোধ: $paid';
  }

  @override
  String get dailyProductionHishab => 'দৈনিক উৎপাদন হিসাব';

  @override
  String failedToLoadStock(Object message) {
    return 'স্টক লোড করতে ব্যর্থ: $message';
  }

  @override
  String get setInitialStock => 'প্রাথমিক স্টক নির্ধারণ';

  @override
  String historyFor(Object name) {
    return '$name এর ইতিহাস';
  }

  @override
  String get noHistory => 'কোনো ইতিহাস পাওয়া যায়নি';

  @override
  String get currentStock => 'বর্তমান স্টক';

  @override
  String get setStock => 'স্টক নির্ধারণ';

  @override
  String get dayShift => 'দিনের শিফট';

  @override
  String get nightShift => 'রাতের শিফট';

  @override
  String get viewHistory => 'ইতিহাস দেখুন';

  @override
  String shiftEntry(Object shift) {
    return '$shift শিফট এন্ট্রি';
  }

  @override
  String get dateLabel => 'তারিখ: ';

  @override
  String get enterValidAmount => 'সঠিক পরিমাণ লিখুন';

  @override
  String kgAmount(Object amount) {
    return '$amount কেজি';
  }

  @override
  String get typePani => 'পানি';

  @override
  String get type1No => '১ নং';

  @override
  String get type2No => '২ নং';

  @override
  String get type3No => '৩ নং';

  @override
  String get opBlowing => 'ব্লোয়িং';

  @override
  String get opCutting => 'কাটিং';

  @override
  String get opWastage => 'অপচয়';

  @override
  String get shiftDay => 'দিন';

  @override
  String get shiftNight => 'রাত';

  @override
  String get catBoro => 'বড়';

  @override
  String get catChoto => 'ছোট';

  @override
  String get opAdd => 'যোগ';

  @override
  String get opSubtract => 'বিয়োগ';

  @override
  String get unitKg => 'কেজি';

  @override
  String get unitBundle => 'বান্ডেল';

  @override
  String get currentStockSummary => 'বর্তমান স্টকের সারাংশ';

  @override
  String get goToSpreadsheet => 'স্প্রেডশিটে যান';

  @override
  String get changesSavedLocally => 'পরিবর্তন সাময়িকভাবে সংরক্ষিত হয়েছে';

  @override
  String get unsavedChanges => 'অসংরক্ষিত পরিবর্তন';

  @override
  String get unsavedChangesPrompt =>
      'কিছু পরিবর্তন সংরক্ষণ করা হয়নি। তারিখ বদলানোর আগে সংরক্ষণ করবেন?';

  @override
  String descriptionFor(Object item) {
    return '$item এর বিবরণ';
  }

  @override
  String get enterDescription => 'বিবরণ লিখুন...';

  @override
  String get cannotSubmitFuture => 'ভবিষ্যতের তারিখের তথ্য জমা দেওয়া যাবে না';

  @override
  String stockSubmittedFor(Object date) {
    return '$date এর স্টক তথ্য জমা হয়েছে';
  }

  @override
  String get noChangesToSubmit => 'জমা দেওয়ার মতো কোনো পরিবর্তন নেই';

  @override
  String firestoreError(Object message) {
    return 'ডাটাবেস ত্রুটি: $message';
  }

  @override
  String get permissionDenied => 'অনুমতি নেই। সিকিউরিটি রুলস দেখুন';

  @override
  String get stockAccounting => 'স্টক হিসাব';

  @override
  String get stockSummary => 'স্টক সারাংশ';

  @override
  String get editingDisabledFuture => 'ভবিষ্যতের তারিখে সম্পাদনা বন্ধ';

  @override
  String get colItem => 'আইটেম';

  @override
  String get colValue => 'মান';

  @override
  String get colAddSub => 'যোগ/বিয়োগ';

  @override
  String get colDesc => 'বিবরণ';

  @override
  String get submitToFirestore => 'ডাটাবেসে জমা দিন';

  @override
  String get saveChanges => 'পরিবর্তন সংরক্ষণ';

  @override
  String get confirmReset => 'রিসেট নিশ্চিত করুন';

  @override
  String get confirmResetInfo =>
      'আপনি কি পুরো ইনভেন্টরি রিসেট করতে চান? এটি আর ফেরত আনা যাবে না।';

  @override
  String get inventoryReset => 'ইনভেন্টরি রিসেট হয়েছে।';

  @override
  String updateItem(Object item) {
    return '$item হালনাগাদ';
  }

  @override
  String amountIn(Object unit) {
    return 'পরিমাণ ($unit)';
  }

  @override
  String get shift => 'শিফট';

  @override
  String get pickDate => 'তারিখ বাছুন';

  @override
  String get operationLabel => 'অপারেশন:';

  @override
  String get readyGoodsInventory => 'তৈরি মালের ইনভেন্টরি';

  @override
  String get resetInventory => 'ইনভেন্টরি রিসেট';

  @override
  String readyGoodsSummary(
    Object amount,
    Object date,
    Object shift,
    Object unit,
  ) {
    return 'পরিমাণ: $amount $unit • শিফট: $shift • তারিখ: $date';
  }

  @override
  String get editQuantity => 'পরিমাণ সম্পাদনা';

  @override
  String get noHistoryRecords => 'কোনো ইতিহাস পাওয়া যায়নি।';

  @override
  String shiftDateLine(Object date, Object shift) {
    return 'শিফট: $shift | তারিখ: $date';
  }

  @override
  String get chatOnlyStaff => 'চ্যাট শুধুমাত্র মালিক, অ্যাডমিন ও এডিটরের জন্য।';

  @override
  String get teamChat => 'টিম চ্যাট';

  @override
  String everyoneMembers(Object count) {
    return 'সবাই · $count জন সদস্য';
  }

  @override
  String membersCount(Object count) {
    return '$count জন সদস্য';
  }

  @override
  String get tapToStartChatting => 'চ্যাট শুরু করতে ট্যাপ করুন';

  @override
  String get youPrefix => 'আপনি: ';

  @override
  String errorLoadingMessages(Object message) {
    return 'বার্তা লোড করতে ত্রুটি: $message';
  }

  @override
  String get noMessagesYet => 'এখনও কোনো বার্তা নেই। হ্যালো বলুন 👋';

  @override
  String get typeMessage => 'বার্তা লিখুন';

  @override
  String messageNotSent(Object message) {
    return '❌ বার্তা পাঠানো যায়নি: $message';
  }

  @override
  String get today => 'আজ';

  @override
  String newTotal(Object value) {
    return 'নতুন মোট: $value';
  }

  @override
  String itemsChanged(Object count) {
    return '$countটি আইটেম পরিবর্তিত';
  }

  @override
  String get newEntry => 'নতুন এন্ট্রি';

  @override
  String get totalLabel => 'মোট';

  @override
  String get noteLabel => 'নোট';

  @override
  String get inStock => 'মজুদ';

  @override
  String get nothingEntered => 'অন্তত একটি পরিমাণ লিখুন';
}
