- CLI
- verify cart:
    - input: items (maybe with prices), rules, catalog, pricelist, tax_address.
    - output: items with prices, rules, catalog, pricelist, tax_address, change messages.
- rules, catalog, pricelist are versioned (as in git) and are referenced by hash.
- use only netto prices (which make calculations and state easier).
- prices are fixed precision decimals.
- no licenses. Instead, put owned items into cart (with CONST specifier).
- use json as (cart item) data format.

RULES
-----
- availability (for example no shipping to specific countries)
- apply taxes

ITEM
-----
{article_code='.....', price=...},

PRICE
-----
{amount=..., tax=..., taxref=..., annotation=...}
