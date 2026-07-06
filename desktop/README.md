# Arandu Desktop — fonte da edição instalada

Esta pasta versiona a **fonte** da edição **Desktop** do Arandu (a versão
instalada, não portátil). A edição **Nano** (portátil/USB) é a raiz deste
repositório; a Desktop reusa o mesmo miolo e muda só a "embalagem".
Ver [../docs/ROADMAP.md](../docs/ROADMAP.md) para a nomenclatura completa.

> **Nano** = portátil · **Desktop** = instalada. **Mirim/Eté/Guaçu** = tier de
> tamanho do modelo (eixo diferente). A Desktop roda o mesmo modelo
> `Arandu Mirim 1.1` da Nano.

## Arquivos

**Lançadores** (vão junto com a instalação):
- `IA_Desktop.vbs` — sobe o servidor (fallback llama-server ↔ llamafile) e abre o chat.
- `Iniciar_Arandu_Desktop.vbs` — garante o modelo padrão e chama o `IA_Desktop.vbs`.
- `Desligar_Desktop.bat` — encerra o motor.

**Instaladores** (Inno Setup + PowerShell):
- `Arandu_Desktop.iss` — instalador gráfico **completo** (embute o modelo, ~1,3 GB).
- `Arandu_Desktop_Web.iss` — instalador gráfico **web** (~85 MB; baixa o modelo do
  Hugging Face na instalação, com verificação SHA256).
- `Instalar_Arandu_Desktop.ps1` / `Desinstalar_Arandu_Desktop.ps1` — instalação
  por script (alternativa ao `.exe`, sem depender do Inno Setup).

## Como gerar os instaladores

Os `.iss` usam `SourceDir = D:\Arandu-desktop` — a **instalação montada** (chat.html
rebrandeado + modelo + motor + ferramentas). Essa pasta é *output* (não versionada;
contém o `.gguf` e binários). Para montá-la, rode o `Instalar_Arandu_Desktop.ps1`
a partir de uma cópia da edição Nano, ou ajuste o `SourceDir` para onde os arquivos
estiverem.

Compilar (Inno Setup 6, instalado via `winget install JRSoftware.InnoSetup`):

```powershell
$iscc = "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe"
& $iscc desktop\Arandu_Desktop_Web.iss   # web (~85 MB)
& $iscc desktop\Arandu_Desktop.iss       # completo (~1,3 GB)
```

Saída em `D:\` (`Arandu-Desktop-1.1-Setup.exe` e `-Web.exe`).

## Nota de ambiente (WDAC)

O `.exe` gerado **não é assinado**. Em PCs com WDAC enforce (como o de
desenvolvimento) ele é **bloqueado** — o teste do wizard tem que ser numa máquina
sem essa política. Assinar (code signing) resolveria, mas exige certificado.
