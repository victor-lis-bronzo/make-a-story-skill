Example standalone output. Imitate the shape and density, not the domain. Everything is invented.

Input:

```
/make-a-story #142
```

> **#142 Allow partial orders when a pickup day sells out**
>
> When a customer's order doesn't fit the remaining capacity for a pickup day, checkout rejects the whole order. Let them take what fits and move the rest to another day.
>
> - [ ] Checkout shows how many of each item still fit on the chosen day.
> - [ ] The customer can split the order: what fits stays on the chosen day, the rest moves to the next day with room.
> - [ ] The bakery dashboard shows split orders as one customer with two pickups.

---

# Allow partial orders when a pickup day sells out - the story

> **Cast:** Maya owns *Crumb & Co* (Lisbon, two shops, ~400 pre-orders a week). Theo owns *Rye House* (Porto, one shop, bakes only on weekends). Customers: Lena (orders every Saturday), Sam (orders for his office on Fridays).

📖 **Today:** It's Friday, 16:20, and Crumb & Co has 118 of its 120 bread slots booked for Saturday. Lena wants 4 sourdoughs and 6 croissants for her daughter's birthday brunch, and checkout answers "Saturday is full" without saying that 2 sourdoughs and all the croissants would still fit. She closes the app and buys supermarket bread instead. Twenty minutes later Sam tries to add 2 baguettes to his office order and gets the same wall, so he calls the shop, and Maya squeezes his loaves in by hand on a sticky note. On Saturday morning Maya counts 7 customers who were turned away on Friday afternoon, roughly €90 of bread that her ovens had room for. Theo sees the same pattern in Porto every Thursday night, when Saturday fills up and the people who wanted "just a bit more" disappear.

📖 **After #142:** On Friday at 16:20 Lena puts the same order in her basket, and checkout tells her "2 of 4 sourdoughs and all 6 croissants fit on Saturday". She taps "split the rest", and the remaining 2 sourdoughs move to Sunday, the next day with room, with their own pickup time. She pays once and gets one confirmation listing both pickups. When Maya opens the dashboard on Saturday at 06:30, Lena appears as one customer with two pickups, Saturday and Sunday, instead of two strangers with the same name. Sam's 2 extra baguettes land on Saturday's list without a sticky note, and Maya stops counting the customers she lost on Friday afternoons.

🔧 **Technical context:** `place_order()` (`orders/service.py:88`) checks `daily_capacity` for one pickup date and rejects the whole order on failure; there is no way to return "partially fits". An order has a single `pickup_date` column, so a split order would need either two orders linked by a shared id or pickups moved onto `order_items`. The dashboard groups by `order_id`, not by customer.

❓ **Open questions**
1. If Sunday is full too, does the rest move to Monday, or does Lena have to pick a day herself?
2. Does a split order pay once, or is the Sunday part charged when it's picked up?
3. Theo bakes only on weekends: if Saturday sells out, is "the next day with room" next Saturday?
4. If Lena cancels the Saturday pickup, does the Sunday one stay?

Want to grill these with `/grill-with-stories`? It starts from these questions with the same cast.
