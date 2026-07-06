# ============================================================
#  Desinstalar_Arandu_Desktop.ps1 - remove o Arandu Desktop (edicao instalada)
#
#  Uso:
#    powershell -ExecutionPolicy Bypass -File Desinstalar_Arandu_Desktop.ps1
#    powershell -ExecutionPolicy Bypass -File Desinstalar_Arandu_Desktop.ps1 -ApagarArquivos
#
#  Sem -ApagarArquivos: so remove os atalhos (Menu Iniciar / Inicializar) e
#  encerra o servidor. Os arquivos instalados ficam intactos (memoria inclusa).
#  -ApagarArquivos: alem dos atalhos, apaga a pasta inteira da instalacao.
# ============================================================
param(
    [switch]$ApagarArquivos,
    [string]$Destino = (Join-Path $env:LOCALAPPDATA "Rendeia\AranduDesktop")
)

Write-Host "=== Desinstalando Arandu Desktop ===" -ForegroundColor Cyan

taskkill /IM llamafile.exe /F 2>$null | Out-Null
taskkill /IM llama-server.exe /F 2>$null | Out-Null

$menuDir    = [Environment]::GetFolderPath("Programs")
$startupDir = [Environment]::GetFolderPath("Startup")
foreach ($lnk in @((Join-Path $menuDir "Arandu Desktop.lnk"), (Join-Path $startupDir "Arandu Desktop.lnk"))) {
    if (Test-Path $lnk) {
        Remove-Item $lnk -Force
        Write-Host "  - atalho removido: $lnk"
    }
}

if ($ApagarArquivos) {
    if (Test-Path $Destino) {
        Remove-Item $Destino -Recurse -Force
        Write-Host "  - pasta apagada: $Destino"
    }
} else {
    Write-Host "Arquivos mantidos em $Destino (rode com -ApagarArquivos para remover tudo, memoria inclusa)."
}

Write-Host ""
Write-Host "=== PRONTO ===" -ForegroundColor Green
