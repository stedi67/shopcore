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

CATALOG_ITEM
------------
{article_code:"....", meta_data:...}

TAX_ADDRESS
-----------
a tax address is used to find out what kind of tax (if any) will be applied.
For the simplified model, we ignore different taxes inside one country.
buisiness_type: "b2c", "b2b"
{country_code:"de" buisiness_type:"b2c"}

COUNTRY
-------
allowed regions: "eu", "non-eu"
{country_code:"de", region:"eu"}


SAMPLE CLI SESSION
------------------
> # create all tax related stuff here
> ADD TO TAXES {tax_region:"de", physical:"false", buisiness_type:"b2c", rate:0.19, meta_data:{}};
> ADD TO TAXES {tax_region:"de", physical:"true", buisiness_type:"b2c", rate:0.19, meta_data:{}};
> ADD TO ARTICLES {article_code:"...", physical:"false"};
> CREATE PRICELIST DIRECT_DE;
> ADD TO PRICELIST DIRECT_DE {<article_code>:<catalog_price>};
