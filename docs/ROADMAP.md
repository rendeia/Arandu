# Rendeia — Nomes e Roadmap

Referência rápida da nomenclatura e das próximas evoluções do projeto.
Para a estrutura completa de nomes, ver [NOMENCLATURA_MODELOS.md](NOMENCLATURA_MODELOS.md).

_Atualizado em 2026-07-06._

## 1. Os nomes — 5 eixos

| Eixo | O que define | Valores |
|---|---|---|
| **Plataforma** | a marca | **Rendeia** |
| **Família** | geração / capacidade | **Arandu** (G1 Eficiência) · **Katu** (G2 Raciocínio) · **Vera** (G3 Multimodal) · **Taba** (G4 Agentes) |
| **Tier** | tamanho do modelo | **Mirim** (pequeno) · **Eté** (médio) · **Guaçu** (grande) |
| **Edição** | forma de entrega | **Nano** (portátil/USB) · **Desktop** (instalada) |
| **Versão** | evolução da linha | 1.0 · 1.1 · … |

> **Modelo** = Família + Tier + Versão → ex.: _Arandu Mirim 1.1_.
> **Edição** = a embalagem que roda esse modelo → _Nano_ ou _Desktop_.
> Nome completo de uso: **"Arandu Desktop rodando o modelo Arandu Mirim 1.1"**.
>
> Atenção: **Nano** e **Desktop** são _edições_ (portátil vs. instalada), NÃO
> tiers. **Mirim/Eté/Guaçu** são _tiers_ (tamanho do modelo). São eixos
> diferentes e independentes.

## 2. O que existe hoje

| Item | Nome | Detalhe |
|---|---|---|
| Repo da família Arandu | `rendeia/Arandu` | plataforma + família G1 |
| Repo da família Katu | `rendeia/Katu` | família G2 (repo próprio) |
| Modelo padrão | **Arandu Mirim 1.1** | Qwen3-1.7B + imatrix pt-BR |
| Modelo próprio anterior | Arandu Mirim 1.0 | fine-tune sobre Llama-1B |
| Modelo de raciocínio | Katu Mirim 2.0 | DeepSeek-R1-Distill-Qwen-1.5B |
| Edição portátil | **Arandu Nano** | roda de USB, duplo-clique |
| Edição instalada | **Arandu Desktop** | instalador `.exe` (web ~85 MB / completo ~1,3 GB) |

## 3. Próximas evoluções (roadmap)

| Horizonte | Evolução | Status |
|---|---|---|
| **Curto** (semanas) | Q4_0 + AVX-512 como velocidade padrão | 🟡 pronto no projeto, falta aplicar |
| **Curto** | Release público com os instaladores Desktop | 🟡 instaladores prontos, falta publicar |
| **Curto** | Assinar os instaladores (code signing) | ⚪ opcional (custo de certificado) |
| **Médio** (meses) | Ampliar dataset → **Arandu Mirim 1.2** | ⚪ o que mais melhora a qualidade |
| **Médio** | Memória + **ações assistidas** (criar evento, rascunhar e-mail) | 🟡 leitura pronta, falta agir |
| **Contínuo** | Voz + integração com o PC | 🟢 parcial, evoluindo |
| **Longo** (depende de hardware) | Arandu **Eté** (~3B) / **Guaçu** (~7B) | 🔴 inviável no hardware atual |
| **Longo** | Família **Vera** (multimodal) / **Taba** (agentes) | 🔴 conceito |

**Legenda:** 🟢 em uso · 🟡 pronto/parcial, falta um passo · ⚪ planejado · 🔴 longo prazo

> **Nota de hardware:** o alvo (16 GB RAM, CPU 4 núcleos, iGPU Intel bloqueada
> por WDAC) comporta bem o tier **Mirim**. Os tiers **Eté/Guaçu** e as famílias
> **Vera/Taba** dependem de hardware acima do alvo — por isso ficam no longo
> prazo. A aposta de foco é o tier Mirim bem-acabado (ver análise em conversa).
