# Lumluay POS — คู่มือการใช้งาน & Deploy

## GitHub Repositories

| Repo | URL |
|------|-----|
| **Flutter App (POS)** | https://github.com/tay1862/lumluay-app.git |
| **Server + Deploy** | https://github.com/tay1862/lumluay-server.git |

---

## สถานะ Build (6 เม.ย. 2026)

| Platform | สถานะ | ไฟล์ Output | ขนาด |
|----------|--------|------------|------|
| **Android APK** | ✅ Build แล้ว (release-signed) | `build/app/outputs/flutter-apk/app-release.apk` | 69 MB |
| **Flutter Web** | ✅ Build แล้ว | `build/web/` | 47 MB |
| **iOS IPA** | ⏳ รอ Xcode | ยังไม่มี | — |
| **Server (Docker)** | ✅ พร้อม deploy | Dockerfile อยู่ใน server repo | — |

---

## 1. ทดสอบ Android (Offline)

### ติดตั้ง APK ลงมือถือ

```bash
# วิธีที่ 1: ใช้ ADB (เสียบสาย USB)
adb install build/app/outputs/flutter-apk/app-release.apk

# วิธีที่ 2: ส่งไฟล์ไปมือถือผ่าน Google Drive / Line / Telegram
# ไฟล์อยู่ที่: build/app/outputs/flutter-apk/app-release.apk
# เปิดไฟล์ในมือถือ → กด "ติดตั้ง"
# ถ้ามือถือบล็อก → ตั้งค่า → เปิด "ติดตั้งจากแหล่งที่ไม่รู้จัก"
```

### เปิดแอพครั้งแรก (Quick Setup)

เปิดแอพ → จะเจอหน้า **Quick Setup** ให้กรอก:

1. **Store Name** — ชื่อร้าน (เช่น "ร้านกาแฟ")
2. **Your Name** — ชื่อพนักงาน (เช่น "สมชาย")
3. **Login PIN** — PIN 4 หลักสำหรับ login (เช่น "1234")
4. กด **Create & Start**

หลังจากนั้น → หน้า Login จะแสดงรายชื่อพนักงาน → กดเลือกชื่อ → ใส่ PIN → เข้าหน้า POS

### ฟีเจอร์หลักที่ใช้ได้ (Offline)
- ขายสินค้า / สร้างใบเสร็จ
- จัดการรายการสินค้า / หมวดหมู่
- จัดการสต็อก / Inventory
- จัดการลูกค้า
- จัดการพนักงาน / กะ (Shift)
- ดูรายงานยอดขาย
- ตั้งค่าร้าน / ภาษี / สกุลเงิน

---

## 2. ทดสอบ iOS (iPhone)

### ยังต้องรอ Xcode ลงเสร็จ

เมื่อ Xcode ลงแล้ว:

```bash
# ตั้ง Xcode path
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# ติดตั้ง CocoaPods
sudo gem install cocoapods

# Install dependencies
cd /Users/aphilack/Documents/lumluay-pos
cd ios && pod install && cd ..

# วิธีที่ 1: Run ตรงลง iPhone (ฟรี — เสียบสาย)
flutter run -d <iPhone-ID> --release

# วิธีที่ 2: Build IPA (ต้องมี Apple Developer $99/ปี)
flutter build ipa --release
```

### ทดสอบบน iPhone แบบฟรี (ไม่ต้องมี Developer Account)
1. เสียบ iPhone เข้า Mac ด้วยสาย
2. เปิด Xcode → Open `ios/Runner.xcworkspace`
3. เลือก Team = **Personal Team** (Apple ID ตัวเอง)
4. กด Run ▶ → แอพติดตั้งลง iPhone
5. ⚠️ แอพหมดอายุใน **7 วัน** ต้อง Run ใหม่

---

## 3. Deploy Server บน VPS

### Prerequisites
- VPS (DigitalOcean / Vultr / Linode) — แนะนำ 2+ CPU, 4+ GB RAM
- **VPS ปัจจุบัน**: `root@217.216.75.64`
- Domain `kanghan.site` ชี้ DNS มาที่ VPS IP

### 3.1 ตั้งค่า DNS (ทำที่ Domain Provider)

| Type | Name | Value |
|------|------|-------|
| A | `kanghan.site` | `217.216.75.64` |
| A | `api.kanghan.site` | `217.216.75.64` |
| A | `app.kanghan.site` | `217.216.75.64` |
| A | `insights.kanghan.site` | `217.216.75.64` |

### 3.2 Setup ครั้งแรก (บน VPS)

```bash
# SSH เข้า VPS
ssh root@217.216.75.64

# Clone server repo
git clone https://github.com/tay1862/lumluay-server.git ~/lumluay/lumluay_server
cd ~/lumluay/lumluay_server/deploy

# ให้ scripts execute ได้
chmod +x scripts/*.sh

# Run setup (ครั้งแรกเท่านั้น — ติดตั้ง Docker, สร้าง .env, ขอ SSL, start ทุกอย่าง)
./scripts/setup.sh kanghan.site admin@kanghan.site
```

### 3.3 Copy Flutter Web Build ขึ้น VPS

```bash
# จากเครื่อง Mac — build web ก่อน (ถ้ายังไม่ได้ build)
cd /Users/aphilack/Documents/lumluay-pos
flutter build web --release

# Upload web build ไปใส่ server
scp -r build/web/* root@217.216.75.64:~/lumluay/lumluay_server/web/app/

# SSH เข้าไป restart server
ssh root@217.216.75.64 "cd ~/lumluay/lumluay_server/deploy && ./scripts/deploy.sh"
```

### 3.4 สิ่งที่ setup.sh ทำให้อัตโนมัติ
1. ติดตั้ง Docker (ถ้ายังไม่มี)
2. สร้าง `.env` พร้อม random passwords (DB, Redis, Dashboard)
3. ขอ SSL certificate จาก Let's Encrypt
4. Start ทุก container: **Server, PostgreSQL, Redis, Nginx, Certbot, pg-backup**

### 3.5 URLs หลัง Deploy

| Service | URL | หน้าที่ |
|---------|-----|--------|
| **API** | `https://api.kanghan.site` | Serverpod API (แอพเชื่อมที่นี่) |
| **Web App** | `https://app.kanghan.site` | POS ใช้ผ่าน browser |
| **Insights** | `https://insights.kanghan.site` | Monitoring dashboard |

---

## 4. คำสั่งที่ใช้บ่อย

### บน VPS

```bash
cd ~/lumluay/lumluay_server/deploy

# ── ดู status ──
docker compose -f docker-compose.prod.yml ps

# ── ดู logs ──
docker compose -f docker-compose.prod.yml logs -f              # ทุก service
docker compose -f docker-compose.prod.yml logs -f lumluay-server  # เฉพาะ server

# ── Deploy อัพเดทใหม่ (zero-downtime) ──
cd ~/lumluay/lumluay_server && git pull
cd deploy && ./scripts/deploy.sh

# ── Backup database ──
docker compose -f docker-compose.prod.yml exec pg-backup /usr/local/bin/backup.sh

# ── Restore database ──
./scripts/restore.sh backups/lumluay_YYYYMMDD_HHMMSS.sql.gz

# ── ดู backups ──
ls -lh backups/

# ── Restart / Stop ──
docker compose -f docker-compose.prod.yml restart
docker compose -f docker-compose.prod.yml down

# ── ดู resource ──
docker stats
```

### บนเครื่อง Mac (Build & Push)

```bash
cd /Users/aphilack/Documents/lumluay-pos

# ── Build Android APK ──
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# ── Build Web ──
flutter build web --release
# Output: build/web/

# ── Build iOS (เมื่อมี Xcode) ──
flutter build ipa --release
# Output: build/ios/ipa/lumluay_pos.ipa

# ── Push code แล้ว deploy ──
git add -A && git commit -m "update" && git push

# Upload web build ขึ้น VPS
scp -r build/web/* root@217.216.75.64:~/lumluay/lumluay_server/web/app/
ssh root@217.216.75.64 "cd ~/lumluay/lumluay_server/deploy && ./scripts/deploy.sh"
```

---

## 5. Architecture

```
┌──────────────────────────────────────────────────────────┐
│                  VPS (217.216.75.64)                      │
│                                                          │
│  Internet ──→ Nginx (:80/:443)                           │
│                 ├── api.kanghan.site  ──→ Serverpod:8080  │
│                 ├── app.kanghan.site  ──→ Serverpod:8082  │
│                 └── insights.kanghan.site → Serverpod:8081│
│                                                          │
│  Serverpod ──→ PostgreSQL:5432                            │
│            └──→ Redis:6379                                │
│                                                          │
│  pg-backup (cron ทุกวัน 02:00)                            │
│  Certbot (SSL auto-renew ทุก 12 ชม.)                      │
└──────────────────────────────────────────────────────────┘

┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐
│ Android (.apk)  │  │  iOS (.ipa)     │  │  Web Browser │
│ Offline: SQLite │  │  Offline: SQLite│  │  app.kanghan │
│ Online: ↔ API   │  │  Online: ↔ API  │  │  .site       │
└─────────────────┘  └─────────────────┘  └──────────────┘
```

---

## 6. ไฟล์สำคัญ (ห้ามหาย!)

| ไฟล์ | ที่อยู่ | ทำไมสำคัญ |
|------|--------|----------|
| **Android Keystore** | `android/app/lumluay-pos.jks` | ⚠️ ถ้าหาย = อัพเดทแอพบน Play Store ไม่ได้ |
| **Key Properties** | `android/key.properties` | Password ของ keystore (gitignored) |
| **Server passwords** | `config/passwords.yaml` (ใน server repo) | DB, Redis, JWT passwords (gitignored) |
| **VPS .env** | `deploy/.env` (บน VPS) | Passwords สำหรับ production |

### สำรอง Keystore !!!
```bash
cp android/app/lumluay-pos.jks ~/Desktop/lumluay-pos-keystore-BACKUP.jks
cp android/key.properties ~/Desktop/key-properties-BACKUP.txt
```

---

## สรุป: ทดสอบใช้จริง

| ขั้นตอน | วิธี |
|---------|------|
| **1. ทดสอบ Android offline** | ส่ง APK ไปมือถือ → Quick Setup → ใช้งาน POS |
| **2. Deploy server** | SSH เข้า VPS → `git clone` → `setup.sh` |
| **3. Upload web** | `scp` web build ขึ้น VPS → `deploy.sh` |
| **4. ทดสอบ online** | เปิด `https://app.kanghan.site` / เชื่อมแอพกับ API |
| **5. ทดสอบ iOS** | รอ Xcode → เสียบ iPhone → Run ผ่าน Xcode |
