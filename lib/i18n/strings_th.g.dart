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
	@override late final _TranslationsReceiptsTh receipts = _TranslationsReceiptsTh._(_root);
	@override late final _TranslationsItemsTh items = _TranslationsItemsTh._(_root);
	@override late final _TranslationsInventoryTh inventory = _TranslationsInventoryTh._(_root);
	@override late final _TranslationsProductionTh production = _TranslationsProductionTh._(_root);
	@override late final _TranslationsCustomersTh customers = _TranslationsCustomersTh._(_root);
	@override late final _TranslationsEmployeesTh employees = _TranslationsEmployeesTh._(_root);
	@override late final _TranslationsShiftsTh shifts = _TranslationsShiftsTh._(_root);
	@override late final _TranslationsReportsTh reports = _TranslationsReportsTh._(_root);
	@override late final _TranslationsSettingsTh settings = _TranslationsSettingsTh._(_root);
	@override late final _TranslationsCurrencyTh currency = _TranslationsCurrencyTh._(_root);
	@override late final _TranslationsRestaurantTh restaurant = _TranslationsRestaurantTh._(_root);
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
	@override String get tickets => 'ตั๋ว';
	@override String get tables => 'โต๊ะ';
	@override String get kds => 'KDS';
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
	@override String get splitPayment => 'แบ่งจ่าย';
	@override String get amountTendered => 'จำนวนที่จ่าย';
	@override String get insufficientAmount => 'จำนวนเงินไม่พอ';
	@override String get paymentMethod => 'วิธีชำระ';
}

// Path: receipts
class _TranslationsReceiptsTh extends TranslationsReceiptsEn {
	_TranslationsReceiptsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'ใบเสร็จ';
	@override String get receiptHistory => 'ประวัติใบเสร็จ';
	@override String get receiptDetail => 'รายละเอียดใบเสร็จ';
	@override String get noReceipts => 'ไม่พบใบเสร็จ';
	@override String get reprint => 'พิมพ์ใหม่';
	@override String get emailReceipt => 'ส่งทางอีเมล';
	@override String get completed => 'สำเร็จ';
	@override String get voided => 'ยกเลิก';
	@override String get refunded => 'คืนเงินแล้ว';
	@override String get refundReceipt => 'คืนเงินใบเสร็จ';
	@override String get refundReason => 'เหตุผลคืนเงิน';
	@override String get refundReasonHint => 'กรุณาระบุเหตุผล';
	@override String get fullRefund => 'คืนเงินทั้งหมด';
	@override String get partialRefund => 'คืนเงินบางส่วน';
	@override String get selectItemsToRefund => 'เลือกสินค้าที่ต้องการคืน';
	@override String get refundAmount => 'จำนวนเงินคืน';
	@override String get refundProcessed => 'คืนเงินสำเร็จ';
	@override String get confirmVoid => 'คุณแน่ใจหรือไม่ว่าต้องการยกเลิกใบเสร็จนี้?';
	@override String get confirmRefund => 'คุณแน่ใจหรือไม่ว่าต้องการคืนเงินใบเสร็จนี้?';
	@override String items({required Object count}) => '${count} รายการ';
	@override String get paidWith => 'ชำระด้วย';
	@override String get printReceipt => 'พิมพ์ใบเสร็จ';
	@override String get shareReceipt => 'แชร์ใบเสร็จ';
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
	@override String get quantity => 'จำนวน';
	@override String get adjustment => 'การปรับ';
	@override String get reason => 'เหตุผล';
	@override String get damaged => 'เสียหาย';
	@override String get lost => 'สูญหาย';
	@override String get correction => 'แก้ไข';
	@override String get received => 'รับเข้า';
	@override String get returned => 'ส่งคืน';
	@override String get other => 'อื่นๆ';
	@override String get adjustmentHistory => 'ประวัติการปรับ';
	@override String get noStockItems => 'ไม่พบรายการสต๊อก';
	@override String get startCount => 'เริ่มนับ';
	@override String get applyCount => 'นำไปใช้';
	@override String get expected => 'คาดหมาย';
	@override String get counted => 'นับได้';
	@override String get difference => 'ส่วนต่าง';
	@override String get countCompleted => 'นับสต๊อกเสร็จสิ้น';
	@override String get threshold => 'เกณฑ์แจ้งเตือน';
	@override String get setThreshold => 'ตั้งเกณฑ์สต๊อกต่ำ';
	@override String get valuation => 'มูลค่าสต๊อก';
	@override String get totalValue => 'มูลค่ารวม';
	@override String get adjustmentCreated => 'ปรับสต๊อกสำเร็จ';
	@override String get createPO => 'สร้างใบสั่งซื้อ';
	@override String get editPO => 'แก้ไขใบสั่งซื้อ';
	@override String get poNumber => 'ใบสั่งซื้อ #';
	@override String get noPurchaseOrders => 'ไม่มีใบสั่งซื้อ';
	@override String get draft => 'ร่าง';
	@override String get ordered => 'สั่งแล้ว';
	@override String get partiallyReceived => 'รับบางส่วน';
	@override String get receivedStatus => 'รับแล้ว';
	@override String get receiveStock => 'รับสินค้า';
	@override String get receivedQty => 'จำนวนที่รับ';
	@override String get addSupplier => 'เพิ่มผู้จัดจำหน่าย';
	@override String get editSupplier => 'แก้ไขผู้จัดจำหน่าย';
	@override String get noSuppliers => 'ไม่มีผู้จัดจำหน่าย';
	@override String get supplierName => 'ชื่อผู้จัดจำหน่าย';
	@override String get phone => 'โทรศัพท์';
	@override String get email => 'อีเมล';
	@override String get address => 'ที่อยู่';
	@override String get selectSupplier => 'เลือกผู้จัดจำหน่าย';
	@override String get addItems => 'เพิ่มรายการ';
	@override String get unitCost => 'ราคาต่อหน่วย';
	@override String get poCreated => 'สร้างใบสั่งซื้อสำเร็จ';
	@override String get poUpdated => 'แก้ไขใบสั่งซื้อสำเร็จ';
	@override String get stockReceived => 'รับสินค้าสำเร็จ';
	@override String get createTransfer => 'สร้างการโอน';
	@override String get noTransfers => 'ไม่มีการโอน';
	@override String get fromStore => 'จากร้าน';
	@override String get toStore => 'ไปร้าน';
	@override String get pending => 'รอดำเนินการ';
	@override String get inTransit => 'กำลังส่ง';
	@override String get transferCreated => 'สร้างการโอนสำเร็จ';
	@override String get transferCompleted => 'โอนสำเร็จ';
	@override String get selectItems => 'เลือกรายการ';
}

// Path: production
class _TranslationsProductionTh extends TranslationsProductionEn {
	_TranslationsProductionTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'การผลิต';
	@override String get recipes => 'สูตร';
	@override String get addRecipe => 'เพิ่มสูตร';
	@override String get editRecipe => 'แก้ไขสูตร';
	@override String get noRecipes => 'ยังไม่มีสูตร';
	@override String get finishedItem => 'สินค้าสำเร็จ';
	@override String get selectFinishedItem => 'เลือกสินค้าสำเร็จ';
	@override String get outputQuantity => 'จำนวนผลผลิต';
	@override String get ingredients => 'วัตถุดิบ';
	@override String get addIngredient => 'เพิ่มวัตถุดิบ';
	@override String get selectIngredient => 'เลือกวัตถุดิบ';
	@override String get ingredientQty => 'จำนวนที่ต้องการ';
	@override String get produce => 'ผลิต';
	@override String get produceNow => 'ผลิตเลย';
	@override String get batchQuantity => 'จำนวนชุด';
	@override String get insufficientStock => 'วัตถุดิบไม่เพียงพอ';
	@override String get productionComplete => 'การผลิตเสร็จสมบูรณ์';
	@override String get recipeCreated => 'สร้างสูตรสำเร็จ';
	@override String get recipeUpdated => 'แก้ไขสูตรสำเร็จ';
	@override String get recipeDeleted => 'ลบสูตรสำเร็จ';
	@override String get confirmDelete => 'คุณแน่ใจหรือไม่ว่าต้องการลบสูตรนี้?';
	@override String get productionLog => 'บันทึกการผลิต';
	@override String get noLogs => 'ยังไม่มีบันทึกการผลิต';
	@override String get currentStock => 'สต็อกปัจจุบัน';
	@override String get required => 'ต้องการ';
	@override String get available => 'มีอยู่';
	@override String get notes => 'หมายเหตุ';
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
	@override String get noCustomers => 'ไม่มีลูกค้า';
	@override String get customerName => 'ชื่อลูกค้า';
	@override String get phone => 'โทรศัพท์';
	@override String get email => 'อีเมล';
	@override String get address => 'ที่อยู่';
	@override String get birthday => 'วันเกิด';
	@override String get notes => 'หมายเหตุ';
	@override String get purchaseHistory => 'ประวัติการซื้อ';
	@override String get loyaltyBalance => 'คะแนนคงเหลือ';
	@override String get pointsEarned => 'คะแนนที่ได้';
	@override String get pointsRedeemed => 'คะแนนที่ใช้';
	@override String get customerCreated => 'เพิ่มลูกค้าสำเร็จ';
	@override String get customerUpdated => 'แก้ไขลูกค้าสำเร็จ';
	@override String get assignCustomer => 'เลือกลูกค้า';
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
	@override String get employeeName => 'ชื่อพนักงาน';
	@override String get selectRole => 'เลือกบทบาท';
	@override String get enterPin => 'ใส่รหัส PIN';
	@override String get pinHint => '4-6 หลัก';
	@override String get noRole => 'ไม่มีบทบาท';
	@override String get roles => 'บทบาท';
	@override String get addRole => 'เพิ่มบทบาท';
	@override String get editRole => 'แก้ไขบทบาท';
	@override String get roleName => 'ชื่อบทบาท';
	@override String get noRoles => 'ยังไม่มีบทบาท';
	@override String get employeeCreated => 'สร้างพนักงานแล้ว';
	@override String get employeeUpdated => 'อัปเดตพนักงานแล้ว';
	@override String get employeeDeleted => 'ลบพนักงานแล้ว';
	@override String get roleCreated => 'สร้างบทบาทแล้ว';
	@override String get roleUpdated => 'อัปเดตบทบาทแล้ว';
	@override String get roleDeleted => 'ลบบทบาทแล้ว';
	@override String get clockedIn => 'เข้างานแล้ว';
	@override String get clockedOut => 'ออกงานแล้ว';
	@override String get notClockedIn => 'ยังไม่ได้เข้างาน';
	@override String get timeEntries => 'บันทึกเวลา';
	@override String get noTimeEntries => 'ไม่มีบันทึกเวลา';
	@override String get duration => 'ระยะเวลา';
	@override String get confirmDelete => 'ลบพนักงานนี้?';
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
	@override String get noShift => 'ไม่มีกะเปิด';
	@override String get shiftOpened => 'เปิดกะแล้ว';
	@override String get shiftClosed => 'ปิดกะแล้ว';
	@override String get cashAdded => 'เพิ่มเงินแล้ว';
	@override String get cashRemoved => 'ถอนเงินแล้ว';
	@override String get reason => 'เหตุผล';
	@override String get amount => 'จำนวน';
	@override String get enterAmount => 'ใส่จำนวน';
	@override String get alreadyOpen => 'มีกะเปิดอยู่แล้ว';
	@override String get shiftSummary => 'สรุปกะ';
	@override String get totalSales => 'ยอดขายทั้งหมด';
	@override String get cashMovements => 'การเคลื่อนย้ายเงิน';
	@override String get noMovements => 'ไม่มีการเคลื่อนย้ายเงิน';
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
	@override String get salesByHour => 'ขายตามชั่วโมง';
	@override String get taxReport => 'รายงานภาษี';
	@override String get discountReport => 'รายงานส่วนลด';
	@override String get customerReport => 'รายงานลูกค้า';
	@override String get inventoryReport => 'รายงานสินค้า';
	@override String get profitAndLoss => 'กำไร & ขาดทุน';
	@override String get expenses => 'ค่าใช้จ่าย';
	@override String get today => 'วันนี้';
	@override String get thisWeek => 'สัปดาห์นี้';
	@override String get thisMonth => 'เดือนนี้';
	@override String get custom => 'กำหนดเวลา';
	@override String get revenue => 'รายได้';
	@override String get cogs => 'ต้นทุนสินค้า';
	@override String get grossProfit => 'กำไรรวม';
	@override String get netProfit => 'กำไรสุทธิ';
	@override String get totalDiscount => 'รวมส่วนลด';
	@override String get avgDiscount => 'ส่วนลดเฉลี่ย';
	@override String get receiptsWithDiscount => 'บิลที่มีส่วนลด';
	@override String get taxCollected => 'ภาษีเก็บได้';
	@override String get taxRate => 'อัตรา';
	@override String get visits => 'จำนวนครั้ง';
	@override String get totalSpent => 'ใช้จ่ายทั้งหมด';
	@override String get stockLevel => 'ระดับสต็อก';
	@override String get stockValue => 'มูลค่าสต็อก';
	@override String get lowStock => 'สต็อกต่ำ';
	@override String get export => 'ส่งออก';
	@override String get exportCsv => 'ส่งออก CSV';
	@override String get exportPdf => 'ส่งออก PDF';
	@override String get addExpense => 'เพิ่มค่าใช้จ่าย';
	@override String get expenseCategory => 'หมวดค่าใช้จ่าย';
	@override String get noExpenses => 'ไม่มีค่าใช้จ่าย';
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

// Path: restaurant
class _TranslationsRestaurantTh extends TranslationsRestaurantEn {
	_TranslationsRestaurantTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get openTickets => 'ตั๋วที่เปิด';
	@override String get newTicket => 'ตั๋วใหม่';
	@override String get noTickets => 'ไม่มีตั๋วเปิด';
	@override String get selectTicket => 'เลือกหรือสร้างตั๋ว';
	@override String get ticketDetail => 'รายละเอียดตั๋ว';
	@override String get assignTable => 'กำหนดโต๊ะ';
	@override String get noTable => 'ไม่มีโต๊ะ';
	@override String get mergeTicket => 'รวมเข้าตั๋วนี้';
	@override String get charge => 'คิดเงิน';
	@override String get sentToPOS => 'ส่งไป POS แล้ว';
	@override String get addItems => 'เพิ่มรายการ';
	@override String get tableManagement => 'จัดการโต๊ะ';
	@override String get addTable => 'เพิ่มโต๊ะ';
	@override String get editTable => 'แก้ไขโต๊ะ';
	@override String get noTables => 'ยังไม่มีโต๊ะ';
	@override String get addFirstTable => 'เพิ่มโต๊ะแรก';
	@override String get tableName => 'ชื่อโต๊ะ';
	@override String get seats => 'ที่นั่ง';
	@override String get zone => 'โซน';
	@override String get available => 'ว่าง';
	@override String get occupied => 'มีคน';
	@override String get reserved => 'จองแล้ว';
	@override String get kds => 'จอแสดงครัว';
	@override String get kitchen => 'ครัว';
	@override String get bar => 'บาร์';
	@override String get dessert => 'ของหวาน';
	@override String get allCaughtUp => 'เสร็จหมดแล้ว!';
	@override String get done => 'เสร็จ';
	@override String get recall => 'เรียกคืน';
	@override String get pending => 'รอ';
	@override String get preparing => 'กำลังเตรียม';
	@override String get ready => 'พร้อม';
	@override String get served => 'เสิร์ฟแล้ว';
}
