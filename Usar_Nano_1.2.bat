@echo off
REM Define o modelo ativo como o Arandu Mirim 1.2 (fine-tune proprio sobre Qwen3-1.7B).
cd /d "%~dp0"
echo arandu-mirim-1.2-Q4_K_M.gguf> modelo.txt
echo Modelo ativo agora: Arandu Mirim 1.2 (fine-tune pt-BR sobre Qwen3-1.7B).
echo Feche a IA (Desligar_IA.bat) e abra de novo para aplicar.
timeout /t 3 /nobreak >nul
