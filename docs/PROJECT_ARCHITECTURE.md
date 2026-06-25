# Project Architecture

Tai lieu nay mo ta kien truc hien tai cua DocuFill, cach chia package, pattern trien khai feature, cac cong cu code generation va tool `generate_keys.dart`.

## Tong quan monorepo

Repo dung `melos` de quan ly nhieu Flutter/Dart package:

- `apps/desktop`: ung dung desktop chinh.
- `apps/mobile`: ung dung mobile, hien co scaffold va mot so cau hinh platform.
- `packages/core`: hang so, enum, utils dung chung.
- `packages/data`: tang data, entities, repositories, local data source, services xu ly file/docx/xlsx/AI.
- `packages/design`: theme, design tokens, UI atoms/components dung chung.
- `packages/localization`: cau hinh `easy_localization`, file dich va key generated.
- `tools`: cac script ho tro dev, hien co `generate_keys.dart`.

File cau hinh workspace:

- `melos.yaml`: khai bao packages `apps/*`, `packages/*` va scripts build/analyze/format.
- `pubspec.yaml` o root: khai bao SDK va dev dependency `melos`.

## Package boundaries

### apps/desktop

Vai tro:

- Chua UI, routing, DI, ViewModel va feature pages cua ung dung desktop.
- Dung `GoRouter` cho dieu huong.
- Dung `maac_mvvm_with_get_it` va `maac_mvvm_annotation` cho MVVM + bind state.
- Dung `GetIt` lam service locator.
- Khoi tao app trong `main.dart`: window manager, localization, screen util, Isar database, DI modules.

Thu muc quan trong:

- `lib/main.dart`: bootstrap app.
- `lib/app.dart`: `MaterialApp.router`, theme, localization wrapper, loading wrapper.
- `lib/route`: khai bao route path va `GoRouter`.
- `lib/di`: dang ky repositories, services, view models.
- `lib/core`: base view/view model, event navigation/snackbar/dialog/loading.
- `lib/features`: cac feature UI.

Feature hien tai:

- `home`: danh sach template va form nhap field/xuat van ban.
- `configure`: cau hinh field cua template.
- `upload`: upload template.
- `setting`: settings, Gemini config, API log actions.
- `log_history`: xem lich su log API hien tai.
- `tool`: cac cong cu phu.
- `splash`: man hinh khoi dong.

### packages/data

Vai tro:

- Chua model domain, Isar entities, local data source, repository implementation va service nghiep vu.
- Xu ly docx/xlsx, parse template, export template, trich xuat data, Gemini.
- La noi nen dat cac model va service lien quan export history/dashboard neu can persistent data.

Pattern hien tai:

- Domain model: `template_config.dart`, `template_field.dart`.
- Isar entity: `entities/*_model.dart`.
- Data source: thao tac truc tiep voi Isar.
- Repository: interface + implementation, convert entity <-> domain.
- Service: nghiep vu cao hon repository, vi du `TemplateService`.

Vi du flow template:

1. UI/ViewModel goi `TemplateService` hoac `TemplateRepository`.
2. Repository convert `TemplateConfig` sang `TemplateConfigModel`.
3. Local data source thao tac Isar collection.
4. Entity convert nguoc ve domain khi tra data len app.

### packages/core

Vai tro:

- Chua utilities va constant dung chung.
- Hien co helper cho date time, docx, excel, path/app constants va enum.
- Nen dat logic pure, khong phu thuoc UI feature cu the.

Luu y:

- Neu helper lien quan truc tiep den Flutter UI cua desktop, uu tien dat trong `apps/desktop/lib/core`.
- Neu helper xu ly file/data co the tai su dung cho data package, dat trong `packages/core`.

### packages/design

Vai tro:

- Chua theme, token va atom UI dung chung.
- Export qua `packages/design/lib/ui.dart`.
- Desktop app import `package:design/ui.dart` de dung theme, spacing, typography, atom widgets.

Thanh phan quan trong:

- `src/theme`: app theme va custom colors.
- `src/methodology/tokens`: colors, typography, spacing, radii, dimens.
- `src/atom`: widgets nho nhu avatar, image, dropdown, text field.

### packages/localization

Vai tro:

- Chua translation assets va wrapper `EasyLocalizationWrapper`.
- Export `AppLang` va extension `.tr()` tu `easy_localization`.

Files quan trong:

- `assets/translations/en-US.json`
- `assets/translations/vi-VN.json`
- `assets/translations/en.json`
- `assets/translations/vi.json`
- `lib/src/app_lang.dart`: generated localization keys.
- `lib/src/easy_localization_wrapper.dart`: supported locales, fallback/start locale.

## Desktop MVVM pattern

Moi page nen theo flow:

- Page extends `BaseView<MyViewModel>`.
- ViewModel extends `BaseViewModel`.
- ViewModel dung `@BindableViewModel()` va field `@Bind()` de tao stream data generated.
- UI doc state qua `StreamDataConsumer`.
- Dieu huong/snackbar/dialog/loading di qua event trong `BaseViewModel`, khong goi truc tiep tu service.

Base classes:

- `apps/desktop/lib/core/src/base_view_model.dart`
  - `navigatePage`
  - `showSnackbar`
  - `showAppAlertDialog`
  - `showSelectionDialog`
  - `loadingGuard`
- `apps/desktop/lib/core/src/base_view.dart`
  - Lang nghe event tu ViewModel.
  - Goi `GoRouter`, `ScaffoldMessenger`, `showDialog`, `LoadingDialogManager`.

Quy tac de them ViewModel moi:

1. Tao file ViewModel va them `part '...g.dart';`.
2. Gan `@BindableViewModel()`.
3. Dung `@Bind()` cho state can expose.
4. Dang ky trong `apps/desktop/lib/di/view_model_module.dart`.
5. Chay build runner.

## Routing

Routes nam o:

- `apps/desktop/lib/route/src/routes_path.dart`
- `apps/desktop/lib/route/src/app_routes.dart`

Pattern:

- `RoutesPath` giu string route tap trung.
- `GoRouter` co `ShellRoute` boc `MainPage`.
- Cac route chinh hien tai: splash, home, tool, setting.
- Route con cua `home`: input/configure/upload/quick image input.
- Route con cua `setting`: theme/log history/log detail.

Khi them page moi:

1. Them path vao `RoutesPath`.
2. Them `GoRoute` vao `app_routes.dart`.
3. Neu can hien tren sidebar, cap nhat `MainDesktopMenu` trong `main_view_model.dart`.
4. Neu page can export public qua feature barrel, cap nhat `apps/desktop/lib/features/page.dart`.

## Dependency Injection

Service locator:

- `apps/desktop/lib/di/app_get_it.dart`
- Bien `sl` va `inject` tro den `GetIt.instance`.

Modules:

- `repositories_module.dart`: dang ky Isar, data source, repository, service.
- `view_model_module.dart`: dang ky ViewModel.

Bootstrap:

`apps/desktop/lib/main.dart` goi theo thu tu:

1. Flutter binding/window manager.
2. `EasyLocalization.ensureInitialized()`.
3. `ScreenUtil.ensureScreenSize()`.
4. `IsarDatabase.instance.initialize()`.
5. `setupRepositoriesModule()`.
6. `setupViewModelModule()`.
7. `runApp()`.

## Data va Isar

Database:

- `packages/data/lib/src/data_source/isar_database.dart`
- Hien dang mo Isar voi schema:
  - `TemplateConfigModelSchema`
  - `AppSettingsModelSchema`

Khi them collection moi:

1. Tao entity trong `packages/data/lib/src/entities`.
2. Them annotation `@collection`.
3. Them `part '*.g.dart';`.
4. Them schema vao danh sach `Isar.open([...])`.
5. Export entity/data source/repository/service trong `packages/data/lib/data.dart` neu app can dung.
6. Chay build runner.

Luu y migration:

- Isar schema change co the anh huong database local cua dev/user.
- Truong moi nen co default value an toan neu du lieu cu da ton tai.
- Neu thay doi index unique, can quy tac ro ve du lieu cu.

## Code generation

Repo hien dung cac generator:

- `maac_mvvm_generator`: tao binding cho ViewModel.
- `json_serializable`: tao `fromJson`/`toJson`.
- `isar_community_generator`: tao Isar schema/query helpers.
- `flutter_launcher_icons`: tao icon app khi can.

Lenh thuong dung:

```bash
melos run build
melos run analyze
melos run format
melos run lint:fix
```

Neu chi muon build trong mot package:

```bash
cd apps/desktop
dart run build_runner build --delete-conflicting-outputs
```

hoac:

```bash
cd packages/data
dart run build_runner build --delete-conflicting-outputs
```

## Localization va `tools/generate_keys.dart`

`tools/generate_keys.dart` doc file:

- Input: `packages/localization/assets/translations/en-US.json`
- Output: `packages/localization/lib/src/app_lang.dart`

Script se:

- Doc JSON tieng Anh `en-US`.
- Flatten nested keys thanh dang `section.key`.
- Tao class `AppLang` voi static const key.
- Sort key de output on dinh.
- Gom key theo top-level section.

Chay script:

```bash
dart run tools/generate_keys.dart
```

Quy trinh them text moi:

1. Them key vao `en-US.json`.
2. Them cung key vao `vi-VN.json`, `en.json`, `vi.json` neu app dang dung day du cac file nay.
3. Chay `dart run tools/generate_keys.dart`.
4. Dung key qua `AppLang.someGeneratedKey.tr()`.

Luu y:

- `app_lang.dart` la file generated, khong edit tay.
- Script hien lay `en-US.json` lam source of truth. Neu key chi co trong file vi ma khong co trong `en-US`, `AppLang` se khong sinh key do.
- Ten bien generated duoc tao bang camelCase tu key, tach theo `.` va `_`.

## Quy trinh them feature moi

Checklist de them mot feature desktop:

- [ ] Tao folder trong `apps/desktop/lib/features/src/<feature_name>`.
- [ ] Tao page extends `BaseView`.
- [ ] Tao ViewModel extends `BaseViewModel`.
- [ ] Dang ky ViewModel trong `view_model_module.dart`.
- [ ] Them route path va `GoRoute`.
- [ ] Export page/view model trong `features/page.dart` neu can.
- [ ] Them localization keys.
- [ ] Chay `tools/generate_keys.dart` neu co key moi.
- [ ] Chay `melos run build` neu co generator.
- [ ] Chay `melos run analyze`.

Neu feature can persistent data:

- [ ] Tao domain model trong `packages/data/lib/src`.
- [ ] Tao Isar entity trong `packages/data/lib/src/entities`.
- [ ] Tao local data source.
- [ ] Tao repository interface + implementation.
- [ ] Tao service neu co nghiep vu phuc tap.
- [ ] Dang ky DI trong `repositories_module.dart`.
- [ ] Export public API trong `packages/data/lib/data.dart`.
- [ ] Them schema vao `IsarDatabase`.
- [ ] Viet test data/service neu logic co rui ro.

## Huong dan kien truc cho Export History/Dashboard

Theo plan `docs/EXPORT_HISTORY_DASHBOARD_PLAN.md`, nen dat phan data nhu sau:

- `ExportHistory` domain model trong `packages/data`.
- `ExportHistoryModel` Isar entity trong `packages/data/lib/src/entities`.
- `ExportHistoryLocalDataSource` thao tac Isar.
- `ExportHistoryRepository` tra ve data cho app va aggregate query co ban.
- `ExportHistoryService` xu ly snapshot, serialize/deserialize JSON va replay export neu can.

Desktop UI nen dat:

- `apps/desktop/lib/features/src/export_history`
- `apps/desktop/lib/features/src/dashboard`

Luon luu history tai thoi diem `FieldsInputViewModel.exported()` truoc khi clear form bang `doneExported()`.

## Nguyen tac phu thuoc

Huong dependency nen giu:

- `apps/desktop` phu thuoc `design`, `core`, `data`, `localization`.
- `packages/design` phu thuoc `core`, `localization`.
- `packages/data` phu thuoc `core`, `localization` va cac thu vien data/file/AI.
- `packages/core` co the phu thuoc `localization` va helper thu vien thap.
- `packages/localization` nen doc lap, chi boc `easy_localization`.

Nen tranh:

- `packages/data` import UI desktop.
- `packages/core` phu thuoc feature cu the.
- Service trong data goi truc tiep snackbar/dialog/navigation.
- UI thao tac Isar truc tiep bo qua repository.
