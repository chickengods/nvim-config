---
name: render-doc-html
description: Render a markdown/feature doc to a clean, styled HTML page and open it in the browser. Use when the user asks for an HTML page/view of a doc, analysis, or landscape ("make an html page for this", "open the webpage", "refresh the page"), wants diagrams of a system landscape, or wants twin MD+HTML docs kept in sync. External references (PRs, issues, dashboards, docs) always become clickable links.
---

<helper>
Persistent renderer: `~/.claude/skills/render-doc-html/md2html.py` (python3 stdlib only — no pandoc). Create it on first use if missing; extend it rather than writing a new script per session. CLI: `python3 md2html.py <input.md> [-o output.html] [--title <t>]`.
</helper>

<output_standards>
- Semantic structure: single `<h1>`, `<header>/<main>/<section>`, heading levels never skipped.
- Embedded `<style>` (single-file page): system/sans font stack, centered `max-width: 72ch`, `line-height: 1.6`, relative units (`rem`), high contrast, left-aligned body text.
- Tables only for tabular data; `<figure>/<figcaption>` for diagrams.
- **Every external reference is a clickable `<a>`**: PRs, issues, dashboards, docs. Auto-linkify bare ticket IDs and PR numbers when the URL is derivable.
- Mermaid blocks: include mermaid.js via CDN only when the source contains them.
</output_standards>

<workflow>
1. Source: the given MD file (write the MD first if asked to create both).
2. Render via the helper → HTML next to the MD with the same basename. For feature docs, register new HTML pages in `feature.yaml.docs.reference_docs`.
3. `open <file>` — always reopen after every re-render; don't make the user ask.
4. **Twin-sync mode**: when both MD + HTML exist for a doc, every content edit updates both, then reopens.
5. Highlight/recolor requests ("make those rows orange"): apply as classes in the renderer or inline annotations in the MD so they survive re-renders.
</workflow>
