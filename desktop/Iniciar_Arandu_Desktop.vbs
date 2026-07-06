' ============================================================
'  Arandu Desktop - Iniciar (versao instalada, nao portatil)
'  Sem menu: garante o modelo Arandu Mirim 1.1 em modelo.txt e abre a IA.
'  So reinicia o servidor se a versao estiver diferente (poupa tempo e RAM).
'  (Mirim/Ete/Guacu = tier de tamanho do modelo; Desktop = esta edicao instalada.)
' ============================================================
Option Explicit
Dim fso, sh, base, modeloArq, atual, cfgFile, ts
Set fso = CreateObject("Scripting.FileSystemObject")
Set sh  = CreateObject("WScript.Shell")
base = fso.GetParentFolderName(WScript.ScriptFullName)
cfgFile = base & "\modelo.txt"

' Modelo PADRAO: Arandu Mirim 1.1 (Qwen3-1.7B) — Mirim e o tier (tamanho pequeno).
modeloArq = "Qwen_Qwen3-1.7B-Q4_K_M.gguf"

atual = ""
If fso.FileExists(cfgFile) Then atual = Trim(fso.OpenTextFile(cfgFile, 1).ReadLine())

If Not fso.FileExists(base & "\" & modeloArq) Then
  MsgBox "Modelo nao encontrado:" & vbCrLf & modeloArq & vbCrLf & vbCrLf & _
         "Reinstale o Arandu Desktop (Instalar_Arandu_Desktop.ps1).", vbExclamation, "Arandu Desktop"
  WScript.Quit
End If

' Se modelo.txt estiver diferente, ajusta para o 1.1 e reinicia o servidor.
If LCase(modeloArq) <> LCase(atual) Then
  Set ts = fso.OpenTextFile(cfgFile, 2, True)
  ts.WriteLine modeloArq
  ts.Close
  sh.Run "taskkill /IM llamafile.exe /F", 0, True
  sh.Run "taskkill /IM llama-server.exe /F", 0, True
  WScript.Sleep 1500
End If

' Abre a IA (sobe o servidor oculto + ajudante de voz/saude + navegador padrao).
sh.Run "wscript.exe """ & base & "\IA_Desktop.vbs""", 0, False
