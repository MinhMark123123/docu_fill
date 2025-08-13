// lib/core/l10n/app_lang_keys.dart

/// Contains all localization keys used in the application.
/// This class should not be instantiated.
abstract class AppLang {
  AppLang._(); // Prevents instantiation

  static const String appName = "app_name";

  // --- Actions ---
  static const String actionsSave = "actions.save";
  static const String actionsCancel = "actions.cancel";
  static const String actionsDone = "actions.done";
  static const String actionsEdit = "actions.edit";
  static const String actionsDelete = "actions.delete";
  static const String actionsAdd = "actions.add";
  static const String actionsCreate = "actions.create";
  static const String actionsNext = "actions.next";
  static const String actionsBack = "actions.back";
  static const String actionsSubmit = "actions.submit";
  static const String actionsContinue = "actions.continue";
  static const String actionsConfirm = "actions.confirm";
  static const String actionsYes = "actions.yes";
  static const String actionsNo = "actions.no";
  static const String actionsClose = "actions.close";
  static const String actionsOpen = "actions.open";
  static const String actionsView = "actions.view";
  static const String actionsSearch = "actions.search";
  static const String actionsClear = "actions.clear";
  static const String actionsApply = "actions.apply";
  static const String actionsReset = "actions.reset";
  static const String actionsUpload = "actions.upload";
  static const String actionsDownload = "actions.download";
  static const String actionsShare = "actions.share";
  static const String actionsSend = "actions.send";
  static const String actionsFillDocument = "actions.fill_document";
  static const String actionsNewDocument = "actions.new_document";
  static const String actionsImportData = "actions.import_data";
  static const String actionsExportData = "actions.export_data";
  static const String actionsSignDocument = "actions.sign_document";
  static const String actionsPreviewDocument = "actions.preview_document";
  static const String actionsStartProcess = "actions.start_process";
  static const String actionsFinishProcess = "actions.finish_process";
  static const String actionsRetryAction = "actions.retry_action";
  static const String actionsOpenSettings = "actions.open_settings";
  static const String actionsShowMore = "actions.show_more";
  static const String actionsShowLess = "actions.show_less";
  static const String actionsAcceptTerms = "actions.accept_terms";
  static const String actionsDeclineOffer = "actions.decline_offer";
  static const String actionsProceedToPayment = "actions.proceed_to_payment";
  static const String actionsLearnMoreAbout = "actions.learn_more_about";
  static const String actionsGetStartedNow = "actions.get_started_now";
  static const String actionsGoToAppSettings = "actions.go_to_app_settings";
  static const String actionsTryAgainLater = "actions.try_again_later";
  static const String actionsUploadTemplate = "actions.upload_template";
  static const String actionsBrowseFiles = "actions.browse_files";
  static const String actionsOpenDocument = "actions.open_document";
  static const String actionsReturnToTemplates = "actions.return_to_templates";
  static const String actionsDownloadDocument = "actions.download_document";
  static const String actionsSelectDateTime = "actions.select_date_time";
  static const String actionsShowMenu = "actions.show_menu";
  static const String actionsPickImage = "actions.pick_image";

  // --- Labels ---
  static const String labelsTemplates = "labels.templates";
  static const String labelsDocuments = "labels.documents";
  static const String labelsSettings = "labels.settings";
  static const String labelsRecentTemplates = "labels.recent_templates";
  static const String labelsNewTemplate = "labels.new_template";
  static const String labelsAllTemplates = "labels.all_templates";
  static const String labelsConfigureTemplateFields =
      "labels.configure_template_fields";
  static const String labelsDetectedFields = "labels.detected_fields";
  static const String labelsFieldKey = "labels.field_key";
  static const String labelsFieldName = "labels.field_name";
  static const String labelsInputType = "labels.input_type";
  static const String labelsOptions = "labels.options";
  static const String labelsRequired = "labels.required";
  static const String labelsActions = "labels.actions";
  static const String labelsUploadDocxFile = "labels.upload_docx_file";
  static const String labelsSupportedFileTypes = "labels.supported_file_types";
  static const String labelsThemeColor = "labels.theme_color";
  static const String labelsImportExportConfiguration =
      "labels.import_export_configuration";
  static const String labelsImportConfiguration = "labels.import_configuration";
  static const String labelsExportConfiguration = "labels.export_configuration";
  static const String labelsExportProgress = "labels.export_progress";
  static const String labelsInputFieldName = "labels.input_field_name";
  static const String labelsInputOptions = "labels.input_options";
  static const String labelsEnterTemplateName = "labels.enter_template_name";
  static const String labelsTemplateName = "labels.template_name";
  static const String labelsDefaultValue = "labels.default_value";
  static const String labelsEnableMultipleChoice =
      "labels.enable_multiple_choice";
  static const String labelsSingle = "labels.single";
  static const String labelsMultiple = "labels.multiple";

  // --- Messages ---
  static const String messagesReviewAndConfigureFields =
      "messages.review_and_configure_fields";
  static const String messagesDragAndDropDocx = "messages.drag_and_drop_docx";
  static const String messagesDocumentExportedSuccessfully =
      "messages.document_exported_successfully";
  static const String messagesDocumentExportedReadyForDownload =
      "messages.document_exported_ready_for_download";
  static const String messagesUploadTemplate = "messages.upload_template";
  static const String documentSuccessFullyCreate =
      "messages.document_successfully_create";
  static const String messagesConfirmCreateDocument =
      "messages.confirm_create_document";
  static const String messagesEnterTemplateNameHint =
      "messages.enter_template_name_hint";
  static const String messagesInputTextHint = "messages.input_text_hint";
  static const String messagesFieldIsRequired = "messages.field_is_required";
  static const String messagesPickFolderToExport =
      "messages.pick_folder_to_export";
  static const String messagesNameTheDocumentExported =
      "messages.name_the_document_exported";
  static const String messagesDateFormatInvalid =
      "messages.date_format_invalid";
  static const String messagesEnterDateFormat = "messages.enter_date_format";

  // If you had more top-level keys or nested structures, you'd continue like this:
  // static const String someOtherTopLevelKey = "some_other_top_level_key";
  // static const String nestedObjectFirstKey = "nested_object.first_key";
}
