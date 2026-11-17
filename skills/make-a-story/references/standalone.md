# Standalone mode

Turn an issue, PR, ticket or spec into **one narrative**: the people affected today, then the same people once the change ships. It lets the reader see the issue before reading its acceptance criteria.

The story rules, the cast and the technical-context rules in [SKILL.md](../SKILL.md) still apply.

## Input

All optional, any order:

| Input | How to read it |
|---|---|
| `#123`, issue or PR URL | `gh issue view` / `gh pr view` (with comments). Fall back to a GitHub MCP if `gh` is missing. |
| Jira key or URL | A Jira MCP. If none is connected, ask the user to paste the ticket. |
| File path | Read it. |
| Free text | Use it as the spec. |
| Nothing | The current conversation is the spec. Ask only if there is nothing to work from. |

Flag: `--out [dir]` also writes the output to `<dir>/<slug>.md` (default dir `.make-a-story/`). Slug: issue number plus a kebab-case title, e.g. `142-partial-orders`.

Never comment on, edit or label the issue. If the user wants to paste the story somewhere, print it as a clean markdown block.

## Workflow

1. **Digest** (working notes, not output): goal, who is affected, current behaviour, the change, acceptance criteria, what the issue does not say.
2. **Facts**: if there is a repo, dispatch a sub-agent to find the code behind the current behaviour, so "Today" is true and 🔧 is verified. Skip this when there is no code.
3. **Cast**: build it from the repo's domain (see [The cast](../SKILL.md#the-cast)). One owner or operator and one or two end users are usually enough.
4. **Write** the output below.
5. If `--out` is set, write the same markdown to the file and say where.
6. **Close** by offering the grill (see below).

## Output

```
# <issue title> - the story

> **Cast:** <one line>

📖 **Today:** <one paragraph>

📖 **After #<n>:** <one paragraph>

🔧 **Technical context:** <optional>

❓ **Open questions**
1. <one line>
2. <one line>
```

- **Today**: 4–8 sentences. The friction as the cast lives it now, with names, weekdays, times and numbers. End on the moment it hurts.
- **After**: 4–8 sentences. Same people, same situation, after the change ships. Every acceptance criterion should be visible as something a person does or sees; do not list them. When the issue has no number, use `📖 **After:**`.
- **Technical context**: only verified facts. Say what the code does today and what the change touches. Omit the section when there is no code.
- **Open questions**: 1–4. Each one is a gap the story ran into: an edge case the issue does not cover, a choice it leaves open, a person it forgot. Write each as a question a product owner can answer. If the story ran into no gaps, write "None found." and skip the grill offer.
- No jargon in either 📖 paragraph. Translate labels and prose into the conversation's language.

## Closing: hand off to the grill

After the output, offer one line, in the conversation's language:

> Want to grill these with `/grill-with-stories`? It starts from these questions with the same cast.

If the user agrees, invoke the `grilling` skill (or `mattpocock-skills:grilling`), switch this skill to grill mode, and use the open questions as the first frontier. Keep the cast you already introduced.

See [example-standalone.md](example-standalone.md) for a complete output.
