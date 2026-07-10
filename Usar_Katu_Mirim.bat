@echo off
REM Define o modelo ativo como o Katu Mirim 2.1 (familia G2 - Raciocinio).
REM Qwen3-1.7B em modo PENSANTE (copia do Qwen3 base): pensa com <think>, otimo pt-BR, roda em CPU.
cd /d "%~dp0"
if not exist "Katu-Qwen3-1.7B-Q4_K_M.gguf" (
  echo.
  echo [!] O modelo da Katu (Katu-Qwen3-1.7B-Q4_K_M.gguf) nao esta na pasta - troca cancelada.
  echo     Faca uma copia do Qwen_Qwen3-1.7B-Q4_K_M.gguf com esse nome e rode de novo.
  timeout /t 8 /nobreak >nul
  exit /b 1
)
echo Katu-Qwen3-1.7B-Q4_K_M.gguf> modelo.txt
echo Modelo ativo agora: Katu Mirim 2.1 (raciocinio, Qwen3-thinking, CPU).
echo Dica: no chat, o bloco "Pensamento" aparece sozinho (e um modelo que raciocina).
echo Feche a IA (Desligar_IA.bat) e abra de novo para aplicar.
timeout /t 3 /nobreak >nul
