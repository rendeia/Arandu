; ============================================================
;  Arandu Desktop - Instalador grafico (Inno Setup)
;  Gera um .exe de duplo clique que instala o Arandu Desktop por
;  USUARIO (sem exigir admin), cria atalhos, registra em
;  "Adicionar ou Remover Programas" e traz um desinstalador.
;
;  (Desktop = edicao instalada; Nano = edicao portatil/USB.
;   Mirim/Ete/Guacu = tier de tamanho do MODELO, coisa diferente.)
;
;  Compilar (completo):
;    "%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe" Arandu_Desktop.iss
;  Compilar (teste rapido, sem modelo/llamafile - so valida estrutura):
;    ISCC.exe /DFAST Arandu_Desktop.iss
;
;  Fonte dos arquivos: D:\Arandu-desktop (instalacao ja montada e testada).
; ============================================================

#define MyAppName "Arandu Desktop"
#define MyAppVersion "1.1"
#define MyAppPublisher "Rendeia"
#define MyAppURL "https://github.com/rendeia"
#define SourceDir "D:\Arandu-desktop"

[Setup]
; AppId identifica o app para updates/desinstalacao - NAO mudar entre versoes.
AppId={{92FBE097-8328-4407-BE67-40D3AE9CAC99}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
; Instalacao por usuario em %LOCALAPPDATA% (sem admin; passa no WDAC corporativo).
PrivilegesRequired=lowest
DefaultDirName={localappdata}\Programs\Arandu Desktop
DefaultGroupName=Arandu Desktop
DisableProgramGroupPage=yes
DisableDirPage=auto
OutputDir=D:\
#ifdef FAST
OutputBaseFilename=Arandu-Desktop-{#MyAppVersion}-Setup-TESTE
#else
OutputBaseFilename=Arandu-Desktop-{#MyAppVersion}-Setup
#endif
Compression=lzma2/fast
SolidCompression=no
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayName={#MyAppName} {#MyAppVersion}
; Espaco necessario aprox. (modelo + motor) para o wizard avisar cedo.
ExtraDiskSpaceRequired=0

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "Criar atalho na Área de Trabalho"; GroupDescription: "Atalhos adicionais:"
Name: "autostart"; Description: "Iniciar o Arandu Desktop junto com o Windows"; GroupDescription: "Inicialização:"; Flags: unchecked

[Files]
; Arquivos grandes: incluidos so na compilacao COMPLETA (sem /DFAST).
#ifndef FAST
Source: "{#SourceDir}\Qwen_Qwen3-1.7B-Q4_K_M.gguf"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\llamafile.exe"; DestDir: "{app}"; Flags: ignoreversion
#endif
; Todo o resto (chat.html ja rebrandeado, motor llama\, ferramentas\, vendor\,
; lancadores, modelo.txt, README, LICENSE). Exclui runtime (cache/memoria) e os
; grandes ja tratados acima.
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion; Excludes: "cache\*,memoria\*,*.log,Qwen_Qwen3-1.7B-Q4_K_M.gguf,llamafile.exe"

[Dirs]
; Runtime: criadas vazias na instalacao (o app grava aqui em uso).
Name: "{app}\cache"
Name: "{app}\memoria\itens"

[Icons]
Name: "{group}\Arandu Desktop"; Filename: "{sys}\wscript.exe"; Parameters: """{app}\Iniciar_Arandu_Desktop.vbs"""; WorkingDir: "{app}"; Comment: "Abrir o Arandu Desktop"
Name: "{group}\Desligar Arandu Desktop"; Filename: "{app}\Desligar_Desktop.bat"; WorkingDir: "{app}"; Comment: "Encerrar o servidor do Arandu"
Name: "{group}\Desinstalar Arandu Desktop"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Arandu Desktop"; Filename: "{sys}\wscript.exe"; Parameters: """{app}\Iniciar_Arandu_Desktop.vbs"""; WorkingDir: "{app}"; Tasks: desktopicon
Name: "{userstartup}\Arandu Desktop"; Filename: "{sys}\wscript.exe"; Parameters: """{app}\Iniciar_Arandu_Desktop.vbs"""; WorkingDir: "{app}"; Tasks: autostart

[Run]
Filename: "{sys}\wscript.exe"; Parameters: """{app}\Iniciar_Arandu_Desktop.vbs"""; Description: "Abrir o Arandu Desktop agora"; Flags: postinstall nowait skipifsilent

[UninstallRun]
; Encerra o motor antes de remover os arquivos (evita "arquivo em uso").
Filename: "{sys}\taskkill.exe"; Parameters: "/IM llamafile.exe /F"; Flags: runhidden; RunOnceId: "KillLlamafile"
Filename: "{sys}\taskkill.exe"; Parameters: "/IM llama-server.exe /F"; Flags: runhidden; RunOnceId: "KillLlamaServer"

[UninstallDelete]
; Remove dados gerados em uso que nao vieram do instalador.
Type: filesandordirs; Name: "{app}\cache"
Type: filesandordirs; Name: "{app}\memoria"
