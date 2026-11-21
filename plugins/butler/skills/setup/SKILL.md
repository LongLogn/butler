---
name: setup
description: First-run onboarding for the personal assistant. Asks the owner what to name their assistant and which life areas to manage (study, work, health...), then creates the assistant's own knowledge base, by default a "Butler" folder in Google Drive. Use when the user invokes /butler:setup, wants to set up, reset or extend their assistant, or when the butler skill finds no knowledge base.
---

# Assistant setup

You are setting up a personal assistant for the user (the **owner**). The assistant keeps its own
**knowledge base (KB)**: a tree of folders, one per area of the owner's life, each with a
`00_README` note. The `butler` skill in this plugin reads and maintains it; this skill creates it.
The KB's root folder is always named `Butler`, whatever name the owner gives the assistant.
Write everything in the KB in the owner's language. Translate the template headings below.

Talk to the owner in their language. Keep each message short. Ask a few questions at a time,
never a long form.

## 1. Check what this session can do

| Connector | Needed for | Required? |
| --- | --- | --- |
| Google Drive | finding the KB, creating folders and docs (`search_files`, `create_file`) | yes |
| Google Docs | reading and **editing** note content (`read_doc`, `update_doc`) | yes |
| Google Sheets | tables of measurements | recommended |
| Google Calendar | timed events | recommended |

Drive alone is not enough. Its `update_file` changes only metadata (title, folder, star), never content,
so without Docs the assistant can create notes but never update them.

If Drive or Docs is missing, tell the owner in one line how to connect it (Settings → Connectors on claude.ai,
or the connector card in Claude Code) and offer the local-folder fallback if this session has file access.
Don't continue until one storage option can both create and edit notes.

## 2. Look for an existing KB

Search Drive for a folder named `Butler` containing a `00_README` whose first line is `butler-root: v1`
(or, for local storage, the folder the owner names).
- **Found:** show its assistant name and areas. Ask whether to keep it and add areas, or create a new one.
  Never delete or overwrite an existing KB without an explicit yes.
- **Not found:** continue.

## 3. Interview the owner

Round 1 (required):
1. What should your assistant be called? (default: Butler)
2. How should it address you?
3. Which areas do you want it to manage? (examples: study, work, health, finances, personal projects)
4. Language and tone? (default: the language of this chat, short and direct)

Round 2 (optional, offer "skip, fill in later"):
5. For each area: one line on what it is and how important it is (high / medium / low).
6. When areas conflict, what wins? (e.g. health > study > work)
7. Fixed routine: classes, work hours, preferred sleep time.
8. Existing notes to import? (e.g. a local folder of notes, a spreadsheet the assistant may read)

Don't invent answers. Leave unknown fields as `(chưa điền)` / `(not set)` in the owner's language.

## 4. Confirm the plan

Show the tree you will create, e.g.

```
Butler/
├── 00_README
├── Học tập/00_README
├── Công việc/00_README
└── Sức khỏe/00_README
```

plus any Sheets and the calendar. Create it only after the owner says yes.

## 5. Create the KB

1. Create the root folder named `Butler`, in the Drive root unless the owner picks a place
   (Drive `create_file`, `contentMimeType: application/vnd.google-apps.folder`).
2. Create `00_README` in the root from the **layer-0 template** below. Use Drive `create_file` with `parentId` = the folder,
   `textContent` = the filled template and `contentMimeType: text/markdown`. Drive converts it to a Google Doc.
   Read it back with Docs `read_doc`. If the headings came through as literal `#` text, recreate it with `text/plain`
   and apply heading styles with `update_doc` (`updateParagraphStyle`, `namedStyleType: HEADING_1/2`).
3. For each area, create a folder and its `00_README` the same way, from the **node template** below.
4. Import notes if the owner asked. Read each source note and put its content into the matching node, in the
   owner's original wording. Split deeper topics (e.g. one course) into child nodes. Fill the one-line summaries upward.
   Leave the source files untouched.
5. Calendar, if connected: use a calendar named after the assistant. If the connector can't create calendars,
   use the primary calendar and prefix event titles with `[<Name>]`. Create no events during setup unless the owner asks.
6. **Verify:** read the root `00_README` back with `read_doc`. Then append the setup line to its system log with `update_doc`
   (`insertText` at `endOfSegmentLocation`). If editing fails, say so plainly: the assistant can't record updates until it works.
7. Save a memory pointer if this client has memory (e.g. "Assistant KB: Google Drive folder Butler, root doc 00_README, link …").

## 6. Hand over

In 3–5 lines: the assistant's name, the link to the KB, the areas created, and how to use it from now on.
For example: "From any device, call `/butler:butler` or just talk to me. Tell me things and I'll record them."
Then switch into the assistant persona.

## Template rules (they make Docs editing safe)

- **The log is always the last section.** New entries are then a single `insertText` at `endOfSegmentLocation`.
- **No tables in Docs.** Use one line per item with ` · ` separators. A line can then be updated with `replaceAllText`
  on its exact old text. Docs tables need index arithmetic and break easily.
- **Every list line starts with a unique key** (`- Học tập ·`, `- Cloud ·`), so `replaceAllText` matches exactly one line.

## Layer-0 template (root `00_README`)

The first line must stay exactly `butler-root: v1`. It is how later sessions find the KB.

```
butler-root: v1
storage: google-drive            (or: local:<absolute path>)

# <Name>: knowledge base

## Identity
- Assistant name: <Name>
- Owner: <how to address them>
- Language and tone: <...>
- Reply length: <default: short, about one phone screen>

## Owner
- Priorities (what wins in a conflict): <...>
- Goals: <...>
- Fixed routine and constraints: <...>

## Areas (layer 1)
- <Area> · active · <one-line summary> · next: <YYYY-MM-DD what> · updated <YYYY-MM-DD>

## Data map
- Calendar: <calendar name or "not connected">
- Sheets: <name, which node it lives in, what it holds>
- Outside the KB (links only): <repos, owner's documents>

## Conventions
- Dates are written YYYY-MM-DD (shown to the owner in their local style).
- Logs are append-only and always the last section. Corrections are new dated lines.
- Each folder has one 00_README. Each parent keeps a one-line summary of each child.

## System log
- <YYYY-MM-DD>: KB created by setup.
```

## Node template (`00_README` of any area or sub-node)

Keep only sections that make sense for the node, but keep `## Log` last.

```
# <Node name>
Path: <Area / ... / Node>
Status: <active | paused | done> · Importance: <high | medium | low>

## Summary
<2–3 lines. The parent's one-line summary is distilled from this.>

## Children
- <Child> · <one line> · next: <YYYY-MM-DD what> · updated <YYYY-MM-DD>

## Key info
- <rules, grading, people, places, links to the owner's files>

## Milestones
- <YYYY-MM-DD>: <what> (<weight or stakes>)

## Next
- [ ] <...>

## Data
- <Sheet name>: <what it holds>

## Log
### <YYYY-MM-DD>
- <what happened, what the owner said or thinks>
```
