#!/usr/bin/env nimdebug
#

import
  pm_decimals

type 
  PriceType {.pure.} = enum
    net, gross

  BuisinessType = enum
    btB2C, btB2B

  Currency = enum
    curEur="EUR", curUsd="USD"

  Money = tuple[amount: Decimal, currency: Currency]

  Country = object
    country_code, region, tax_region: string
    allow_shipment: bool

  GoodsType {.pure.} = enum
    physical, software, book

  Tax = object
    id: int
    tax_region: string
    goods_type: GoodsType
    rate: Decimal

  Price = tuple
    raw: Money
    taxRate: Decimal
    priceType: PriceType

  Article = object
    name: string
    goodsType: GoodsType

  LineItem = object
    b2bTax: Tax
    b2cTax: Tax
    price: Price
    buisinessType: BuisinessType
    article: Article
    amount: int

  LineItemRef = ref LineItem

# money
proc newMoney(value: string, currency:Currency): Money =
  result = (newDecimal(value), currency)

proc `$`(money: Money): string =
  result = $money.amount & ' ' & $money.currency

proc `+`(a, b:Money): Money =
  assert(a.currency == b.currency)
  result = (a.amount + b.amount, a.currency)

proc `-`(a, b:Money): Money =
  assert(a.currency == b.currency)
  result = (a.amount - b.amount, a.currency)

# prices
proc value*(price: Price): Decimal =
  result = price.raw.amount

proc gross*(price: Price): Money =
  case price.priceType:
    of PriceType.gross:
      result = price.raw
    of PriceType.net:
      let prec = price.value.prec
      let x = price.value
      let rate = price.tax_rate
      let new_value = (x + x * rate).toPrecision(x.prec)
      result = (new_value, price.raw.currency)

proc net*(price: Price): Money =
  case price.priceType:
    of PriceType.gross:
      let prec = price.value.prec
      let x = price.value
      let rate = price.tax_rate
      let new_value = (x - (x * rate * (inv (newDecimal("1.0")+rate)))).toPrecision(x.prec)
      result = (new_value, price.raw.currency)
    of PriceType.net:
      result = price.raw

proc tax*(price: Price): Money =
  result = price.gross - price.net

when isMainModule:
  echo "running assetions"
  assert($newMoney("1.00", curEur) == "1.00 EUR")
  assert((newMoney("1.00", curEur) + newMoney("1.00", curEur)) == newMoney("2.00", curEur))
  assert((newMoney("2.00", curEur) - newMoney("1.05", curEur)) == newMoney("0.95", curEur))
  let price1 = (newMoney("100.00", curEur), newDecimal("0.19"), PriceType.net)
  let price2 = (newMoney("119.00", curEur), newDecimal("0.19"), PriceType.gross)
  assert(price1.gross == newMoney("119.00", curEur))
  assert(price2.gross == newMoney("119.00", curEur))
  assert(price1.net == newMoney("100.00", curEur))
  assert(price2.net == newMoney("100.00", curEur))
  assert(price1.tax == newMoney("19.00", curEur))
  assert(price2.tax == newMoney("19.00", curEur))
