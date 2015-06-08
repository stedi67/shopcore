#!/usr/bin/env nimdebug
#

import
  pm_decimals

type 
  BuisinessType = enum
    b2c, b2b

  PriceType = enum
    net, gross

  Currency = enum
    EUR="EUR", USD="USD"

  Money = tuple[amount: Decimal, currency: Currency]

  Country = object
    country_code, region, tax_region: string
    allow_shipment: bool

  GoodsType = enum
    physical, software, book

  Tax = object
    id: int
    tax_region: string
    goods_type: GoodsType
    rate: Decimal

  Price = object
    net_price: Money
    tax: Money
    tax_line: Tax

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

when isMainModule:
  echo "running assetions"
  assert($newMoney("1.00", EUR) == "1.00 EUR")
  assert((newMoney("1.00", EUR) + newMoney("1.00", EUR)) == newMoney("2.00", EUR))
  assert((newMoney("2.00", EUR) - newMoney("1.05", EUR)) == newMoney("0.95", EUR))
