# Plano de execução — Arandu Mirim 1.2 + Ações assistidas

Duas frentes de evolução propostas para o Arandu, aterradas no código atual.
São **independentes** e podem correr em paralelo: a Frente A é modelo/Colab; a
Frente B é código local (ajudante 8099 + `chat.html`).

_Criado em 2026-07-07. Ver também [ROADMAP.md](ROADMAP.md) e [PLANO.md](PLANO.md)._

---

## Frente A — Arandu Mirim 1.2 (qualidade do modelo)

### Estado hoje
- `treino/dataset_arandu.jsonl` tem **54 exemplos**.
- O notebook `treino/Arandu_Nano_Finetuning.ipynb` faz LoRA sobre **Llama-3.2-1B**.
- O modelo **padrão** em produção (Mirim 1.1) é **Qwen3-1.7B** — ou seja, o
  fine-tune próprio (Mirim 1.0) hoje está numa base *inferior* ao padrão.

### Decisão central (recomendada)
Treinar o **1.2 sobre o Qwen3-1.7B**, não sobre o Llama-1B. Assim o 1.2 herda a
qualidade da 1.1 **e** ganha a personalização pt-BR.
- **Risco a validar cedo:** confirmar que o Unsloth treina Qwen3-1.7B e exporta
  GGUF limpo. Manter o `/no_think` que o `chat.html` injeta só para Qwen.

### Fase A1 — Dataset (o que mais move o ponteiro)
- Meta: **54 → 250 exemplos** de qualidade (patamar do PLANO: 200–500).
- Categorias sugeridas (~30–40 cada): conversa/dia a dia · redação (e-mail,
  mensagens) · resumo · tradução · contas/lógica simples · identidade ("o que é
  o Arandu / privacidade / offline", neutra) · recusa educada (fora de escopo) ·
  pt-BR bem-acabado (tom, formato).
- **Fonte de ouro:** coletar respostas ruins reais do uso e transformá-las em
  exemplo com a resposta ideal. Mini-fluxo sugerido: botão 👎 no chat que grava
  o par pergunta/resposta num `.jsonl` local para curar depois.
- **Validador:** script que checa cada linha (`messages` com system/user/
  assistant, JSON válido, sem duplicatas).

### Fase A2 — Treino (Colab, GPU T4 grátis)
- Adaptar o notebook: base `Qwen3-1.7B`, chat template do Qwen, `SFTConfig` +
  `save_strategy="no"` + `report_to="none"` (lições já documentadas no PLANO).
- Exportar GGUF (glob recursivo na subpasta `*_gguf/`); baixar via Google Drive.

### Fase A3 — Quantização + imatrix pt-BR
- Re-quantizar Q4_K_M **com a imatrix pt-BR** (pipeline já existe em
  `treino/imatrix/`).

### Fase A4 — Integração na plataforma
- `arandu-mirim-1.2-Q4_K_M.gguf` → `modelo.txt`; entrada nova em `NOMES_MODELO`
  no `chat.html`; `Usar_Nano_1.2.bat`; atualizar ROADMAP/PLANO/NOMENCLATURA.
- **A/B honesto** contra a 1.1 (mesmas perguntas) antes de promover a padrão.

---

## Frente B — Ações assistidas (fechar o loop leitura → ação)

### Estado hoje
O ajudante (`ferramentas/saude_sistema.ps1`, porta 8099) **lê** agenda e e-mail
do Outlook via COM (`GetDefaultFolder(9)` = agenda, `(6)` = inbox) mas é
**100% somente leitura**. O preflight CORS e o padrão de rota POST
(`/memoria/item`) já existem — a base para escrever já está pronta.

### Princípio inegociável
O modelo **propõe**, o usuário **confirma**, o código **executa**. Nada é
criado/enviado sem clique explícito. E-mail = sempre **rascunho**
(`.Display()`, **nunca** `.Send()`).

### Fase B1 — Rotas de escrita no ajudante
Adicionar 3 rotas POST em `saude_sistema.ps1` (no mesmo dispatch das rotas
`/memoria*`), cada uma recebendo JSON:

| Rota | Ação (Outlook COM) | Contrato |
|---|---|---|
| `POST /agenda/criar` | `CreateItem(1)` → `Subject/Start/End/Location` → `.Save()` | `{assunto, inicio, fim, local}` |
| `POST /email/rascunho` | `CreateItem(0)` → `To/Subject/Body` → `.Save()` + `.Display()` | `{para, assunto, corpo}` |
| `POST /limpeza/executar` | apaga só caminhos que o próprio `/limpeza` já listou (allowlist server-side) | `{ids:[...]}` |

Guardas: validar campos; nunca `.Send()`; `/limpeza/executar` só aceita
caminhos devolvidos pela varredura (nada de path arbitrário do cliente).
Espelhar o contrato no `saude_sistema.py` onde fizer sentido (Outlook é Windows;
limpeza é multiplataforma).

### Fase B2 — Confirmação no chat (o design que segura a segurança)
Abordagem **híbrida**, começando pela mais segura:

1. **Botões determinísticos primeiro** (não dependem do modelo acertar JSON):
   quando o painel mostra um e-mail/evento, oferecer "Responder (rascunho)" /
   "Criar evento" que abrem um **card de confirmação** com campos editáveis → no
   confirmar, faz o POST. Confiável no modelo pequeno (Qwen3-1.7B, 2048 tokens).
2. **Sugestão pelo modelo depois:** ensinar o system prompt a emitir um bloco
   estruturado (ex.: cerca ```` ```acao ````) que o `chat.html` detecta,
   **renderiza como card de confirmação** (não executa direto) e só age no
   clique. Reforçar com exemplos no dataset da Frente A → as duas frentes se
   ajudam.

### Fase B3 — Ponta a ponta
- Testar criação de evento e rascunho de e-mail reais no Outlook clássico;
  confirmar que o rascunho **abre para revisão e não sai sozinho**.
- Atualizar ROADMAP (🟡 → 🟢 "ações assistidas") e o README/`ferramentas/README`.

---

## Ordem sugerida

```
Semana 1   B1 (rotas de escrita) + A1 (começar dataset em paralelo)
Semana 2   B2 botões + card de confirmação   |   A1 continua
Semana 3   A2/A3 treino+quant   →   B2 sugestão pelo modelo (usa exemplos do dataset)
Semana 4   A4 integração + A/B   |   B3 ponta a ponta
```

**Por que começar pela B1:** é local, testável hoje, não depende de Colab e
desbloqueia a B2. A A1 (dataset) roda em paralelo por ser curadoria manual que
não bloqueia nada.
