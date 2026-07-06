; ============================================================
;  Arandu Desktop - Instalador WEB (leve, baixa o modelo na hora)
;
;  Diferenca para o Arandu_Desktop.iss (completo):
;   - NAO embute o modelo Qwen3 (1,05 GB) nem o llamafile.exe (320 MB).
;   - Baixa o modelo do Hugging Face DURANTE a instalacao, com barra de
;     progresso e verificacao de integridade (SHA256).
;   - Resultado: instalador ~85 MB (vs. 1,33 GB do completo).
;
;  Requisito: INTERNET durante a instalacao (so pra baixar o modelo, ~1 GB).
;  Depois de instalado, o Arandu roda 100% offline como sempre.
;
;  Sem o llamafile.exe, usa o motor llama-server (embutido). Maquinas com
;  WDAC corporativo nem rodariam este .exe nao assinado, entao o fallback
;  llamafile e desnecessario aqui.
;
;  Compilar:
;    "%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe" Arandu_Desktop_Web.iss
; ============================================================

#define MyAppName "Arandu Desktop"
#define MyAppVersion "1.1"
#define MyAppPublisher "Rendeia"
#define MyAppURL "https://github.com/rendeia"
#define SourceDir "D:\Arandu-desktop"
#define ModeloArq "Qwen_Qwen3-1.7B-Q4_K_M.gguf"
#define ModeloUrl "https://huggingface.co/rendeia/Arandu-Nano-1.1-GGUF/resolve/main/Qwen_Qwen3-1.7B-Q4_K_M.gguf"
#define ModeloSha "B903E72BA850BD84F13D95E8F86767CE2962E0F8BBFBD66ECF080EDD47E9D2D7"

[Setup]
AppId={{92FBE097-8328-4407-BE67-40D3AE9CAC99}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
PrivilegesRequired=lowest
DefaultDirName={localappdata}\Programs\Arandu Desktop
DefaultGroupName=Arandu Desktop
DisableProgramGroupPage=yes
DisableDirPage=auto
OutputDir=D:\
OutputBaseFilename=Arandu-Desktop-{#MyAppVersion}-Setup-Web
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayName={#MyAppName} {#MyAppVersion}

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "Criar atalho na Área de Trabalho"; GroupDescription: "Atalhos adicionais:"
Name: "autostart"; Description: "Iniciar o Arandu Desktop junto com o Windows"; GroupDescription: "Inicialização:"; Flags: unchecked

[Files]
; Tudo do source MENOS o modelo, o llamafile e o runtime (cache/memoria).
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion; Excludes: "cache\*,memoria\*,*.log,{#ModeloArq},llamafile.exe"
; O modelo baixado (fica em {tmp}) e copiado para {app} ao instalar.
Source: "{tmp}\{#ModeloArq}"; DestDir: "{app}"; Flags: external ignoreversion

[Dirs]
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
Filename: "{sys}\taskkill.exe"; Parameters: "/IM llamafile.exe /F"; Flags: runhidden; RunOnceId: "KillLlamafile"
Filename: "{sys}\taskkill.exe"; Parameters: "/IM llama-server.exe /F"; Flags: runhidden; RunOnceId: "KillLlamaServer"

[UninstallDelete]
Type: filesandordirs; Name: "{app}\cache"
Type: filesandordirs; Name: "{app}\memoria"
; o modelo baixado nao veio do instalador -> removo explicitamente
Type: files; Name: "{app}\{#ModeloArq}"

[Code]
var
  DownloadPage: TDownloadWizardPage;

function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if ProgressMax <> 0 then
    DownloadPage.SetProgress(Progress, ProgressMax);
  Result := True;
end;

procedure InitializeWizard;
begin
  DownloadPage := CreateDownloadPage(
    'Baixando o modelo do Arandu',
    'O modelo de IA (~1 GB) esta sendo baixado do Hugging Face. Depois disso, o Arandu roda 100% offline.',
    @OnDownloadProgress);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  if CurPageID = wpReady then begin
    DownloadPage.Clear;
    DownloadPage.Add('{#ModeloUrl}', '{#ModeloArq}', '{#ModeloSha}');
    DownloadPage.Show;
    try
      try
        DownloadPage.Download;
        Result := True;
      except
        if DownloadPage.AbortedByUser then
          Log('Download cancelado pelo usuario.')
        else
          SuppressibleMsgBox(
            'Nao consegui baixar o modelo do Arandu.' + #13#10#13#10 +
            'Verifique a conexao com a internet e tente de novo.' + #13#10 +
            'Detalhe: ' + AddPeriod(GetExceptionMessage),
            mbCriticalError, MB_OK, IDOK);
        Result := False;
      end;
    finally
      DownloadPage.Hide;
    end;
  end else
    Result := True;
end;
