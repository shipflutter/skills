# Skill Store

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│ SkillStore                         Catalog  Premium  Sepay Flow  Support     │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Ship premium AI skills that feel ready to sell.          ┌───────────────┐  │
│  Curated skill packages, checkout-ready flows,             │  Skill Card   │  │
│  and SePay bank transfer confirmation.                     │  Premium      │  │
│                                                           └───────────────┘  │
│  [Browse skills] [View payment flow]                                         │
│                                                                              │
├──────────────────────────────────────────────────────────────────────────────┤
│ Filters: [All] [Agent Ops] [Design] [Payments] [Automation]                  │
│                                                                              │
│ ┌───────────────┐ ┌───────────────┐ ┌───────────────┐ ┌───────────────┐     │
│ │ Skill product │ │ Skill product │ │ Skill product │ │ Skill product │     │
│ │ price + CTA   │ │ price + CTA   │ │ price + CTA   │ │ price + CTA   │     │
│ └───────────────┘ └───────────────┘ └───────────────┘ └───────────────┘     │
│                                                                              │
├──────────────────────────────────────────────────────────────────────────────┤
│ Selected skill detail                                                        │
│ ┌──────────────────────────────┐ ┌───────────────────────────────────────┐  │
│ │ Outcomes / includes          │ │ SePay checkout architecture           │  │
│ │ [Buy premium skill]          │ │ order -> transfer -> webhook -> unlock│  │
│ └──────────────────────────────┘ └───────────────────────────────────────┘  │
│                                                                              │
├──────────────────────────────────────────────────────────────────────────────┤
│ Footer CTA: Build the premium shelf for your best skills. [Open checkout]    │
└──────────────────────────────────────────────────────────────────────────────┘

Checkout modal
┌────────────────────────────────────────────┐
│ Complete purchase                           │
│ Email: [ buyer@example.com              ]   │
│ Skill: Premium Skill Name                   │
│ Amount: 499,000 VND                         │
│ Order code: SKILL-20260611-AB12             │
│ Transfer content: SKILL-20260611-AB12       │
│ Bank account: configured by backend         │
│ [I have paid - mock confirmation]           │
└────────────────────────────────────────────┘

Store page
┌──────────────────────────────────────────────────────────────────────────────┐
│ SkillStore                         Store  Catalog  SePay Flow  Support       │
├──────────────────────────────────────────────────────────────────────────────┤
│ Choose the skill package that pays for itself.             ┌──────────────┐  │
│ Compare outcomes, included assets, and pricing.            │ 5 products   │  │
│                                                            └──────────────┘  │
├───────────────────────┬──────────────────────────────────────────────────────┤
│ Search products        │ Products                         [Sort select]       │
│ [ search input      ]  │ ┌────────────────────┐ ┌────────────────────┐      │
│                        │ │ Product card        │ │ Product card        │      │
│ Category               │ │ price, outcomes     │ │ price, outcomes     │      │
│ [All products]         │ │ includes, tags      │ │ includes, tags      │      │
│ [Agent Ops]            │ │ [Buy now][Preview]  │ │ [Buy now][Preview]  │      │
│ [Design]               │ └────────────────────┘ └────────────────────┘      │
│ [Payments]             │ ┌────────────────────┐ ┌────────────────────┐      │
│ [Automation]           │ │ Product card        │ │ Product card        │      │
│                        │ │ [Buy now][Preview]  │ │ [Buy now][Preview]  │      │
│ Buyer-safe checkout    │ └────────────────────┘ └────────────────────┘      │
└───────────────────────┴──────────────────────────────────────────────────────┘
```

## Components

- Top navigation.
- Hero with primary and secondary CTA.
- Category filter toolbar.
- Skill catalog bento grid.
- Selected skill detail panel.
- SePay flow timeline.
- Checkout modal.
- Dedicated store page with search, filters, sort, product cards, and buy/preview CTAs.
- Footer CTA.

## States

- `catalog:all`
- `catalog:filtered`
- `skill:selected`
- `checkout:pending`
- `checkout:paid`
- `checkout:expired` future backend state
- `payment:needs_review` future backend state
- `store:filtered`
- `store:searched`
- `store:sorted`

## Events

- `click.filterCategory`
- `click.selectSkill`
- `click.openCheckout`
- `click.buyProduct`
- `click.previewProduct`
- `input.searchProducts`
- `change.sortProducts`
- `submit.checkoutEmail`
- `click.mockPaymentPaid`
- `click.closeModal`
- `poll.orderStatus` future backend event
