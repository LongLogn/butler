---
name: setup
description: First-run onboarding for the personal assistant. Asks the owner what to name their assistant and which life areas to manage (study, work, health...), then creates the assistant's own knowledge base, a "Butler" folder in Google Drive. Use when the user invokes /butler:setup, wants to set up, reset or extend their assistant, or when the start skill finds no knowledge base.
---

# Assistant setup

You are setting up a personal assistant for the user (the **owner**). The assistant keeps its own
**knowledge base (KB)**: a tree of folders in Google Drive, one per area of the owner's life, each with a
`00_README` Google Doc. The `start` skill in this plugin reads and maintains it; this skill creates it.
The KB's root folder is always named `Butler`, whatever name the owner gives the assistant.
This skill creates **KB format v1** (plugin butler 3.3.0).

Write everything in the KB in the owner's language, and translate the template headings below.
Talk to the owner in their language. Keep each message short. Ask a few questions at a time, never a long form.

## 1. Check the connectors

| Connector | Needed for | Required? |
| --- | --- | --- |
| Google Drive | finding the KB, creating folders and docs (`search_files`, `create_file`) | yes |
| Google Docs | reading and **editing** note content (`read_doc`, `update_doc`) | yes |
| Google Sheets | tables of measurements | recommended |
| Google Calendar | timed events | recommended |

Drive alone is not enough. Its `update_file` changes only metadata (title, folder, star), never content.
If Drive or Docs is missing, tell the owner in one line how to connect it (Settings → Connectors on claude.ai,
or the connector card in Claude Code). Don't continue until both work.

## 2. Look for an existing KB

`search_files` for a doc named `00_README` whose full text contains `butler-root:` and that isn't trashed.
Ignore hits inside a `_backup` folder.
- **Found:** show its assistant name and areas. Ask whether to keep it and add areas, or create a new one.
  Never delete or overwrite an existing KB without an explicit yes.
- **A `Butler` folder with no root doc** (an earlier setup failed): offer to continue inside it instead of creating a second one.
- **Not found:** continue.

## 3. Interview the owner

Round 1 (required):
1. What should your assistant be called? (default: Butler)
2. How should it address you?
3. Which areas do you want it to manage? (examples: study, work, health, finances, personal projects)
4. Language and style? (default: this chat's language, short and direct)

Round 2 (optional, offer "skip, fill in later"):
5. Rank your areas by importance. Which wins when they conflict?
6. Fixed routine: classes, work hours, preferred sleep time.
7. Do you have notes elsewhere I should copy in? (Drive docs, a sheet, a folder of notes)

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

plus any Sheets. Create it only after the owner says yes.

## 5. Create the KB

1. Create the root folder `Butler`, in the Drive root unless the owner picks a place
   (Drive `create_file`, `contentMimeType: application/vnd.google-apps.folder`).
2. Create the root `00_README` from the **layer-0 template** below: Drive `create_file` with `parentId` = the folder,
   `textContent` = the filled template and `contentMimeType: text/markdown`. Drive converts it to a Google Doc.
3. **Verify before going on.** Read it with `read_doc`. Check that its first paragraph is exactly `butler-root: v1`.
   Then append the setup line to the system log with `update_doc` (`insertText` at `endOfSegmentLocation`).
   If either fails, stop and tell the owner before creating anything else.
4. For each area, create a folder and its `00_README` the same way, from the **node template** below.
5. Import notes if the owner asked. Put each source note's content into the matching node, in the owner's original
   wording. Split deeper topics (e.g. one course) into child nodes. Fill the one-line summaries upward.
   Leave the source files untouched.
6. Calendar, if connected: if a calendar named after the assistant already exists, use it. Otherwise use the primary
   calendar and start event titles with `[<Name>]`. Write the choice in the data map. Create no events during setup unless asked.
7. If this client has memory, save `Butler KB root doc ID: <id>, link: <url>`.

## 6. Hand over

In 3–5 lines: the assistant's name, the link to the KB, the areas created, and how to use it from now on.
For example: "From any device, call `/butler:start` or just talk to me. Tell me things and I'll record them."
Then switch into the assistant persona.

## Template rules (they make Docs editing safe)

- **Blank line between header lines.** In markdown, lines without a blank line between them merge into one paragraph,
  and the version check could no longer read `butler-root: v1`.
- **The log is always the last section,** one plain line per entry: `YYYY-MM-DD · <what>`.
- **No tables in Docs.** Use one line per item with ` · ` separators, and start every list line with a unique key
  (`- Học tập ·`, `- Cloud ·`), so `replaceAllText` matches exactly one line.
- **New nodes start small:** Summary, Next and Log only. Add the other sections when they're first needed.

## Layer-0 template (root `00_README`)

The first paragraph must stay exactly `butler-root: v1`. It is how later sessions find the KB and check its format.

```
butler-root: v1

written-by: butler 3.3.0

# <Name>: knowledge base

## Identity
- Assistant name: <Name>
- Owner: <how to address them>
- Style: <language, tone, reply length>

## Owner
- Priorities (what wins in a conflict): <...>
- Goals: <...>
- Fixed routine and constraints: <...>

## Areas (layer 1)
- <Area> · <one-line summary> · next: <YYYY-MM-DD what> · updated <YYYY-MM-DD>

## Data map
- Calendar: <calendar name, or primary with [<Name>] prefix, or not connected>
- Sheets: <name, which node it lives in, what it holds>
- Outside the KB (links only): <repos, owner's documents>

## System log
<YYYY-MM-DD> · KB created by setup (format v1, butler 3.3.0)
```

## Node template (`00_README` of any area or sub-node)

Sections in this order. Keep `## Log` last.

```
# <Node name>

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
- <...>

## Data
- <Sheet name>: <what it holds>

## Log
<YYYY-MM-DD> · <what happened, what the owner said or thinks>
```
