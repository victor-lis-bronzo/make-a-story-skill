# Example session: Pilates studio sequences

This is an example of what `/grill-with-stories` produces: Matt Pocock's `grilling` interview, where every question is told as a short story about a real person before the technical detail.

**Prompt used:**

```
/grill-with-stories add a daily send cap and timezone-aware "day N" triggers to marketing sequences
```

- The output language follows the conversation. This session is in English, so the output is too.
- The domain is invented: a SaaS for boutique fitness studios that sends automated marketing email **sequences** (win-back, expiring credits, renewal reminders). All names, studios and companies are made up.

---

## Round 1

**Cast:** **Ana** owns Studio Bondi, a reformer Pilates studio in Sydney with 3,000 members. **Bruno** owns CrossBox Manly, a smaller box with 600 members. **Joana** is a Studio Bondi member with 4 class credits left. **Carla** is a lapsed Studio Bondi member who moved to Perth.

---

❓ **Q1 - What gets sent first when the cap is hit**

📖 **Story:** Ana imports her 3,000 members on Monday, and 2,400 of them land in the win-back sequence at the same moment. With a cap of 500 emails a day, the backlog takes five days to clear. On Wednesday, Joana's 4 credits are due to expire on Friday, and her "use them before they expire" email is stuck behind 1,500 win-back emails to people who haven't visited in a year. Joana's credits expire on Friday without a single reminder, and on Saturday she emails Ana to complain.

🔧 **Technical context:** `dispatch_due_steps` (`marketing_sequences.py:513`) selects due steps `ORDER BY enrolled_at` and stops at the cap, so the oldest enrollment always wins. The bulk import goes through `enroll_existing` (`backfill.py:88`), which gives all 2,400 enrollments the same `enrolled_at`. Sequences have no `priority` column today (`models/sequence.py:41`).

**Options:**
(a) **Priority lanes.** Each sequence type gets a priority (expiring credits > renewal > win-back). The cap is filled from highest priority first, and anything left over rolls to the next day.
(b) **Separate caps per sequence type.** Each type gets its own share of the 500 (for example 200 / 150 / 150). This is simple to reason about, but the share for urgent types sits unused on quiet days while win-back stays throttled.
(c) **Time-sensitive sends skip the cap.** These are the only emails that never wait, but one busy expiry day can push Ana well past the limit her email provider tolerates.

➡️ (a). Joana gets her warning on the right day, and win-back keeps draining the backlog with whatever room is left.

---

❓ **Q2 - Whose midnight is "day 3"?**

📖 **Story:** Carla lapsed from Studio Bondi and moved to Perth, which is 2 hours behind Sydney (3 hours during Sydney's daylight saving). Her win-back step says "day 3, 9:00 am". The engine counts days in UTC, so on Thursday Carla's "we miss you" email arrives at 6:00 am Perth time, while she is still asleep. It sits under 20 other emails by breakfast, and she never opens it. Meanwhile Bruno's members in Manly get the same step at 8:00 am instead of 9:00 am every summer, and he can't work out why his open rates drop in October.

🔧 **Technical context:** `compute_step_due_at` (`scheduling.py:142`) does `enrolled_at + timedelta(days=step.day_offset)` in UTC, then sets the hour from `step.send_hour` with no timezone. `Member.timezone` exists (`models/member.py:27`) but is null for about 60% of imported members. `Studio.timezone` is always set.

**Options:**
(a) **Member's timezone, falling back to the studio's.** "Day N at 9:00" is counted in calendar days in the member's local time and resolved with `zoneinfo`, so daylight saving is handled.
(b) **Studio's timezone only.** This is simpler and right for most members, but Carla and every member who has moved still get emails at odd hours.
(c) **Fixed 24-hour offsets from enrollment.** This is predictable for engineers, but "day 3 at 9:00" means nothing to Ana when she builds a sequence.

➡️ (a). Carla gets her email at 9:00 am Perth time, and Bruno's 9:00 am stays 9:00 am all year.

---

> **You:** Q1 a, Q2 a

---

## Round 2

---

❓ **Q3 - Can a studio raise its own cap?**

📖 **Story:** Bruno runs a "Summer Challenge" launch and wants all 600 members emailed on Monday morning. The default cap is 500, so 100 members, his most loyal ones because they enrolled last, get the email on Tuesday after the challenge has already started. Bruno asks support to "just turn the cap off for one day". Meanwhile Ana is happy with 500 and would rather never think about it.

**Options:**
(a) **Plan-based cap with a one-day boost.** Each plan has a cap. Owners can request a 24-hour boost up to 2x from settings, and it is logged and limited to once a week.
(b) **Fully editable cap.** Owners type any number they like. This gives them the most freedom, but one mistake can burn the shared sending domain's reputation for every studio.
(c) **No overrides.** Support handles exceptions by hand. This is safe, but it doesn't scale, and Bruno waits a day for a reply.

➡️ (a). Bruno reaches all 600 members on launch day without opening a ticket, and Ana never sees a setting she doesn't need.

---

❓ **Q4 - When is a deferred email too late to send at all?**

📖 **Story:** With priority lanes (Q1), a busy week can still push some emails to the next day. Joana's expiring-credits reminder is meant for Wednesday, but it is deferred to Thursday, then to Friday, and her credits expire at 11:59 pm on Friday. If it finally goes out on Saturday at 9:00 am in Joana's timezone (Q2), it tells her to use credits she no longer has. Joana's next message to Ana won't be a polite one.

🔧 **Technical context:** Deferred steps are re-queued by `roll_over_unsent` (`marketing_sequences.py:601`) with no upper bound. Steps have no `expires_at` or relevance window (`models/sequence_step.py:18`). Credit expiry lives in `Membership.credits_expire_at`.

➡️ Every step gets a **relevance deadline**, and a step that misses it is dropped and logged as `skipped_stale` instead of being sent. For expiring credits, the deadline is 24 hours before `credits_expire_at` in the member's local time. For renewal reminders, it is the renewal date. Win-back has no deadline. Show the count of skipped emails on the owner's dashboard so Ana can see when her cap is too tight.

---

## Shared understanding

- **Cap ordering:** the daily cap is filled by priority lane (expiring credits > renewal > win-back), and leftovers roll to the next day.
- **"Day N" timing:** steps run on calendar days in the member's timezone, falling back to the studio's timezone, with daylight saving handled by `zoneinfo`.
- **Overrides:** each plan has a cap. Owners can trigger a logged, weekly-limited 24-hour boost of up to 2x. There is no free-form editing.
- **Stale sends:** each step type has a relevance deadline. Missed steps are skipped, logged and shown on the dashboard, never sent late.
- **Still open:** what to do for the 60% of imported members with no timezone if they later book a class from a different city. Should their timezone be inferred from booking location?
