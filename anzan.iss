[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "fr"; MessagesFile: "compiler:Languages\French.isl"
Name: "pt"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "it"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "es"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "de"; MessagesFile: "compiler:Languages\German.isl"
Name: "tr"; MessagesFile: "compiler:Languages\Turkish.isl"

[Setup]
AppName="Anzan"
AppVersion=0.6.0
ArchitecturesInstallIn64BitMode=x64os
DefaultDirName="{commonpf}\Anzan"
DefaultGroupName="Anzan"

[Dirs]
Name: "{app}\data"

[Files]
Source: ".\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data\"; Flags: ignoreversion
Source: ".\build\windows\x64\runner\Release\anzan.exe"; DestDir: "{app}\"; Flags: ignoreversion
Source: ".\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}\"; Flags: ignoreversion
Source: ".\build\windows\x64\runner\Release\libmpv-2.dll"; DestDir: "{app}\"; Flags: ignoreversion
Source: ".\build\windows\x64\runner\Release\media_kit_libs_windows_audio_plugin.dll"; DestDir: "{app}\"; Flags: ignoreversion
Source: ".\build\windows\x64\runner\Release\url_launcher_windows_plugin.dll"; DestDir: "{app}\"; Flags: ignoreversion

[Icons]
Name: "{group}\Uninstall Anzan"; Filename: "{uninstallexe}"
