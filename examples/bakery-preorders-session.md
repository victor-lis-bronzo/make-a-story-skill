# Example session: bakery pre-orders

This is what `/grill-with-stories` produces. The plan being grilled:

```
/grill-with-stories add per-day baking capacity and a pickup-slot picker to the pre-order app
```

The product is an invented app that lets small bakeries take pre-orders for pickup. All bakeries, people, code and numbers are fictional. The output follows the language of the conversation; this session ran in English.

---

## Round 1

> **Cast:** Maya owns *Crumb & Co* (Lisbon, two shops, ~400 pre-orders a week). Theo owns *Rye House* (Porto, one shop, bakes only on weekends). Customers: Lena (orders every Saturday), Sam (orders for his office on Fridays).

❓ **Q1 - What is "capacity" counted in?**

📖 **Story:** Maya tells the app she can bake 120 loaves on Saturday. On Friday afternoon there are 40 orders. Most are a single loaf, but Sam's office order is 30 croissants and 6 baguettes. The app shows "40 / 120, plenty of room", so it keeps accepting orders. At 05:00 on Saturday the bakers find they need dough for 170 items, and Maya spends her morning calling customers to cancel.

🔧 **Technical context:** `daily_capacity` (`bakeries` table) is a single integer. `place_order()` (`orders/service.py:88`) compares it with `COUNT(*)` from `orders` for that pickup date. Items live in `order_items.quantity`, which is never summed. Products have no notion of oven time or batch size.

**Options:**
(a) **Items, per product category.** The bakery sets a cap per category (bread, viennoiserie, cakes). An order reserves `quantity` in each category it touches. This matches how Maya actually plans her ovens.
(b) A single cap on total items. Easier to set up, but 120 croissants and 120 sourdoughs are very different mornings.
(c) Keep counting orders and add a per-order item limit.

➡️ (a). Maya already thinks "40 loaves, 80 pastries"; the app should ask her in the same units. Default every bakery to a single "everything" category so Theo does not have to configure anything on day one.

---

❓ **Q2 - What happens when capacity is full?**

📖 **Story:** It's Friday, 16:20. Crumb & Co has 118 of 120 bread slots booked for Saturday. Lena tries to order 4 sourdoughs for her daughter's birthday brunch. Whatever the app does next decides whether she gets 2 loaves, 0 loaves, a different day, or a phone call from Maya at 07:30 on Saturday.

🔧 **Technical context:** today the capacity check and the insert run in separate transactions (`orders/service.py:88-104`), so two customers checking out at the same moment can both pass. There is no "partially available" state in the checkout UI.

**Options:**
(a) **Reject the whole order, suggest another day.** "Only 2 sourdoughs left for Saturday. Sunday has room." Lock the capacity row so two checkouts cannot both take the last slots.
(b) Accept the 2 that fit and drop the rest, with a notice.
(c) Accept everything and let the bakery overbook by up to 5%.

➡️ (a). Lena chooses for herself, at checkout, instead of finding out from Maya on Saturday morning. Partial orders (b) quietly break the reason she ordered: a birthday brunch for 8.

---

> **You:** Q1 a, Q2 a

## Round 2

❓ **Q3 - Can a bakery raise capacity after it is full?**

📖 **Story:** On Thursday night Theo sees Saturday is sold out by 20:00, earlier than ever. He has a spare baker coming in, so he wants to open 30 more loaves. Lena, who was told "Saturday is full" an hour ago, would happily order now, but nothing tells her that space opened up.

**Options:**
(a) **Yes, any time before the order cutoff, and notify customers who were turned away for that day.** They get one message: "Rye House just opened more bread for Saturday."
(b) Yes, but silently: new space is just available to whoever looks next.
(c) No; capacity is fixed once the first order arrives.

➡️ (a). The bakery gets the sales it can bake, and Lena hears about it instead of having to keep checking. The notification only goes to people who were rejected for that day, so it never feels like marketing.

---

❓ **Q4 - How fine-grained are pickup slots?**

📖 **Story:** Crumb & Co opens at 07:00. Last Saturday, 60 of the 118 customers turned up between 08:30 and 09:00, the queue reached the corner, and Sam waited 25 minutes for an order that was already bagged. Maya would like people to spread out over the morning, but she does not want to run a booking system for bread.

➡️ Thirty-minute slots, with a soft cap per slot that the bakery can leave empty (no cap). The picker shows how busy each slot is ("quiet", "busy") instead of a hard "full", so nobody is refused a loaf because of a queue. Revisit hard slot caps only if a bakery asks for them after a month of data.

---

## Shared understanding

| # | Decision |
|---|---|
| Q1 | Capacity is counted in items, per product category. Every bakery starts with one "everything" category. |
| Q2 | When an order does not fit, reject it as a whole and suggest the next day with room. The capacity check locks the row. |
| Q3 | Bakeries can raise capacity before the cutoff. Customers turned away for that day are notified once. |
| Q4 | 30-minute pickup slots with an optional soft cap. The picker shows how busy a slot is and never refuses an order. |

Still open: whether cakes (made to order) need their own lead time on top of capacity. That gets its own grill once the capacity work ships.
