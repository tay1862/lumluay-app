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
	late final TranslationsReceiptsEn receipts = TranslationsReceiptsEn.internal(_root);
	late final TranslationsItemsEn items = TranslationsItemsEn.internal(_root);
	late final TranslationsInventoryEn inventory = TranslationsInventoryEn.internal(_root);
	late final TranslationsProductionEn production = TranslationsProductionEn.internal(_root);
	late final TranslationsCustomersEn customers = TranslationsCustomersEn.internal(_root);
	late final TranslationsEmployeesEn employees = TranslationsEmployeesEn.internal(_root);
	late final TranslationsShiftsEn shifts = TranslationsShiftsEn.internal(_root);
	late final TranslationsReportsEn reports = TranslationsReportsEn.internal(_root);
	late final TranslationsSettingsEn settings = TranslationsSettingsEn.internal(_root);
	late final TranslationsCurrencyEn currency = TranslationsCurrencyEn.internal(_root);
	late final TranslationsRestaurantEn restaurant = TranslationsRestaurantEn.internal(_root);
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

	/// en: 'Tickets'
	String get tickets => 'Tickets';

	/// en: 'Tables'
	String get tables => 'Tables';

	/// en: 'KDS'
	String get kds => 'KDS';
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

	/// en: 'Split Payment'
	String get splitPayment => 'Split Payment';

	/// en: 'Amount Tendered'
	String get amountTendered => 'Amount Tendered';

	/// en: 'Insufficient amount'
	String get insufficientAmount => 'Insufficient amount';

	/// en: 'Payment Method'
	String get paymentMethod => 'Payment Method';
}

// Path: receipts
class TranslationsReceiptsEn {
	TranslationsReceiptsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Receipts'
	String get title => 'Receipts';

	/// en: 'Receipt History'
	String get receiptHistory => 'Receipt History';

	/// en: 'Receipt Detail'
	String get receiptDetail => 'Receipt Detail';

	/// en: 'No receipts found'
	String get noReceipts => 'No receipts found';

	/// en: 'Reprint'
	String get reprint => 'Reprint';

	/// en: 'Email Receipt'
	String get emailReceipt => 'Email Receipt';

	/// en: 'Completed'
	String get completed => 'Completed';

	/// en: 'Voided'
	String get voided => 'Voided';

	/// en: 'Refunded'
	String get refunded => 'Refunded';

	/// en: 'Refund Receipt'
	String get refundReceipt => 'Refund Receipt';

	/// en: 'Refund Reason'
	String get refundReason => 'Refund Reason';

	/// en: 'Enter reason for refund'
	String get refundReasonHint => 'Enter reason for refund';

	/// en: 'Full Refund'
	String get fullRefund => 'Full Refund';

	/// en: 'Partial Refund'
	String get partialRefund => 'Partial Refund';

	/// en: 'Select items to refund'
	String get selectItemsToRefund => 'Select items to refund';

	/// en: 'Refund Amount'
	String get refundAmount => 'Refund Amount';

	/// en: 'Refund processed successfully'
	String get refundProcessed => 'Refund processed successfully';

	/// en: 'Are you sure you want to void this receipt?'
	String get confirmVoid => 'Are you sure you want to void this receipt?';

	/// en: 'Are you sure you want to refund this receipt?'
	String get confirmRefund => 'Are you sure you want to refund this receipt?';

	/// en: '${count} item(s)'
	String items({required Object count}) => '${count} item(s)';

	/// en: 'Paid with'
	String get paidWith => 'Paid with';

	/// en: 'Print Receipt'
	String get printReceipt => 'Print Receipt';

	/// en: 'Share Receipt'
	String get shareReceipt => 'Share Receipt';
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

	/// en: 'Quantity'
	String get quantity => 'Quantity';

	/// en: 'Adjustment'
	String get adjustment => 'Adjustment';

	/// en: 'Reason'
	String get reason => 'Reason';

	/// en: 'Damaged'
	String get damaged => 'Damaged';

	/// en: 'Lost'
	String get lost => 'Lost';

	/// en: 'Correction'
	String get correction => 'Correction';

	/// en: 'Received'
	String get received => 'Received';

	/// en: 'Returned'
	String get returned => 'Returned';

	/// en: 'Other'
	String get other => 'Other';

	/// en: 'Adjustment History'
	String get adjustmentHistory => 'Adjustment History';

	/// en: 'No stock items found'
	String get noStockItems => 'No stock items found';

	/// en: 'Start Count'
	String get startCount => 'Start Count';

	/// en: 'Apply Count'
	String get applyCount => 'Apply Count';

	/// en: 'Expected'
	String get expected => 'Expected';

	/// en: 'Counted'
	String get counted => 'Counted';

	/// en: 'Difference'
	String get difference => 'Difference';

	/// en: 'Inventory count completed'
	String get countCompleted => 'Inventory count completed';

	/// en: 'Threshold'
	String get threshold => 'Threshold';

	/// en: 'Set Low Stock Threshold'
	String get setThreshold => 'Set Low Stock Threshold';

	/// en: 'Inventory Valuation'
	String get valuation => 'Inventory Valuation';

	/// en: 'Total Value'
	String get totalValue => 'Total Value';

	/// en: 'Stock adjustment created'
	String get adjustmentCreated => 'Stock adjustment created';

	/// en: 'Create Purchase Order'
	String get createPO => 'Create Purchase Order';

	/// en: 'Edit Purchase Order'
	String get editPO => 'Edit Purchase Order';

	/// en: 'PO #'
	String get poNumber => 'PO #';

	/// en: 'No purchase orders'
	String get noPurchaseOrders => 'No purchase orders';

	/// en: 'Draft'
	String get draft => 'Draft';

	/// en: 'Ordered'
	String get ordered => 'Ordered';

	/// en: 'Partially Received'
	String get partiallyReceived => 'Partially Received';

	/// en: 'Received'
	String get receivedStatus => 'Received';

	/// en: 'Receive Stock'
	String get receiveStock => 'Receive Stock';

	/// en: 'Received Qty'
	String get receivedQty => 'Received Qty';

	/// en: 'Add Supplier'
	String get addSupplier => 'Add Supplier';

	/// en: 'Edit Supplier'
	String get editSupplier => 'Edit Supplier';

	/// en: 'No suppliers yet'
	String get noSuppliers => 'No suppliers yet';

	/// en: 'Supplier Name'
	String get supplierName => 'Supplier Name';

	/// en: 'Phone'
	String get phone => 'Phone';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Address'
	String get address => 'Address';

	/// en: 'Select Supplier'
	String get selectSupplier => 'Select Supplier';

	/// en: 'Add Items'
	String get addItems => 'Add Items';

	/// en: 'Unit Cost'
	String get unitCost => 'Unit Cost';

	/// en: 'Purchase order created'
	String get poCreated => 'Purchase order created';

	/// en: 'Purchase order updated'
	String get poUpdated => 'Purchase order updated';

	/// en: 'Stock received successfully'
	String get stockReceived => 'Stock received successfully';

	/// en: 'Create Transfer'
	String get createTransfer => 'Create Transfer';

	/// en: 'No transfers yet'
	String get noTransfers => 'No transfers yet';

	/// en: 'From Store'
	String get fromStore => 'From Store';

	/// en: 'To Store'
	String get toStore => 'To Store';

	/// en: 'Pending'
	String get pending => 'Pending';

	/// en: 'In Transit'
	String get inTransit => 'In Transit';

	/// en: 'Transfer created'
	String get transferCreated => 'Transfer created';

	/// en: 'Transfer completed'
	String get transferCompleted => 'Transfer completed';

	/// en: 'Select Items'
	String get selectItems => 'Select Items';
}

// Path: production
class TranslationsProductionEn {
	TranslationsProductionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Production'
	String get title => 'Production';

	/// en: 'Recipes'
	String get recipes => 'Recipes';

	/// en: 'Add Recipe'
	String get addRecipe => 'Add Recipe';

	/// en: 'Edit Recipe'
	String get editRecipe => 'Edit Recipe';

	/// en: 'No recipes yet'
	String get noRecipes => 'No recipes yet';

	/// en: 'Finished Item'
	String get finishedItem => 'Finished Item';

	/// en: 'Select Finished Item'
	String get selectFinishedItem => 'Select Finished Item';

	/// en: 'Output Quantity'
	String get outputQuantity => 'Output Quantity';

	/// en: 'Ingredients'
	String get ingredients => 'Ingredients';

	/// en: 'Add Ingredient'
	String get addIngredient => 'Add Ingredient';

	/// en: 'Select Ingredient'
	String get selectIngredient => 'Select Ingredient';

	/// en: 'Qty Required'
	String get ingredientQty => 'Qty Required';

	/// en: 'Produce'
	String get produce => 'Produce';

	/// en: 'Produce Now'
	String get produceNow => 'Produce Now';

	/// en: 'Batch Quantity'
	String get batchQuantity => 'Batch Quantity';

	/// en: 'Insufficient stock for one or more ingredients'
	String get insufficientStock => 'Insufficient stock for one or more ingredients';

	/// en: 'Production completed'
	String get productionComplete => 'Production completed';

	/// en: 'Recipe created'
	String get recipeCreated => 'Recipe created';

	/// en: 'Recipe updated'
	String get recipeUpdated => 'Recipe updated';

	/// en: 'Recipe deleted'
	String get recipeDeleted => 'Recipe deleted';

	/// en: 'Are you sure you want to delete this recipe?'
	String get confirmDelete => 'Are you sure you want to delete this recipe?';

	/// en: 'Production Log'
	String get productionLog => 'Production Log';

	/// en: 'No production logs'
	String get noLogs => 'No production logs';

	/// en: 'Current Stock'
	String get currentStock => 'Current Stock';

	/// en: 'Required'
	String get required => 'Required';

	/// en: 'Available'
	String get available => 'Available';

	/// en: 'Notes'
	String get notes => 'Notes';
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

	/// en: 'No customers yet'
	String get noCustomers => 'No customers yet';

	/// en: 'Customer Name'
	String get customerName => 'Customer Name';

	/// en: 'Phone'
	String get phone => 'Phone';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Address'
	String get address => 'Address';

	/// en: 'Birthday'
	String get birthday => 'Birthday';

	/// en: 'Notes'
	String get notes => 'Notes';

	/// en: 'Purchase History'
	String get purchaseHistory => 'Purchase History';

	/// en: 'Loyalty Balance'
	String get loyaltyBalance => 'Loyalty Balance';

	/// en: 'Points Earned'
	String get pointsEarned => 'Points Earned';

	/// en: 'Points Redeemed'
	String get pointsRedeemed => 'Points Redeemed';

	/// en: 'Customer created'
	String get customerCreated => 'Customer created';

	/// en: 'Customer updated'
	String get customerUpdated => 'Customer updated';

	/// en: 'Assign Customer'
	String get assignCustomer => 'Assign Customer';
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

	/// en: 'Employee Name'
	String get employeeName => 'Employee Name';

	/// en: 'Select Role'
	String get selectRole => 'Select Role';

	/// en: 'Enter PIN'
	String get enterPin => 'Enter PIN';

	/// en: '4-6 digits'
	String get pinHint => '4-6 digits';

	/// en: 'No Role'
	String get noRole => 'No Role';

	/// en: 'Roles'
	String get roles => 'Roles';

	/// en: 'Add Role'
	String get addRole => 'Add Role';

	/// en: 'Edit Role'
	String get editRole => 'Edit Role';

	/// en: 'Role Name'
	String get roleName => 'Role Name';

	/// en: 'No roles yet'
	String get noRoles => 'No roles yet';

	/// en: 'Employee created'
	String get employeeCreated => 'Employee created';

	/// en: 'Employee updated'
	String get employeeUpdated => 'Employee updated';

	/// en: 'Employee deleted'
	String get employeeDeleted => 'Employee deleted';

	/// en: 'Role created'
	String get roleCreated => 'Role created';

	/// en: 'Role updated'
	String get roleUpdated => 'Role updated';

	/// en: 'Role deleted'
	String get roleDeleted => 'Role deleted';

	/// en: 'Clocked In'
	String get clockedIn => 'Clocked In';

	/// en: 'Clocked Out'
	String get clockedOut => 'Clocked Out';

	/// en: 'Not clocked in'
	String get notClockedIn => 'Not clocked in';

	/// en: 'Time Entries'
	String get timeEntries => 'Time Entries';

	/// en: 'No time entries'
	String get noTimeEntries => 'No time entries';

	/// en: 'Duration'
	String get duration => 'Duration';

	/// en: 'Delete this employee?'
	String get confirmDelete => 'Delete this employee?';
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

	/// en: 'No shift open'
	String get noShift => 'No shift open';

	/// en: 'Shift opened'
	String get shiftOpened => 'Shift opened';

	/// en: 'Shift closed'
	String get shiftClosed => 'Shift closed';

	/// en: 'Cash added'
	String get cashAdded => 'Cash added';

	/// en: 'Cash removed'
	String get cashRemoved => 'Cash removed';

	/// en: 'Reason'
	String get reason => 'Reason';

	/// en: 'Amount'
	String get amount => 'Amount';

	/// en: 'Enter amount'
	String get enterAmount => 'Enter amount';

	/// en: 'A shift is already open'
	String get alreadyOpen => 'A shift is already open';

	/// en: 'Shift Summary'
	String get shiftSummary => 'Shift Summary';

	/// en: 'Total Sales'
	String get totalSales => 'Total Sales';

	/// en: 'Cash Movements'
	String get cashMovements => 'Cash Movements';

	/// en: 'No cash movements'
	String get noMovements => 'No cash movements';
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

	/// en: 'Sales by Hour'
	String get salesByHour => 'Sales by Hour';

	/// en: 'Tax Report'
	String get taxReport => 'Tax Report';

	/// en: 'Discount Report'
	String get discountReport => 'Discount Report';

	/// en: 'Customer Report'
	String get customerReport => 'Customer Report';

	/// en: 'Inventory Report'
	String get inventoryReport => 'Inventory Report';

	/// en: 'Profit & Loss'
	String get profitAndLoss => 'Profit & Loss';

	/// en: 'Expenses'
	String get expenses => 'Expenses';

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'This Week'
	String get thisWeek => 'This Week';

	/// en: 'This Month'
	String get thisMonth => 'This Month';

	/// en: 'Custom Range'
	String get custom => 'Custom Range';

	/// en: 'Revenue'
	String get revenue => 'Revenue';

	/// en: 'Cost of Goods Sold'
	String get cogs => 'Cost of Goods Sold';

	/// en: 'Gross Profit'
	String get grossProfit => 'Gross Profit';

	/// en: 'Net Profit'
	String get netProfit => 'Net Profit';

	/// en: 'Total Discounts'
	String get totalDiscount => 'Total Discounts';

	/// en: 'Avg Discount'
	String get avgDiscount => 'Avg Discount';

	/// en: 'Receipts with Discount'
	String get receiptsWithDiscount => 'Receipts with Discount';

	/// en: 'Tax Collected'
	String get taxCollected => 'Tax Collected';

	/// en: 'Rate'
	String get taxRate => 'Rate';

	/// en: 'Visits'
	String get visits => 'Visits';

	/// en: 'Total Spent'
	String get totalSpent => 'Total Spent';

	/// en: 'Stock Level'
	String get stockLevel => 'Stock Level';

	/// en: 'Stock Value'
	String get stockValue => 'Stock Value';

	/// en: 'Low Stock'
	String get lowStock => 'Low Stock';

	/// en: 'Export'
	String get export => 'Export';

	/// en: 'Export CSV'
	String get exportCsv => 'Export CSV';

	/// en: 'Export PDF'
	String get exportPdf => 'Export PDF';

	/// en: 'Add Expense'
	String get addExpense => 'Add Expense';

	/// en: 'Expense Category'
	String get expenseCategory => 'Expense Category';

	/// en: 'No expenses found'
	String get noExpenses => 'No expenses found';
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

// Path: restaurant
class TranslationsRestaurantEn {
	TranslationsRestaurantEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Open Tickets'
	String get openTickets => 'Open Tickets';

	/// en: 'New Ticket'
	String get newTicket => 'New Ticket';

	/// en: 'No open tickets'
	String get noTickets => 'No open tickets';

	/// en: 'Select or create a ticket'
	String get selectTicket => 'Select or create a ticket';

	/// en: 'Ticket Detail'
	String get ticketDetail => 'Ticket Detail';

	/// en: 'Assign Table'
	String get assignTable => 'Assign Table';

	/// en: 'No Table'
	String get noTable => 'No Table';

	/// en: 'Merge Into This Ticket'
	String get mergeTicket => 'Merge Into This Ticket';

	/// en: 'Charge'
	String get charge => 'Charge';

	/// en: 'Ticket sent to POS'
	String get sentToPOS => 'Ticket sent to POS';

	/// en: 'Add items'
	String get addItems => 'Add items';

	/// en: 'Table Management'
	String get tableManagement => 'Table Management';

	/// en: 'Add Table'
	String get addTable => 'Add Table';

	/// en: 'Edit Table'
	String get editTable => 'Edit Table';

	/// en: 'No tables yet'
	String get noTables => 'No tables yet';

	/// en: 'Add First Table'
	String get addFirstTable => 'Add First Table';

	/// en: 'Table name'
	String get tableName => 'Table name';

	/// en: 'Seats'
	String get seats => 'Seats';

	/// en: 'Zone'
	String get zone => 'Zone';

	/// en: 'Available'
	String get available => 'Available';

	/// en: 'Occupied'
	String get occupied => 'Occupied';

	/// en: 'Reserved'
	String get reserved => 'Reserved';

	/// en: 'Kitchen Display'
	String get kds => 'Kitchen Display';

	/// en: 'Kitchen'
	String get kitchen => 'Kitchen';

	/// en: 'Bar'
	String get bar => 'Bar';

	/// en: 'Dessert'
	String get dessert => 'Dessert';

	/// en: 'All caught up!'
	String get allCaughtUp => 'All caught up!';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Recall'
	String get recall => 'Recall';

	/// en: 'Pending'
	String get pending => 'Pending';

	/// en: 'Preparing'
	String get preparing => 'Preparing';

	/// en: 'Ready'
	String get ready => 'Ready';

	/// en: 'Served'
	String get served => 'Served';
}
