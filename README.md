# make-a-story

> Grill-me, but every question comes with a story.

`make-a-story` is a pair of agent skills for **Claude Code** and **Google Antigravity (`agy`)**. It runs a relentless grilling session on your plan, like Matt Pocock's [`/grill-me`](https://github.com/mattpocock/skills), but every question arrives with a short story told from your **user's** point of view: named recurring characters, concrete numbers, the moment the decision actually bites. You stop answering abstract trade-offs and start answering "what happens to Ana on Monday morning?".

```
/grill-with-stories docs/plans/reminder-sequences.md
/grill-with-stories we're adding automated WhatsApp reminders to the studio app
/grill-with-stories                 # uses the current conversation as the plan
```

## What a question looks like

> ❓ **Q2 - How do we split the 100/day send cap across sequences?**
>
> 📖 **Story:** It's Monday, 7:40. Ana, who owns Studio Bondi, has three sequences live: class reminders for 64 bookings today, a "we miss you" nudge for 52 members who haven't come in 30 days, and a renewal notice for 18 memberships expiring this week. That's 134 messages against a cap of 100. If we send in creation order, the win-back campaign Ana set up last month eats the cap first, and by 9:00 Carla, who booked the 18:00 reformer class, never gets her reminder, misses the class and loses the credit. Ana finds out from Carla at the front desk.
>
> 🔧 **Technical context:** `SendQueue.enqueue()` drains messages FIFO by `created_at`; the cap lives in `WHATSAPP_DAILY_LIMIT=100` and is checked per send, with no notion of sequence priority.
>
> **Options:** (a) Fixed priority: class reminders first, then renewals, then win-back; anything over the cap rolls to tomorrow. (b) Per-sequence quotas Ana sets herself (e.g. 60/25/15).
>
> ➡️ (a). Reminders are time-critical and cost Ana real money when missed; a win-back message sent a day late loses almost nothing. Quotas can come later if a studio asks for them.

A full session lives in [`examples/pilates-studio-session.md`](examples/pilates-studio-session.md). The studio, people and numbers are invented for the demo.

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

Plugin skills are namespaced: invoke as `/make-a-story:grill-with-stories`.

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

Manual, script and `npx skills` installs invoke as plain `/grill-with-stories`.

## Usage

| Input | Example |
|---|---|
| Plan file | `/grill-with-stories docs/plans/reminders.md` |
| Free text | `/grill-with-stories a waitlist for full reformer classes` |
| Nothing | `/grill-with-stories` after discussing a plan |

`grill-with-stories` is manual-only: it runs when you type it, never on its own. It asks in rounds (every question it can ask right now), waits for your answers, and keeps going until the plan has no open branches.

`make-a-story` is the format on its own, and the agent may pick it up whenever it's asking you questions. Use it without the grilling session:

- "tell it as a story" in the middle of any conversation where the agent asks you to decide something;
- alongside Matt's `/grill-with-docs`: `/grill-with-docs` and then "tell it as a story", to get stories *and* the glossary/ADR upkeep.

Output language follows the conversation: grill in Portuguese and the stories, characters and options come back in Portuguese.

## How it works

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
