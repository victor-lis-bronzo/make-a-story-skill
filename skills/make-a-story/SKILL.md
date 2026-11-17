---
name: make-a-story
description: Turns decisions and specs into concrete stories told from the user's, customer's or product's point of view. Two modes - alongside any grill skill it frames each question as a story with technical context, options and a recommendation; on its own it turns an issue, PR, ticket or spec into a before/after narrative. Use with grill skills, when the user runs /make-a-story on an issue or spec, or asks to "tell it as a story", "with stories", "make a story", "conta como história".
---

# make-a-story

A question about a decision is hard to answer in the abstract. Before asking it, show what happens to a real person when the decision goes one way or the other.

## Modes

Pick the mode before writing anything:

- **Grill mode**: a grill skill (`grilling`, `grill-with-stories`, `grill-with-docs`, ...) is running in this conversation, or the user asks to tell a pending question as a story. Follow [Grill mode](#grill-mode).
- **Standalone mode**: invoked directly (`/make-a-story #142`, a URL, a file, free text, or nothing after a discussion) with no grill running, or asked to "make a story of this issue/spec". Follow [references/standalone.md](references/standalone.md).

Both modes share [Writing the story](#writing-the-story), [The cast](#the-cast) and [Technical context](#technical-context).

## Grill mode

This skill changes **how questions are written**, not which questions get asked. When a grill skill (e.g. `grilling`) is active, keep its loop (design tree, frontier, rounds, sub-agents for facts) and replace its question template with the one below.

### Question template

Write every question exactly like this. Separate questions with `---`.

```
❓ **Q<n> - <short title>**

📖 **Story:** <the story>

🔧 **Technical context:** <real facts from the system>

**Options:**
(a) **<short name>.** <what it means>
(b) <alternative, with its trade-off>

➡️ (a). <why, tied back to someone in the story>
```

- ❓, 📖 and ➡️ are **always** present.
- 🔧 appears only when real code, data, config or an external system is involved. Omit it for pure business or product decisions.
- **Options** appear only when there are two or more concrete alternatives. For an open-ended question, skip them and put your proposed answer after ➡️.
- Translate the labels (Story, Technical context, Options) and all prose into the conversation's language. Keep code identifiers as they are.

### Recommendation

Name the option, then give a one- or two-sentence reason that points back to the story ("Lena sees 'only 2 left' at checkout instead of getting a call from Maya on Saturday morning"). If a recommendation costs something, say what.

### Collecting answers

1. Write the full round as text first, so the user can read every story.
2. If a structured question tool is available (e.g. `AskUserQuestion`), follow up with it: one entry per question (max 4 per call, split into more calls if needed), recommended option first and marked as recommended. Make each picker question stand on its own, since the text may be hidden while it is open.
3. Otherwise, ask the user to answer by number and letter (`Q1 a, Q2 b`).

See [references/example-round.md](references/example-round.md) for a complete annotated question.

## Standalone mode

Read [references/standalone.md](references/standalone.md) and follow it. See [references/example-standalone.md](references/example-standalone.md) for a complete output.

## Writing the story

- **Point of view**: the end user, the customer, or the product owner. Not the developer.
- **Internal decisions** (process, tooling, code structure): still start from a person. Follow the consequence until it reaches someone real: the customer who gets the email twice, the reviewer who stops trusting self-reviews.
- **Concrete**: named people, named businesses, real numbers, weekdays and times ("Lena orders at 23:10 on Thursday", "120 loaves of capacity, 118 already booked").
- **Show the failure or the friction**: what goes wrong for that person under the wrong choice, or what they gain under the right one. Make the stakes visible without stating them.
- **No jargon**: function names, tables and flags go in 🔧, not in 📖. Describe behaviour as the person sees it.
- **Length**: 3–6 sentences per question in grill mode. Standalone mode sets its own length.

## The cast

Build a small cast once (in the first grill round, or at the top of a standalone story) and reuse it for the whole session:

- 2–3 owners or operators (name, business name, one relevant detail such as size or city).
- A few end customers with names.

Take names, business types and vocabulary from the repo's domain when it has one (glossary, `CONTEXT.md`, seeds, fixtures, entity names, UI copy). Otherwise invent plausible ones that fit the product. Introduce the cast in one line before Q1 of the first round, or before the standalone story. Characters may come back in later questions; that is the point.

## Technical context

- State only facts you verified: `file:line` references, function and table names, current behaviour, constraints, spec lines. Find them with sub-agents, as the grill skill says. Never invent them.
- Say what the code does **today** and what part of the story it causes.
