# Plan: Lich su xuat van ban va Dashboard thong ke

## Muc tieu

Tao them khu vuc xem lich su xuat van ban va dashboard thong ke so luong van ban nguoi dung da xuat theo thang. Moi lan bam "Xuat van ban", app phai luu lai snapshot du lieu tai thoi diem xuat de co the xem lai, tim kiem, xuat lai va ve sau dung lam case study cho AI.

## Nguyen tac san pham

- Lich su xuat la nguon du lieu chinh cho dashboard, khong suy dien tu file output tren may.
- Moi ban ghi lich su can doc lap voi cau hinh template hien tai: neu template bi sua/xoa sau do, lich su cu van xem lai duoc.
- Xoa template tren UI chi nen an khoi danh sach su dung hang ngay, khong xoa file template vat ly neu file do tung duoc dung de xuat.
- Dashboard nen tra loi nhanh cac cau hoi: thang nay xuat bao nhieu van ban, template nao duoc dung nhieu, ngay nao xuat nhieu, lan xuat nao loi/thanh cong.

## Brainstorm tinh nang

### Trang lich su xuat van ban

- Danh sach cac lan xuat theo thoi gian moi nhat.
- Tim kiem theo ten file xuat, ten template, gia tri field quan trong, thu muc xuat.
- Bo loc theo khoang ngay, thang, template, trang thai thanh cong/loi.
- Chi tiet mot lan xuat:
  - danh sach template da dung;
  - du lieu field da nhap;
  - single line values;
  - duong dan file output da tao;
  - thoi gian xuat, base file name, thu muc xuat;
  - trang thai thanh cong/loi va thong bao loi neu co.
- Hanh dong nhanh:
  - xuat lai tu snapshot cu;
  - nap du lieu cu vao form hien tai de sua tiep;
  - mo file output neu con ton tai;
  - copy/export snapshot JSON de chia se hoac lam test case.
- Can nhac danh dau/favorite mot lich su hay dung lam case study.

### Dashboard thong ke

- Tong so van ban da xuat trong thang hien tai.
- Tong so lan bam xuat trong thang hien tai.
- So file xuat thanh cong va so lan loi.
- Bieu do theo ngay trong thang.
- Top template duoc xuat nhieu.
- So van ban theo template va theo thang.
- Lich su gan day de bam vao chi tiet.
- Bo chon thang/nam.
- Chi so phu:
  - trung binh van ban moi ngay;
  - ngay xuat nhieu nhat;
  - template moi xoa nhung van con duoc tham chieu trong lich su.

### Case study cho AI ve sau

- Luu snapshot input/output theo lan xuat.
- Co the gan nhan case: "good", "needs_review", "failed".
- Co the an/loai tru field nhay cam truoc khi dung lam case study.
- Co the export thanh JSON gom: template metadata, field schema, field values, output files.

## Mo hinh du lieu de xuat

### Soft delete template

Bo sung vao `TemplateConfig`/`TemplateConfigModel`:

- `isDeleted`: template da bi an khoi danh sach chinh.
- `deletedAt`: thoi diem bi xoa mem.
- `createdAt`, `updatedAt`: phuc vu sap xep/kiem tra.

Repository mac dinh chi tra ve template chua xoa. Can them API rieng de lay template da xoa khi phuc vu lich su.

### Export history

Tao collection moi, vi du `ExportHistoryModel`, gom cac truong:

- `id`
- `createdAt`
- `baseFileName`
- `exportDirectory`
- `status`: `success` / `partialSuccess` / `failed`
- `templateIds`: list id template tai thoi diem xuat
- `templateSnapshots`: snapshot ten template, path file template, version, fields
- `fieldValues`: map field key -> value
- `singleLineValues`: map key -> value
- `outputFiles`: list file path da tao thanh cong
- `errorMessage`: loi tong neu co
- `documentCount`: so file van ban tao thanh cong
- `caseStudyStatus`: optional, dung cho AI ve sau

Ghi chu: vi Isar khong luu Map truc tiep tot trong embedded object, co the luu snapshot JSON string de giam migration phuc tap, sau do tao helper parse trong repository/service.

## Task checklist

### Phase 1: Nen tang du lieu

- [x] Them field soft delete vao domain/model template.
- [x] Cap nhat generated code bang `build_runner`.
- [x] Sua repository/data source de `getAllTemplates()` va `watchAllTemplates()` chi lay template chua xoa.
- [x] Them API `getTemplateByIdIncludingDeleted()` hoac `getTemplatesByIdsIncludingDeleted()` cho man hinh lich su.
- [x] Sua `TemplateService.deleteTemplate()` thanh soft delete cau hinh va khong xoa file template vat ly.
- [ ] Kiem tra import/export configuration de template bi xoa mem khong gay trung ten kho xu ly.

### Phase 2: Luu lich su moi lan xuat

- [x] Tao domain/model/repository/data source cho export history.
- [x] Dang ky schema Isar moi trong `IsarDatabase`.
- [x] Dang ky repository/service trong DI.
- [x] Sua `TemplateService.executeExport()` de tra ve ket qua export gom output files, skipped files, errors.
- [x] Sau khi bam xuat trong `FieldsInputViewModel.exported()`, luu history snapshot ke ca khi partial/failed.
- [x] Dam bao lich su duoc luu truoc khi form bi reset boi `doneExported()`.
- [x] Them test cho viec luu history va soft delete.

### Phase 3: Trang lich su xuat

- [ ] Tao feature `export_history` cho desktop.
- [ ] Tao list page voi tim kiem, bo loc thang/template/status.
- [ ] Tao detail page de xem snapshot field values, template snapshots va output files.
- [ ] Them action "Xuat lai" dung snapshot cu.
- [ ] Them action "Nap lai vao form" neu can tiep tuc sua du lieu.
- [ ] Them empty/error/loading states.
- [ ] Them localization vi/en cho label moi.

### Phase 4: Dashboard thong ke

- [ ] Tao feature `dashboard` cho desktop.
- [ ] Repository/service aggregate history theo thang.
- [ ] UI cards: tong van ban trong thang, tong lan xuat, thanh cong/loi, template top.
- [ ] Bieu do theo ngay trong thang.
- [ ] Bo chon thang/nam.
- [ ] Danh sach lich su gan day lien ket sang detail.

### Phase 5: Dieu huong va hoan thien

- [ ] Them route moi cho dashboard va export history.
- [ ] Them destination moi vao `NavigationRail`.
- [ ] Quyet dinh UX: tach `Dashboard` va `Lich su` thanh 2 menu, hoac tao mot menu `Thong ke` co tabs.
- [ ] Chay analyze/test.
- [ ] Kiem tra lai du lieu cu: template hien tai can default `isDeleted = false`.

## File du kien se edit

### Data package

- `packages/data/lib/src/template_config.dart`
- `packages/data/lib/src/template_config.g.dart`
- `packages/data/lib/src/entities/template_config_model.dart`
- `packages/data/lib/src/entities/template_config_model.g.dart`
- `packages/data/lib/src/data_source/template_local_data_source.dart`
- `packages/data/lib/src/repositories/template/template_repository.dart`
- `packages/data/lib/src/repositories/template/template_repository_impl.dart`
- `packages/data/lib/src/services/template_service.dart`
- `packages/data/lib/src/data_source/isar_database.dart`
- `packages/data/lib/data.dart`

Files moi du kien:

- `packages/data/lib/src/export_history.dart`
- `packages/data/lib/src/export_history.g.dart`
- `packages/data/lib/src/entities/export_history_model.dart`
- `packages/data/lib/src/entities/export_history_model.g.dart`
- `packages/data/lib/src/data_source/export_history_local_data_source.dart`
- `packages/data/lib/src/repositories/export_history/export_history_repository.dart`
- `packages/data/lib/src/repositories/export_history/export_history_repository_impl.dart`
- `packages/data/lib/src/services/export_history_service.dart`

### Desktop app

- `apps/desktop/lib/features/src/home/view_model/fields_input_view_model.dart`
- `apps/desktop/lib/features/src/home/view_model/fields_input_view_model.g.dart`
- `apps/desktop/lib/features/src/home/view_model/home_view_model.dart`
- `apps/desktop/lib/features/src/main/view_model/main_view_model.dart`
- `apps/desktop/lib/features/src/main/main_page.dart`
- `apps/desktop/lib/route/src/routes_path.dart`
- `apps/desktop/lib/route/src/app_routes.dart`
- `apps/desktop/lib/di/repositories_module.dart`
- `apps/desktop/lib/di/view_model_module.dart`
- `apps/desktop/lib/features/page.dart`

Files moi du kien:

- `apps/desktop/lib/features/src/export_history/export_history_page.dart`
- `apps/desktop/lib/features/src/export_history/export_history_detail_page.dart`
- `apps/desktop/lib/features/src/export_history/view_model/export_history_view_model.dart`
- `apps/desktop/lib/features/src/export_history/view_model/export_history_detail_view_model.dart`
- `apps/desktop/lib/features/src/export_history/components/export_history_item.dart`
- `apps/desktop/lib/features/src/export_history/components/export_history_filters.dart`
- `apps/desktop/lib/features/src/dashboard/dashboard_page.dart`
- `apps/desktop/lib/features/src/dashboard/view_model/dashboard_view_model.dart`
- `apps/desktop/lib/features/src/dashboard/components/dashboard_stat_card.dart`
- `apps/desktop/lib/features/src/dashboard/components/monthly_export_chart.dart`
- `apps/desktop/lib/features/src/dashboard/components/top_templates_panel.dart`

### Localization va tests

- `packages/localization/assets/translations/vi.json`
- `packages/localization/assets/translations/vi-VN.json`
- `packages/localization/assets/translations/en.json`
- `packages/localization/assets/translations/en-US.json`
- `packages/data/test/template_service_test.dart`

Files moi du kien:

- `packages/data/test/export_history_repository_test.dart`
- `packages/data/test/template_soft_delete_test.dart`

## De xuat UX ban dau

Nen them 2 muc tren `NavigationRail`:

- `Dashboard`: vao thang hien tai, phuc vu xem nhanh.
- `Lich su`: phuc vu tra cuu, xem chi tiet va xuat lai.

Ly do: dashboard va lich su co tan suat su dung khac nhau. Dashboard can giai dap nhanh bang so lieu, lich su can bo loc va thao tac chi tiet.

## Rui ro can xu ly

- Isar schema thay doi co the can migration/clear database trong dev neu generated schema khong tu nang cap truong moi nhu mong doi.
- Ten template dang co unique index. Neu soft delete ma nguoi dung tao lai template cung ten, can quy tac ro:
  - cho phep trung ten voi template da xoa, hoac
  - giu unique va yeu cau khoi phuc/doi ten.
- File template vat ly co the bi nguoi dung xoa ngoai app. Lich su van xem duoc snapshot input, nhung "xuat lai" can bao loi ro rang neu file goc khong con.
- Field image luu path anh; neu anh goc bi xoa, xuat lai co the thieu anh. Can hien canh bao trong detail.
