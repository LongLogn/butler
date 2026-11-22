---
name: setup
description: Onboarding for the personal assistant. Asks what to name it, how it should talk and which life areas to manage, then creates its memory in Google Drive (a "Butler" folder tree and a memory Sheet) and copies in existing notes. Also upgrades an older Butler knowledge base. Use when the user invokes /butler:setup, wants to set up, reset, extend or upgrade their assistant, or when the start skill finds no knowledge base or an old one.
---

# Assistant setup

This is the assistant's hiring day. You set up a personal assistant for the user (the **owner**) and then hand over to
the `start` skill, which runs it every day. This skill creates **KB format v2** (plugin butler 4.0.0).

It creates two things:
- a `Butler` folder tree in Google Drive, one folder per area of the owner's life, each with a `00_README` Google Doc;
- a **memory Sheet** with three tabs. `start` loads the top of each tab at every session:
  - **Recent:** newest events;
  - **Important:** ranked matters;
  - **Protocol:** the owner's instructions and personality.

Write everything in the owner's language, folder names, tab names and headings included, and talk to them in it.
Keep messages short and ask only a few questions at a time.

## 1. Check the connectors

| Connector | Needed for | Required? |
| --- | --- | --- |
| Google Drive | finding the KB, creating folders, docs and sheets, reading notes | yes |
| Google Docs | **editing** the READMEs (Drive can't edit content) | yes |
| Google Sheets | the memory Sheet and data tables | yes |
| Google Calendar | routines, events and reminders | recommended |

If a required one is missing, say in one line how to connect it (Settings → Connectors on claude.ai, or the connector
card in Claude Code). Don't continue until all three work.

## 2. Look for an existing KB

`search_files` with `title = '00_README' and fullText contains 'butler-root' and mimeType = 'application/vnd.google-apps.document' and trashed = false`.
Ignore hits whose parent is a `_backup` folder.

- **Format v2:** show the assistant's name and areas, then ask whether to add areas or start fresh.
  Never delete or overwrite a KB without an explicit yes.
- **Format v1:** offer the upgrade (§7).
- **A `Butler` folder without a root doc** (an earlier setup failed): offer to continue inside it.
- **None:** continue.

## 3. Interview the owner

Round 1 (required):
1. What should your assistant be called? (default: Butler)
2. How should it address you, and how should it talk (language, tone, length)?
3. Which areas of your life should it manage? (e.g. study, work, health, money, family, projects)

Round 2 (optional; offer "skip, it'll learn as we go"):
4. A little about you: what you do, and what wins when things clash.
5. Fixed routine: classes, work hours, usual sleep.
6. Deadlines or goals coming up?
7. Notes elsewhere I should copy in? (Drive docs, sheets, a folder)

Don't invent answers. Whatever isn't given, the assistant learns later.

## 4. Confirm the plan

Show the tree with the owner's own names, for example:

```
Butler/
├── 00_README
├── Memory (Sheet: Recent · Important · Protocol)
├── Study/00_README
├── Work/00_README
└── Health/00_README
```

Create it only after the owner says yes.

## 5. Create the KB

1. **Root folder.**
   - Call Drive `create_file` with `title: "Butler"` and `contentMimeType: application/vnd.google-apps.folder`.
   - Put it in the Drive root unless the owner picks a place.
2. **Memory Sheet.**
   - Call `create_file` with `title`, `parentId` = the root folder and `contentMimeType: application/vnd.google-apps.spreadsheet`.
   - Read `get_spreadsheet` for the first tab's sheetId.
   - Then make one `update_spreadsheet` batch:
     - `updateSheetProperties` on that tab: title = Recent, `gridProperties.frozenRowCount: 1`.
     - `addSheet` twice with explicit `sheetId: 1` and `sheetId: 2` (Important, Protocol), also with one frozen row.
     - `updateCells` at `rowIndex: 0` of each tab, writing the headers as `stringValue`s:
       - Recent: `ID · When · What · Node`;
       - Important: `ID · What · Due · Progress · Node · Updated`;
       - Protocol: `ID · Instruction or fact · Since · Source`.
   - Verify with `get_spreadsheet`.
3. **Root `00_README`.**
   - Call `create_file` with `title: "00_README"`, `parentId` = the root folder, `textContent` = the filled template below,
     and `contentMimeType: text/markdown`.
   - **Verify:** `read_doc`, and check that the first paragraph is exactly `butler-root: v2`.
   - If anything here fails, stop and tell the owner before creating more.
4. **Area folders:** create each folder and its `00_README` from the node template.
   Put each area's link in the root's Areas list.
5. **Seed the memory Sheet** from the interview. Give every row an ID `YYMMDD-HHMM` and write values as text.
   - **Protocol,** one item per row:
     - **pinned rows first** (`Source: pinned`): the assistant's name, how it addresses the owner and itself,
       and the owner's time zone;
     - then the owner's rules, style, who they are and what wins in a conflict, and their routine habits (`Source: owner`).
   - **Important:** deadlines, commitments and goals, most important first.
   - **Recent:** leave it empty.
6. **Import notes,** if asked. Read sources with `read_file_content`.
   - Put content into the matching node in the owner's wording. Split deeper topics into child folders.
   - Data with rows and numbers goes into a Sheet in that node.
   - Every README lists its children and files with links.
   - Anything with a date or a stake goes into Important.
   - Leave the source files untouched.
7. **Calendar,** if connected.
   - Use a calendar named after the assistant if one exists. Otherwise use the primary calendar, with `[<Name>]` before event titles.
   - Write the choice in the root README.
   - If the owner has a fixed weekly routine, **offer** recurring events for it (`recurrenceData` RRULE, with reminders).
     `start` reads today and tomorrow from the calendar at every session, so routines should live there.
8. **Client memory,** if this client has it: save `Butler root doc ID: <id>`.

## 6. Hand over

In 3–5 lines, give the assistant's name, the KB link, the areas, and how to use it.
For example: "From any device, call `/butler:start` or just talk to me. Tell me what happens and what you want, and I'll remember."
Then switch into the assistant persona.

## Root `00_README` template

```
butler-root: v2

written-by: butler 4.0.0

memory: <Sheet ID> · tabs: <Recent title>=0 · <Important title>=1 · <Protocol title>=2

# <Name>: knowledge base

The working memory (recent events, important matters, the owner's instructions) is in the memory Sheet.
Each folder has a 00_README explaining what it holds.

## Areas
- <Area> · <what it covers> · <link>

## Data map
- Calendar: <name, or primary with [<Name>] prefix, or not connected>
- Other Sheets: <name · node · what it holds · link>
- Outside the KB (links only): <repos, owner's documents>

## System log
<YYYY-MM-DD> · KB created (format v2, butler 4.0.0)
```

Keep a blank line between header lines; in markdown, adjacent lines merge into one paragraph. Use no tables in Docs.
The system log records only structural changes such as setup, new areas and upgrades.

## Node `00_README` template

```
# <Name>

What this is: <one line>

Status: <active | paused | done> · updated <YYYY-MM-DD>

## Now
<current state>

## Contents
- <child folder or file> · <what it holds> · <link>

## History
<YYYY-MM-DD> · created
```

`## History` must stay the last section, because `start` appends to the end of the doc.

## 7. Upgrade an older KB

Ask before upgrading, and say in 2–3 lines what changes.
- **Back up first:** copy every doc you will change into `Butler/_backup/<YYYY-MM-DD> vN/`,
  renaming each copy `<name> (backup vN)` so it is never taken for the root.
- **Order:** set the `butler-root:` and `written-by:` lines last, then add a line to the system log.
  If the upgrade is interrupted, the KB still reads as the old version, so run it again. Each step must be safe to re-run.

**v1 → v2:**
1. If the root has no `memory:` line, create the memory Sheet (§5 step 2). Then add the `memory:` header line.
2. **Protocol:** seed from the root's Identity and Owner sections, with name, address and time zone as pinned rows. **Important:** seed from each area's `next:` milestone
   and anything urgent. Ask the owner to glance at the order.
3. **Root README:** reshape it to the v2 template. Keep the Areas list and add each area's link.
4. **Node READMEs:** rename `## Log` to `## History` and leave the entries as they are.
   Missing sections are added the first time `start` edits the node.
