- CLI
- verify cart:
    - input: items (maybe with prices), catalog, pricelist, tax_address.
    - output: items with prices, catalog, pricelist, tax_address, change messages.
- rules (what is update, addon, etc.) are bound to catalog
- price lists can be handled either as brutto or netto (decided when used)
- prices are fixed precision decimals with a currency.
- priceobject in pricelist: just amount and currency (can be brutto or netto).
- priceobject in item: amount is always netto.
- no licenses. Instead, put owned items into cart (with CONST specifier).
- use json as generic data format.
- article_code is the unique item identifier.

- country and tax information is global.

RULES
-----
bundles, upgrades, addons, coupons, ...

ITEM
-----
{article_code:".....", price:...}

PRICE
-----
{amount:..., tax:..., taxref:..., annotation:..., currency:...}

CATALOG_ITEM
------------
{article_code:"....", meta_data:...}

TAX_ADDRESS
-----------
a tax address is used to find out what kind of tax (if any) will be applied.
For the simplified model, we ignore different taxes inside one country.
buisiness_type: "b2c", "b2b"
{tax_region:"de" buisiness_type:"b2c"}

COUNTRY
-------
allowed regions: "eu", "non-eu"
region: used for shipping
{country_code:"de", region:"eu", tax_region:"de", allow_shipment:true}


SAMPLE CLI SESSION
------------------
> ADD TO COUNTRIES {country_code:"de", region:"eu", tax_region:"de", allow_shipment:true};
> ADD TO COUNTRIES {country_code:"fr", region:"eu", tax_region:"fr", allow_shipment:true};
> ADD TO COUNTRIES {country_code:"ru", region:"non-eu", tax_region:"non-eu", allow_shipment:false};
> # create all tax related stuff here
> # germany
> ADD TO TAXES {ref:1, tax_region:"de", physical:false, buisiness_type:"b2c", rate:0.19, meta_data:{}};
> ADD TO TAXES {ref:2, tax_region:"de", physical:true, buisiness_type:"b2c", rate:0.19, meta_data:{}};
> ADD TO TAXES {ref:3, tax_region:"de", physical:false, buisiness_type:"b2b", rate:0.19, meta_data:{}};
> ADD TO TAXES {ref:4, tax_region:"de", physical:true, buisiness_type:"b2b", rate:0.19, meta_data:{}};
> # france as an example for eu country
> ADD TO TAXES {ref:5, tax_region:"fr", physical:"false", buisiness_type:"b2c", rate:0.2, meta_data:{}};
> ADD TO TAXES {ref:6, tax_region:"fr", physical:"true", buisiness_type:"b2c", rate:0.2, meta_data:{}};
> # non eu
> ADD TO TAXES {ref:7, tax_region:"non-eu", physical:"false", buisiness_type:"b2c", rate:0.0, meta_data:{}};
> ADD TO TAXES {ref:8, tax_region:"non-eu", physical:"true", buisiness_type:"b2c", rate:0.0, meta_data:{}};
> ADD TO TAXES {ref:9, tax_region:"non-eu", physical:"false", buisiness_type:"b2b", rate:0.0, meta_data:{}};
> ADD TO TAXES {ref:10, tax_region:"non-eu", physical:"true", buisiness_type:"b2b", rate:0.0, meta_data:{}};
> CREATE CATALOG ARTICLES;
> ADD TO CATALOG ARTICLES {article_code:"abc", physical:"false"};
> ADD TO CATALOG ARTICLES {article_code:"efg", physical:"true"};
> # we bind the pricelist to a specific catalog
> CREATE PRICELIST DIRECT_EUR FOR ARTICLES;
> ADD TO PRICELIST DIRECT_EUR {article_code:"abc", price:{amount:10.0000, currency:"EUR"}};
> ADD TO PRICELIST DIRECT_EUR {article_code:"efg", price:{amount:20.0000, currency:"EUR"}};
> # think about pricelist verification
> # * missing product
> # * double entry
>
>
> CREATE PRICELIST DIRECT_USD FOR ARTICLES;
> ADD TO PRICELIST DIRECT_USD {article_code:"abc", price:{amount:10.0000, currency:"USD"}};
> ADD TO PRICELIST DIRECT_USD {article_code:"efg", price:{amount:20.0000, currency:"USD"}};
> VERIFY [{article_code:"abc"}] FOR {tax_region:"de", buisiness_type:"b2c"} WITH BRUTTO PRICELIST DIRECT_EUR;
[{article_code:"abc", price:{amount:8.4034, tax:1.5966, taxref:1, currency:"EUR", quantity:1}], []
> VERIFY [{article_code:"efg"}] FOR {tax_region:"ru", buisiness_type:"b2c"} WITH NETTO PRICELIST DIRECT_USD;
[], ["Can't deliver physical items to 'ru'"]
> VERIFY [{article_code:"abc", price:{amount:8.4034, tax:1.5966, taxref:1, currency:"EUR"}] FOR {tax_region:"de", buisiness_type:"b2c"} WITH BRUTTO PRICELIST DIRECT_EUR;
[{article_code:"abc", price:{amount:8.4034, tax:1.5966, taxref:1, currency:"EUR"}], []
> VERIFY [{article_code:"abc", price:{amount:8.4034, tax:1.5966, taxref:1, currency:"EUR"}] FOR {tax_region:"non-eu", buisiness_type:"b2c"} WITH NETTO PRICELIST DIRECT_USD;
[{article_code:"abc", price:{amount:10.0000, tax:0.0000, taxref:7, currency:"USD"}], ["Changed currency from EUR to USD", "Changed tax"]
