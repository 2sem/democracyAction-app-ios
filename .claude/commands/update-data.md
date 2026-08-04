---
description: Web search official Assembly sources and update direct_democracy.xlsx safely.
---

Load and follow the `update-assembly-xlsx` skill via the Skill tool.

First read the `info` sheet in `Projects/App/Resources/Datas/direct_democracy.xlsx` and determine the current `data_update` date. Web search official Assembly sources for National Assembly member changes since that `data_update` date, unless the user explicitly provides a different date range.

Update National Assembly member data in `Projects/App/Resources/Datas/direct_democracy.xlsx` from official Assembly web sources, then regenerate `Projects/App/Resources/Datas/direct_democracy.xlsx.secret`.

Follow the skill checklist exactly:
- Use official Assembly endpoints and member detail pages first.
- Keep active `congressman` rows as `row 3...302` matching `no 1...300`.
- Reuse existing replacement/vacancy IDs; never append active members after blank rows.
- Keep `office_area` and `office_asm` separated.
- Preserve `xl/sharedStrings.xml` compatibility.
- Validate workbook, phone ranges, photos, and IDs before `git secret hide -m`.
- Commit only intended workbook/photo/secret changes.

If `data_update` cannot be read from the workbook, ask one short clarification question before editing data.
