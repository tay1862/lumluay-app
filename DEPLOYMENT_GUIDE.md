# Lumluay POS — คู่มือการ Deploy & ทดสอบ

## สถานะปัจจุบัน (6 เม.ย. 2026)

| Platform | สถานะ | ไฟล์ Output | ขนาด |
|----------|--------|------------|------|
| **Android APK** | ✅ Build แล้ว (release-signed) | `build/app/outputs/flutter-apk/app-release.apk` | 66 MB |
| **Flutter Web** | ✅ Build แล้ว | `build/web/` | 47 MB |
| **iOS IPA** | ⏳ ต้องลง Xcode ก่อน | ยังไม่มี | — |
| **Server (Docker)** | ✅ พร้อม deploy | `lumluay_server/Dockerfile` | — |

---

## 1. ทดสอบ Android (Offline)

### ติดตั้ง APK ลงมือถือ

```bash
# วิธีที่ 1: ใช้ ADB (ถ้าเชื่อมสาย USB)
adb install build/app/outputs/flutter-apk/app-release.apk

# วิธีที่ 2: ส่งไฟล์ไปมือถือ
# - AirDrop, Google Drive, Line, Telegram ก็ได้
# - ไฟล์อยู่ที่: build/app/outputs/flutter-apk/app-release.apk
# - เปิดไฟล์ในมือถือแล้วกด "ติดตั้ง"
# - ถ้ามือถือบล็อก ให้ไปเปิด "ติดตั้งจากแหล่งที่ไม่รู้จัก" ในตั้งค่า
```

> **หมายเหตุ**: ตอนตั้งต้น (ยังไม่ได้ sync กับ server) แอพจะเป็น offline mode — ต้องสร้าง Store และ Employee ในเครื่องก่อนจึงจะ login ได้

### สิ่งที่ต้องทำหลังติดตั้ง
1. เปิดแอพ → หน้า Login จะแสดง "No stores found"
2. ต้อง sync ข้อมูลจาก server ก่อน **หรือ** สร้างร้านค้า/พนักงานผ่าน Settings (ถ้ามี)

---

## 2. ทดสอบ iOS (iPhone)

### ⚠️ ต้องติดตั้ง Xcode ก่อน (กำลังดาวน์โหลดอยู่)

เมื่อ Xcode ลงเสร็จแล้ว:

```bash
# ตั้งค่า Xcode path
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# ติดตั้ง CocoaPods (ถ้ายังไม่มี)
sudo gem install cocoapods

# Install iOS dependencies
cd ios && pod install && cd ..

# Build IPA (Ad Hoc — ต้องมี Apple Developer account สำหรับ distribute)
flutter build ipa --release

# หรือ Run ตรงลงมือถือ (ฟรี — ต้องเสียบสาย + trust certificate)
flutter run -d <iPhone-ID> --release
```

### ทดสอบบน iPhone โดยไม่มี Apple Developer Account ($99/ปี)
1. เสียบ iPhone เข้า Mac ด้วยสาย
2. เปิด Xcode → Open `ios/Runner.xcworkspace`
3. เลือก Team เป็น **Personal Team** (Apple ID ของตัวเอง)
4. กด Run ▶ → แอพจะติดตั้งลง iPhone
5. ⚠️ แอพจะหมดอายุใน **7 วัน** (ข้อจำกัด Free Provisioning)

### ถ้าต้องการแจก .ipa ให้คนอื่น
- ต้องสมัคร **Apple Developer Program** ($99/ปี)
- ใช้ TestFlight หรือ Ad Hoc Distribution

---

## 3. Deploy Server บน VPS

### Prerequisites
- VPS (เช่น DigitalOcean, Vultr, Linode) — แนะนำ 2+ CPU, 4+ GB RAM
- Domain `kanghan.site` ชี้ DNS มาที่ VPS IP แล้ว
- **VPS ปัจจุบัน**: `root@217.216.75.64`

### DNS Records (ตั้งค่าที่ Domain Provider)

| Type | Name | Value |
|------|------|-------|
| A | `kanghan.site` | `217.216.75.64` |
| A | `api.kanghan.site` | `217.216.75.64` |
| A | `app.kanghan.site` | `217.216.75.64` |
| A | `insights.kanghan.site` | `217.216.75.64` |

### Step-by-Step Deploy

```bash
# ── 1. Copy โปรเจค server ขึ้น VPS ──────────────────
# จากเครื่อง Mac:
cd /Users/aphilack/Documents/lumluay

# Upload server code
rsync -avz --exclude='.dart_tool' --exclude='build' \
  lumluay_server/ root@217.216.75.64:~/lumluay/lumluay_server/

# Upload deploy config
rsync -avz deploy/ root@217.216.75.64:~/lumluay/deploy/

# ── 2. Copy Flutter web build ไปใส่ server ────────────
# (web build ต้องอยู่ใน lumluay_server/web/app/)
rsync -avz /Users/aphilack/Documents/lumluay-pos/build/web/ \
  root@217.216.75.64:~/lumluay/lumluay_server/web/app/

# ── 3. SSH เข้า VPS แล้ว run setup ────────────────────
ssh root@217.216.75.64
cd ~/lumluay/deploy

# ให้ scripts มีสิทธิ์ execute
chmod +x scripts/*.sh

# Run initial setup (ครั้งแรกเท่านั้น)
./scripts/setup.sh kanghan.site admin@kanghan.site
```

### สิ่งที่ setup.sh ทำให้อัตโนมัติ
1. ✅ ติดตั้ง Docker (ถ้ายังไม่มี)
2. ✅ สร้าง `.env` พร้อม random passwords
3. ✅ ขอ SSL certificate จาก Let's Encrypt
4. ✅ Start ทุก container: Server, PostgreSQL, Redis, Nginx, Certbot, Backup

### หลังจาก setup เสร็จ

```bash
# ดู status ทุก container
docker compose -f docker-compose.prod.yml ps

# ดู logs แบบ real-time
docker compose -f docker-compose.prod.yml logs -f

# ดู logs เฉพาะ server
docker compose -f docker-compose.prod.yml logs -f lumluay-server
```

### ✅ URLs ที่ใช้งานได้หลัง deploy

| Service | URL | หน้าที่ |
|---------|-----|--------|
| **API** | `https://api.kanghan.site` | Serverpod API endpoint (Flutter app เชื่อมที่นี่) |
| **Web App** | `https://app.kanghan.site` | Flutter web app (POS ใช้ผ่าน browser) |
| **Insights** | `https://insights.kanghan.site` | Serverpod Insights monitoring |

---

## 4. เชื่อม App กับ Server (Online Mode)

เมื่อ server บน VPS พร้อมแล้ว ต้องตรวจสอบว่า Flutter app ชี้ไปที่ API ที่ถูกต้อง:

```
API endpoint: https://api.kanghan.site
```

> ถ้าต้องการเปลี่ยน URL ให้แก้ใน Flutter config แล้ว build ใหม่

---

## 5. คำสั่งที่ใช้บ่อย (บน VPS)

```bash
cd ~/lumluay/deploy

# ── Deploy อัพเดทใหม่ (zero-downtime) ──
./scripts/deploy.sh

# ── Backup database ──
docker compose -f docker-compose.prod.yml exec pg-backup /usr/local/bin/backup.sh

# ── Restore database จาก backup ──
./scripts/restore.sh backups/lumluay_YYYYMMDD_HHMMSS.sql.gz

# ── ดู backups ทั้งหมด ──
ls -lh backups/

# ── Restart ทุก service ──
docker compose -f docker-compose.prod.yml restart

# ── หยุดทุก service ──
docker compose -f docker-compose.prod.yml down

# ── ดู resource usage ──
docker stats
```

---

## 6. Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    VPS (217.216.75.64)                   │
│                                                         │
│  Internet ──→ Nginx (:80/:443)                          │
│                 ├── api.kanghan.site ──→ Server (:8080)  │
│                 ├── app.kanghan.site ──→ Server (:8082)  │
│                 └── insights.kanghan.site → Server(:8081)│
│                                                         │
│              Serverpod Server                            │
│                 ├── PostgreSQL (:5432)                   │
│                 └── Redis (:6379)                        │
│                                                         │
│              pg-backup (cron 02:00 daily)                │
│              Certbot (SSL auto-renew 12h)                │
└─────────────────────────────────────────────────────────┘

┌─────────────────────┐     ┌─────────────────────┐
│  Android App (.apk) │     │   iPhone App (.ipa)  │
│  ───────────────────│     │  ────────────────────│
│  Offline: SQLite    │────▶│  Offline: SQLite     │
│  Online: Sync ↔ API │     │  Online: Sync ↔ API  │
└─────────────────────┘     └─────────────────────┘
```

---

## 7. Keystore สำคัญ (เก็บให้ดี!)

| ไฟล์ | ที่อยู่ | สำคัญ |
|------|--------|------|
| **Android Keystore** | `android/app/lumluay-pos.jks` | ⚠️ ห้ามหาย! ถ้าหายจะอัพเดทแอพบน Play Store ไม่ได้ |
| **Key Properties** | `android/key.properties` | Password ของ keystore (gitignored) |
| **Server passwords** | `lumluay_server/config/passwords.yaml` | Passwords ของ DB, Redis, JWT (gitignored) |
| **VPS .env** | `deploy/.env` | Passwords สำหรับ production containers |

### Backup Keystore !!!
```bash
# สำรอง keystore ไว้ที่ปลอดภัย
cp android/app/lumluay-pos.jks ~/Desktop/lumluay-pos-keystore-backup.jks
cp android/key.properties ~/Desktop/lumluay-pos-key-properties-backup.txt
```

---

## 8. Build ใหม่ (เมื่อแก้โค้ด)

```bash
cd /Users/aphilack/Documents/lumluay-pos

# ── Build Web ──
flutter build web --release
# Output: build/web/

# ── Build Android APK ──
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# ── Build Android App Bundle (สำหรับ Play Store) ──
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# ── Build iOS (เมื่อมี Xcode) ──
flutter build ipa --release
# Output: build/ios/ipa/lumluay_pos.ipa

# ── Deploy web ใหม่ขึ้น VPS ──
rsync -avz build/web/ root@217.216.75.64:~/lumluay/lumluay_server/web/app/
ssh root@217.216.75.64 "cd ~/lumluay/deploy && ./scripts/deploy.sh"
```

---

## สรุป: ขั้นตอนถัดไป

1. **ตอนนี้**: ส่ง `app-release.apk` ไปลงมือถือ Android ทดสอบ offline
2. **Xcode ลงเสร็จ**: Build iOS แล้วทดสอบบน iPhone  
3. **Deploy VPS**: ตั้ง DNS → rsync code ขึ้น VPS → run `setup.sh`
4. **ทดสอบ online**: เปิด `https://app.kanghan.site` บน browser / เชื่อมแอพกับ API
