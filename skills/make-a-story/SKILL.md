---
name: make-a-story
description: Frames each interview or decision question as a concrete story told from the user's, customer's or product's point of view, followed by technical context, options and a recommendation. Use alongside any grill skill, or when the user asks to "tell it as a story", "with stories", "make a story", "conta como história".
---

# make-a-story

A question about a decision is hard to answer in the abstract. Before asking it, show what happens to a real person when the decision goes one way or the other.

This skill changes **how questions are written**, not which questions get asked. When a grill skill (e.g. `grilling`) is active, keep its loop (design tree, frontier, rounds, sub-agents for facts) and replace its question template with the one below.

## Question template

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

## Writing the story

- **Point of view**: the end user, the customer, or the product owner. Not the developer.
- **Internal decisions** (process, tooling, code structure): still start from a person. Follow the consequence until it reaches someone real: the customer who gets the email twice, the reviewer who stops trusting self-reviews.
- **Concrete**: named people, named businesses, real numbers, weekdays and times ("Carla renews on Friday at 22:30", "3,000 members, 2,000 inactive for 30+ days").
- **Show the failure or the friction**: what goes wrong for that person under the wrong choice, or what they gain under the right one. Make the stakes visible without stating them.
- **No jargon**: function names, tables and flags go in 🔧, not in 📖. Describe behaviour as the person sees it.
- **Length**: 3–6 sentences.

## The cast

In the first round, build a small cast and reuse it for the whole session:

- 2–3 owners or operators (name, business name, one relevant detail such as size or city).
- A few end customers with names.

Take names, business types and vocabulary from the repo's domain when it has one (glossary, `CONTEXT.md`, seeds, fixtures, entity names, UI copy). Otherwise invent plausible ones that fit the product. Introduce the cast in one line before Q1 of the first round. Characters may come back in later questions; that is the point.

## Technical context

- State only facts you verified: `file:line` references, function and table names, current behaviour, constraints, spec lines. Find them with sub-agents, as the grill skill says. Never invent them.
- Say what the code does **today** and what part of the story it causes.

## Recommendation

Name the option, then give a one- or two-sentence reason that points back to the story ("Joana gets her warning on the right day while win-back keeps draining the backlog"). If a recommendation costs something, say what.

## Collecting answers

1. Write the full round as text first, so the user can read every story.
2. If a structured question tool is available (e.g. `AskUserQuestion`), follow up with it: one entry per question (max 4 per call, split into more calls if needed), recommended option first and marked as recommended. Make each picker question stand on its own, since the text may be hidden while it is open.
3. Otherwise, ask the user to answer by number and letter (`Q1 a, Q2 b`).

See [references/example-round.md](references/example-round.md) for a complete annotated question.
