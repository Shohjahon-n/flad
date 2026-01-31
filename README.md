# flad

Shadcn-style Flutter UI CLI tool.

## Maqsad
- Flutter UI komponentlarini paket sifatida emas, **source file** sifatida projectga ko'chirish.
- Foydalanuvchi ko'chirilgan kodni to'liq tahrir qilishi mumkin.
- Minimal, unopinionated, vendor lock-in yo'q.

## Nima kerak
- Dart SDK (>= 3.3.0)
- Flutter project (kamida `lib/` papkasi bo'lishi kerak)

## Qanday ishlaydi
CLI komponent shablonlarini (Dart string) tanlaydi va:
- Flutter projectdagi `lib/` borligini tekshiradi
- Target papkani yaratadi
- Fayl bor bo'lsa ustidan yozmaydi
- Aniq console xabarlar chiqaradi

Ko'chirilgan fayllar **CLIga bog'liq emas**. Ya'ni, keyin komponentlar mustaqil ishlaydi.

## Buyruqlar
```
flad init
flad add <component>
flad add <component> --path <custom_path>
```

## Misollar
```
flad init
flad add button
flad add button --path lib/shared/ui
```

Default target:
- `flad add button` -> `lib/ui/button.dart` (agar init paytida boshqacha tanlanmagan bo'lsa)

Custom target:
- `flad add button --path lib/shared/ui` -> `lib/shared/ui/button.dart`

## Init paytida path tanlash
`flad init` ishga tushganda CLI sizdan target papkani so'raydi. Default qiymat:
```
lib/ui
```
Tanlangan path `.flad.json` faylida saqlanadi va keyingi `add` buyruqlarida ishlatiladi.

## Hozirgi komponentlar
- button
- input

## Yangi komponent qo'shish
`lib/src/templates/` ichida:
- yangi template string fayl yarating
- `lib/src/templates.dart` ichida ro'yxatga qo'shing

Namuna:
```
const componentTemplates = {
  'button': buttonTemplate,
  'card': cardTemplate,
};
```

## Dizayn falsafasi
- Minimal
- Unopinionated
- Paket import qilinmaydi
- Kod ochiq va tahrirlashga tayyor

## Ishga tushirish (local)
```
dart pub get
dart run bin/flad_cli.dart --help
```
