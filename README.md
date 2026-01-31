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
- `flad add button` -> `lib/ui/button.dart`

Custom target:
- `flad add button --path lib/shared/ui` -> `lib/shared/ui/button.dart`

## Hozirgi komponentlar
- button

## Yangi komponent qo'shish
`bin/flad_cli.dart` ichida:
- `_componentTemplates` map ga yangi key qo'shing
- Shu komponent uchun Dart template string yarating

Namuna:
```
const _componentTemplates = {
  'button': _buttonDart,
  'card': _cardDart,
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
# flad
