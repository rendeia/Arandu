@echo off
REM Define o modelo ativo como o Katu Mirim 2.1 (familia G2 - Raciocinio).
REM DeepSeek-R1-Distill-Qwen-1.5B (Q4_K_M): pensa antes de responder (<think>), roda em CPU.
cd /d "%~dp0"
if not exist "DeepSeek-R1-Distill-Qwen-1.5B-Q4_K_M.gguf" (
  echo.
  echo [!] O modelo da Katu ainda NAO esta na pasta - troca cancelada.
  echo     Baixe "DeepSeek-R1-Distill-Qwen-1.5B" Q4_K_M (bartowski, no Hugging Face),
  echo     renomeie para DeepSeek-R1-Distill-Qwen-1.5B-Q4_K_M.gguf e coloque nesta pasta.
  echo     Depois rode este .bat de novo.
  timeout /t 8 /nobreak >nul
  exit /b 1
)
echo DeepSeek-R1-Distill-Qwen-1.5B-Q4_K_M.gguf> modelo.txt
echo Modelo ativo agora: Katu Mirim 2.1 (raciocinio, CPU).
echo Dica: no chat, o bloco "Pensamento" aparece sozinho (e um modelo que raciocina).
echo Feche a IA (Desligar_IA.bat) e abra de novo para aplicar.
timeout /t 3 /nobreak >nul
