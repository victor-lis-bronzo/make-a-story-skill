# Example question

Imitate the shape and the density of this question, not its domain. The product, people and code below are invented.

> Cast: Maya owns *Crumb & Co* (Lisbon, two shops, ~400 pre-orders a week). Theo owns *Rye House* (Porto). Customers: Lena, Sam.

---

❓ **Q3 - What does "order by the day before" mean?**

📖 **Story:** Theo sets the rule "order by 18:00 the day before" so his bakers know Saturday's numbers on Friday evening. Sam orders a box of pastéis on **Friday at 17:50**, Lisbon time. The app rejects it: "too late for Saturday". Ten minutes later his neighbour Lena orders the same box and it goes through. Sam calls Rye House, Theo checks the dashboard and sees both orders listed at 17:50 and 18:00, and has no idea why one failed. In the last week of March, when the clocks change, every order between 17:00 and 18:00 is rejected.

🔧 **Technical context:** `cutoff_for(pickup_date)` (`orders/cutoff.py:41`) returns `pickup_date - 1 day + 18:00` as a naive datetime and compares it with `datetime.utcnow()`. The bakery's timezone exists in `bakeries.timezone` but is never read here. The dashboard formats times in the bakery's timezone, so it shows a different clock from the one the check uses.

**Options:**
(a) **Cutoff in the bakery's local time.** Build the cutoff as 18:00 on the previous calendar day in `bakeries.timezone`, convert to UTC, and compare. Sam's 17:50 order goes through. Add tests for a DST week in `Europe/Lisbon`.
(b) Keep UTC and show "order by 17:00 UTC" in the app. Simpler, but every bakery owner has to do the conversion in their head, twice a year differently.

➡️ (a). Theo's rule means what he typed, and the dashboard and the check finally read the same clock.

---

Why it works:

- The story uses recurring characters (Theo, Sam, Lena), a weekday and a time, and shows the exact moment the behaviour diverges from what the owner expects.
- No identifier appears in the story. They are all in 🔧.
- 🔧 explains *why* the story happens (a naive datetime compared with UTC) and why the owner cannot see it (the dashboard uses a different clock).
- The recommendation says what changes and how it will be proven, and ties back to a person.
