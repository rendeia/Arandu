# ============================================================
#  Instalar_Arandu_Desktop.ps1 - instala o Arandu Desktop (edicao NAO portatil)
#
#  Reusa as mesmas configuracoes/layout do Arandu Nano (motor, flags,
#  chat.html, ferramentas de voz/saude, memoria em camadas), mas copia
#  tudo para um local FIXO no disco do PC (%LOCALAPPDATA%\Rendeia\AranduDesktop)
#  em vez de rodar do pendrive. Isso libera autostart e um atalho fixo no
#  Menu Iniciar, coisas que o Windows bloqueia para executaveis em USB.
#
#  (Desktop = edicao instalada; Nano = edicao portatil. Mirim/Ete/Guacu =
#   tier de tamanho do MODELO, coisa diferente da edicao.)
#
#  Uso:
#    powershell -ExecutionPolicy Bypass -File Instalar_Arandu_Desktop.ps1
#    powershell -ExecutionPolicy Bypass -File Instalar_Arandu_Desktop.ps1 -AutoIniciar
#    powershell -ExecutionPolicy Bypass -File Instalar_Arandu_Desktop.ps1 -ComRAG
#
#  -AutoIniciar   tambem cria atalho na pasta Inicializar (abre com o Windows)
#  -ComRAG        inclui o embedding bge-m3 + base de conhecimento
#  -CopiarMemoria copia a memoria/perfil ja existente no Nano (padrao: comeca vazio)
#  -Destino       pasta de instalacao (padrao: %LOCALAPPDATA%\Rendeia\AranduDesktop)
# ============================================================
param(
    [switch]$AutoIniciar,
    [switch]$ComRAG,
    [switch]$CopiarMemoria,
    [string]$Destino = (Join-Path $env:LOCALAPPDATA "Rendeia\AranduDesktop")
)

$ErrorActionPreference = "Stop"
$raiz = $PSScriptRoot

Write-Host "=== Instalando Arandu Desktop em $Destino ===" -ForegroundColor Cyan

# --- arquivos/pastas base (sempre) ---
$arquivosBase = @(
    "chat.html",
    "Qwen_Qwen3-1.7B-Q4_K_M.gguf",
    "IA_Desktop.vbs",
    "Iniciar_Arandu_Desktop.vbs",
    "Desligar_Desktop.bat",
    "README.md",
    "LICENSE"
)
$pastasBase = @("ferramentas", "vendor")

# --- validacao antes de comecar ---
$faltando = @()
foreach ($f in $arquivosBase) {
    if (-not (Test-Path (Join-Path $raiz $f))) { $faltando += $f }
}
foreach ($p in $pastasBase) {
    if (-not (Test-Path (Join-Path $raiz $p))) { $faltando += "$p\" }
}
if (-not (Test-Path (Join-Path $raiz "llama\llama-server.exe")) -and -not (Test-Path (Join-Path $raiz "llamafile.exe"))) {
    $faltando += "llama\llama-server.exe (ou llamafile.exe)"
}
if ($ComRAG -and -not (Test-Path (Join-Path $raiz "rag\bge-m3-Q4_K_M.gguf"))) {
    $faltando += "rag\bge-m3-Q4_K_M.gguf"
}
if ($faltando.Count -gt 0) {
    Write-Host "ERRO: arquivos ausentes na pasta de origem ($raiz):" -ForegroundColor Red
    $faltando | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

# --- prepara pasta de destino ---
New-Item -ItemType Directory -Path $Destino -Force | Out-Null

# --- copia arquivos base ---
foreach ($f in $arquivosBase) {
    Copy-Item (Join-Path $raiz $f) (Join-Path $Destino $f) -Force
    Write-Host "  + $f"
}

# --- copia pastas base (ferramentas de voz/saude, pdf.js) ---
foreach ($p in $pastasBase) {
    Copy-Item (Join-Path $raiz $p) (Join-Path $Destino $p) -Recurse -Force
    Write-Host "  + $p\"
}

# --- motor: prefere llama\ (passa no AppLocker), senao llamafile.exe ---
if (Test-Path (Join-Path $raiz "llama\llama-server.exe")) {
    Copy-Item (Join-Path $raiz "llama") (Join-Path $Destino "llama") -Recurse -Force
    Write-Host "  + llama\ (llama-server.exe)"
}
if (Test-Path (Join-Path $raiz "llamafile.exe")) {
    Copy-Item (Join-Path $raiz "llamafile.exe") (Join-Path $Destino "llamafile.exe") -Force
    Write-Host "  + llamafile.exe (fallback)"
}

# --- garante o modelo ativo = Qwen3 (Arandu Mirim 1.1) ---
Set-Content -Path (Join-Path $Destino "modelo.txt") -Value "Qwen_Qwen3-1.7B-Q4_K_M.gguf" -Encoding ascii -NoNewline
Write-Host "  + modelo.txt (= Qwen_Qwen3-1.7B-Q4_K_M.gguf)"

# --- RAG (opcional, mesmo pacote do Nano) ---
if ($ComRAG) {
    $ragDst = Join-Path $Destino "rag"
    New-Item -ItemType Directory -Path $ragDst -Force | Out-Null
    Copy-Item (Join-Path $raiz "rag\bge-m3-Q4_K_M.gguf") $ragDst -Force
    Copy-Item (Join-Path $raiz "rag\index.js")           $ragDst -Force
    Copy-Item (Join-Path $raiz "rag\gerar_indice.mjs")   $ragDst -Force
    Copy-Item (Join-Path $raiz "rag\docs") $ragDst -Recurse -Force
    Write-Host "  + rag\ (bge-m3 + index.js + docs)"
}

# --- memoria: comeca vazia por padrao (dados do Nano ficam no Nano) ---
$memDst = Join-Path $Destino "memoria"
New-Item -ItemType Directory -Path (Join-Path $memDst "itens") -Force | Out-Null
if ($CopiarMemoria -and (Test-Path (Join-Path $raiz "memoria"))) {
    Copy-Item (Join-Path $raiz "memoria\*") $memDst -Recurse -Force
    Write-Host "  + memoria\ (copiada do Nano)"
} else {
    Write-Host "  + memoria\ (vazia - comeca do zero na instalacao)"
}
New-Item -ItemType Directory -Path (Join-Path $Destino "cache") -Force | Out-Null

# --- rebrand: chat.html reusa o layout do Nano, so ajusta os textos que
#     citam "pendrive"/"USB" (a instalacao roda do disco do PC, nao da USB) ---
$chatPath = Join-Path $Destino "chat.html"
$html = Get-Content -Path $chatPath -Raw -Encoding UTF8
$trocas = [ordered]@{
    "a partir de um pendrive"                                  = "localmente no seu computador"
    "que roda no seu pendrive"                                 = "que roda no seu computador"
    "gravado no USB e"                                         = "gravado no computador e"
    "Perfil salvo no USB. "                                    = "Perfil salvo no computador. "
    "Procurando a resposta no pendrive…"                       = "Procurando a resposta no computador…"
    "Cabe num USB, mas pensa com calma…"                       = "Roda local, mas pensa com calma…"
    "salvou na memória do Arandu (no pendrive)"                = "salvou na memória do Arandu (no computador)"
}
foreach ($k in $trocas.Keys) { $html = $html.Replace($k, $trocas[$k]) }
[System.IO.File]::WriteAllText($chatPath, $html, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "  ~ chat.html (textos de pendrive/USB trocados para 'computador')"

# --- atalhos (Menu Iniciar sempre; Inicializar so com -AutoIniciar) ---
$wsh = New-Object -ComObject WScript.Shell
$alvoVbs = Join-Path $Destino "Iniciar_Arandu_Desktop.vbs"

$menuDir = [Environment]::GetFolderPath("Programs")
$atalhoMenu = $wsh.CreateShortcut((Join-Path $menuDir "Arandu Desktop.lnk"))
$atalhoMenu.TargetPath = "wscript.exe"
$atalhoMenu.Arguments  = """$alvoVbs"""
$atalhoMenu.WorkingDirectory = $Destino
$atalhoMenu.Description = "Arandu Desktop - IA local (instalada)"
$atalhoMenu.Save()
Write-Host "  + atalho no Menu Iniciar"

if ($AutoIniciar) {
    $startupDir = [Environment]::GetFolderPath("Startup")
    $atalhoStartup = $wsh.CreateShortcut((Join-Path $startupDir "Arandu Desktop.lnk"))
    $atalhoStartup.TargetPath = "wscript.exe"
    $atalhoStartup.Arguments  = """$alvoVbs"""
    $atalhoStartup.WorkingDirectory = $Destino
    $atalhoStartup.Description = "Arandu Desktop - inicia com o Windows"
    $atalhoStartup.Save()
    Write-Host "  + atalho em Inicializar (abre sozinho ao ligar o PC)"
}

Write-Host ""
Write-Host "=== PRONTO ===" -ForegroundColor Green
Write-Host "Instalado em: $Destino"
Write-Host "Abrir: menu Iniciar -> Arandu Desktop  (ou de novo este instalador, ele so atualiza os arquivos)"
Write-Host "Desinstalar: Desinstalar_Arandu_Desktop.ps1"
