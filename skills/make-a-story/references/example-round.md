# Example question

Imitate the shape and the density of this question, not its domain.

> Cast: Ana owns *Studio Bondi* (Sydney, 3,000 members). Bruno owns *CrossBox Manly*. Members: Joana, Carla.

---

❓ **Q7 - What does "day N" mean?**

📖 **Story:** Bruno creates "renewal coming up: exactly 3 days left", with an email at 09:00. Carla renews on **Friday at 22:30**. He expects her to get the email on **Tuesday** morning, three calendar days before. Today the system counts 72 elapsed hours: she only "reaches day 3" on Tuesday at 22:30, which is inside quiet hours, so the email goes out on **Wednesday**, two days before. In the week the clocks change, it slips by one more hour.

🔧 **Technical context:** `crossing_days` (Python), `_crossing_sql` (`make_interval`), `_countdown_existing` and `_existing_no_booking` all compute `± N×24h` in UTC. The intro-window fallback reads `start_date` as UTC midnight. The spec (line 41) says "calendar days in the studio's timezone".

**Options:**
(a) **Crossing at local midnight.** A member is on day N when `local_date(today) - local_date(event) = N`. Carla enters day 3 on Tuesday at 00:00 and the email goes out Tuesday at 09:00.
(b) Keep elapsed 24h periods and change the spec. Not recommended: both reviewers flagged it as must-fix.

➡️ (a), applied in Python, in SQL, in the `existing` scanners and in the intro-window fallback, with tests for a late-night deadline and for a DST week in `Australia/Sydney`.

---

Why it works:

- The story uses a recurring character (Bruno, Carla), a weekday and a time, and shows the exact moment the behaviour diverges from what the owner expects.
- No identifier appears in the story. They are all in 🔧.
- 🔧 explains *why* the story happens (24h arithmetic in UTC) and cites the spec line that settles the expectation.
- The recommendation says where the change lands and how it will be proven.
