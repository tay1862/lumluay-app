///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsLo extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsLo({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.lo,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <lo>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final TranslationsLo _root = this; // ignore: unused_field

	@override 
	TranslationsLo $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsLo(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppLo app = _TranslationsAppLo._(_root);
	@override late final _TranslationsNavLo nav = _TranslationsNavLo._(_root);
	@override late final _TranslationsCommonLo common = _TranslationsCommonLo._(_root);
	@override late final _TranslationsAuthLo auth = _TranslationsAuthLo._(_root);
	@override late final _TranslationsSalesLo sales = _TranslationsSalesLo._(_root);
	@override late final _TranslationsReceiptsLo receipts = _TranslationsReceiptsLo._(_root);
	@override late final _TranslationsItemsLo items = _TranslationsItemsLo._(_root);
	@override late final _TranslationsInventoryLo inventory = _TranslationsInventoryLo._(_root);
	@override late final _TranslationsProductionLo production = _TranslationsProductionLo._(_root);
	@override late final _TranslationsCustomersLo customers = _TranslationsCustomersLo._(_root);
	@override late final _TranslationsEmployeesLo employees = _TranslationsEmployeesLo._(_root);
	@override late final _TranslationsShiftsLo shifts = _TranslationsShiftsLo._(_root);
	@override late final _TranslationsReportsLo reports = _TranslationsReportsLo._(_root);
	@override late final _TranslationsSettingsLo settings = _TranslationsSettingsLo._(_root);
	@override late final _TranslationsCurrencyLo currency = _TranslationsCurrencyLo._(_root);
	@override late final _TranslationsRestaurantLo restaurant = _TranslationsRestaurantLo._(_root);
}

// Path: app
class _TranslationsAppLo extends TranslationsAppEn {
	_TranslationsAppLo._(TranslationsLo root) : this._root = root, super.internal(root);

	final TranslationsLo _root; // ignore: unused_field

	// Translations
	@override String get name => 'ລຸ້ມລວຍ POS';
	@override String get version => 'v0.1.0';
}

// Path: nav
class _TranslationsNavLo extends TranslationsNavEn {
	_TranslationsNavLo._(TranslationsLo root) : this._root = root, super.internal(root);

	final TranslationsLo _root; // ignore: unused_field

	// Translations
	@override String get sales => 'ຂາຍ';
	@override String get items => 'ສິນຄ້າ';
	@override String get inventory => 'ສາງ';
	@override String get customers => 'ລູກຄ້າ';
	@override String get employees => 'ພະນັກງານ';
	@override String get shifts => 'ກະ';
	@override String get reports => 'ລາຍງານ';
	@override String get settings => 'ຕັ້ງຄ່າ';
	@override String get tickets => 'ປີ້';
	@override String get tables => 'ໂຕະ';
	@override String get kds => 'KDS';
}

// Path: common
class _TranslationsCommonLo extends TranslationsCommonEn {
	_TranslationsCommonLo._(TranslationsLo root) : this._root = root, super.internal(root);

	final TranslationsLo _root; // ignore: unused_field

	// Translations
	@override String get save => 'ບັນທຶກ';
	@override String get cancel => 'ຍົກເລີກ';
	@override String get delete => 'ລົບ';
	@override String get edit => 'ແກ້ໄຂ';
	@override String get add => 'ເພີ່ມ';
	@override String get search => 'ຄົ້ນຫາ';
	@override String get filter => 'ກັ່ນຕອງ';
	@override String get sort => 'ຈັດລຽງ';
	@override String get loading => 'ກຳລັງໂຫລດ...';
	@override String get noData => 'ບໍ່ພົບຂໍ້ມູນ';
	@override String get confirm => 'ຢືນຢັນ';
	@override String get back => 'ກັບຄືນ';
	@override String get next => 'ຕໍ່ໄປ';
	@override String get done => 'ສຳເລັດ';
	@override String get error => 'ຜິດພາດ';
	@override String get success => 'ສຳເລັດ';
	@override String get warning => 'ເຕືອນ';
	@override String get yes => 'ແມ່ນ';
	@override String get no => 'ບໍ່';
	@override String get ok => 'ຕົກລົງ';
	@override String get close => 'ປິດ';
	@override String get retry => 'ລອງໃໝ່';
	@override String get total => 'ລວມ';
	@override String get subtotal => 'ລວມຍ່ອຍ';
	@override String get tax => 'ພາສີ';
	@override String get discount => 'ສ່ວນຫຼຸດ';
	@override String get quantity => 'ຈຳນວນ';
	@override String get price => 'ລາຄາ';
	@override String get amount => 'ຈຳນວນເງິນ';
	@override String get date => 'ວັນທີ';
	@override String get time => 'ເວລາ';
	@override String get name => 'ຊື່';
	@override String get description => 'ລາຍລະອຽດ';
	@override String get status => 'ສະຖານະ';
	@override String get active => 'ເປີດໃຊ້';
	@override String get inactive => 'ປິດໃຊ້';
	@override String get all => 'ທັງໝົດ';
}

// Path: auth
class _TranslationsAuthLo extends TranslationsAuthEn {
	_TranslationsAuthLo._(TranslationsLo root) : this._root = root, super.internal(root);

	final TranslationsLo _root; // ignore: unused_field

	// Translations
	@override String get enterPin => 'ກະລຸນາໃສ່ລະຫັດ PIN';
	@override String get wrongPin => 'ລະຫັດ PIN ບໍ່ຖືກ, ກະລຸນາລອງໃໝ່';
	@override String get logout => 'ອອກຈາກລະບົບ';
	@override String get selectEmployee => 'ເລືອກພະນັກງານ';
}

// Path: sales
class _TranslationsSalesLo extends TranslationsSalesEn {
	_TranslationsSalesLo._(TranslationsLo root) : this._root = root, super.internal(root);

	final TranslationsLo _root; // ignore: unused_field

	// Translations
	@override String get newSale => 'ຂາຍໃໝ່';
	@override String get charge => 'ຄິດເງິນ';
	@override String get addItem => 'ເພີ່ມສິນຄ້າ';
	@override String get clearCart => 'ລ້າງຕະກ້າ';
	@override String get receipt => 'ໃບບິນ';
	@override String get receiptNumber => 'ໃບບິນ #';
	@override String get dineIn => 'ທານທີ່ຮ້ານ';
	@override String get takeaway => 'ຫໍ່ກັບ';
	@override String get delivery => 'ສົ່ງ';
	@override String get payNow => 'ຈ່າຍເງິນ';
	@override String get cashPayment => 'ເງິນສົດ';
	@override String get qrPayment => 'QR Payment';
	@override String get cardPayment => 'ບັດ';
	@override String get otherPayment => 'ອື່ນໆ';
	@override String get changeDue => 'ເງິນທອນ';
	@override String get noItemsInCart => 'ບໍ່ມີສິນຄ້າໃນຕະກ້າ';
	@override String get itemAdded => 'ເພີ່ມສິນຄ້າແລ້ວ';
	@override String get refund => 'ຄືນເງິນ';
	@override String get voidReceipt => 'ຍົກເລີກໃບບິນ';
	@override String get splitPayment => 'ແບ່ງຈ່າຍ';
	@override String get amountTendered => 'ຈຳນວນທີ່ຈ່າຍ';
	@override String get insufficientAmount => 'ຈຳນວນເງິນບໍ່ພໍ';
	@override String get paymentMethod => 'ວິທີຈ່າຍ';
}

// Path: receipts
class _TranslationsReceiptsLo extends TranslationsReceiptsEn {
	_TranslationsReceiptsLo._(TranslationsLo root) : this._root = root, super.internal(root);

	final TranslationsLo _root; // ignore: unused_field

	// Translations
	@override String get title => 'ໃບບິນ';
	@override String get receiptHistory => 'ປະຫວັດໃບບິນ';
	@override String get receiptDetail => 'ລາຍລະອຽດໃບບິນ';
	@override String get noReceipts => 'ບໍ່ພົບໃບບິນ';
	@override String get reprint => 'ພິມໃໝ່';
	@override String get emailReceipt => 'ສົ່ງທາງອີເມວ';
	@override String get completed => 'ສຳເລັດ';
	@override String get voided => 'ຍົກເລີກ';
	@override String get refunded => 'ຄືນເງິນແລ້ວ';
	@override String get refundReceipt => 'ຄືນເງິນໃບບິນ';
	@override String get refundReason => 'ເຫດຜົນຄືນເງິນ';
	@override String get refundReasonHint => 'ກະລຸນາລະບຸເຫດຜົນ';
	@override String get fullRefund => 'ຄືນເງິນທັງໝົດ';
	@override String get partialRefund => 'ຄືນເງິນບາງສ່ວນ';
	@override String get selectItemsToRefund => 'ເລືອກສິນຄ້າທີ່ຕ້ອງການຄືນ';
	@override String get refundAmount => 'ຈຳນວນເງິນຄືນ';
	@override String get refundProcessed => 'ຄືນເງິນສຳເລັດ';
	@override String get confirmVoid => 'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການຍົກເລີກໃບບິນນີ້?';
	@override String get confirmRefund => 'ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການຄືນເງິນໃບບິນນີ້?';
	@override String items({required Object count}) => '${count} ລາຍການ';
	@override String get paidWith => 'ຈ່າຍດ້ວຍ';
	@override String get printReceipt => 'ພິມໃບບິນ';
	@override String get shareReceipt => 'ແບ່ງປັນໃບບິນ';
}

// Path: items
class _TranslationsItemsLo extends TranslationsItemsEn {
	_TranslationsItemsLo._(TranslationsLo root) : this._root = root, super.internal(root);

	final TranslationsLo _root; // ignore: unused_field

	// Translations
	@override String get allItems => 'ສິນຄ້າທັງໝົດ';
	@override String get categories => 'ໝວດໝູ່';
	@override String get addItem => 'ເພີ່ມສິນຄ້າ';
	@override String get editItem => 'ແກ້ໄຂສິນຄ້າ';
	@override String get itemName => 'ຊື່ສິນຄ້າ';
	@override String get sku => 'SKU';
	@override String get barcode => 'ບາໂຄ້ດ';
	@override String get cost => 'ຕົ້ນທຶນ';
	@override String get trackStock => 'ຕິດຕາມສະຕ໊ອກ';
	@override String get soldByWeight => 'ຂາຍຕາມນ້ຳໜັກ';
	@override String get variants => 'ຕົວເລືອກ';
	@override String get modifiers => 'ສ່ວນເພີ່ມ';
	@override String get addCategory => 'ເພີ່ມໝວດໝູ່';
	@override String get editCategory => 'ແກ້ໄຂໝວດໝູ່';
	@override String get categoryName => 'ຊື່ໝວດໝູ່';
	@override String get noItems => 'ຍັງບໍ່ມີສິນຄ້າ';
	@override String get noCategories => 'ຍັງບໍ່ມີໝວດໝູ່';
}

// Path: inventory
class _TranslationsInventoryLo extends TranslationsInventoryEn {
	_TranslationsInventoryLo._(TranslationsLo root) : this._root = root, super.internal(root);

	final TranslationsLo _root; // ignore: unused_field

	// Translations
	@override String get stockLevels => 'ລະດັບສະຕ໊ອກ';
	@override String get adjustStock => 'ປັບສະຕ໊ອກ';
	@override String get stockCount => 'ນັບສະຕ໊ອກ';
	@override String get purchaseOrders => 'ໃບສັ່ງຊື້';
	@override String get transfers => 'ໂອນຍ້າຍ';
	@override String get suppliers => 'ຜູ້ສະໜອງ';
	@override String get lowStock => 'ສະຕ໊ອກຕ່ຳ';
	@override String get outOfStock => 'ໝົດສະຕ໊ອກ';
	@override String get inStock => 'ມີສະຕ໊ອກ';
	@override String get quantity => 'ຈຳນວນ';
	@override String get adjustment => 'ການປັບ';
	@override String get reason => 'ເຫດຜົນ';
	@override String get damaged => 'ເສຍຫາຍ';
	@override String get lost => 'ສູນເສຍ';
	@override String get correction => 'ແກ້ໄຂ';
	@override String get received => 'ຮັບເຂົ້າ';
	@override String get returned => 'ສົ່ງຄືນ';
	@override String get other => 'ອື່ນໆ';
	@override String get adjustmentHistory => 'ປະຫວັດການປັບ';
	@override String get noStockItems => 'ບໍ່ພົບລາຍການສະຕ໊ອກ';
	@override String get startCount => 'ເລີ່ມນັບ';
	@override String get applyCount => 'ນຳໃຊ້ການນັບ';
	@override String get expected => 'ຄາດໝາຍ';
	@override String get counted => 'ນັບໄດ້';
	@override String get difference => 'ຜິດແຜກ';
	@override String get countCompleted => 'ນັບສະຕ໊ອກສຳເລັດ';
	@override String get threshold => 'ເກນແຈ້ງເຕືອນ';
	@override String get setThreshold => 'ຕັ້ງເກນສະຕ໊ອກຕ່ຳ';
	@override String get valuation => 'ມູນຄ່າສະຕ໊ອກ';
	@override String get totalValue => 'ມູນຄ່າລວມ';
	@override String get adjustmentCreated => 'ປັບສະຕ໊ອກສຳເລັດ';
	@override String get createPO => 'ສ້າງໃບສັ່ງຊື້';
	@override String get editPO => 'ແກ້ໄຂໃບສັ່ງຊື້';
	@override String get poNumber => 'ໃບສັ່ງຊື້ #';
	@override String get noPurchaseOrders => 'ບໍ່ມີໃບສັ່ງຊື້';
	@override String get draft => 'ຮ່າງ';
	@override String get ordered => 'ສັ່ງແລ້ວ';
	@override String get partiallyReceived => 'ຮັບບາງສ່ວນ';
	@override String get receivedStatus => 'ຮັບແລ້ວ';
	@override String get receiveStock => 'ຮັບສິນຄ້າ';
	@override String get receivedQty => 'ຈຳນວນທີ່ຮັບ';
	@override String get addSupplier => 'ເພີ່ມຜູ້ສະໜອງ';
	@override String get editSupplier => 'ແກ້ໄຂຜູ້ສະໜອງ';
	@override String get noSuppliers => 'ບໍ່ມີຜູ້ສະໜອງ';
	@override String get supplierName => 'ຊື່ຜູ້ສະໜອງ';
	@override String get phone => 'ໂທລະສັບ';
	@override String get email => 'ອີເມວ';
	@override String get address => 'ທີ່ຢູ່';
	@override String get selectSupplier => 'ເລືອກຜູ້ສະໜອງ';
	@override String get addItems => 'ເພີ່ມລາຍການ';
	@override String get unitCost => 'ລາຄາຕໍ່ໜ່ວຍ';
	@override String get poCreated => 'ສ້າງໃບສັ່ງຊື້ສຳເລັດ';
	@override String get poUpdated => 'ແກ້ໄຂໃບສັ່ງຊື້ສຳເລັດ';
	@override String get stockReceived => 'ຮັບສິນຄ້າສຳເລັດ';
	@override String get createTransfer => 'ສ້າງການໂອນ';
	@override String get noTransfers => 'ບໍ່ມີການໂອນ';
	@override String get fromStore => 'ຈາກຮ້ານ';
	@override String get toStore => 'ໄປຮ້ານ';
	@override String get pending => 'ລໍຖ້າ';
	@override String get inTransit => 'ກຳລັງສົ່ງ';
	@override String get transferCreated => 'ສ້າງການໂອນສຳເລັດ';
	@override String get transferCompleted => 'ໂອນສຳເລັດ';
	@override String get selectItems => 'ເລືອກລາຍການ';
}

// Path: production
class _TranslationsProductionLo extends TranslationsProductionEn {
	_TranslationsProductionLo._(TranslationsLo root) : this._root = root, super.internal(root);

	final TranslationsLo _root; // ignore: unused_field

	// Translations
	@override String get title => 'ການຜະລິດ';
	@override String get recipes => 'ສູດ';
	@override String get addRecipe => 'ເພີ່ມສູດ';
	@override String get editRecipe => 'ແກ້ໄຂສູດ';
	@override String get noRecipes => 'ຍັງບໍ່ມີສູດ';
	@override String get finishedItem => 'ສິນຄ້າສຳເລັດ';
	@override String get selectFinishedItem => 'ເລືອກສິນຄ້າສຳເລັດ';
	@override String get outputQuantity => 'ຈຳນວນຜົນຜະລິດ';
	@override String get ingredients => 'ວັດຖຸດິບ';
	@override String get addIngredient => 'ເພີ່ມວັດຖຸດິບ';
	@override String get selectIngredient => 'ເລືອກວັດຖຸດິບ';
	@override String get ingredientQty => 'ຈຳນວນທີ່ຕ້ອງການ';
	@override String get produce => 'ຜະລິດ';
	@override String get produceNow => 'ຜະລິດດຽວນີ້';
	@override String get batchQuantity => 'ຈຳນວນຊຸດ';
	@override String get insufficientStock => 'ວັດຖຸດິບບໍ່ພຽງພໍ';
	@override String get productionComplete => 'ການຜະລິດສຳເລັດ';
	@override String get recipeCreated => 'ສ້າງສູດສຳເລັດ';
	@override String get recipeUpdated => 'ແກ້ໄຂສູດສຳເລັດ';
	@override String get recipeDeleted => 'ລົບສູດສຳເລັດ';
	@override String get confirmDelete => 'ທ່ານແນ່ໃຈຫຼືບໍ່ວ່າຕ້ອງການລົບສູດນີ້?';
	@override String get productionLog => 'ບັນທຶກການຜະລິດ';
	@override String get noLogs => 'ຍັງບໍ່ມີບັນທຶກການຜະລິດ';
	@override String get currentStock => 'ສາງປັດຈຸບັນ';
	@override String get required => 'ຕ້ອງການ';
	@override String get available => 'ມີຢູ່';
	@override String get notes => 'ໝາຍເຫດ';
}

// Path: customers
class _TranslationsCustomersLo extends TranslationsCustomersEn {
	_TranslationsCustomersLo._(TranslationsLo root) : this._root = root, super.internal(root);

	final TranslationsLo _root; // ignore: unused_field

	// Translations
	@override String get allCustomers => 'ລູກຄ້າທັງໝົດ';
	@override String get addCustomer => 'ເພີ່ມລູກຄ້າ';
	@override String get editCustomer => 'ແກ້ໄຂລູກຄ້າ';
	@override String get loyaltyPoints => 'ຄະແນນສະສົມ';
	@override String get totalSpent => 'ໃຊ້ຈ່າຍທັງໝົດ';
	@override String get visits => 'ເຂົ້າໃຊ້';
	@override String get noCustomers => 'ບໍ່ມີລູກຄ້າ';
	@override String get customerName => 'ຊື່ລູກຄ້າ';
	@override String get phone => 'ໂທລະສັບ';
	@override String get email => 'ອີເມວ';
	@override String get address => 'ທີ່ຢູ່';
	@override String get birthday => 'ວັນເກີດ';
	@override String get notes => 'ບັນທຶກ';
	@override String get purchaseHistory => 'ປະຫວັດການຊື້';
	@override String get loyaltyBalance => 'ຄະແນນຄົງເຫຼືອ';
	@override String get pointsEarned => 'ຄະແນນທີ່ໄດ້';
	@override String get pointsRedeemed => 'ຄະແນນທີ່ໃຊ້';
	@override String get customerCreated => 'ເພີ່ມລູກຄ້າສຳເລັດ';
	@override String get customerUpdated => 'ແກ້ໄຂລູກຄ້າສຳເລັດ';
	@override String get assignCustomer => 'ເລືອກລູກຄ້າ';
}

// Path: employees
class _TranslationsEmployeesLo extends TranslationsEmployeesEn {
	_TranslationsEmployeesLo._(TranslationsLo root) : this._root = root, super.internal(root);

	final TranslationsLo _root; // ignore: unused_field

	// Translations
	@override String get allEmployees => 'ພະນັກງານທັງໝົດ';
	@override String get addEmployee => 'ເພີ່ມພະນັກງານ';
	@override String get editEmployee => 'ແກ້ໄຂພະນັກງານ';
	@override String get role => 'ບົດບາດ';
	@override String get pin => 'ລະຫັດ PIN';
	@override String get timeTracking => 'ບັນທຶກເວລາ';
	@override String get clockIn => 'ເຂົ້າວຽກ';
	@override String get clockOut => 'ອອກວຽກ';
	@override String get employeeName => 'ຊື່ພະນັກງານ';
	@override String get selectRole => 'ເລືອກບົດບາດ';
	@override String get enterPin => 'ໃສ່ລະຫັດ PIN';
	@override String get pinHint => '4-6 ຕົວເລກ';
	@override String get noRole => 'ບໍ່ມີບົດບາດ';
	@override String get roles => 'ບົດບາດ';
	@override String get addRole => 'ເພີ່ມບົດບາດ';
	@override String get editRole => 'ແກ້ໄຂບົດບາດ';
	@override String get roleName => 'ຊື່ບົດບາດ';
	@override String get noRoles => 'ຍັງບໍ່ມີບົດບາດ';
	@override String get employeeCreated => 'ສ້າງພະນັກງານແລ້ວ';
	@override String get employeeUpdated => 'ອັບເດດພະນັກງານແລ້ວ';
	@override String get employeeDeleted => 'ລົບພะນັກງານແລ້ວ';
	@override String get roleCreated => 'ສ້າງບົດບາດແລ້ວ';
	@override String get roleUpdated => 'ອັບເດດບົດບາດແລ້ວ';
	@override String get roleDeleted => 'ລົບບົດບາດແລ້ວ';
	@override String get clockedIn => 'ເຂົ້າວຽກແລ້ວ';
	@override String get clockedOut => 'ອອກວຽກແລ້ວ';
	@override String get notClockedIn => 'ຍັງບໍ່ໄດ້ເຂົ້າວຽກ';
	@override String get timeEntries => 'ບັນທຶກເວລາ';
	@override String get noTimeEntries => 'ບໍ່ມີບັນທຶກເວລາ';
	@override String get duration => 'ໄລຍະເວລາ';
	@override String get confirmDelete => 'ລົບພະນັກງານນີ້?';
}

// Path: shifts
class _TranslationsShiftsLo extends TranslationsShiftsEn {
	_TranslationsShiftsLo._(TranslationsLo root) : this._root = root, super.internal(root);

	final TranslationsLo _root; // ignore: unused_field

	// Translations
	@override String get currentShift => 'ກະປັດຈຸບັນ';
	@override String get openShift => 'ເປີດກະ';
	@override String get closeShift => 'ປິດກະ';
	@override String get openingCash => 'ເງິນເປີດກະ';
	@override String get closingCash => 'ເງິນປິດກະ';
	@override String get expectedCash => 'ເງິນທີ່ຄາດ';
	@override String get difference => 'ຜິດແຜກ';
	@override String get cashIn => 'ເງິນເຂົ້າ';
	@override String get cashOut => 'ເງິນອອກ';
	@override String get shiftHistory => 'ປະຫວັດກະ';
	@override String get noShift => 'ບໍ່ມີກະເປີດ';
	@override String get shiftOpened => 'ເປີດກະແລ້ວ';
	@override String get shiftClosed => 'ປິດກະແລ້ວ';
	@override String get cashAdded => 'ເພີ່ມເງິນແລ້ວ';
	@override String get cashRemoved => 'ຖອນເງິນແລ້ວ';
	@override String get reason => 'ເຫດຜົນ';
	@override String get amount => 'ຈໍານວນ';
	@override String get enterAmount => 'ໃສ່ຈໍານວນ';
	@override String get alreadyOpen => 'ມີກະເປີດຢູ່ແລ້ວ';
	@override String get shiftSummary => 'ສະຫຼຸບກະ';
	@override String get totalSales => 'ຍອດຂາຍທັງໝົດ';
	@override String get cashMovements => 'ການເຄື່ອນຍ້າຍເງິນ';
	@override String get noMovements => 'ບໍ່ມີການເຄື່ອນຍ້າຍເງິນ';
}

// Path: reports
class _TranslationsReportsLo extends TranslationsReportsEn {
	_TranslationsReportsLo._(TranslationsLo root) : this._root = root, super.internal(root);

	final TranslationsLo _root; // ignore: unused_field

	// Translations
	@override String get salesSummary => 'ສະຫຼຸບການຂາຍ';
	@override String get salesByItem => 'ຂາຍຕາມສິນຄ້າ';
	@override String get salesByCategory => 'ຂາຍຕາມໝວດໝູ່';
	@override String get salesByEmployee => 'ຂາຍຕາມພະນັກງານ';
	@override String get salesByPayment => 'ຂາຍຕາມການຈ່າຍ';
	@override String get salesByHour => 'ຂາຍຕາມຊົ່ວໂມງ';
	@override String get taxReport => 'ລາຍງານພາສີ';
	@override String get discountReport => 'ລາຍງານສ່ວນຫຼຸດ';
	@override String get customerReport => 'ລາຍງານລູກຄ້າ';
	@override String get inventoryReport => 'ລາຍງານສິນຄ້າ';
	@override String get profitAndLoss => 'ກຳໄລ & ຂາດທຶນ';
	@override String get expenses => 'ລາຍຈ່າຍ';
	@override String get today => 'ມື້ນີ້';
	@override String get thisWeek => 'ອາທິດນີ້';
	@override String get thisMonth => 'ເດືອນນີ້';
	@override String get custom => 'ກຳນົດເວລາ';
	@override String get revenue => 'ລາຍຮັບ';
	@override String get cogs => 'ຕົ້ນທຶນສິນຄ້າ';
	@override String get grossProfit => 'ກຳໄລລວມ';
	@override String get netProfit => 'ກຳໄລສຸດທິ';
	@override String get totalDiscount => 'ລວມສ່ວນຫຼຸດ';
	@override String get avgDiscount => 'ສ່ວນຫຼຸດສະເລ່ຍ';
	@override String get receiptsWithDiscount => 'ບິນທີ່ມີສ່ວນຫຼຸດ';
	@override String get taxCollected => 'ພາສີທີ່ເກັບ';
	@override String get taxRate => 'ອັດຕາ';
	@override String get visits => 'ຈຳນວນຄັ້ງ';
	@override String get totalSpent => 'ໃຊ້ຈ່າຍທັງໝົດ';
	@override String get stockLevel => 'ລະດັບສະຕ໋ອກ';
	@override String get stockValue => 'ມູນຄ່າສະຕ໋ອກ';
	@override String get lowStock => 'ສະຕ໋ອກຕ່ຳ';
	@override String get export => 'ສົ່ງອອກ';
	@override String get exportCsv => 'ສົ່ງອອກ CSV';
	@override String get exportPdf => 'ສົ່ງອອກ PDF';
	@override String get addExpense => 'ເພີ່ມລາຍຈ່າຍ';
	@override String get expenseCategory => 'ໝວດລາຍຈ່າຍ';
	@override String get noExpenses => 'ບໍ່ມີລາຍຈ່າຍ';
}

// Path: settings
class _TranslationsSettingsLo extends TranslationsSettingsEn {
	_TranslationsSettingsLo._(TranslationsLo root) : this._root = root, super.internal(root);

	final TranslationsLo _root; // ignore: unused_field

	// Translations
	@override String get general => 'ທົ່ວໄປ';
	@override String get store => 'ຮ້ານ';
	@override String get receipt => 'ໃບບິນ';
	@override String get payment => 'ວິທີຈ່າຍ';
	@override String get taxes => 'ພາສີ';
	@override String get loyalty => 'ສະສົມແຕ້ມ';
	@override String get currency => 'ສະກຸນເງິນ';
	@override String get language => 'ພາສາ';
	@override String get darkMode => 'ໂໝດມືດ';
	@override String get about => 'ກ່ຽວກັບ';
	@override String get backup => 'ສຳຮອງ & ຊິ້ງ';
	@override String get multiCurrency => 'ຫຼາຍສະກຸນເງິນ';
	@override String get exchangeRate => 'ອັດຕາແລກປ່ຽນ';
	@override String get auditLog => 'ບັນທຶກກິດຈະກຳ';
}

// Path: currency
class _TranslationsCurrencyLo extends TranslationsCurrencyEn {
	_TranslationsCurrencyLo._(TranslationsLo root) : this._root = root, super.internal(root);

	final TranslationsLo _root; // ignore: unused_field

	// Translations
	@override String get lak => 'ກີບລາວ (₭)';
	@override String get thb => 'ບາດໄທ (฿)';
	@override String get usd => 'ໂດລາ (USD)';
}

// Path: restaurant
class _TranslationsRestaurantLo extends TranslationsRestaurantEn {
	_TranslationsRestaurantLo._(TranslationsLo root) : this._root = root, super.internal(root);

	final TranslationsLo _root; // ignore: unused_field

	// Translations
	@override String get openTickets => 'ປີ້ທີ່ເປີດ';
	@override String get newTicket => 'ປີ້ໃໝ່';
	@override String get noTickets => 'ບໍ່ມີປີ້ເປີດ';
	@override String get selectTicket => 'ເລືອກ ຫຼື ສ້າງປີ້';
	@override String get ticketDetail => 'ລາຍລະອຽດປີ້';
	@override String get assignTable => 'ກຳນົດໂຕະ';
	@override String get noTable => 'ບໍ່ມີໂຕະ';
	@override String get mergeTicket => 'ລວມເຂົ້າປີ້ນີ້';
	@override String get charge => 'ຄິດເງິນ';
	@override String get sentToPOS => 'ສົ່ງໄປ POS ແລ້ວ';
	@override String get addItems => 'ເພີ່ມລາຍການ';
	@override String get tableManagement => 'ຈັດການໂຕະ';
	@override String get addTable => 'ເພີ່ມໂຕະ';
	@override String get editTable => 'ແກ້ໄຂໂຕະ';
	@override String get noTables => 'ຍັງບໍ່ມີໂຕະ';
	@override String get addFirstTable => 'ເພີ່ມໂຕະທຳອິດ';
	@override String get tableName => 'ຊື່ໂຕະ';
	@override String get seats => 'ບ່ອນນັ່ງ';
	@override String get zone => 'ໂຊນ';
	@override String get available => 'ວ່າງ';
	@override String get occupied => 'ມີຄົນ';
	@override String get reserved => 'ຈອງແລ້ວ';
	@override String get kds => 'ຈໍສະແດງຄົວ';
	@override String get kitchen => 'ຄົວ';
	@override String get bar => 'ບາ';
	@override String get dessert => 'ຂອງຫວານ';
	@override String get allCaughtUp => 'ສຳເລັດໝົດແລ້ວ!';
	@override String get done => 'ສຳເລັດ';
	@override String get recall => 'ເອີ້ນຄືນ';
	@override String get pending => 'ລໍຖ້າ';
	@override String get preparing => 'ກຳລັງກະກຽມ';
	@override String get ready => 'ພ້ອມ';
	@override String get served => 'ເສີບແລ້ວ';
}
