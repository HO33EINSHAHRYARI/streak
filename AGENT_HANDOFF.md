# 📋 سند تحویل پروژه پناهگاه — برای ایجنت بعدی

> این سند رو به ایجنت بده تا بدون تبدیل کار کنه. آخرین به‌روزرسانی: 2026-11-20

## ۱. پروژه چیست؟

- **مسیر پروژه:** `D:\app` — فورک فارسی‌شده‌ی اپ [Streak](https://github.com/InlitX/streak) (ردیاب عادت Flutter)
- **ریپو گیت‌هاب کاربر:** https://github.com/HO33EINSHAHRYARI/streak (public، شاخه main)
- **نام تجاری فورک:** «پناهگاه» (Panahgah) — **هرگز** در ترجمه‌های fa به Streak برنگردان؛ این هویت فورک کاربره
- **زبان پیش‌فرض اپ: فارسی (fa)** و همه‌ی تاریخ‌های نمایشی باید **شمسی (Jalali)** باشند
- **پلتفرم هدف:** فقط اندروید (خروجی arm64). Windows/Linux از قبل بودند ولی ویندوز قابل بیلد نیست چون **Visual Studio نصب نیست**. iOS نیمه‌کاره

## ۲. محیط سیستم — خیلی مهم

| ابزار | مسیر | نکته |
|---|---|---|
| Flutter SDK (master 3.51.0-0.1.pre) | `D:\flutter-sdk` | اجرا: `/d/flutter-sdk/bin/flutter` |
| Pub cache | `D:\Tools\pub-cache` | همیشه `export PUB_CACHE=D:/Tools/pub-cache` |
| JDK 17 | `D:\Tools\jdk-17` | همیشه `export JAVA_HOME=D:/Tools/jdk-17` (java پیش‌فرض PATH نسخه ۸ است!) |
| Android SDK | `D:\Tools\android-sdk` | کامل است: platform-36، build-tools 35.0.1، NDK 28.2.1، CMake 3.22.1، لایسنس‌ها accept شده |
| کش Gradle | `D:\Tools\.gradle` | `export GRADLE_USER_HOME=D:/Tools/.gradle` |
| VS Code | `"J:\vscode\Microsoft VS Code\bin\code"` | روی PATH نیست |

**چرا SDK روی D است؟** فاصله در مسیر `C:\Users\RAYANEH GOSTAR` هوک‌های native assets را می‌شکند (`'C:\Users\RAYANEH' is not recognized` — باگ flutter test و بیلد اندروید با objective_c). SDK و pub cache به مسیر بدون فاصله منتقل شده‌اند. **دیسک C تقریباً پر است (~99%)** — هیچ‌وقت دانلود/extract به /tmp (C:) نکن، همیشه به D.

**تنظیمات VS Code** در `.vscode/` است (gitignore شده ولی روی سیستم هست): `dart.flutterSdkPath=D:\flutter-sdk`، `dart.env` شامل JAVA_HOME/GRADLE_USER_HOME/PUB_CACHE، **Hot Reload خودکار روی ذخیره فایل** (`dart.flutterHotReloadOnSave: always`) و بازتولید خودکار ترجمه‌ها (`dart.flutterGenerateLocalizationsOnSave: all`).

## ۳. 🎮 سیستم پیش‌نمایش زنده روی گوشی (مهم‌ترین بخش)

گوشی کاربر: **Samsung Galaxy A52 (SM-A525F)، USB id: `RZ8T10XT2JL`** — با کابل USB و دیباگینگ روشن وصل می‌شود.

### چرخه کار:
```bash
export JAVA_HOME="D:/Tools/jdk-17"
export GRADLE_USER_HOME="D:/Tools/.gradle"
export PUB_CACHE="D:/Tools/pub-cache"
tail -f /d/app/.reload_cmd | /d/flutter-sdk/bin/flutter run -d RZ8T10XT2JL --debug > /d/app/.flutter_run.log 2>&1
```
(به‌صورت background task اجرا کن — `run_in_background: true`)

**ترفند کانال فرمان:** چون نمی‌شود به stdin یک پروسه background نوشت، `tail -f /d/app/.reload_cmd` به stdin فلتر وصل است. برای هات‌ریلود فقط بنویس:
```bash
echo "r" >> /d/app/.reload_cmd      # hot reload (~2-8 ثانیه)
echo "R" >> /d/app/.reload_cmd      # hot restart
echo "q" >> /d/app/.reload_cmd      # خروج
```
باگ‌ها/خطاها در `/d/app/.flutter_run.log` دیده می‌شوند — **لاگ را با `tail`/`grep` بخوان نه با Read کامل** (گرفتار log ورودی‌های سیستم اندروید می‌شود).

### قانون طلایی:
- تغییرات Dart (UI، رنگ، ویجت، نمودار، ترجمه از طریق `lib/l10n/app_localizations_fa.dart`) → فقط `echo "r"` کافی است
- تغییر فایل‌های `.arb` → هم فایل arb را ویرایش کن **و هم** مستقیم فایل تولیدشده `lib/l10n/app_localizations_fa.dart` را (چون `flutter gen-l10n` وسط جلسه‌ی فعال flutter run ممکن است روی قفل گیر کند)
- تغییر pubspec، manifest اندروید، فونت/آیکون → باید جلسه را بکشی و از اول run بگیری

### مشکلات رایج:
- **`Lost connection to device`**: کابل قطع شده یا گوشی خوابیده. صبر کن پروسه تمام شود، `flutter devices --device-timeout 10` بگیر، اگر گوشی بود دوباره `flutter run` (بیلد گرم ~1-2 دقیقه)
- **`Waiting for another flutter command to release the startup lock`**: پروسه flutter قدیمی مانده — `ps aux | grep flutter.bat | awk '{print $1}' | xargs -r kill -f` و `rm -f /d/flutter-sdk/bin/cache/lockfile`
- **`INSTALL_FAILED_UPDATE_INCOMPATIBLE`**: امضا فرق دارد — دیگر نباید پیش بیاید چون keystore ثابت داریم (بخش ۵)
- گوشی را **روشن و کابل را محکم** نگه دار؛ قطع USB وسط هات‌ریلود یعنی تغییر به گوشی نرسیده

### پچ flutter_tools (محلی روی این سیستم):
فایل `D:\flutter-sdk\packages\flutter_tools\lib\src\android\application_package.dart` پچ شده تا `activity-alias` را به‌عنوان مقصد لانچ resolve کند (مانیفست اپ، لانچر را روی alias دارد نه activity). اگر پچ پرید (`flutter run` خطای "package identifier or launch activity not found" داد): `rm -f D:\flutter-sdk\bin\cache\flutter_tools.snapshot` و `.stamp` تا دوباره bootstrap شود، و پچ را دوباره اعمال کن (بخش‌های `findAllElements('activity-alias')`).

## ۴. امضا و ریلیز

- **Keystore ثابت:** `android/panahgah-key.jks` (کامیت شده، پسورد `panahgah2026`، alias `panahgah`) — بیلدهای debug محلی **و** fallback ریلیز CI همه با این امضا می‌شوند → آپدیت درجا، بدون uninstall
- **ریلیز:** GitHub Actions → `.github/workflows/build-apk.yml` — فقط **arm64** (`--target-platform android-arm64`)، تگ پیش‌فرض `v2.10.6-fa`. تریگر push گاهی کار نمی‌کند — دستی بده:
  ```bash
  gh workflow run build-apk.yml --repo HO33EINSHAHRYARI/streak --ref main
  gh run watch <run_id> --repo HO33EINSHAHRYARI/streak --exit-status
  ```
- نسخه فعلی pubspec: `2.10.6+22`

## ۵. قراردادهای طراحی (تصمیم‌های قطعی کاربر — تغییر نده!)

1. **نمودارها زمان چپ→راست (LTR):** یک بار RTL-میرور شدیم و کاربر گفت «برعکسه» — برعکس شد. fl_chart را میرور نکن. `_GridYearStrip` هم forced-LTR است
2. **هایت‌مپ‌ها سبک GitHub:** روزهای لاگ‌نشده = خاکستری محو (`surfaceContainerHighest @ 0.4`)، **روزهای قبل از ساخت عادت هم خاکستری محو** (نه شفاف! کاربر گفت «چیزی نمی‌بینم»)، آینده = خاکستری خنثی (عادت اجتنابی هرگز فردا را رنگی نکند)
3. **لیبل ماه‌های هیت‌مپ سالانه:** روی ستونی که *هفته‌اش شامل روز اول ماه* است (نه ستونی که اولش ماه جدید است) — وگرنه لیبل ۶ روز عقب می‌افتد و دو ماه چسبیده دیده می‌شوند
4. **ترجمه‌ها:** «استریک» یکدست، «رنگ شاخص» برای Accent، کانفتی/سورپرایز transliteration، placeholderها با فاصله. فایل منبع: `lib/l10n/app_fa.arb`
5. **تب‌سوییچ‌ها:** هایلایت باید RTL-آگاه باشد — الگوی باگ: `Alignment(-1 + index)` و `Positioned(left:)` در RTL آینه نمی‌شوند ولی Row آینه می‌شود. با فرمول `rtl ? 1 - index : -1 + index` درست کن
6. **منوی پایین کلاسیک:** استایل liquid-glass (blur 28، گرادیان شیشه، خط براق بالا، سایه رنگی primary) — نگه‌دار
7. **`adaptiveQuality` باید false بماند:** در بیلد debug، نمونه‌بردار FPS اپ JITِ کند را «دستگاه ضعیف» می‌خواند و شیشه را تا نامرئی شدن downgrade می‌کند — کاربر عین آن را دید («گلس بعد از خروج/ورود پرید و اپ به حالت قبل برگشت»). در release هم مشکلی ندارد؛ فقط false

## ۶. تاریخچه باگ‌های حل‌شده (مرجع سریع)

- باگ «هفته می‌زنی سال روشن می‌شه» → `_ViewSelector` و `ExpressTabs` (هم‌ترازی هایلایت در RTL)
- «تمام روزها رنگی میشه» → شد شفاف (اشتباه بود) → حالا خاکستری محو GitHub-سبک
- «فردا بنفشه» → آینده خنثی شد برای همه انواع عادت
- «نمودارها برعکسه» → revert میرور نمودارها
- «دو ماه چسبیده» → لیبل روی هفته‌ی حاوی روز اول ماه
- کرش صفحه جزیره → `Expanded` زیر `FittedBox` در `_NextChip` حذف شد (island_page.dart)
- خطای «package identifier or launch activity not found» → پچ flutter_tools (بخش ۳)

## ۷. جزیره (گیمیفیکشن)

- کد: `lib/features/island/` — صفحه: `island_page.dart`، کنترلر: `IslandController`، داده: `island_ledger.dart`
- ورودی جزیره بالای تب آمار است (`IslandEntry` در statistics_page) و فقط وقتی `islandEnabled` باشد (تنظیمات، پیش‌فرض true)
- باگ کرش footer با `_NextChip` فیکس و پوش شد (کامیت `12ccd0c`) — **دوباره صفحه جزیره را باز کن و با `grep -i "exception\|error" /d/app/.flutter_run.log` چک کن که خطای جدیدی نیست**
- دارایی‌ها: `assets/island/*.webp` — تصاویر voxel با `IslandArt.ready?.sprites[...]` لود می‌شوند (FutureBuilder<IslandArt>)

## ۸. کارهای در انتظار / ایده‌ها

- [ ] دیسک C کاربر پر است — پیشنهاد پاکسازی (Pagefile روی D است، پس بحرانی نیست ولی محدودکننده است)
- [ ] iOS: پوشه هست ولی نیمه‌کاره؛ آیکون‌ها را ما گذاشتیم
- [ ] Windows desktop: بدون Visual Studio نمی‌شود — اگر کاربر خواست، Build Tools (~4-6GB روی D نصب‌شدنی)
- [ ] ریلیز بعدی CI با keystore جدید امضا می‌شود → کاربر باید **یک بار دیگر** از GitHub نصب کند، بعدش همه‌چیز درجاست
- [ ] شماره نسخه pubspec (2.10.6+22) با تگ ریلیز هماهنگ نگه داشته شود

## ۹. تله‌های محیطی Bash (وقت خراب کرده‌اند!)

- **heredoc بک‌اسلش خراب می‌کند:** `python <<'EOF'` روی این سیستم `\\n` را به newline واقعی تبدیل می‌کند → اسکریپت‌های پچ پایتونی را **با ابزار Write در فایل بنویس** و `python -I script.py` اجرا کن
- **فایل با نام `nul`** ممکن است ساخته شود → `git add -A` را می‌شکند؛ حذف با مسیر extended `\\?\D:\app\nul` از پایتون
- **اجرای مستقیم adb ممنوع** (بلاک است، ابزار Android MCP هم موجود نیست) → برای دیدن دستگاه: `flutter devices --device-timeout 10`
- فایل‌های لاگ را با `tail`/`grep` بخوان، Read کامل نکن
- `pubspec.lock` و `.dart_tool` تغییرات محلی زیاد دارند — فقط `lib/`، `android/`، `.arb`ها و فایل‌های معنی‌دار را کامیت کن

## ۱۰. چک‌لیست شروع کار برای ایجنت جدید

```bash
cd /d/app
git pull
export JAVA_HOME="D:/Tools/jdk-17"
export GRADLE_USER_HOME="D:/Tools/.gradle"
export PUB_CACHE="D:/Tools/pub-cache"
/d/flutter-sdk/bin/flutter devices --device-timeout 10   # چک گوشی
# اپ را اجرا کن (کانال فرمان):
rm -f /d/app/.reload_cmd && touch /d/app/.reload_cmd
tail -f /d/app/.reload_cmd | /d/flutter-sdk/bin/flutter run -d RZ8T10XT2JL --debug > /d/app/.flutter_run.log 2>&1 &
# بعد از بالا آمدن (لاگ: "A Dart VM Service")، تغییر بده و:
echo "r" >> /d/app/.reload_cmd
```
