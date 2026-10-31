; DocuFill installer (Inno Setup 6).
;
; Build the app first (flutter build windows --release), then:
;   ISCC.exe windows_inno_script.iss
; With the offline engine (build it with engine\build.ps1 first):
;   ISCC.exe /DWithEngine windows_inno_script.iss
;
; Paths are relative to this script, so the repo can live anywhere.

#define MyAppName "DocuFill"
#ifndef MyAppVersion
  #define MyAppVersion "1.1.0"
#endif
#define MyAppPublisher "MT Company, Inc."
#define MyAppExeName "docu_fill.exe"
#define BuildDir "..\build\windows\x64\runner\Release"
#define EngineDir "..\..\..\engine\build\dist\docufill_engine"

[Setup]
; Same AppId as earlier versions: installing upgrades in place and keeps the
; user's data (it lives in Documents, not in the install folder).
AppId={{B468AB94-7D27-4CA3-9627-12E7AEAEB228}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes
OutputDir=Output
#ifdef WithEngine
OutputBaseFilename=DocuFillSetup_{#MyAppVersion}_offline
; The engine is ~3 GB, mostly already-compressed model weights.
Compression=lzma2/fast
SolidCompression=no
#else
OutputBaseFilename=DocuFillSetup_{#MyAppVersion}
Compression=lzma2
SolidCompression=yes
#endif
SetupIconFile=..\windows\runner\resources\app_icon.ico
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
#ifdef WithEngine
Source: "{#EngineDir}\*"; DestDir: "{app}\engine"; Flags: ignoreversion recursesubdirs createallsubdirs
#endif

[InstallDelete]
; Engine files of an older version (e.g. a different model) must not linger.
Type: filesandordirs; Name: "{app}\engine"

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
