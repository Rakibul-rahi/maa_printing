import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Maa Printing Factory'**
  String get appName;

  /// No description provided for @appNameCaps.
  ///
  /// In en, this message translates to:
  /// **'MAA PRINTING FACTORY'**
  String get appNameCaps;

  /// No description provided for @managementSystem.
  ///
  /// In en, this message translates to:
  /// **'Management System'**
  String get managementSystem;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(Object message);

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {message}'**
  String failedToDelete(Object message);

  /// No description provided for @unexpectedErrorWith.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {message}'**
  String unexpectedErrorWith(Object message);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleEditor.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get roleEditor;

  /// No description provided for @welcomeOwner.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Owner! Full access granted'**
  String get welcomeOwner;

  /// No description provided for @welcomeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Admin! Managerial access'**
  String get welcomeAdmin;

  /// No description provided for @welcomeEditor.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Shad'**
  String get welcomeEditor;

  /// No description provided for @welcomeDefault.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Maa Printing Factory!'**
  String get welcomeDefault;

  /// No description provided for @viewNotifications.
  ///
  /// In en, this message translates to:
  /// **'View Notifications'**
  String get viewNotifications;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @totalDueToParties.
  ///
  /// In en, this message translates to:
  /// **'Total Due to Danar Parties'**
  String get totalDueToParties;

  /// No description provided for @totalReceivableFromCustomers.
  ///
  /// In en, this message translates to:
  /// **'Total Receivable from Customers'**
  String get totalReceivableFromCustomers;

  /// No description provided for @errorFetchingParty.
  ///
  /// In en, this message translates to:
  /// **'Error fetching party data'**
  String get errorFetchingParty;

  /// No description provided for @errorFetchingCustomer.
  ///
  /// In en, this message translates to:
  /// **'Error fetching customer data'**
  String get errorFetchingCustomer;

  /// No description provided for @menuDanarParty.
  ///
  /// In en, this message translates to:
  /// **'Danar Party Heshab'**
  String get menuDanarParty;

  /// No description provided for @menuCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer Heshab'**
  String get menuCustomer;

  /// No description provided for @menuDailyProduction.
  ///
  /// In en, this message translates to:
  /// **'Daily Production Heshab'**
  String get menuDailyProduction;

  /// No description provided for @menuPowder.
  ///
  /// In en, this message translates to:
  /// **'Powder Heshab'**
  String get menuPowder;

  /// No description provided for @menuReadyGoods.
  ///
  /// In en, this message translates to:
  /// **'Ready Goods'**
  String get menuReadyGoods;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @errorLoadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'❌ Error loading notifications'**
  String get errorLoadingNotifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotifications;

  /// No description provided for @noMessage.
  ///
  /// In en, this message translates to:
  /// **'No message'**
  String get noMessage;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailHint;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPasswordHint;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get signIn;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @requestAccess.
  ///
  /// In en, this message translates to:
  /// **'Request Access'**
  String get requestAccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Login failed: {reason}'**
  String loginFailed(Object reason);

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'❌ Unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @errUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email'**
  String get errUserNotFound;

  /// No description provided for @errWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get errWrongPassword;

  /// No description provided for @errInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get errInvalidEmail;

  /// No description provided for @errUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'Account has been disabled'**
  String get errUserDisabled;

  /// No description provided for @errAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get errAuthFailed;

  /// No description provided for @errTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get errTooManyRequests;

  /// No description provided for @errNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errNoInternet;

  /// No description provided for @errResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send reset email ({code})'**
  String errResetFailed(Object code);

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'❌ Access denied: Contact administrator'**
  String get accessDenied;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter your account email and we\'ll send you a link to reset your password.'**
  String get resetPasswordInfo;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get sendLink;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'✅ If an account exists for {email}, a password reset link has been sent. Check your inbox and spam folder.'**
  String resetEmailSent(Object email);

  /// No description provided for @requestAccessInfo.
  ///
  /// In en, this message translates to:
  /// **'Fill in your details. The owner or admin will review your request and create your account.'**
  String get requestAccessInfo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get enterValidPhone;

  /// No description provided for @requestedRole.
  ///
  /// In en, this message translates to:
  /// **'Requested Role'**
  String get requestedRole;

  /// No description provided for @reasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get reasonOptional;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'SEND REQUEST'**
  String get sendRequest;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request Sent'**
  String get requestSent;

  /// No description provided for @requestSentInfo.
  ///
  /// In en, this message translates to:
  /// **'Your request has been sent to the owner and admin. You will be contacted once your account is ready.'**
  String get requestSentInfo;

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Could not send request. Please check your connection and try again.'**
  String get requestFailed;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkYourEmail;

  /// No description provided for @verifyEmailInfo.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification link to your email address. Please click the link to verify your account.'**
  String get verifyEmailInfo;

  /// No description provided for @resendVerification.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerification;

  /// No description provided for @iVerified.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified my email'**
  String get iVerified;

  /// No description provided for @verificationResent.
  ///
  /// In en, this message translates to:
  /// **'Verification email resent!'**
  String get verificationResent;

  /// No description provided for @searchCustomer.
  ///
  /// In en, this message translates to:
  /// **'Search by customer name...'**
  String get searchCustomer;

  /// No description provided for @searchParty.
  ///
  /// In en, this message translates to:
  /// **'Search by party name...'**
  String get searchParty;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact: {name}'**
  String contactLabel(Object name);

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone: {phone}'**
  String phoneLabel(Object phone);

  /// No description provided for @dueAmount.
  ///
  /// In en, this message translates to:
  /// **'Due: {amount}'**
  String dueAmount(Object amount);

  /// No description provided for @advanceAmount.
  ///
  /// In en, this message translates to:
  /// **'Advance: {amount}'**
  String advanceAmount(Object amount);

  /// No description provided for @lastDate.
  ///
  /// In en, this message translates to:
  /// **'Last: {date}'**
  String lastDate(Object date);

  /// No description provided for @contactPerson.
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get contactPerson;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} Transactions'**
  String transactionsTitle(Object name);

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.'**
  String get noTransactions;

  /// No description provided for @errorLoadingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Error loading transactions.'**
  String get errorLoadingTransactions;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @deleteSelectedTransactions.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected Transactions'**
  String get deleteSelectedTransactions;

  /// No description provided for @deleteTransactionsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} transaction(s)?'**
  String deleteTransactionsConfirm(Object count);

  /// No description provided for @transactionsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transactions deleted.'**
  String get transactionsDeleted;

  /// No description provided for @deleteConfirmName.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteConfirmName(Object name);

  /// No description provided for @enterValidNonNegative.
  ///
  /// In en, this message translates to:
  /// **'Enter valid non-negative number'**
  String get enterValidNonNegative;

  /// No description provided for @recalculate.
  ///
  /// In en, this message translates to:
  /// **'Recalculate'**
  String get recalculate;

  /// No description provided for @balanceRecalculated.
  ///
  /// In en, this message translates to:
  /// **'Recalculated and updated balance.'**
  String get balanceRecalculated;

  /// No description provided for @customerAccounts.
  ///
  /// In en, this message translates to:
  /// **'Customer Accounts'**
  String get customerAccounts;

  /// No description provided for @deleteCustomer.
  ///
  /// In en, this message translates to:
  /// **'Delete Customer'**
  String get deleteCustomer;

  /// No description provided for @customerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Customer deleted'**
  String get customerDeleted;

  /// No description provided for @noMatchingCustomers.
  ///
  /// In en, this message translates to:
  /// **'No matching customers.'**
  String get noMatchingCustomers;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales: {amount}'**
  String totalSales(Object amount);

  /// No description provided for @totalReceived.
  ///
  /// In en, this message translates to:
  /// **'Total Received: {amount}'**
  String totalReceived(Object amount);

  /// No description provided for @saleAmount.
  ///
  /// In en, this message translates to:
  /// **'Sale Amount'**
  String get saleAmount;

  /// No description provided for @receivedAmount.
  ///
  /// In en, this message translates to:
  /// **'Received Amount'**
  String get receivedAmount;

  /// No description provided for @saleReceivedLine.
  ///
  /// In en, this message translates to:
  /// **'Sale: {sale}, Received: {received}'**
  String saleReceivedLine(Object received, Object sale);

  /// No description provided for @danarPartyHishab.
  ///
  /// In en, this message translates to:
  /// **'Danar Party Hishab'**
  String get danarPartyHishab;

  /// No description provided for @deleteParty.
  ///
  /// In en, this message translates to:
  /// **'Delete Party'**
  String get deleteParty;

  /// No description provided for @partyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Party deleted'**
  String get partyDeleted;

  /// No description provided for @noPartyAccounts.
  ///
  /// In en, this message translates to:
  /// **'No party accounts found'**
  String get noPartyAccounts;

  /// No description provided for @addParty.
  ///
  /// In en, this message translates to:
  /// **'Add Party'**
  String get addParty;

  /// No description provided for @partyName.
  ///
  /// In en, this message translates to:
  /// **'Party Name'**
  String get partyName;

  /// No description provided for @totalBill.
  ///
  /// In en, this message translates to:
  /// **'Total Bill: {amount}'**
  String totalBill(Object amount);

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid: {amount}'**
  String totalPaid(Object amount);

  /// No description provided for @amountPaidLine.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount}, Paid: {paid}'**
  String amountPaidLine(Object amount, Object paid);

  /// No description provided for @dailyProductionHishab.
  ///
  /// In en, this message translates to:
  /// **'Daily Production Hishab'**
  String get dailyProductionHishab;

  /// No description provided for @failedToLoadStock.
  ///
  /// In en, this message translates to:
  /// **'Failed to load stock: {message}'**
  String failedToLoadStock(Object message);

  /// No description provided for @setInitialStock.
  ///
  /// In en, this message translates to:
  /// **'Set Initial Stock'**
  String get setInitialStock;

  /// No description provided for @historyFor.
  ///
  /// In en, this message translates to:
  /// **'History for {name}'**
  String historyFor(Object name);

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No history found'**
  String get noHistory;

  /// No description provided for @currentStock.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get currentStock;

  /// No description provided for @setStock.
  ///
  /// In en, this message translates to:
  /// **'Set Stock'**
  String get setStock;

  /// No description provided for @dayShift.
  ///
  /// In en, this message translates to:
  /// **'Day Shift'**
  String get dayShift;

  /// No description provided for @nightShift.
  ///
  /// In en, this message translates to:
  /// **'Night Shift'**
  String get nightShift;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// No description provided for @shiftEntry.
  ///
  /// In en, this message translates to:
  /// **'{shift} Shift Entry'**
  String shiftEntry(Object shift);

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: '**
  String get dateLabel;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @kgAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} KG'**
  String kgAmount(Object amount);

  /// No description provided for @typePani.
  ///
  /// In en, this message translates to:
  /// **'Pani'**
  String get typePani;

  /// No description provided for @type1No.
  ///
  /// In en, this message translates to:
  /// **'1 No'**
  String get type1No;

  /// No description provided for @type2No.
  ///
  /// In en, this message translates to:
  /// **'2 No'**
  String get type2No;

  /// No description provided for @type3No.
  ///
  /// In en, this message translates to:
  /// **'3 No'**
  String get type3No;

  /// No description provided for @opBlowing.
  ///
  /// In en, this message translates to:
  /// **'Blowing'**
  String get opBlowing;

  /// No description provided for @opCutting.
  ///
  /// In en, this message translates to:
  /// **'Cutting'**
  String get opCutting;

  /// No description provided for @opWastage.
  ///
  /// In en, this message translates to:
  /// **'Wastage'**
  String get opWastage;

  /// No description provided for @shiftDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get shiftDay;

  /// No description provided for @shiftNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get shiftNight;

  /// No description provided for @catBoro.
  ///
  /// In en, this message translates to:
  /// **'Boro'**
  String get catBoro;

  /// No description provided for @catChoto.
  ///
  /// In en, this message translates to:
  /// **'Choto'**
  String get catChoto;

  /// No description provided for @opAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get opAdd;

  /// No description provided for @opSubtract.
  ///
  /// In en, this message translates to:
  /// **'Subtract'**
  String get opSubtract;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'KG'**
  String get unitKg;

  /// No description provided for @unitBundle.
  ///
  /// In en, this message translates to:
  /// **'Bundle'**
  String get unitBundle;

  /// No description provided for @currentStockSummary.
  ///
  /// In en, this message translates to:
  /// **'Current Stock Summary'**
  String get currentStockSummary;

  /// No description provided for @goToSpreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Go to Spreadsheet'**
  String get goToSpreadsheet;

  /// No description provided for @changesSavedLocally.
  ///
  /// In en, this message translates to:
  /// **'Changes saved locally'**
  String get changesSavedLocally;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChanges;

  /// No description provided for @unsavedChangesPrompt.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Save before switching date?'**
  String get unsavedChangesPrompt;

  /// No description provided for @descriptionFor.
  ///
  /// In en, this message translates to:
  /// **'Description for {item}'**
  String descriptionFor(Object item);

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description...'**
  String get enterDescription;

  /// No description provided for @cannotSubmitFuture.
  ///
  /// In en, this message translates to:
  /// **'Cannot submit data for future dates'**
  String get cannotSubmitFuture;

  /// No description provided for @stockSubmittedFor.
  ///
  /// In en, this message translates to:
  /// **'Stock data submitted for {date}'**
  String stockSubmittedFor(Object date);

  /// No description provided for @noChangesToSubmit.
  ///
  /// In en, this message translates to:
  /// **'No changes to submit'**
  String get noChangesToSubmit;

  /// No description provided for @firestoreError.
  ///
  /// In en, this message translates to:
  /// **'Firestore Error: {message}'**
  String firestoreError(Object message);

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Check security rules'**
  String get permissionDenied;

  /// No description provided for @stockAccounting.
  ///
  /// In en, this message translates to:
  /// **'Stock Accounting'**
  String get stockAccounting;

  /// No description provided for @stockSummary.
  ///
  /// In en, this message translates to:
  /// **'Stock Summary'**
  String get stockSummary;

  /// No description provided for @editingDisabledFuture.
  ///
  /// In en, this message translates to:
  /// **'Editing disabled for future dates'**
  String get editingDisabledFuture;

  /// No description provided for @colItem.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get colItem;

  /// No description provided for @colValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get colValue;

  /// No description provided for @colAddSub.
  ///
  /// In en, this message translates to:
  /// **'Add/Sub'**
  String get colAddSub;

  /// No description provided for @colDesc.
  ///
  /// In en, this message translates to:
  /// **'Desc'**
  String get colDesc;

  /// No description provided for @submitToFirestore.
  ///
  /// In en, this message translates to:
  /// **'Submit to Firestore'**
  String get submitToFirestore;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @confirmReset.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reset'**
  String get confirmReset;

  /// No description provided for @confirmResetInfo.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the entire inventory? This action cannot be undone.'**
  String get confirmResetInfo;

  /// No description provided for @inventoryReset.
  ///
  /// In en, this message translates to:
  /// **'Inventory reset.'**
  String get inventoryReset;

  /// No description provided for @updateItem.
  ///
  /// In en, this message translates to:
  /// **'Update {item}'**
  String updateItem(Object item);

  /// No description provided for @amountIn.
  ///
  /// In en, this message translates to:
  /// **'Amount in {unit}'**
  String amountIn(Object unit);

  /// No description provided for @shift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get shift;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick Date'**
  String get pickDate;

  /// No description provided for @operationLabel.
  ///
  /// In en, this message translates to:
  /// **'Operation:'**
  String get operationLabel;

  /// No description provided for @readyGoodsInventory.
  ///
  /// In en, this message translates to:
  /// **'Ready Goods Inventory'**
  String get readyGoodsInventory;

  /// No description provided for @resetInventory.
  ///
  /// In en, this message translates to:
  /// **'Reset Inventory'**
  String get resetInventory;

  /// No description provided for @readyGoodsSummary.
  ///
  /// In en, this message translates to:
  /// **'Amount: {amount} {unit} • Shift: {shift} • Date: {date}'**
  String readyGoodsSummary(
    Object amount,
    Object date,
    Object shift,
    Object unit,
  );

  /// No description provided for @editQuantity.
  ///
  /// In en, this message translates to:
  /// **'Edit Quantity'**
  String get editQuantity;

  /// No description provided for @noHistoryRecords.
  ///
  /// In en, this message translates to:
  /// **'No history records found.'**
  String get noHistoryRecords;

  /// No description provided for @shiftDateLine.
  ///
  /// In en, this message translates to:
  /// **'Shift: {shift} | Date: {date}'**
  String shiftDateLine(Object date, Object shift);

  /// No description provided for @chatOnlyStaff.
  ///
  /// In en, this message translates to:
  /// **'Chat is only available for owner, admin and editor.'**
  String get chatOnlyStaff;

  /// No description provided for @teamChat.
  ///
  /// In en, this message translates to:
  /// **'Team Chat'**
  String get teamChat;

  /// No description provided for @everyoneMembers.
  ///
  /// In en, this message translates to:
  /// **'Everyone · {count} members'**
  String everyoneMembers(Object count);

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String membersCount(Object count);

  /// No description provided for @tapToStartChatting.
  ///
  /// In en, this message translates to:
  /// **'Tap to start chatting'**
  String get tapToStartChatting;

  /// No description provided for @youPrefix.
  ///
  /// In en, this message translates to:
  /// **'You: '**
  String get youPrefix;

  /// No description provided for @errorLoadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Error loading messages: {message}'**
  String errorLoadingMessages(Object message);

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Say hello 👋'**
  String get noMessagesYet;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get typeMessage;

  /// No description provided for @messageNotSent.
  ///
  /// In en, this message translates to:
  /// **'❌ Message not sent: {message}'**
  String messageNotSent(Object message);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @newTotal.
  ///
  /// In en, this message translates to:
  /// **'New total: {value}'**
  String newTotal(Object value);

  /// No description provided for @itemsChanged.
  ///
  /// In en, this message translates to:
  /// **'{count} items changed'**
  String itemsChanged(Object count);

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get newEntry;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get inStock;

  /// No description provided for @nothingEntered.
  ///
  /// In en, this message translates to:
  /// **'Enter at least one quantity'**
  String get nothingEntered;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
