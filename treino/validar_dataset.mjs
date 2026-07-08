// Validador do dataset de fine-tuning do Arandu (formato chat JSONL).
// Uso:  node treino/validar_dataset.mjs [caminho.jsonl]
// Padrao: treino/dataset_arandu.jsonl
//
// Checa, por linha: JSON valido; presenca de `messages`; papeis validos
// (system|user|assistant); ao menos 1 user e 1 assistant; ultima mensagem =
// assistant; conteudo nao vazio. Aponta duplicatas (mesma 1a pergunta do user)
// e alerta (nao falha) sobre casos suspeitos. Sai com codigo 1 se houver ERRO.

import { readFileSync } from "node:fs";

const arquivo = process.argv[2] || "treino/dataset_arandu.jsonl";
const PAPEIS = new Set(["system", "user", "assistant"]);

let linhas;
try {
  linhas = readFileSync(arquivo, "utf8").split(/\r?\n/).filter((l) => l.trim());
} catch (e) {
  console.error(`Nao consegui ler ${arquivo}: ${e.message}`);
  process.exit(1);
}

const erros = [];
const alertas = [];
const vistos = new Map(); // primeira pergunta do user -> primeira linha onde apareceu
let comSystem = 0;
let multiTurno = 0;

linhas.forEach((linha, idx) => {
  const n = idx + 1;
  let obj;
  try {
    obj = JSON.parse(linha);
  } catch (e) {
    erros.push(`L${n}: JSON invalido (${e.message})`);
    return;
  }

  const msgs = obj && obj.messages;
  if (!Array.isArray(msgs) || msgs.length === 0) {
    erros.push(`L${n}: sem array "messages" ou vazio`);
    return;
  }

  let temUser = false;
  let temAssistant = false;
  msgs.forEach((m, j) => {
    if (!m || typeof m !== "object") {
      erros.push(`L${n}: mensagem ${j + 1} nao e objeto`);
      return;
    }
    if (!PAPEIS.has(m.role)) {
      erros.push(`L${n}: papel invalido "${m.role}" na mensagem ${j + 1}`);
    }
    if (typeof m.content !== "string" || m.content.trim() === "") {
      erros.push(`L${n}: content vazio/nao-texto na mensagem ${j + 1} (${m.role})`);
    }
    if (m.role === "user") temUser = true;
    if (m.role === "assistant") temAssistant = true;
  });

  if (!temUser) erros.push(`L${n}: nenhuma mensagem de user`);
  if (!temAssistant) erros.push(`L${n}: nenhuma mensagem de assistant`);

  const ultimo = msgs[msgs.length - 1];
  if (ultimo && ultimo.role !== "assistant") {
    erros.push(`L${n}: ultima mensagem deveria ser do assistant (esta: ${ultimo.role})`);
  }

  if (msgs[0] && msgs[0].role === "system") comSystem++;
  else alertas.push(`L${n}: sem mensagem system no inicio (recomendado para consistencia)`);

  const naoSystem = msgs.filter((m) => m.role !== "system");
  if (naoSystem.length > 2) multiTurno++;

  const primeiroUser = (msgs.find((m) => m.role === "user")?.content || "").trim();
  if (primeiroUser) {
    if (vistos.has(primeiroUser)) {
      alertas.push(`L${n}: 1a pergunta duplicada (igual a L${vistos.get(primeiroUser)})`);
    } else {
      vistos.set(primeiroUser, n);
    }
  }
});

console.log(`Arquivo: ${arquivo}`);
console.log(`Exemplos: ${linhas.length} | com system: ${comSystem} | multi-turno: ${multiTurno}`);
console.log(`Erros: ${erros.length} | Alertas: ${alertas.length}`);
if (alertas.length) {
  console.log("\n--- alertas ---");
  alertas.forEach((a) => console.log("  " + a));
}
if (erros.length) {
  console.log("\n--- ERROS ---");
  erros.forEach((e) => console.log("  " + e));
  process.exit(1);
}
console.log("\nOK: dataset valido.");
