' ============================================================
'  Arandu Desktop - lancador "1 clique" (versao INSTALADA, nao portatil)
'  - Sobe o servidor llama SEM janela de console (escondido)
'  - Abre a IA no navegador padrao do sistema
'  - Mesma logica do IA_Portatil.vbs: usa a propria pasta como base,
'    entao funciona em qualquer local onde for instalado
'    (%LOCALAPPDATA%\Programs\Arandu Desktop por padrao).
' ============================================================
Option Explicit
Dim fso, sh, base, modelo, exe, chatUrl, cmd, i, ok, http

Set fso = CreateObject("Scripting.FileSystemObject")
Set sh  = CreateObject("WScript.Shell")

' pasta onde este .vbs esta (independe de onde foi instalado)
base   = fso.GetParentFolderName(WScript.ScriptFullName)
exe    = base & "\llamafile.exe"

' modelo ativo: lido de modelo.txt (troque o modelo editando esse arquivo,
' ou rode Usar_1B_Rapido.bat / Usar_3B_Qualidade.bat). Padrao: 1B rapido.
Dim nomeModelo, cfgFile
nomeModelo = "Llama-3.2-1B-Instruct-Q4_K_M.gguf"
cfgFile = base & "\modelo.txt"
If fso.FileExists(cfgFile) Then
    Dim linha
    linha = Trim(fso.OpenTextFile(cfgFile, 1).ReadLine())
    If linha <> "" Then nomeModelo = linha
End If
modelo = base & "\" & nomeModelo

' se ja houver servidor respondendo, so abre a janela
If Not ServidorNoAr() Then
    ' Garante a pasta de cache (prompt caching: --slot-save-path) — se nao existir,
    ' o llama-server falha ao salvar slots. Criada sob demanda; ignorada pelo Git.
    If Not fso.FolderExists(base & "\cache") Then fso.CreateFolder(base & "\cache")

    ' Motor de IA: PREFERE o llama-server.exe (llama.cpp, .exe comum) -> passa no
    ' AppLocker do Windows corporativo. Cai para o llamafile.exe (APE) se aquele
    ' nao existir (ex.: maquina sem restricao de execucao).
    '
    ' Otimizacao A: prompt caching
    '   --cache-reuse 256        reusa prefixo do prompt entre turnos via KV shift
    '   --slot-save-path "cache" persiste o slot em disco -> sobrevive ao sleep-idle
    Dim srvExe, cacheDir, engineOk, msgErros
    srvExe   = base & "\llama\llama-server.exe"
    cacheDir = base & "\cache"
    engineOk = False
    msgErros = ""

    ' 1) tenta o llama-server.exe primeiro (.exe comum, passa no AppLocker na
    '    maioria das maquinas corporativas; sem UI em ingles).
    If fso.FileExists(srvExe) Then
        cmd = """" & srvExe & """ -m """ & modelo & """" & _
              " --host 127.0.0.1 --port 8080 -c 2048 -t 3 -fa on" & _
              " -ctk q8_0 -ctv q8_0 -ub 256 -b 512 --no-webui" & _
              " --cache-reuse 256 --slot-save-path """ & cacheDir & """"
        sh.CurrentDirectory = base & "\llama"
        On Error Resume Next
        sh.Run cmd, 0, False
        If Err.Number = 0 Then
            engineOk = True
        Else
            msgErros = msgErros & "- llama-server.exe: " & Err.Description & vbCrLf
        End If
        On Error GoTo 0
    End If

    ' 2) se o llama-server.exe nao existir OU tiver sido bloqueado, cai para o
    '    llamafile.exe (formato APE) — em algumas maquinas e o INVERSO que passa
    '    no AppLocker/antivirus, entao os dois lados precisam ser tentados.
    If Not engineOk And fso.FileExists(exe) Then
        ' --sleep-idle-seconds 180: apos 3 min ocioso o servidor "dorme" e libera a RAM.
        cmd = """" & exe & """ --server -m """ & modelo & """" & _
              " --host 127.0.0.1 --port 8080 -c 2048 -t 3 -fa on" & _
              " -ctk q8_0 -ctv q8_0 -ub 256 -b 512 --gpu disable" & _
              " --sleep-idle-seconds 180" & _
              " --cache-reuse 256 --slot-save-path """ & cacheDir & """"
        sh.CurrentDirectory = base
        On Error Resume Next
        sh.Run cmd, 0, False
        If Err.Number = 0 Then
            engineOk = True
        Else
            msgErros = msgErros & "- llamafile.exe: " & Err.Description & vbCrLf
        End If
        On Error GoTo 0
    End If

    If Not engineOk Then
        MsgBox "Nao consegui iniciar o motor de IA neste Windows." & vbCrLf & vbCrLf & _
               "A politica de seguranca (AppLocker/antivirus) bloqueou os executaveis:" & vbCrLf & _
               msgErros & vbCrLf & _
               "O chat vai abrir assim mesmo; quando o servidor estiver no ar, atualize a pagina.", _
               vbExclamation, "Arandu Desktop - motor bloqueado pelo Windows"
    Else
        ' espera o modelo carregar (ate ~40s), checando a porta
        ok = False
        For i = 1 To 40
            WScript.Sleep 1000
            If ServidorNoAr() Then ok = True : Exit For
        Next
        If Not ok Then
            MsgBox "Nao consegui iniciar o servidor da IA." & vbCrLf & _
                   "Verifique a instalacao em " & base, vbExclamation, "Arandu Desktop"
            WScript.Quit
        End If
    End If
End If

' tambem sobe o AJUDANTE de saude do sistema (mini painel no canto superior).
' Somente leitura (RAM/disco/arquivos limpaveis); NUNCA apaga nada.
Dim ps1
ps1 = base & "\ferramentas\saude_sistema.ps1"
If fso.FileExists(ps1) Then
    If Not AjudanteNoAr() Then
        sh.CurrentDirectory = base
        sh.Run "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & ps1 & """", 0, False
    End If
End If

' URL local da interface (modo arquivo)
chatUrl = "file:///" & Replace(base, "\", "/") & "/chat.html"

' abre no navegador padrao configurado no sistema
sh.Run chatUrl, 1, False

' ---------- funcoes ----------
Function ServidorNoAr()
    ServidorNoAr = False
    On Error Resume Next
    Set http = CreateObject("MSXML2.XMLHTTP")
    http.open "GET", "http://127.0.0.1:8080/props", False
    http.send
    If Err.Number = 0 Then
        If http.status = 200 Then ServidorNoAr = True
    End If
    On Error GoTo 0
End Function

Function AjudanteNoAr()
    AjudanteNoAr = False
    On Error Resume Next
    Dim h2
    Set h2 = CreateObject("MSXML2.XMLHTTP")
    h2.open "GET", "http://127.0.0.1:8099/ping", False
    h2.send
    If Err.Number = 0 Then
        If h2.status = 200 Then AjudanteNoAr = True
    End If
    On Error GoTo 0
End Function
