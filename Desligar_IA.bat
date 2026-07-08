@echo off
REM Encerra TUDO que a IA Portatil sobe em segundo plano:
REM   - o motor de IA (llamafile.exe e/ou llama-server.exe)
REM   - o ajudante de saude/modelo (powershell rodando saude_sistema.ps1)
REM Assim, ao reabrir por IA_Portatil.vbs, tudo sobe atualizado.

set _algo=0
taskkill /IM llamafile.exe /F >nul 2>&1 && set _algo=1
taskkill /IM llama-server.exe /F >nul 2>&1 && set _algo=1

REM mata SO o powershell do ajudante (filtra pela linha de comando -> nao afeta outros)
powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='powershell.exe'\" | Where-Object { $_.CommandLine -like '*saude_sistema*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }" >nul 2>&1

if %_algo%==1 (
  echo IA Portatil desligada (motor + ajudante).
) else (
  echo Nenhum servidor da IA estava rodando.
)
timeout /t 2 /nobreak >nul
