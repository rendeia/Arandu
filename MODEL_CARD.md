---
license: apache-2.0
base_model: Qwen/Qwen3-1.7B
language:
- pt
library_name: gguf
pipeline_tag: text-generation
tags:
- portuguese
- pt-br
- qwen3
- gguf
- llama.cpp
- llamafile
- offline
- cpu
- rendeia
- arandu
---

# Arandu Mirim 1.2 (GGUF)

**Assistente de IA de uso geral em português do Brasil, que roda 100% local e offline, na CPU — cabe num pendrive.**

Arandu Mirim 1.2 é um **fine-tune** do [Qwen3-1.7B](https://huggingface.co/Qwen/Qwen3-1.7B) sobre um dataset próprio em pt-BR, distribuído em **GGUF Q4_K_M** (~1,1 GB, ~1,2 GB de RAM). Faz parte da plataforma **Rendeia** ([github.com/rendeia/Arandu](https://github.com/rendeia/Arandu)).

> **Nomenclatura:** *Arandu* = a família (G1, eficiência) · *Mirim* = o tier (pequeno) · *1.2* = a versão. Roda nas edições *Nano* (portátil/USB) e *Desktop* (instalada).

---

## ⚠️ Leia antes de usar: o system prompt importa

Este modelo foi treinado **condicionado a um system prompt específico**. Sem ele, o comportamento (identidade, recusas, segurança) **degrada** — o modelo-base volta a dominar. **Use sempre o system prompt abaixo** (ou equivalente):

```text
Você é o Arandu, modelo de IA da família G1 (Eficiência) da plataforma Rendeia. Funciona 100% local e offline, a partir de um pendrive. A Rendeia NÃO é o ChatGPT, o Gemini, a Llama nem outro serviço em nuvem: é um projeto próprio e independente, executado na CPU pelo motor llamafile, sem acesso à internet. Outras famílias da Rendeia: Katu (G2 - raciocínio), Vera (G3 - multimodal), Taba (G4 - agentes). Ao perguntarem "o que é o Arandu", "o que é a Rendeia" ou "quem é você" (ou equivalente em outro idioma), responda com base nesta identidade.

Detect the user's language and answer ONLY in that exact language — never mix words from other languages (no Spanish, French or English words sneaking into a Portuguese answer).

Responda de forma clara, objetiva e prestativa.

Regras importantes:
- NÃO invente fatos, datas, números, nomes, leis ou fontes. Se não tiver certeza, diga claramente que não sabe ou que não tem certeza, em vez de preencher a lacuna com suposições.
- Prefira respostas curtas e diretas. Não apresente palpites como se fossem fatos.
- Se a pergunta exigir informação específica (uma lei, uma data, um dado) que você não conhece com segurança, diga isso e sugira ativar a Base de conhecimento (RAG).
- Ao usar a Base de conhecimento, baseie-se APENAS nos trechos fornecidos e cite a fonte entre colchetes (ex.: [1]).
```

**Modo não-pensante:** o Qwen3 tem "modo pensamento". O Arandu roda em modo direto — acrescente ` /no_think` ao fim do system prompt (ou use `enable_thinking=False` no chat template). Assim o modelo responde direto, sem bloco `<think>`, poupando CPU.

---

## Como rodar

### llama.cpp — servidor (recomendado)

```sh
llama-server -m arandu-mirim-1.2-Q4_K_M.gguf --host 127.0.0.1 --port 8080 \
  -c 2048 -t 3 -fa on -ctk q8_0 -ctv q8_0
```

Depois, envie um chat completion com a mensagem `system` acima (com ` /no_think` no fim) e a `user`.

### llama.cpp — conversa no terminal

```sh
llama-cli -m arandu-mirim-1.2-Q4_K_M.gguf -cnv \
  -sys "COLE_AQUI_O_SYSTEM_PROMPT /no_think" \
  -p "Quem é você?"
```

### llamafile

```sh
llamafile --server -m arandu-mirim-1.2-Q4_K_M.gguf --host 127.0.0.1 --port 8080 \
  -c 2048 -t 3 -fa on --gpu disable
```

Parâmetros sugeridos: `temperature 0.3`, `top_p 0.9`, `top_k 20`. Contexto: 2048.

---

## Para que serve

Conversa e tarefas do dia a dia em pt-BR: dúvidas, redação (e-mails, mensagens), resumos, traduções, contas simples, explicações. Foi calibrado para:

- **Privacidade:** roda 100% offline; nada sai da máquina.
- **Segurança:** recusa previsões impossíveis (loteria, futuro) e, diante de emergências (ex.: dor no peito), encaminha para o SAMU (192) sem tentar diagnosticar.
- **Honestidade:** diz "não sei" em vez de inventar; não apresenta palpite como fato.

## Limitações (honestas)

- É um modelo de **1,7B**: pode errar fatos, datas e contas mais complexas. **Confira informações importantes.**
- **Limitação conhecida:** a distinção gramatical **"mais" vs "mas"** ainda é pouco confiável (o instinto do modelo-base venceu o fine-tune neste ponto).
- O comportamento depende do **system prompt** (ver acima).
- **Não** substitui profissional de saúde, jurídico ou financeiro — para decisões desse tipo, procure um especialista.

---

## Treinamento

- **Base:** `Qwen/Qwen3-1.7B` (Apache-2.0).
- **Método:** LoRA (via [Unsloth](https://github.com/unslothai/unsloth)), r=16, 3 épocas, no Google Colab (T4).
- **Dados:** 282 exemplos próprios em pt-BR (conversa, redação, resumo, tradução, contas, fatos do Brasil, casos de segurança e identidade), com o system prompt de produção embutido em cada exemplo. Dataset e notebook em [github.com/rendeia/Arandu/tree/main/treino](https://github.com/rendeia/Arandu/tree/main/treino).
- **Quantização:** Q4_K_M. Uma variante com **imatrix pt-BR** (calibração de importância) pode ser regenerada — ver `treino/imatrix/` no repositório.

## Licença e créditos

- **Fine-tune e dataset:** Apache-2.0 (mesmo do projeto Rendeia).
- **Modelo base:** Qwen3-1.7B, © Alibaba Cloud, Apache-2.0.
- Motor de execução: [llamafile](https://github.com/Mozilla-Ocho/llamafile) / [llama.cpp](https://github.com/ggml-org/llama.cpp), Apache-2.0.

> Versão anterior: **Arandu Mirim 1.1** (Qwen3-1.7B + imatrix, sem fine-tune) — [rendeia/Arandu-Nano-1.1-GGUF](https://huggingface.co/rendeia/Arandu-Nano-1.1-GGUF).
