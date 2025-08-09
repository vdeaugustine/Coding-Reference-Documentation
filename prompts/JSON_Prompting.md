# The short version (TL;DR)

1. **Prefer native “structured outputs.”** If your provider offers JSON mode or tools that enforce a schema, use that first. It’s the most robust way to get valid JSON. ([OpenAI Platform][1], [Anthropic][2])
2. **Backstop with validation.** Define a JSON Schema / Pydantic model, validate the output, and **auto-retry with a corrective message** when validation fails. ([pydantic.dev][3])
3. **For ironclad guarantees**, use **constrained/grammar decoding** (e.g., JSON-Schema-driven decoding engines). It ensures outputs are syntactically valid and schema-conformant. ([arXiv][4], [OpenReview][5], [vLLM Blog][6])

---

# When (and why) JSON?

Use JSON whenever the output feeds another system: APIs, databases, RAG pipelines, UI forms, analytics, etc. Avoid free-text that you later regex into shape—life’s too short.

---

# The three reliability levels

## 1) Prompting only (baseline)

* Ask for “**valid JSON only**,” show an **example**, forbid prose, and instruct the model to **avoid trailing commentary**.
* Works for demos, but **not guaranteed**—models can drift, especially under long context or temperature > 0. ([Medium][7])

**Use cases:** quick prototypes, low-risk tasks.
**Don’t stop here for production**.

## 2) Native structured outputs (recommended default)

Modern APIs expose **JSON/structured output modes** that bind the model to your schema.

* **OpenAI**: “Structured outputs / JSON mode” lets you declare a schema; the model is steered to emit strictly valid JSON. ([OpenAI Platform][8])
* **Anthropic**: **Tool use** can be leveraged just to force JSON that matches your tool’s input schema; set `tool_choice` to require it. ([Anthropic][2])

**Why this is good:** high conformity with minimal code; better than raw prompting.
**Still do**: validate and retry on failure (because nothing is 100%). ([pydantic.dev][3])

## 3) Constrained/grammar decoding (maximum control)

Decode with a **grammar** or **JSON Schema** so invalid tokens simply can’t be produced. Popular backends (Outlines, XGrammar) and runtimes (like **vLLM**) now support this. It provides strong guarantees and can be faster/more efficient at scale. ([arXiv][4], [vLLM Blog][6])

Recent evaluations/benchmarks focus specifically on **JSON Schema compliance** and efficiency—useful if you’re choosing a backend. ([OpenReview][5], [arXiv][9], [GitHub][10])

---

# Production recipe (copy this approach)

## Step 0 — Define your contract

Start with a **JSON Schema** or **Pydantic model** (language of your choice). Keep:

* **Types** tight (enums, number ranges).
* **Optional** vs **nullable** explicit.
* **Arrays** bounded when possible (minItems/maxItems).
* **Unions** discriminated (add a `"type"` field).
  Then generate a small **golden sample** JSON that matches it. (You’ll use it in prompts & tests.)

Why Pydantic? Great DX, validation, and rich error messages; pairs well with auto-repair loops. ([pydantic.dev][3], [GitHub][11])

## Step 1 — Prefer a structured-output API

* **OpenAI**: enable **JSON/structured output** with a schema. ([OpenAI Platform][8])
* **Anthropic**: define a **single tool** representing your schema; **force tool use** so the model must return JSON conforming to it. ([Anthropic][2])

> Tip: Provide a **concise description** of each field and 1–2 **valid examples** inside the tool/schema description. ([Anthropic][2])

## Step 2 — Validate, then repair

* Run the output through **JSON Schema / Pydantic**.
* On failure, **auto-retry** with a short **systematic repair prompt** that includes the validation error and **the same schema**. Libraries like **Instructor** make this pattern ergonomic. ([pydantic.dev][3], [Instructor][12], [GitHub][11])

## Step 3 — (Optional) Lock it down with constrained decoding

If you absolutely need guaranteed shape (ETL, finance, compliance), enable **grammar/structured decoding** against your schema. vLLM supports Outlines/XGrammar backends. ([vLLM Blog][6])

---

# Prompt template that actually works

Use this when you *can’t* use native JSON mode yet (or as extra belt-and-suspenders):

```
You are a service that returns ONLY valid JSON.

Requirements:
- Output must be a single JSON object, no markdown, no comments, no trailing text.
- It MUST conform to the following JSON Schema (no extra properties):

<JSON_SCHEMA_HERE>

If unsure, return nulls or empty arrays that still satisfy the schema.

Example of a valid response shape (illustrative, not prescriptive):
<MINIMAL_VALID_JSON_EXAMPLE>
```

This pattern is consistent with provider guidance: define a schema, forbid prose, and keep examples minimal. Still validate after. ([OpenAI Platform][1], [Anthropic][2])

---

# Schema design tips (battle-tested)

* **Name things like an API.** Future you will thank you.
* Prefer **enums** over free-text categories.
* Add **string formats** (`email`, `uri`, `date-time`) where applicable.
* Use **`additionalProperties: false`** to block junk fields.
* For lists of items, set **`minItems`/`maxItems`**.
* For nested objects, consider **discriminated unions** to avoid ambiguous shapes.
* For extraction tasks, add **`source_spans`** (start/end indices) so you can verify post-hoc.

These constraints improve model adherence and simplify validation/repair loops. ([pydantic.dev][3], [OpenReview][5])

---

# Error handling & hardening

* **Strict JSON parse ➜ validate ➜ repair loop**:

  1. parse; 2) validate; 3) if invalid, show the **exact validation error** to the model and retry **once or twice**; 4) if still invalid, **fallback** to constrained decoding or flag to human review. ([pydantic.dev][3])
* **Temperature**: keep low (0–0.3) for structured tasks.
* **Streaming**: if you stream, **buffer until valid JSON**; don’t process partials unless your decoder can.
* **Security**: reject unexpected fields; never eval model text; whitelist keys.
* **Observability**: log raw prompts, outputs, validation errors, and repair attempts.

---

# What to use (tooling options)

* **Provider-native**:

  * OpenAI **Structured outputs / JSON mode**. ([OpenAI Platform][8])
  * Anthropic **tool use** (force tool, JSON mode guidance). ([Anthropic][2])
* **Validation & repair**: **Pydantic** + **Instructor** (Python); similar patterns exist for TS/Zod. ([pydantic.dev][3], [GitHub][11])
* **Constrained decoding** (for guarantees & scale): **vLLM** with Outlines/XGrammar; JSON-Schema benchmarks to compare engines. ([vLLM Blog][6], [OpenReview][5], [GitHub][10])

---

# Common pitfalls (and how to dodge them)

* **Model adds commentary** → Forbid prose explicitly; **force tool/JSON mode**. ([Anthropic][2], [OpenAI Platform][1])
* **Valid JSON but wrong shape** → Tighten schema (enums, required vs optional); include **`additionalProperties: false`**; validate & repair. ([pydantic.dev][3])
* **Edge cases blow up** (empty lists, nullables) → Encode them in the schema with `minItems`, `nullable`, and examples; add tests. ([pydantic.dev][3])
* **Provider/model swaps** → Keep the **schema+validation layer** stable; switch backends underneath; use constrained decoding where supported. ([vLLM Blog][6])

---

# Example implementation checklists

## OpenAI (JSON mode)

* [ ] Define JSON Schema (or equivalent).
* [ ] Enable JSON/structured output; pass schema.
* [ ] Parse ➜ validate (Pydantic/JSON Schema) ➜ repair on failure.
* [ ] Tests for empty, large, and adversarial inputs. ([OpenAI Platform][8])

## Anthropic (Tool use)

* [ ] Create **one tool** with parameters = your schema.
* [ ] Set **`tool_choice`** to require tool use.
* [ ] Validate & repair as above. ([Anthropic][2])

## Constrained decoding (vLLM)

* [ ] Convert your schema to the decoder’s grammar format.
* [ ] Turn on structured decoding backend (Outlines or XGrammar).
* [ ] Keep validation anyway (belt & suspenders), but expect far fewer failures. ([vLLM Blog][6])

---

# Further reading / references

* OpenAI: **Structured outputs & JSON mode** (official docs). ([OpenAI Platform][8])
* Anthropic: **Tool use** to force structured JSON; increasing output consistency. ([Anthropic][2])
* Pydantic team: **Validating structured outputs + Instructor library** (how-to). ([pydantic.dev][3])
* Instructor: “Get reliable JSON from any LLM” (repo/blog). ([GitHub][11], [Instructor][12])
* Research & engineering notes on **constrained decoding** and **JSON-Schema-based evaluation**. ([arXiv][4], [OpenReview][5], [vLLM Blog][6])

---
[1]: https://platform.openai.com/docs/guides/structured-outputs/json-mode?utm_source=chatgpt.com "JSON mode"
[2]: https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/overview?utm_source=chatgpt.com "Tool use with Claude"
[3]: https://pydantic.dev/articles/llm-intro?utm_source=chatgpt.com "Steering Large Language Models with Pydantic"
[4]: https://arxiv.org/html/2403.06988v1?utm_source=chatgpt.com "Guiding LLMs The Right Way: Fast, Non-Invasive ..."
[5]: https://openreview.net/pdf?id=FKOaJqKoio&utm_source=chatgpt.com "Evaluating Constrained Decoding with LLMs on Efficiency, ..."
[6]: https://blog.vllm.ai/2025/01/14/struct-decode-intro.html?utm_source=chatgpt.com "Structured Decoding in vLLM: a gentle introduction"
[7]: https://medium.com/%40docherty/mastering-structured-output-in-llms-choosing-the-right-model-for-json-output-with-langchain-be29fb6f6675?utm_source=chatgpt.com "Mastering Structured Output in LLMs 1: JSON output with ..."
[8]: https://platform.openai.com/docs/guides/structured-outputs?utm_source=chatgpt.com "the Structured Outputs guide"
[9]: https://arxiv.org/html/2501.10868v1?utm_source=chatgpt.com "Generating Structured Outputs from Language Models"
[10]: https://github.com/Saibo-creator/Awesome-LLM-Constrained-Decoding?utm_source=chatgpt.com "Saibo-creator/Awesome-LLM-Constrained-Decoding"
[11]: https://github.com/567-labs/instructor?utm_source=chatgpt.com "567-labs/instructor: structured outputs for llms"
[12]: https://python.useinstructor.com/blog/2024/06/15/zero-cost-abstractions/?utm_source=chatgpt.com "Why Instructor is the best way to get JSON from LLMs"
