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
	@override late final _TranslationsItemsLo items = _TranslationsItemsLo._(_root);
	@override late final _TranslationsInventoryLo inventory = _TranslationsInventoryLo._(_root);
	@override late final _TranslationsCustomersLo customers = _TranslationsCustomersLo._(_root);
	@override late final _TranslationsEmployeesLo employees = _TranslationsEmployeesLo._(_root);
	@override late final _TranslationsShiftsLo shifts = _TranslationsShiftsLo._(_root);
	@override late final _TranslationsReportsLo reports = _TranslationsReportsLo._(_root);
	@override late final _TranslationsSettingsLo settings = _TranslationsSettingsLo._(_root);
	@override late final _TranslationsCurrencyLo currency = _TranslationsCurrencyLo._(_root);
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
	@override String get profitAndLoss => 'ກຳໄລ-ຂາດທຶນ';
	@override String get expenses => 'ລາຍຈ່າຍ';
	@override String get inventoryReport => 'ລາຍງານສະຕ໊ອກ';
	@override String get today => 'ມື້ນີ້';
	@override String get thisWeek => 'ອາທິດນີ້';
	@override String get thisMonth => 'ເດືອນນີ້';
	@override String get custom => 'ກຳນົດເອງ';
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
