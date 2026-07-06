@echo off
REM Encerra o servidor do Arandu Desktop que roda em segundo plano.
taskkill /IM llamafile.exe /F >nul 2>&1
taskkill /IM llama-server.exe /F >nul 2>&1
if %errorlevel%==0 (
  echo Arandu Desktop desligado.
) else (
  echo Nenhum servidor do Arandu Desktop estava rodando.
)
timeout /t 2 /nobreak >nul
