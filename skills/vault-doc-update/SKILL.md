---
name: vault-doc-update
description: Safe surgical write to the design vault — read first, smallest correct edit, one-fact-one-home, decisions-log rules, docs written as current.
fires-when: Any write to the design docs — recording a decision, capturing something worth keeping, or correcting a fact — and when unsure which doc owns a fact.
---

# vault-doc-update

**Owner: `knowledge-keeper`.** The docs are the studio's memory; this keeps them honest. The vault's shape — the scaffold, folders-vs-links, why the decisions log is a current-state table — is defined in `guides/design-docs.md`. This is the write procedure.

## Procedure

1. **Find the one home.** Every fact lives in exactly one doc; check `memory-map.md` for the owner. If two docs claim it, that is a defect — pick one home and link the other. If none owns it, the memory-map gains a row.
2. **Read the owning doc first — read, never assume.** Read the current passage before editing; edits apply against the freshest content, and a match copied from memory fails or corrupts.
3. **Make the smallest correct edit.** Change the passage, not the file. Prefer a surgical passage-edit or a section-patch; a whole-body rewrite is the last resort (it overwrites concurrent edits — re-read immediately before and after if unavoidable).
4. **Write as current (doctrine 12).** Every doc reads as if written fresh today. **Delete** the wrong thing and **state** the right thing as fact. No changelogs, no "v2", no "superseded", no dated edit notes, no struck-through rows. Keep a *reason* only where it stops a mistake recurring — as present-tense fact, not a story.
5. **Decisions-log rows are edits, never appends.** `decisions-log.md` is a current-state table: a settled decision is a row *inside* the table with the date settled and the rationale. When a decision changes, **edit the row** — never append a superseding record and keep the corpse. A superseded decision survives only where its history stops a live mistake recurring.
6. **Propose → confirm → write.** State the intended change and confirm before writing, especially for a decision or a rewrite.
7. **Keep the map and index true.** After the edit, ensure `memory-map.md` still points to the right home and `index.md` still links the doc. One-fact-one-home is enforceable only if the map is current.
8. **Open questions live at the bottom of `decisions-log.md`.** Ask once, then proceed and log the answer.

## Block these
- Changelog / archaeology in a live doc (dated edit notes, "v2", superseded chains).
- The same fact in two homes.
- A wholesale rewrite where a surgical edit would do.
- Appending to the decisions log instead of editing the row.
