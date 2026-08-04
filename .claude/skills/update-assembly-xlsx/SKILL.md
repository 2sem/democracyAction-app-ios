---
name: update-assembly-xlsx
description: Use when updating National Assembly member data, photos, SNS links, or Projects/App/Resources/Datas/direct_democracy.xlsx from official web sources and regenerating direct_democracy.xlsx.secret.
---

# Update Assembly XLSX

Use this skill when the user asks to web search, refresh, or update National Assembly data in `Projects/App/Resources/Datas/direct_democracy.xlsx`.

## Source Of Truth

- Use official Assembly data first, not screenshots or unofficial summaries.
- Member list endpoint:
  `https://assembly.go.kr/portal/cnts/cntsNaas/findNaasThx01.json?pageIndex=1&pageSize=300&pageUnit=300&cntsDivCd=NAAS&menuNo=600137`
- Member detail page:
  `https://assembly.go.kr/members/22nd/{openNaId}`
- Use detail page HTML for photos and SNS URLs when available.
- Use web search only to verify missing/broken public SNS links, especially Facebook numeric IDs.

## Critical Invariants

- `congressman` active rows must be exactly 300.
- Active `no` values must be exactly `1...300`, with no duplicates and no gaps.
- `congressman` rows must be contiguous by row order:
  row `3` maps to `no 1`; row `302` maps to `no 300`.
- Do not append replacement members after blank rows. The app loader stops at the first missing `no` or `name`.
- For replaced constituency members, reuse the predecessor/vacancy slot ID instead of creating IDs above 300.
- For proportional succession, reuse the vacated proportional slot ID.
- Keep regional office phone numbers in `office_area`, not mixed into `office_asm`.
- Keep phone range formats compatible with existing `_parseNumber`: examples like `02-784-3396~8,02-788-2469` are valid; mixed slash/range strings like `02-784-3396~8 / 788-2469` are not.
- Preserve CoreXLSX compatibility by ensuring `xl/sharedStrings.xml` exists and worksheet XML has no `inlineStr` cells.

## Workbook Files

- Raw workbook: `Projects/App/Resources/Datas/direct_democracy.xlsx`
- Tracked encrypted artifact: `Projects/App/Resources/Datas/direct_democracy.xlsx.secret`
- Git-secret mapping: `.gitsecret/paths/mapping.cfg`
- The raw `.xlsx` is ignored. After editing it, run `git secret hide -m` and commit only the generated `.secret` and mapping changes.

## Recommended Workflow

1. Reveal or confirm the raw workbook exists.
2. Read the `info` sheet and determine the current `data_update` date.
3. Web search official Assembly sources for member changes since `data_update`, unless the user provided a different date range.
4. Fetch the official 300-member JSON list.
5. Match official members to workbook rows by normalized name and district/field.
6. For each replacement, map the new member into the prior `1...300` slot.
7. Update details from official data and detail pages:
   party, district, office phone, email, homepage, blog, Facebook, Instagram, YouTube, X/Twitter.
8. Download/replace photos only for new/replaced members.
9. Normalize photos to `117x164` JPEG named `{no}.jpg` under `Projects/App/Resources/Images/photos/`.
10. Reorder `congressman` so active rows are physically row `3...302`, sorted by `no`.
11. Delete/clear rows after row `302`.
12. Restore `sharedStrings.xml` if `openpyxl` rewrote strings as inline strings.
13. Validate all invariants.
14. Run `git secret hide -m`.
15. Commit only intended tracked files; do not commit unrelated `.package.resolved` changes.

## Validation Script

Run this after workbook edits and before `git secret hide -m`:

```bash
python3 - <<'PY'
from zipfile import ZipFile
from openpyxl import load_workbook
from pathlib import Path
from PIL import Image

p = 'Projects/App/Resources/Datas/direct_democracy.xlsx'
with ZipFile(p) as z:
    names = set(z.namelist())
    print('has_sharedStrings', 'xl/sharedStrings.xml' in names)
    print('inlineStr_count', sum(
        z.read(n).decode('utf-8', 'ignore').count('inlineStr')
        for n in names
        if n.startswith('xl/worksheets/') and n.endswith('.xml')
    ))

wb = load_workbook(p, data_only=True)
ws = wb['congressman']
h = {ws.cell(2, c).value: c for c in range(1, ws.max_column + 1)}

errors = []
for row in range(3, 303):
    no = ws.cell(row, h['no']).value
    name = ws.cell(row, h['name']).value
    try:
        no_int = int(float(no))
    except Exception:
        no_int = None
    if no_int != row - 2 or not name:
        errors.append((row, no, name))
print('row_sequence_error_count', len(errors), errors[:10])
print('max_row', ws.max_row)

nos = [
    int(float(ws.cell(r, h['no']).value))
    for r in range(3, 303)
    if ws.cell(r, h['no']).value and ws.cell(r, h['name']).value
]
print('count', len(nos), 'min', min(nos), 'max', max(nos))
print('missing', [n for n in range(1, 301) if n not in nos])
print('duplicates', [n for n in sorted(set(nos)) if nos.count(n) > 1])

# Simulate existing _parseNumber range behavior over phone range fields.
for sheet_name, fields in [('congressman', ['mobile', 'office_asm', 'office_area']), ('groups', ['office'])]:
    s = wb[sheet_name]
    header = {s.cell(2, c).value: c for c in range(1, s.max_column + 1)}
    for r in range(3, s.max_row + 1):
        for field in fields:
            if field not in header:
                continue
            value = s.cell(r, header[field]).value
            if not isinstance(value, str) or not value:
                continue
            for comma_num in value.split(','):
                seq_nums = comma_num.split('~')
                if len(seq_nums) > 1:
                    int(seq_nums[0][-1])
                    int(seq_nums[1])
print('phone_range_parse_ok')

photo_dir = Path('Projects/App/Resources/Images/photos')
invalid = sorted(p.name for p in photo_dir.glob('*.jpg') if p.stem.isdigit() and int(p.stem) > 300)
print('over_300_jpg_count', len(invalid), invalid[:10])
PY
```

Expected:
- `has_sharedStrings True`
- `inlineStr_count 0`
- `row_sequence_error_count 0`
- `count 300 min 1 max 300`
- `missing []`
- `duplicates []`
- `phone_range_parse_ok`
- `over_300_jpg_count 0`

## Restoring Shared Strings

`openpyxl` can save all strings as inline strings and remove `xl/sharedStrings.xml`. That can break `CoreXLSX` callers. After any `openpyxl` save, restore shared strings before encrypting the workbook.

Use the existing conversion pattern from prior updates: convert worksheet cells with `t="inlineStr"` into shared-string cells with `t="s"`, write `xl/sharedStrings.xml`, add the content type override, and add the workbook relationship if missing. Then re-run the validation script.

## Facebook Handling

- Prefer numeric Facebook profile/page IDs when a handle is unavailable or redirects poorly in Safari.
- Verify public availability before replacing a handle.
- Do not store `share/...` URLs if a numeric ID can be extracted from the redirect.
- If no verified public numeric ID exists and the handle is unavailable, clear the Facebook field rather than leaving a broken link.

## PR Checklist

- Explain the data source and date/version in the PR body.
- Include workbook validation results.
- Include photo scope: which `{no}.jpg` files changed.
- Mention that raw `.xlsx` remains ignored and only `.xlsx.secret` is tracked.
- Do not include unrelated dependency resolution or generated project changes.

## Deploy Notes

- App version is controlled by `MARKETING_VERSION` in:
  `Projects/App/Configs/debug.xcconfig` and `Projects/App/Configs/release.xcconfig`.
- CI increments build number during deploy via fastlane.
- Deploy workflow is `.github/workflows/deploy-ios.yml`.
