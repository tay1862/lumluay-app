///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  );

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsAppEn app = TranslationsAppEn.internal(_root);
	late final TranslationsNavEn nav = TranslationsNavEn.internal(_root);
	late final TranslationsCommonEn common = TranslationsCommonEn.internal(_root);
	late final TranslationsAuthEn auth = TranslationsAuthEn.internal(_root);
	late final TranslationsSalesEn sales = TranslationsSalesEn.internal(_root);
	late final TranslationsItemsEn items = TranslationsItemsEn.internal(_root);
	late final TranslationsInventoryEn inventory = TranslationsInventoryEn.internal(_root);
	late final TranslationsCustomersEn customers = TranslationsCustomersEn.internal(_root);
	late final TranslationsEmployeesEn employees = TranslationsEmployeesEn.internal(_root);
	late final TranslationsShiftsEn shifts = TranslationsShiftsEn.internal(_root);
	late final TranslationsReportsEn reports = TranslationsReportsEn.internal(_root);
	late final TranslationsSettingsEn settings = TranslationsSettingsEn.internal(_root);
	late final TranslationsCurrencyEn currency = TranslationsCurrencyEn.internal(_root);
}

// Path: app
class TranslationsAppEn {
	TranslationsAppEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Lumluay POS'
	String get name => 'Lumluay POS';

	/// en: 'v0.1.0'
	String get version => 'v0.1.0';
}

// Path: nav
class TranslationsNavEn {
	TranslationsNavEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sales'
	String get sales => 'Sales';

	/// en: 'Items'
	String get items => 'Items';

	/// en: 'Inventory'
	String get inventory => 'Inventory';

	/// en: 'Customers'
	String get customers => 'Customers';

	/// en: 'Employees'
	String get employees => 'Employees';

	/// en: 'Shifts'
	String get shifts => 'Shifts';

	/// en: 'Reports'
	String get reports => 'Reports';

	/// en: 'Settings'
	String get settings => 'Settings';
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'Filter'
	String get filter => 'Filter';

	/// en: 'Sort'
	String get sort => 'Sort';

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'No data found'
	String get noData => 'No data found';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Error'
	String get error => 'Error';

	/// en: 'Success'
	String get success => 'Success';

	/// en: 'Warning'
	String get warning => 'Warning';

	/// en: 'Yes'
	String get yes => 'Yes';

	/// en: 'No'
	String get no => 'No';

	/// en: 'OK'
	String get ok => 'OK';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Total'
	String get total => 'Total';

	/// en: 'Subtotal'
	String get subtotal => 'Subtotal';

	/// en: 'Tax'
	String get tax => 'Tax';

	/// en: 'Discount'
	String get discount => 'Discount';

	/// en: 'Quantity'
	String get quantity => 'Quantity';

	/// en: 'Price'
	String get price => 'Price';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Date'
	String get date => 'Date';

	/// en: 'Time'
	String get time => 'Time';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'Status'
	String get status => 'Status';

	/// en: 'Active'
	String get active => 'Active';

	/// en: 'Inactive'
	String get inactive => 'Inactive';

	/// en: 'All'
	String get all => 'All';
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enter your PIN'
	String get enterPin => 'Enter your PIN';

	/// en: 'Wrong PIN, please try again'
	String get wrongPin => 'Wrong PIN, please try again';

	/// en: 'Log Out'
	String get logout => 'Log Out';

	/// en: 'Select Employee'
	String get selectEmployee => 'Select Employee';
}

// Path: sales
class TranslationsSalesEn {
	TranslationsSalesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New Sale'
	String get newSale => 'New Sale';

	/// en: 'Charge'
	String get charge => 'Charge';

	/// en: 'Add Item'
	String get addItem => 'Add Item';

	/// en: 'Clear Cart'
	String get clearCart => 'Clear Cart';

	/// en: 'Receipt'
	String get receipt => 'Receipt';

	/// en: 'Receipt #'
	String get receiptNumber => 'Receipt #';

	/// en: 'Dine In'
	String get dineIn => 'Dine In';

	/// en: 'Takeaway'
	String get takeaway => 'Takeaway';

	/// en: 'Delivery'
	String get delivery => 'Delivery';

	/// en: 'Pay Now'
	String get payNow => 'Pay Now';

	/// en: 'Cash'
	String get cashPayment => 'Cash';

	/// en: 'QR Payment'
	String get qrPayment => 'QR Payment';

	/// en: 'Card'
	String get cardPayment => 'Card';

	/// en: 'Other'
	String get otherPayment => 'Other';

	/// en: 'Change Due'
	String get changeDue => 'Change Due';

	/// en: 'No items in cart'
	String get noItemsInCart => 'No items in cart';

	/// en: 'Item added'
	String get itemAdded => 'Item added';

	/// en: 'Refund'
	String get refund => 'Refund';

	/// en: 'Void Receipt'
	String get voidReceipt => 'Void Receipt';
}

// Path: items
class TranslationsItemsEn {
	TranslationsItemsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All Items'
	String get allItems => 'All Items';

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: 'Add Item'
	String get addItem => 'Add Item';

	/// en: 'Edit Item'
	String get editItem => 'Edit Item';

	/// en: 'Item Name'
	String get itemName => 'Item Name';

	/// en: 'SKU'
	String get sku => 'SKU';

	/// en: 'Barcode'
	String get barcode => 'Barcode';

	/// en: 'Cost'
	String get cost => 'Cost';

	/// en: 'Track Stock'
	String get trackStock => 'Track Stock';

	/// en: 'Sold by Weight'
	String get soldByWeight => 'Sold by Weight';

	/// en: 'Variants'
	String get variants => 'Variants';

	/// en: 'Modifiers'
	String get modifiers => 'Modifiers';

	/// en: 'Add Category'
	String get addCategory => 'Add Category';

	/// en: 'Edit Category'
	String get editCategory => 'Edit Category';

	/// en: 'Category Name'
	String get categoryName => 'Category Name';

	/// en: 'No items yet'
	String get noItems => 'No items yet';

	/// en: 'No categories yet'
	String get noCategories => 'No categories yet';
}

// Path: inventory
class TranslationsInventoryEn {
	TranslationsInventoryEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Stock Levels'
	String get stockLevels => 'Stock Levels';

	/// en: 'Adjust Stock'
	String get adjustStock => 'Adjust Stock';

	/// en: 'Stock Count'
	String get stockCount => 'Stock Count';

	/// en: 'Purchase Orders'
	String get purchaseOrders => 'Purchase Orders';

	/// en: 'Transfers'
	String get transfers => 'Transfers';

	/// en: 'Suppliers'
	String get suppliers => 'Suppliers';

	/// en: 'Low Stock'
	String get lowStock => 'Low Stock';

	/// en: 'Out of Stock'
	String get outOfStock => 'Out of Stock';

	/// en: 'In Stock'
	String get inStock => 'In Stock';
}

// Path: customers
class TranslationsCustomersEn {
	TranslationsCustomersEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All Customers'
	String get allCustomers => 'All Customers';

	/// en: 'Add Customer'
	String get addCustomer => 'Add Customer';

	/// en: 'Edit Customer'
	String get editCustomer => 'Edit Customer';

	/// en: 'Loyalty Points'
	String get loyaltyPoints => 'Loyalty Points';

	/// en: 'Total Spent'
	String get totalSpent => 'Total Spent';

	/// en: 'Visits'
	String get visits => 'Visits';
}

// Path: employees
class TranslationsEmployeesEn {
	TranslationsEmployeesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'All Employees'
	String get allEmployees => 'All Employees';

	/// en: 'Add Employee'
	String get addEmployee => 'Add Employee';

	/// en: 'Edit Employee'
	String get editEmployee => 'Edit Employee';

	/// en: 'Role'
	String get role => 'Role';

	/// en: 'PIN'
	String get pin => 'PIN';

	/// en: 'Time Tracking'
	String get timeTracking => 'Time Tracking';

	/// en: 'Clock In'
	String get clockIn => 'Clock In';

	/// en: 'Clock Out'
	String get clockOut => 'Clock Out';
}

// Path: shifts
class TranslationsShiftsEn {
	TranslationsShiftsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Current Shift'
	String get currentShift => 'Current Shift';

	/// en: 'Open Shift'
	String get openShift => 'Open Shift';

	/// en: 'Close Shift'
	String get closeShift => 'Close Shift';

	/// en: 'Opening Cash'
	String get openingCash => 'Opening Cash';

	/// en: 'Closing Cash'
	String get closingCash => 'Closing Cash';

	/// en: 'Expected Cash'
	String get expectedCash => 'Expected Cash';

	/// en: 'Difference'
	String get difference => 'Difference';

	/// en: 'Cash In'
	String get cashIn => 'Cash In';

	/// en: 'Cash Out'
	String get cashOut => 'Cash Out';

	/// en: 'Shift History'
	String get shiftHistory => 'Shift History';
}

// Path: reports
class TranslationsReportsEn {
	TranslationsReportsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sales Summary'
	String get salesSummary => 'Sales Summary';

	/// en: 'Sales by Item'
	String get salesByItem => 'Sales by Item';

	/// en: 'Sales by Category'
	String get salesByCategory => 'Sales by Category';

	/// en: 'Sales by Employee'
	String get salesByEmployee => 'Sales by Employee';

	/// en: 'Sales by Payment Method'
	String get salesByPayment => 'Sales by Payment Method';

	/// en: 'Profit & Loss'
	String get profitAndLoss => 'Profit & Loss';

	/// en: 'Expenses'
	String get expenses => 'Expenses';

	/// en: 'Inventory Report'
	String get inventoryReport => 'Inventory Report';

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'This Week'
	String get thisWeek => 'This Week';

	/// en: 'This Month'
	String get thisMonth => 'This Month';

	/// en: 'Custom Range'
	String get custom => 'Custom Range';
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'General'
	String get general => 'General';

	/// en: 'Store'
	String get store => 'Store';

	/// en: 'Receipt'
	String get receipt => 'Receipt';

	/// en: 'Payment Methods'
	String get payment => 'Payment Methods';

	/// en: 'Taxes'
	String get taxes => 'Taxes';

	/// en: 'Loyalty Program'
	String get loyalty => 'Loyalty Program';

	/// en: 'Currency'
	String get currency => 'Currency';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Dark Mode'
	String get darkMode => 'Dark Mode';

	/// en: 'About'
	String get about => 'About';

	/// en: 'Backup & Sync'
	String get backup => 'Backup & Sync';

	/// en: 'Multi-Currency'
	String get multiCurrency => 'Multi-Currency';

	/// en: 'Exchange Rate'
	String get exchangeRate => 'Exchange Rate';

	/// en: 'Audit Log'
	String get auditLog => 'Audit Log';
}

// Path: currency
class TranslationsCurrencyEn {
	TranslationsCurrencyEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Lao Kip (₭)'
	String get lak => 'Lao Kip (₭)';

	/// en: 'Thai Baht (฿)'
	String get thb => 'Thai Baht (฿)';

	/// en: 'US Dollar (USD)'
	String get usd => 'US Dollar (USD)';
}
