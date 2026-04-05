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
class TranslationsTh extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsTh({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.th,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver);

	/// Metadata for the translations of <th>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	late final TranslationsTh _root = this; // ignore: unused_field

	@override 
	TranslationsTh $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsTh(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppTh app = _TranslationsAppTh._(_root);
	@override late final _TranslationsNavTh nav = _TranslationsNavTh._(_root);
	@override late final _TranslationsCommonTh common = _TranslationsCommonTh._(_root);
	@override late final _TranslationsAuthTh auth = _TranslationsAuthTh._(_root);
	@override late final _TranslationsSalesTh sales = _TranslationsSalesTh._(_root);
	@override late final _TranslationsItemsTh items = _TranslationsItemsTh._(_root);
	@override late final _TranslationsInventoryTh inventory = _TranslationsInventoryTh._(_root);
	@override late final _TranslationsCustomersTh customers = _TranslationsCustomersTh._(_root);
	@override late final _TranslationsEmployeesTh employees = _TranslationsEmployeesTh._(_root);
	@override late final _TranslationsShiftsTh shifts = _TranslationsShiftsTh._(_root);
	@override late final _TranslationsReportsTh reports = _TranslationsReportsTh._(_root);
	@override late final _TranslationsSettingsTh settings = _TranslationsSettingsTh._(_root);
	@override late final _TranslationsCurrencyTh currency = _TranslationsCurrencyTh._(_root);
}

// Path: app
class _TranslationsAppTh extends TranslationsAppEn {
	_TranslationsAppTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get name => 'Lumluay POS';
	@override String get version => 'v0.1.0';
}

// Path: nav
class _TranslationsNavTh extends TranslationsNavEn {
	_TranslationsNavTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get sales => 'ขาย';
	@override String get items => 'สินค้า';
	@override String get inventory => 'คลัง';
	@override String get customers => 'ลูกค้า';
	@override String get employees => 'พนักงาน';
	@override String get shifts => 'กะ';
	@override String get reports => 'รายงาน';
	@override String get settings => 'ตั้งค่า';
}

// Path: common
class _TranslationsCommonTh extends TranslationsCommonEn {
	_TranslationsCommonTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get save => 'บันทึก';
	@override String get cancel => 'ยกเลิก';
	@override String get delete => 'ลบ';
	@override String get edit => 'แก้ไข';
	@override String get add => 'เพิ่ม';
	@override String get search => 'ค้นหา';
	@override String get filter => 'กรอง';
	@override String get sort => 'เรียง';
	@override String get loading => 'กำลังโหลด...';
	@override String get noData => 'ไม่พบข้อมูล';
	@override String get confirm => 'ยืนยัน';
	@override String get back => 'กลับ';
	@override String get next => 'ถัดไป';
	@override String get done => 'เสร็จ';
	@override String get error => 'ข้อผิดพลาด';
	@override String get success => 'สำเร็จ';
	@override String get warning => 'คำเตือน';
	@override String get yes => 'ใช่';
	@override String get no => 'ไม่';
	@override String get ok => 'ตกลง';
	@override String get close => 'ปิด';
	@override String get retry => 'ลองใหม่';
	@override String get total => 'รวม';
	@override String get subtotal => 'รวมย่อย';
	@override String get tax => 'ภาษี';
	@override String get discount => 'ส่วนลด';
	@override String get quantity => 'จำนวน';
	@override String get price => 'ราคา';
	@override String get amount => 'จำนวนเงิน';
	@override String get date => 'วันที่';
	@override String get time => 'เวลา';
	@override String get name => 'ชื่อ';
	@override String get description => 'รายละเอียด';
	@override String get status => 'สถานะ';
	@override String get active => 'เปิดใช้';
	@override String get inactive => 'ปิดใช้';
	@override String get all => 'ทั้งหมด';
}

// Path: auth
class _TranslationsAuthTh extends TranslationsAuthEn {
	_TranslationsAuthTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get enterPin => 'กรุณาใส่รหัส PIN';
	@override String get wrongPin => 'รหัส PIN ไม่ถูก กรุณาลองใหม่';
	@override String get logout => 'ออกจากระบบ';
	@override String get selectEmployee => 'เลือกพนักงาน';
}

// Path: sales
class _TranslationsSalesTh extends TranslationsSalesEn {
	_TranslationsSalesTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get newSale => 'ขายใหม่';
	@override String get charge => 'คิดเงิน';
	@override String get addItem => 'เพิ่มสินค้า';
	@override String get clearCart => 'ล้างตะกร้า';
	@override String get receipt => 'ใบเสร็จ';
	@override String get receiptNumber => 'ใบเสร็จ #';
	@override String get dineIn => 'ทานที่ร้าน';
	@override String get takeaway => 'ห่อกลับ';
	@override String get delivery => 'ส่ง';
	@override String get payNow => 'จ่ายเงิน';
	@override String get cashPayment => 'เงินสด';
	@override String get qrPayment => 'QR Payment';
	@override String get cardPayment => 'บัตร';
	@override String get otherPayment => 'อื่นๆ';
	@override String get changeDue => 'เงินทอน';
	@override String get noItemsInCart => 'ไม่มีสินค้าในตะกร้า';
	@override String get itemAdded => 'เพิ่มสินค้าแล้ว';
	@override String get refund => 'คืนเงิน';
	@override String get voidReceipt => 'ยกเลิกใบเสร็จ';
}

// Path: items
class _TranslationsItemsTh extends TranslationsItemsEn {
	_TranslationsItemsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get allItems => 'สินค้าทั้งหมด';
	@override String get categories => 'หมวดหมู่';
	@override String get addItem => 'เพิ่มสินค้า';
	@override String get editItem => 'แก้ไขสินค้า';
	@override String get itemName => 'ชื่อสินค้า';
	@override String get sku => 'SKU';
	@override String get barcode => 'บาร์โค้ด';
	@override String get cost => 'ต้นทุน';
	@override String get trackStock => 'ติดตามสต๊อก';
	@override String get soldByWeight => 'ขายตามน้ำหนัก';
	@override String get variants => 'ตัวเลือก';
	@override String get modifiers => 'ส่วนเพิ่ม';
	@override String get addCategory => 'เพิ่มหมวดหมู่';
	@override String get editCategory => 'แก้ไขหมวดหมู่';
	@override String get categoryName => 'ชื่อหมวดหมู่';
	@override String get noItems => 'ยังไม่มีสินค้า';
	@override String get noCategories => 'ยังไม่มีหมวดหมู่';
}

// Path: inventory
class _TranslationsInventoryTh extends TranslationsInventoryEn {
	_TranslationsInventoryTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get stockLevels => 'ระดับสต๊อก';
	@override String get adjustStock => 'ปรับสต๊อก';
	@override String get stockCount => 'นับสต๊อก';
	@override String get purchaseOrders => 'ใบสั่งซื้อ';
	@override String get transfers => 'โอนย้าย';
	@override String get suppliers => 'ผู้จัดจำหน่าย';
	@override String get lowStock => 'สต๊อกต่ำ';
	@override String get outOfStock => 'หมดสต๊อก';
	@override String get inStock => 'มีสต๊อก';
}

// Path: customers
class _TranslationsCustomersTh extends TranslationsCustomersEn {
	_TranslationsCustomersTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get allCustomers => 'ลูกค้าทั้งหมด';
	@override String get addCustomer => 'เพิ่มลูกค้า';
	@override String get editCustomer => 'แก้ไขลูกค้า';
	@override String get loyaltyPoints => 'คะแนนสะสม';
	@override String get totalSpent => 'ใช้จ่ายทั้งหมด';
	@override String get visits => 'เข้าใช้';
}

// Path: employees
class _TranslationsEmployeesTh extends TranslationsEmployeesEn {
	_TranslationsEmployeesTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get allEmployees => 'พนักงานทั้งหมด';
	@override String get addEmployee => 'เพิ่มพนักงาน';
	@override String get editEmployee => 'แก้ไขพนักงาน';
	@override String get role => 'บทบาท';
	@override String get pin => 'รหัส PIN';
	@override String get timeTracking => 'บันทึกเวลา';
	@override String get clockIn => 'เข้างาน';
	@override String get clockOut => 'ออกงาน';
}

// Path: shifts
class _TranslationsShiftsTh extends TranslationsShiftsEn {
	_TranslationsShiftsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get currentShift => 'กะปัจจุบัน';
	@override String get openShift => 'เปิดกะ';
	@override String get closeShift => 'ปิดกะ';
	@override String get openingCash => 'เงินเปิดกะ';
	@override String get closingCash => 'เงินปิดกะ';
	@override String get expectedCash => 'เงินที่คาด';
	@override String get difference => 'ส่วนต่าง';
	@override String get cashIn => 'เงินเข้า';
	@override String get cashOut => 'เงินออก';
	@override String get shiftHistory => 'ประวัติกะ';
}

// Path: reports
class _TranslationsReportsTh extends TranslationsReportsEn {
	_TranslationsReportsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get salesSummary => 'สรุปการขาย';
	@override String get salesByItem => 'ขายตามสินค้า';
	@override String get salesByCategory => 'ขายตามหมวดหมู่';
	@override String get salesByEmployee => 'ขายตามพนักงาน';
	@override String get salesByPayment => 'ขายตามการจ่าย';
	@override String get profitAndLoss => 'กำไร-ขาดทุน';
	@override String get expenses => 'รายจ่าย';
	@override String get inventoryReport => 'รายงานสต๊อก';
	@override String get today => 'วันนี้';
	@override String get thisWeek => 'สัปดาห์นี้';
	@override String get thisMonth => 'เดือนนี้';
	@override String get custom => 'กำหนดเอง';
}

// Path: settings
class _TranslationsSettingsTh extends TranslationsSettingsEn {
	_TranslationsSettingsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get general => 'ทั่วไป';
	@override String get store => 'ร้าน';
	@override String get receipt => 'ใบเสร็จ';
	@override String get payment => 'วิธีจ่าย';
	@override String get taxes => 'ภาษี';
	@override String get loyalty => 'สะสมแต้ม';
	@override String get currency => 'สกุลเงิน';
	@override String get language => 'ภาษา';
	@override String get darkMode => 'โหมดมืด';
	@override String get about => 'เกี่ยวกับ';
	@override String get backup => 'สำรอง & ซิงค์';
	@override String get multiCurrency => 'หลายสกุลเงิน';
	@override String get exchangeRate => 'อัตราแลกเปลี่ยน';
	@override String get auditLog => 'บันทึกกิจกรรม';
}

// Path: currency
class _TranslationsCurrencyTh extends TranslationsCurrencyEn {
	_TranslationsCurrencyTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get lak => 'กีบลาว (₭)';
	@override String get thb => 'บาทไทย (฿)';
	@override String get usd => 'ดอลลาร์ (USD)';
}
