- CLI
- verify cart:
    - input: items (maybe with prices), rules, catalog, pricelist, tax_address.
    - output: items with prices, rules, catalog, pricelist, tax_address, change messages.
- rules, catalog, pricelist are versioned (as in git) and are referenced by hash.
- use only netto prices (which make calculations and state easier).
  -> might be a bad idea. We then need a pricelist for every country that will have the
     same 'brutto' prices, but due to different tax rate have different 'netto' prices.
- prices are fixed precision decimals with a currency.
- no licenses. Instead, put owned items into cart (with CONST specifier).
- use json as (cart item) data format.
- article_code is the unique item identifier.

RULES
-----
- availability (for example no shipping to specific countries)
- apply taxes

ITEM
-----
{article_code:".....", price:...}

PRICE
-----
{amount:..., tax:..., taxref:..., annotation:...}

CATALOG
-------
{article_code:"....", meta_data:...}


SAMPLE CLI SESSION
------------------
> ADD TO CATALOG {article_code:"...",...}
> ADD TO PRICELIST DIRECT_DE <article_code>:<price>
