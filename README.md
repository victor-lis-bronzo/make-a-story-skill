# make-a-story

> Grill-me, but every question comes with a story.

`make-a-story` is a pair of agent skills for **Claude Code** and **Google Antigravity (`agy`)**. It runs a relentless grilling session on your plan, like Matt Pocock's [`/grill-me`](https://github.com/mattpocock/skills), but every question arrives with a short story told from your **user's** point of view: named recurring characters, concrete numbers, the moment the decision actually bites. You stop answering abstract trade-offs and start answering "what happens to Ana on Monday morning?".

It also works on its own: point `/make-a-story` at an issue, a spec or the current conversation and you get one story, before → after, told by the same kind of named cast, plus the open questions the story exposed. Read it, share it, or hand those questions straight to `/grill-with-stories`.

```
/grill-with-stories docs/plans/reminder-sequences.md
/grill-with-stories we're adding same-day pickup slots to the bakery app
/grill-with-stories                 # uses the current conversation as the plan

/make-a-story #142                  # one before → after story for an issue
/make-a-story docs/spec.md --out    # same, and saves it to .make-a-story/
```

## What a question looks like

> ❓ **Q2 - What happens when the oven capacity for a day is full?**
>
> 📖 **Story:** It's Friday, 16:20. Maya, who owns Crumb & Co, can bake 120 loaves for Saturday pickup and already has 118 pre-orders. Lena opens the app and orders 4 sourdoughs for her daughter's birthday brunch; the checkout accepts all 4. On Saturday at 07:00 the bakers find they are 2 loaves short, and Maya has to call Lena at 07:30 to say half the order is missing. Lena posts about it in the neighbourhood group by 08:00.
>
> 🔧 **Technical context:** `place_order()` (`orders/service.py:88`) checks `daily_capacity` before inserting, but reads and writes in separate transactions, and it compares the number of *orders*, not the number of *items*.
>
> **Options:** (a) **Reserve capacity per item, atomically.** Lock the day's capacity row, subtract the items, reject with "only 2 left for Saturday" if it would go negative. (b) Allow overbooking by 5% and let the bakery adjust by hand.
>
> ➡️ (a). Lena sees "only 2 left" at checkout and picks Sunday for the rest, instead of hearing it from Maya on the phone.

A full session lives in [`examples/bakery-preorders-session.md`](examples/bakery-preorders-session.md). The bakery, people, code and numbers are all invented for the demo.

## Prerequisite

> [!IMPORTANT]
> `/grill-with-stories` builds on the **`grilling`** skill from [mattpocock/skills](https://github.com/mattpocock/skills). Install it first:
>
> ```bash
> npx skills add mattpocock/skills --skill grilling -g -a claude-code -a antigravity-cli -y
> ```
>
> Already using Matt's Claude Code plugin (`claude plugin install mattpocock-skills@claude-plugins-official`)? That covers it.

`make-a-story` on its own has no dependencies.

## Install

Pick one.

### 1. `npx skills` (Claude Code + Antigravity in one go)

```bash
npx skills add victor-lis-bronzo/make-a-story-skill --skill grill-with-stories --skill make-a-story -g -a claude-code -a antigravity-cli -y
```

Drop `-g` to install into the current project instead. Add `-a antigravity` for the Antigravity IDE, or `--copy` to copy files rather than symlink.

### 2. Claude Code plugin

```bash
claude plugin marketplace add victor-lis-bronzo/make-a-story-skill
claude plugin install make-a-story@make-a-story-skill
```

Plugin skills are namespaced: invoke as `/make-a-story:grill-with-stories` and `/make-a-story:make-a-story`.

### 3. Antigravity plugin

```bash
git clone https://github.com/victor-lis-bronzo/make-a-story-skill
agy plugin install ./make-a-story-skill
```

After `agy plugin install`, ask for it by name or type `/grill-with-stories` in the `agy` TUI; run `agy plugin list` to see the exact name.

### 4. Install script

```powershell
# Windows (PowerShell)
git clone https://github.com/victor-lis-bronzo/make-a-story-skill; cd make-a-story-skill
./scripts/install.ps1                    # global, Claude + Antigravity
./scripts/install.ps1 -Claude            # Claude only
./scripts/install.ps1 -Agy               # Antigravity only
./scripts/install.ps1 -Project C:\path\to\repo
./scripts/install.ps1 -Link              # symlink: `git pull` updates the skills
./scripts/install.ps1 -Uninstall
```

```bash
# macOS / Linux / Git Bash
./scripts/install.sh                     # global, Claude + Antigravity
./scripts/install.sh --agy
./scripts/install.sh --project ~/code/my-app
./scripts/install.sh --link
./scripts/install.sh --uninstall
```

Both scripts install the two skills and warn if they can't find `grilling`.

### Manual

Copy both `skills/grill-with-stories/` and `skills/make-a-story/` to:

| Where | Claude Code | Antigravity |
|---|---|---|
| Global | `~/.claude/skills/grill-with-stories`, `~/.claude/skills/make-a-story` | `~/.gemini/config/skills/grill-with-stories`, `~/.gemini/config/skills/make-a-story` |
| Project | `.claude/skills/grill-with-stories`, `.claude/skills/make-a-story` | `.agents/skills/grill-with-stories`, `.agents/skills/make-a-story` |

Manual, script and `npx skills` installs invoke as plain `/grill-with-stories` and `/make-a-story`.

## Usage

### With grill

| Input | Example |
|---|---|
| Plan file | `/grill-with-stories docs/plans/reminders.md` |
| Free text | `/grill-with-stories a waitlist for sold-out pickup days` |
| Nothing | `/grill-with-stories` after discussing a plan |

`grill-with-stories` is manual-only: it runs when you type it, never on its own. It asks in rounds (every question it can ask right now), waits for your answers, and keeps going until the plan has no open branches.

`make-a-story` is the format on its own, and the agent may pick it up whenever it's asking you questions. Use it without the grilling session:

- "tell it as a story" in the middle of any conversation where the agent asks you to decide something;
- alongside Matt's `/grill-with-docs`: `/grill-with-docs` and then "tell it as a story", to get stories *and* the glossary/ADR upkeep.

Output language follows the conversation: grill in Portuguese and the stories, characters and options come back in Portuguese.

### Standalone

`/make-a-story` with an input tells **one** story about it instead of asking questions.

| Input | Example |
|---|---|
| GitHub issue or PR (via `gh`) | `/make-a-story #142` |
| GitHub URL | `/make-a-story https://github.com/acme/bakery/issues/142` |
| Jira key (via your Jira MCP) | `/make-a-story BAKE-142` |
| File, saved to disk | `/make-a-story docs/spec.md --out` |
| Free text | `/make-a-story customers can split an order when a day sells out` |
| Nothing | `/make-a-story` after discussing a change |

You get one narrative, before → after: 📖 **Today** (the friction as people live it), 📖 **After** (the same people once the change ships, including the moment each acceptance criterion shows up), 🔧 technical context when there is real code to point at, and ❓ the open questions the story exposed. It ends by offering to grill those questions with `/grill-with-stories`, keeping the same cast.

It only reads: it never comments on or edits the issue, PR or ticket. `--out [dir]` also writes the story to `<dir>/<slug>.md` (default `.make-a-story/`); if you use it, add `.make-a-story/` to your `.gitignore`.

A trimmed example:

> # Allow partial orders when a pickup day sells out - the story
>
> 📖 **Today:** It's Friday, 16:20, and Crumb & Co has 118 of its 120 bread slots booked for Saturday. Lena wants 4 sourdoughs and 6 croissants, and checkout answers "Saturday is full" without saying that most of it would still fit. She buys supermarket bread instead. …
>
> 📖 **After #142:** Checkout tells Lena "2 of 4 sourdoughs and all 6 croissants fit on Saturday". She taps "split the rest" and the other 2 move to Sunday. …
>
> ❓ **Open questions**
> 1. If Sunday is full too, does the rest move to Monday, or does Lena pick a day herself?
> 2. Does a split order pay once, or is the Sunday part charged at pickup?

The full output lives in [`skills/make-a-story/references/example-standalone.md`](skills/make-a-story/references/example-standalone.md).

## How it works

`make-a-story` has two modes:

- **Grill mode**: it formats each question someone else is asking (the ❓/📖/🔧/Options/➡️ shape below). This is what `/grill-with-stories` uses.
- **Standalone mode**: `/make-a-story <input>` reads an issue, ticket, file, text or the conversation and writes one before → after story with open questions.

`grill-with-stories` = `grilling` + `make-a-story`, the same pattern as Matt's `grill-with-docs` (= `grilling` + `domain-modeling`).

1. **Grilling** (Matt's skill) decides *what* to ask: walks the decision tree, one question at a time, with a recommended answer.
2. **make-a-story** decides *how* to ask it:
   - ❓ the question, one line;
   - 📖 a story from the user's, customer's or product's point of view, with named characters who recur across questions and concrete numbers;
   - 🔧 technical context, only when there is real code or data to point at;
   - **Options** (a), (b), …;
   - ➡️ the recommendation and why.

The format lives in [`skills/make-a-story/SKILL.md`](skills/make-a-story/SKILL.md); the entry point is [`skills/grill-with-stories/SKILL.md`](skills/grill-with-stories/SKILL.md).

## Releasing

The version lives in both `plugin.json` (repo root, for agy) and `.claude-plugin/plugin.json` (Claude). Bump both.

## License

MIT
