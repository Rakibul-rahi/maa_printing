// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Maa Printing Factory';

  @override
  String get appNameCaps => 'MAA PRINTING FACTORY';

  @override
  String get managementSystem => 'Management System';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get add => 'Add';

  @override
  String get submit => 'Submit';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get ok => 'OK';

  @override
  String get discard => 'Discard';

  @override
  String get requiredField => 'Required';

  @override
  String get unknown => 'Unknown';

  @override
  String errorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String failedToDelete(Object message) {
    return 'Failed to delete: $message';
  }

  @override
  String unexpectedErrorWith(Object message) {
    return 'Unexpected error: $message';
  }

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleEditor => 'Editor';

  @override
  String get welcomeOwner => 'Welcome, Owner! Full access granted';

  @override
  String get welcomeAdmin => 'Welcome, Admin! Managerial access';

  @override
  String get welcomeEditor => 'Welcome, Shad';

  @override
  String get welcomeDefault => 'Welcome to Maa Printing Factory!';

  @override
  String get viewNotifications => 'View Notifications';

  @override
  String get chat => 'Chat';

  @override
  String get signOut => 'Sign out';

  @override
  String get totalDueToParties => 'Total Due to Danar Parties';

  @override
  String get totalReceivableFromCustomers => 'Total Receivable from Customers';

  @override
  String get errorFetchingParty => 'Error fetching party data';

  @override
  String get errorFetchingCustomer => 'Error fetching customer data';

  @override
  String get menuDanarParty => 'Danar Party Heshab';

  @override
  String get menuCustomer => 'Customer Heshab';

  @override
  String get menuDailyProduction => 'Daily Production Heshab';

  @override
  String get menuPowder => 'Powder Heshab';

  @override
  String get menuReadyGoods => 'Ready Goods';

  @override
  String get notifications => 'Notifications';

  @override
  String get errorLoadingNotifications => '❌ Error loading notifications';

  @override
  String get noNotifications => 'No notifications yet.';

  @override
  String get noMessage => 'No message';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get enterEmail => 'Please enter your email';

  @override
  String get enterValidEmail => 'Please enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get enterPasswordHint => 'Enter your password';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get signIn => 'SIGN IN';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get requestAccess => 'Request Access';

  @override
  String loginFailed(Object reason) {
    return '❌ Login failed: $reason';
  }

  @override
  String get unexpectedError => '❌ Unexpected error occurred';

  @override
  String get errUserNotFound => 'No account found with this email';

  @override
  String get errWrongPassword => 'Incorrect password';

  @override
  String get errInvalidEmail => 'Invalid email format';

  @override
  String get errUserDisabled => 'Account has been disabled';

  @override
  String get errAuthFailed => 'Authentication failed';

  @override
  String get errTooManyRequests => 'Too many attempts. Please try again later.';

  @override
  String get errNoInternet => 'No internet connection';

  @override
  String errResetFailed(Object code) {
    return 'Could not send reset email ($code)';
  }

  @override
  String get accessDenied => '❌ Access denied: Contact administrator';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordInfo =>
      'Enter your account email and we\'ll send you a link to reset your password.';

  @override
  String get sendLink => 'Send Link';

  @override
  String resetEmailSent(Object email) {
    return '✅ If an account exists for $email, a password reset link has been sent. Check your inbox and spam folder.';
  }

  @override
  String get requestAccessInfo =>
      'Fill in your details. The owner or admin will review your request and create your account.';

  @override
  String get fullName => 'Full Name';

  @override
  String get enterName => 'Please enter your name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterValidPhone => 'Please enter a valid phone number';

  @override
  String get requestedRole => 'Requested Role';

  @override
  String get reasonOptional => 'Reason (optional)';

  @override
  String get sendRequest => 'SEND REQUEST';

  @override
  String get requestSent => 'Request Sent';

  @override
  String get requestSentInfo =>
      'Your request has been sent to the owner and admin. You will be contacted once your account is ready.';

  @override
  String get requestFailed =>
      '❌ Could not send request. Please check your connection and try again.';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String get checkYourEmail => 'Check your email';

  @override
  String get verifyEmailInfo =>
      'We\'ve sent a verification link to your email address. Please click the link to verify your account.';

  @override
  String get resendVerification => 'Resend Verification Email';

  @override
  String get iVerified => 'I\'ve verified my email';

  @override
  String get verificationResent => 'Verification email resent!';

  @override
  String get searchCustomer => 'Search by customer name...';

  @override
  String get searchParty => 'Search by party name...';

  @override
  String contactLabel(Object name) {
    return 'Contact: $name';
  }

  @override
  String phoneLabel(Object phone) {
    return 'Phone: $phone';
  }

  @override
  String dueAmount(Object amount) {
    return 'Due: $amount';
  }

  @override
  String advanceAmount(Object amount) {
    return 'Advance: $amount';
  }

  @override
  String lastDate(Object date) {
    return 'Last: $date';
  }

  @override
  String get contactPerson => 'Contact Person';

  @override
  String get phone => 'Phone';

  @override
  String get description => 'Description';

  @override
  String get selectDate => 'Select Date';

  @override
  String get amount => 'Amount';

  @override
  String get paid => 'Paid';

  @override
  String transactionsTitle(Object name) {
    return '$name Transactions';
  }

  @override
  String get noTransactions => 'No transactions yet.';

  @override
  String get errorLoadingTransactions => 'Error loading transactions.';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get deleteSelectedTransactions => 'Delete Selected Transactions';

  @override
  String deleteTransactionsConfirm(Object count) {
    return 'Are you sure you want to delete $count transaction(s)?';
  }

  @override
  String get transactionsDeleted => 'Transactions deleted.';

  @override
  String deleteConfirmName(Object name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get enterValidNonNegative => 'Enter valid non-negative number';

  @override
  String get recalculate => 'Recalculate';

  @override
  String get balanceRecalculated => 'Recalculated and updated balance.';

  @override
  String get customerAccounts => 'Customer Accounts';

  @override
  String get deleteCustomer => 'Delete Customer';

  @override
  String get customerDeleted => 'Customer deleted';

  @override
  String get noMatchingCustomers => 'No matching customers.';

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get customerName => 'Customer Name';

  @override
  String totalSales(Object amount) {
    return 'Total Sales: $amount';
  }

  @override
  String totalReceived(Object amount) {
    return 'Total Received: $amount';
  }

  @override
  String get saleAmount => 'Sale Amount';

  @override
  String get receivedAmount => 'Received Amount';

  @override
  String saleReceivedLine(Object received, Object sale) {
    return 'Sale: $sale, Received: $received';
  }

  @override
  String get danarPartyHishab => 'Danar Party Hishab';

  @override
  String get deleteParty => 'Delete Party';

  @override
  String get partyDeleted => 'Party deleted';

  @override
  String get noPartyAccounts => 'No party accounts found';

  @override
  String get addParty => 'Add Party';

  @override
  String get partyName => 'Party Name';

  @override
  String totalBill(Object amount) {
    return 'Total Bill: $amount';
  }

  @override
  String totalPaid(Object amount) {
    return 'Total Paid: $amount';
  }

  @override
  String amountPaidLine(Object amount, Object paid) {
    return 'Amount: $amount, Paid: $paid';
  }

  @override
  String get dailyProductionHishab => 'Daily Production Hishab';

  @override
  String failedToLoadStock(Object message) {
    return 'Failed to load stock: $message';
  }

  @override
  String get setInitialStock => 'Set Initial Stock';

  @override
  String historyFor(Object name) {
    return 'History for $name';
  }

  @override
  String get noHistory => 'No history found';

  @override
  String get currentStock => 'Current Stock';

  @override
  String get setStock => 'Set Stock';

  @override
  String get dayShift => 'Day Shift';

  @override
  String get nightShift => 'Night Shift';

  @override
  String get viewHistory => 'View History';

  @override
  String shiftEntry(Object shift) {
    return '$shift Shift Entry';
  }

  @override
  String get dateLabel => 'Date: ';

  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String kgAmount(Object amount) {
    return '$amount KG';
  }

  @override
  String get typePani => 'Pani';

  @override
  String get type1No => '1 No';

  @override
  String get type2No => '2 No';

  @override
  String get type3No => '3 No';

  @override
  String get opBlowing => 'Blowing';

  @override
  String get opCutting => 'Cutting';

  @override
  String get opWastage => 'Wastage';

  @override
  String get shiftDay => 'Day';

  @override
  String get shiftNight => 'Night';

  @override
  String get catBoro => 'Boro';

  @override
  String get catChoto => 'Choto';

  @override
  String get opAdd => 'Add';

  @override
  String get opSubtract => 'Subtract';

  @override
  String get unitKg => 'KG';

  @override
  String get unitBundle => 'Bundle';

  @override
  String get currentStockSummary => 'Current Stock Summary';

  @override
  String get goToSpreadsheet => 'Go to Spreadsheet';

  @override
  String get changesSavedLocally => 'Changes saved locally';

  @override
  String get unsavedChanges => 'Unsaved Changes';

  @override
  String get unsavedChangesPrompt =>
      'You have unsaved changes. Save before switching date?';

  @override
  String descriptionFor(Object item) {
    return 'Description for $item';
  }

  @override
  String get enterDescription => 'Enter description...';

  @override
  String get cannotSubmitFuture => 'Cannot submit data for future dates';

  @override
  String stockSubmittedFor(Object date) {
    return 'Stock data submitted for $date';
  }

  @override
  String get noChangesToSubmit => 'No changes to submit';

  @override
  String firestoreError(Object message) {
    return 'Firestore Error: $message';
  }

  @override
  String get permissionDenied => 'Permission denied. Check security rules';

  @override
  String get stockAccounting => 'Stock Accounting';

  @override
  String get stockSummary => 'Stock Summary';

  @override
  String get editingDisabledFuture => 'Editing disabled for future dates';

  @override
  String get colItem => 'Item';

  @override
  String get colValue => 'Value';

  @override
  String get colAddSub => 'Add/Sub';

  @override
  String get colDesc => 'Desc';

  @override
  String get submitToFirestore => 'Submit to Firestore';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get confirmReset => 'Confirm Reset';

  @override
  String get confirmResetInfo =>
      'Are you sure you want to reset the entire inventory? This action cannot be undone.';

  @override
  String get inventoryReset => 'Inventory reset.';

  @override
  String updateItem(Object item) {
    return 'Update $item';
  }

  @override
  String amountIn(Object unit) {
    return 'Amount in $unit';
  }

  @override
  String get shift => 'Shift';

  @override
  String get pickDate => 'Pick Date';

  @override
  String get operationLabel => 'Operation:';

  @override
  String get readyGoodsInventory => 'Ready Goods Inventory';

  @override
  String get resetInventory => 'Reset Inventory';

  @override
  String readyGoodsSummary(
    Object amount,
    Object date,
    Object shift,
    Object unit,
  ) {
    return 'Amount: $amount $unit • Shift: $shift • Date: $date';
  }

  @override
  String get editQuantity => 'Edit Quantity';

  @override
  String get noHistoryRecords => 'No history records found.';

  @override
  String shiftDateLine(Object date, Object shift) {
    return 'Shift: $shift | Date: $date';
  }

  @override
  String get chatOnlyStaff =>
      'Chat is only available for owner, admin and editor.';

  @override
  String get teamChat => 'Team Chat';

  @override
  String everyoneMembers(Object count) {
    return 'Everyone · $count members';
  }

  @override
  String membersCount(Object count) {
    return '$count members';
  }

  @override
  String get tapToStartChatting => 'Tap to start chatting';

  @override
  String get youPrefix => 'You: ';

  @override
  String errorLoadingMessages(Object message) {
    return 'Error loading messages: $message';
  }

  @override
  String get noMessagesYet => 'No messages yet. Say hello 👋';

  @override
  String get typeMessage => 'Type a message';

  @override
  String messageNotSent(Object message) {
    return '❌ Message not sent: $message';
  }

  @override
  String get today => 'Today';

  @override
  String newTotal(Object value) {
    return 'New total: $value';
  }

  @override
  String itemsChanged(Object count) {
    return '$count items changed';
  }

  @override
  String get newEntry => 'New Entry';

  @override
  String get totalLabel => 'Total';

  @override
  String get noteLabel => 'Note';

  @override
  String get inStock => 'In stock';

  @override
  String get nothingEntered => 'Enter at least one quantity';
}
